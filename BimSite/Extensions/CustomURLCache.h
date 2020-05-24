//
//  CustomURLCache.h
//  LiLottery
//
//  Created by 杨建祥 on 16/6/5.
//  Copyright © 2016年 tospery. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CustomURLCache : NSURLCache

@property(nonatomic, assign) NSInteger cacheTime;
@property(nonatomic, retain) NSString *diskPath;
@property(nonatomic, retain) NSMutableDictionary *responseDictionary;

- (id)initWithMemoryCapacity:(NSUInteger)memoryCapacity diskCapacity:(NSUInteger)diskCapacity diskPath:(NSString *)path cacheTime:(NSInteger)cacheTime;

@end
