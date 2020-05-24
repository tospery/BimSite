//
//  BaseModel.m
//  BimSite
//
//  Created by  方世勇 on 2017/8/27.
//  Copyright © 2017年 成都慧视康科技有限公司. All rights reserved.
//

#import "BaseModel.h"
#import <objc/runtime.h>

#define SuppressPerformSelectorLeakWarning(Stuff) \
do { \
    _Pragma("clang diagnostic push") \
    _Pragma("clang diagnostic ignored \"-Warc-performSelector-leaks\"") \
    Stuff; \
    _Pragma("clang diagnostic pop") \
} while (0)

static NSString *idPropertyName = @"id";
static NSString *idPropertyNameOnObject = @"objectId";

static NSMutableDictionary *propertyListByClass;
static NSMutableDictionary *propertyClassByClassAndPropertyName;


static const char *property_getTypeName(objc_property_t property) {
    const char *attributes = property_getAttributes(property);
    char buffer[1 + strlen(attributes)];
    strcpy(buffer, attributes);
    char *state = buffer, *attribute;
    while ((attribute = strsep(&state, ",")) != NULL) {
        if (attribute[0] == 'T') {
            size_t len = strlen(attribute);
            if (len > 2) {
                attribute[len - 1] = '\0';
                return (const char *)[[NSData dataWithBytes:(attribute + 3) length:len - 2] bytes];
            }else{
                return "@";
            }
        }
    }
    return "@";
}

@implementation BaseModel
#pragma mark -


+ (BOOL)isPropertyReadOnly:(Class)klass propertyName:(NSString*)propertyName{
    const char * type = property_getAttributes(class_getProperty(klass, [propertyName UTF8String]));
    NSString * typeString = [NSString stringWithUTF8String:type];
    NSArray * attributes = [typeString componentsSeparatedByString:@","];
    NSString * typeAttribute = [attributes objectAtIndex:1];
    
    return [typeAttribute rangeOfString:@"R"].length > 0;
}

+ (NSArray *)propertyNames:(Class)klass {
    if (klass == [self class]) {
        return [NSArray array];
    }
    if (!propertyListByClass) {
        propertyListByClass = [[NSMutableDictionary alloc] init];
    }
    
    NSString *className = NSStringFromClass(klass);
    NSArray *value = [propertyListByClass objectForKey:className];
    
    if (value) {
        return value;
    }
    
    NSMutableArray *propertyNamesArray = [NSMutableArray array];
    unsigned int propertyCount = 0;
    objc_property_t *properties = class_copyPropertyList(klass, &propertyCount);
    
    for (unsigned int i = 0; i < propertyCount; ++i) {
        objc_property_t property = properties[i];
        const char * name = property_getName(property);
        
        [propertyNamesArray addObject:[NSString stringWithUTF8String:name]];
    }
    free(properties);
    
    [propertyListByClass setObject:propertyNamesArray forKey:className];
    NSArray* arr = [[self class] propertyNames:class_getSuperclass(klass)];
    [propertyNamesArray addObjectsFromArray:arr];
    return propertyNamesArray;
}

- (void)encodeWithCoder:(NSCoder*)encoder {
    [encoder encodeObject:self.objectId forKey:idPropertyNameOnObject];
    for (NSString *key in [[self class] propertyNames:[self class]]) {
        [encoder encodeObject:[self valueForKey:key] forKey:key];
    }
}

- (id)initWithCoder:(NSCoder *)decoder {
    if ((self = [super init])) {
        [self setValue:[decoder decodeObjectForKey:idPropertyNameOnObject] forKey:idPropertyNameOnObject];
        
        for (NSString *key in [[self class] propertyNames:[self class]]) {
            if ([[self class] isPropertyReadOnly:[self class] propertyName:key]) {
                continue;
            }
            id value = [decoder decodeObjectForKey:key];
            if (value != [NSNull null] && value != nil) {
                [self setValue:value forKey:key];
            }
        }
    }
    return self;
}

- (NSString *)description {
    NSDictionary *dic = [[self class] getObjectData:self];
    return [NSString stringWithFormat:@"#<%@: id = %@ %@>", [self class], self.objectId, [dic description]];
}

- (BOOL)isEqual:(id)object {
    if (object == nil || ![object isKindOfClass:[BaseModel class]]) return NO;
    
    BaseModel *model = (BaseModel *)object;
    
    return [self.objectId isEqualToString:model.objectId];
}

+ (id) model
{
    return [[[self class] alloc]init];
}

+ (instancetype) modelWithDic:(NSDictionary*)dic {
    BaseModel *model = [[self alloc] initWithDic:dic];
    return model;
}

- (instancetype) initWithDic:(NSDictionary*)dic {
    self = [super init];
    if (self) {
        unsigned int outCount, i;
        objc_property_t *properties = class_copyPropertyList([self class], &outCount);
        for (i = 0; i < outCount; i++) {
            objc_property_t property = properties[i];
            NSString *propertyName = [NSString stringWithUTF8String:property_getName(property)];
            id propertyValue = dic[propertyName];
            //            NSLog(@"%@--%@", propertyName, propertyValue);
            if ([propertyName isEqualToString:@"descrip"] && dic[@"description"]) {
                [self setValue:dic[@"description"] forKey:@"descrip"];
            }
            else if (propertyValue) {
                [self setValue:propertyValue forKey:propertyName];
            }
        }
        free(properties);
    }
    return  self;
}


+ (instancetype)modelSmartWithDic:(NSDictionary *)dic
{
    BaseModel *model = [[self alloc] initSmartWithDic:dic];
    return model;
}

- (instancetype)initSmartWithDic:(NSDictionary *)dic
{
    self = [super init];
    if (self) {
        unsigned int outCount, i;
        objc_property_t *properties = class_copyPropertyList([self class], &outCount);
        for (i = 0; i < outCount; i++) {
            objc_property_t property = properties[i];
            NSString *propertyName = [NSString stringWithUTF8String:property_getName(property)];
            NSString *propertyKey = propertyName;
            NSRange dashRange = [propertyKey rangeOfString:@"_" options:NSBackwardsSearch];
            if (dashRange.location != NSNotFound) {
                if (propertyKey.length > dashRange.location) {
                    propertyKey = [propertyKey substringFromIndex:dashRange.location+1];
                }
            }
            id propertyValue = dic[propertyKey];
            NSLog(@"%@--%@", propertyName, propertyValue);
            if ([propertyName isEqualToString:@"descrip"] && dic[@"description"]) {
                [self setValue:dic[@"description"] forKey:@"descrip"];
            }
            else if (propertyValue) {
                
                // handle dictionary
                if ([propertyValue isKindOfClass:[NSDictionary class]]) {
                    Class klass = [[self class] propertyClassForPropertyName:propertyName ofClass:[self class]];
                    if ([klass isSubclassOfClass:[BaseModel class]]) {
                        propertyValue = [[klass alloc]initSmartWithDic:propertyValue];
                    }
                }
                // handle array
                else if ([propertyValue isKindOfClass:[NSArray class]]) {
                    SEL sel = NSSelectorFromString([NSString stringWithFormat:@"%@_instanceClass", propertyName]);
                    if (sel&&[[self class] respondsToSelector:sel]) {
                        
                        Class arrayItemType;
                        SuppressPerformSelectorLeakWarning(
                                                           arrayItemType = [[self class] performSelector:sel withObject:self]
                                                           );
                        NSMutableArray *childObjects = [NSMutableArray arrayWithCapacity:[(NSArray*)propertyValue count]];
                        for (id child in propertyValue) {
                            if ([[child class] isSubclassOfClass:[NSDictionary class]]) {
                                
                                BaseModel *childDTO = [[arrayItemType alloc]initSmartWithDic:child];
                                [childObjects addObject:childDTO];
                            } else {
                                [childObjects addObject:child];
                            }
                        }
                        
                        propertyValue = childObjects;
                    }
                }
                
                [self setValue:propertyValue forKey:propertyName];
            }
        }
        free(properties);
    }
    return  self;
}

#pragma mark - Help

+ (Class)propertyClassForPropertyName:(NSString *)propertyName ofClass:(Class)klass {
    if (!propertyClassByClassAndPropertyName) {
        propertyClassByClassAndPropertyName = [[NSMutableDictionary alloc] init];
    }
    
    NSString *key = [NSString stringWithFormat:@"%@:%@", NSStringFromClass(klass), propertyName];
    NSString *value = [propertyClassByClassAndPropertyName objectForKey:key];
    
    if (value) {
        return NSClassFromString(value);
    }
    
    unsigned int propertyCount = 0;
    objc_property_t *properties = class_copyPropertyList(klass, &propertyCount);
    
    const char * cPropertyName = [propertyName UTF8String];
    
    for (unsigned int i = 0; i < propertyCount; ++i) {
        objc_property_t property = properties[i];
        const char * name = property_getName(property);
        if (strcmp(cPropertyName, name) == 0) {
            free(properties);
            NSString *className = [NSString stringWithUTF8String:property_getTypeName(property)];
            [propertyClassByClassAndPropertyName setObject:className forKey:key];
            //we found the property - we need to free
            return NSClassFromString(className);
        }
    }
    free(properties);
    //this will support traversing the inheritance chain
    return [self propertyClassForPropertyName:propertyName ofClass:class_getSuperclass(klass)];
}

+ (NSDictionary*)getObjectData:(id)obj
{
    NSMutableDictionary *dic = [NSMutableDictionary dictionary];
    unsigned int propsCount;
    objc_property_t *props = class_copyPropertyList([obj class], &propsCount);
    
    for(int i = 0;i < propsCount; i++)
        
    {
        objc_property_t prop = props[i];
        
        NSString *propName = [NSString stringWithUTF8String:property_getName(prop)];
        
        id value = [obj valueForKey:propName];
        
        if(value == nil)
            
        {
            value = [NSNull null];
            
        }
        else
        {
            value = [self getObjectInternal:value];
            
        }
        
        [dic setObject:value forKey:propName];
        
    }
    
    return dic;
    
}

+ (void)print:(id)obj
{
    NSLog(@"%@",[self getObjectData:obj]);
    
}

+ (NSData*)getJSON:(id)obj options:(NSJSONWritingOptions)options error:(NSError**)error

{
    return [NSJSONSerialization dataWithJSONObject:[self getObjectData:obj] options:options error:error];
    
}

+ (id)getObjectInternal:(id)obj
{
    if([obj isKindOfClass:[NSString class]]
       ||[obj isKindOfClass:[NSNumber class]]
       ||[obj isKindOfClass:[NSNull class]])
        
    {
        return obj;
    }
    if([obj isKindOfClass:[NSArray class]])
    {
        NSArray *objarr = obj;
        NSMutableArray *arr = [NSMutableArray arrayWithCapacity:objarr.count];
        
        for(int i = 0;i < objarr.count; i++)
            
        {
            [arr setObject:[self getObjectInternal:[objarr objectAtIndex:i]] atIndexedSubscript:i];
            
        }
        return arr;
        
    }
    
    if([obj isKindOfClass:[NSDictionary class]])
        
    {
        
        NSDictionary *objdic = obj;
        NSMutableDictionary *dic = [NSMutableDictionary dictionaryWithCapacity:[objdic count]];
        
        for(NSString*key in objdic.allKeys)
        {
            [dic setObject:[self getObjectInternal:[objdic objectForKey:key]] forKey:key];
        }
        
        return dic;
        
    }
    
    return [self getObjectData:obj];
    
}
@end
