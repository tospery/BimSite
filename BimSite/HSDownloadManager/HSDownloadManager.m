//
//  HSDownloadManager.m
//  HSDownloadManagerExample
//
//  Created by hans on 15/8/4.
//  Copyright © 2015年 hans. All rights reserved.
//

// 缓存主目录
#define HSCachesDirectory [[NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) lastObject] stringByAppendingPathComponent:@"BimSiteCache"]

// 保存文件名
//#define HSFileName(url) url.md5String

// 文件的存放路径（caches）
#define HSFileFullpath(fileName) [HSCachesDirectory stringByAppendingPathComponent:fileName]

// 文件的已下载长度
#define HSDownloadLength(fileName) [[[NSFileManager defaultManager] attributesOfItemAtPath:HSFileFullpath(fileName) error:nil][NSFileSize] integerValue]

// 存储文件总长度的文件路径（caches）
#define HSTotalLengthFullpath [HSCachesDirectory stringByAppendingPathComponent:@"totalLength.plist"]

#import "HSDownloadManager.h"
#import "NSString+Hash.h"

@interface HSDownloadManager()<NSCopying, NSURLSessionDelegate>

/** 保存所有任务(注：用下载地址md5后作为key) */
@property (nonatomic, strong) NSMutableDictionary *tasks;
/** 保存所有下载相关信息 */
@property (nonatomic, strong) NSMutableDictionary *sessionModels;
@end

@implementation HSDownloadManager

- (NSMutableDictionary *)tasks
{
    if (!_tasks) {
        _tasks = [NSMutableDictionary dictionary];
    }
    return _tasks;
}

- (NSMutableDictionary *)sessionModels
{
    if (!_sessionModels) {
        _sessionModels = [NSMutableDictionary dictionary];
    }
    return _sessionModels;
}


static HSDownloadManager *_downloadManager;

+ (instancetype)allocWithZone:(struct _NSZone *)zone
{
    static dispatch_once_t onceToken;
    
    dispatch_once(&onceToken, ^{
        _downloadManager = [super allocWithZone:zone];
    });
    
    return _downloadManager;
}

- (nonnull id)copyWithZone:(nullable NSZone *)zone
{
    return _downloadManager;
}

+ (instancetype)sharedInstance
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _downloadManager = [[self alloc] init];
    });
    
    return _downloadManager;
}

/**
 *  创建缓存目录文件
 */
- (void)createCacheDirectory
{
    NSFileManager *fileManager = [NSFileManager defaultManager];
    if (![fileManager fileExistsAtPath:HSCachesDirectory]) {
        [fileManager createDirectoryAtPath:HSCachesDirectory withIntermediateDirectories:YES attributes:nil error:NULL];
    }
}

/**
 *  开启任务下载资源
 */
- (void)download:(NSString *)url andFileName:(NSString*)fileName progress:(void (^)(NSInteger, NSInteger, CGFloat))progressBlock state:(void (^)(DownloadState state, NSError *error))stateBlock
{
    if (!url) return;
    if ([self isCompletion:fileName]) {
        stateBlock(DownloadStateCompleted, nil);
        NSLog(@"----该资源已下载完成");
        return;
    }
    
    // 暂停
    if ([self.tasks valueForKey:fileName]) {
        [self handle:fileName];
        
        return;
    }
    
    // 创建缓存目录文件
    [self createCacheDirectory];
    
   NSURLSession *session = [NSURLSession sessionWithConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration] delegate:self delegateQueue:[[NSOperationQueue alloc] init]];
    
    // 创建流
    NSString* filePath =HSFileFullpath(fileName) ;
    NSOutputStream *stream = [NSOutputStream outputStreamToFileAtPath:HSFileFullpath(fileName) append:YES];
    
    // 创建请求
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:url]];
    request.timeoutInterval = 120;
    
    // 设置请求头
    NSString *range = [NSString stringWithFormat:@"bytes=%zd-", HSDownloadLength(fileName)];
    [request setValue:range forHTTPHeaderField:@"Range"];
    
    // 创建一个Data任务
    NSURLSessionDataTask *task = [session dataTaskWithRequest:request];
    NSUInteger taskIdentifier = arc4random() % ((arc4random() % 10000 + arc4random() % 10000));
    [task setValue:@(taskIdentifier) forKeyPath:@"taskIdentifier"];

    // 保存任务
    [self.tasks setValue:task forKey:fileName];

    HSSessionModel *sessionModel = [[HSSessionModel alloc] init];
    sessionModel.url = url;
    sessionModel.fileName = fileName;
    sessionModel.progressBlock = progressBlock;
    sessionModel.stateBlock = stateBlock;
    sessionModel.stream = stream;
    [self.sessionModels setValue:sessionModel forKey:@(task.taskIdentifier).stringValue];
    
    [self start:fileName];
}


- (void)handle:(NSString *)fileName
{
    NSURLSessionDataTask *task = [self getTask:fileName];
    if (task.state == NSURLSessionTaskStateRunning) {
        [self pause:fileName];
    } else {
        [self start:fileName];
    }
}

/**
 *  开始下载
 */
- (void)start:(NSString *)fileName
{
    NSURLSessionDataTask *task = [self getTask:fileName];
    [task resume];

    [self getSessionModel:task.taskIdentifier].stateBlock(DownloadStateStart, nil);
}

/**
 *  暂停下载
 */
- (void)pause:(NSString *)fileName
{
    NSURLSessionDataTask *task = [self getTask:fileName];
    [task suspend];

    [self getSessionModel:task.taskIdentifier].stateBlock(DownloadStateSuspended, nil);
}

/**
 *  根据url获得对应的下载任务
 */
- (NSURLSessionDataTask *)getTask:(NSString *)fileName
{
    return (NSURLSessionDataTask *)[self.tasks valueForKey:fileName];
}

/**
 *  根据url获取对应的下载信息模型
 */
- (HSSessionModel *)getSessionModel:(NSUInteger)taskIdentifier
{
    return (HSSessionModel *)[self.sessionModels valueForKey:@(taskIdentifier).stringValue];
}

/**
 *  判断该文件是否下载完成
 */
- (BOOL)isCompletion:(NSString *)fileName
{
    NSInteger downSize = HSDownloadLength(fileName);
    NSInteger fileSize = [self fileTotalLength:fileName];
    if ([self fileTotalLength:fileName] && HSDownloadLength(fileName) == [self fileTotalLength:fileName]) {
        return YES;
    }
    return NO;
}

/**
 *  查询该资源的下载进度值
 */
- (CGFloat)progress:(NSString *)fileName
{
    return [self fileTotalLength:fileName] == 0 ? 0.0 : 1.0 * HSDownloadLength(fileName) /  [self fileTotalLength:fileName];
}

/**
 *  获取该资源总大小
 */
- (NSInteger)fileTotalLength:(NSString *)fileName
{
    return [[NSDictionary dictionaryWithContentsOfFile:HSTotalLengthFullpath][fileName] integerValue];
}

- (NSString*)fileFullPath:(NSString *)fileName
{
    return HSFileFullpath(fileName);
}

#pragma mark - 删除
/**
 *  删除该资源
 */
- (void)deleteFile:(NSString *)fileName
{
    NSFileManager *fileManager = [NSFileManager defaultManager];
    if ([fileManager fileExistsAtPath:HSFileFullpath(fileName)]) {

        // 删除沙盒中的资源
        [fileManager removeItemAtPath:HSFileFullpath(fileName) error:nil];
        // 删除任务
        [self.tasks removeObjectForKey:fileName];
        [self.sessionModels removeObjectForKey:@([self getTask:fileName].taskIdentifier).stringValue];
        // 删除资源总长度
        if ([fileManager fileExistsAtPath:HSTotalLengthFullpath]) {
            
            NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithContentsOfFile:HSTotalLengthFullpath];
            [dict removeObjectForKey:fileName];
            [dict writeToFile:HSTotalLengthFullpath atomically:YES];
        
        }
    }
}

/**
 *  清空所有下载资源
 */
- (void)deleteAllFile
{
    NSFileManager *fileManager = [NSFileManager defaultManager];
    if ([fileManager fileExistsAtPath:HSCachesDirectory]) {
        // 删除沙盒中所有资源
        [fileManager removeItemAtPath:HSCachesDirectory error:nil];
        // 删除任务
        [[self.tasks allValues] makeObjectsPerformSelector:@selector(cancel)];
        [self.tasks removeAllObjects];
        
        for (HSSessionModel *sessionModel in [self.sessionModels allValues]) {
            [sessionModel.stream close];
        }
        [self.sessionModels removeAllObjects];
        
        // 删除资源总长度
        if ([fileManager fileExistsAtPath:HSTotalLengthFullpath]) {
            [fileManager removeItemAtPath:HSTotalLengthFullpath error:nil];
        }
    }
}

#pragma mark - 代理
#pragma mark NSURLSessionDataDelegate
/**
 * 接收到响应
 */
- (void)URLSession:(NSURLSession *)session dataTask:(NSURLSessionDataTask *)dataTask didReceiveResponse:(NSHTTPURLResponse *)response completionHandler:(void (^)(NSURLSessionResponseDisposition))completionHandler
{
    
    HSSessionModel *sessionModel = [self getSessionModel:dataTask.taskIdentifier];
    
    // 打开流
    [sessionModel.stream open];
    
    // 获得服务器这次请求 返回数据的总长度
    NSInteger totalLength = [response.allHeaderFields[@"Content-Length"] integerValue] + HSDownloadLength(sessionModel.url);
    sessionModel.totalLength = totalLength;
    
    // 存储总长度
    NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithContentsOfFile:HSTotalLengthFullpath];
    if (dict == nil) dict = [NSMutableDictionary dictionary];
    dict[sessionModel.fileName] = @(totalLength);
    [dict writeToFile:HSTotalLengthFullpath atomically:YES];
    
    // 接收这个请求，允许接收服务器的数据
    completionHandler(NSURLSessionResponseAllow);
}

/**
 * 接收到服务器返回的数据
 */
- (void)URLSession:(NSURLSession *)session dataTask:(NSURLSessionDataTask *)dataTask didReceiveData:(NSData *)data
{
    HSSessionModel *sessionModel = [self getSessionModel:dataTask.taskIdentifier];
    
    // 写入数据
    [sessionModel.stream write:data.bytes maxLength:data.length];
    
    // 下载进度
    NSUInteger receivedSize = HSDownloadLength(sessionModel.url);
    NSUInteger expectedSize = sessionModel.totalLength;
    CGFloat progress = 1.0 * receivedSize / expectedSize;

    sessionModel.progressBlock(receivedSize, expectedSize, progress);
}

/**
 * 请求完毕（成功|失败）
 */
- (void)URLSession:(NSURLSession *)session task:(NSURLSessionTask *)task didCompleteWithError:(NSError *)error
{
    HSSessionModel *sessionModel = [self getSessionModel:task.taskIdentifier];
    if (!sessionModel) return;
    
    if ([self isCompletion:sessionModel.url]) {
        // 下载完成
        sessionModel.stateBlock(DownloadStateCompleted, error);
    } else if (error){
        // 下载失败
        sessionModel.stateBlock(DownloadStateFailed, error);
    }
    
    // 关闭流
    [sessionModel.stream close];
    sessionModel.stream = nil;
    
    // 清除任务
    [self.tasks removeObjectForKey:sessionModel.fileName];
    [self.sessionModels removeObjectForKey:@(task.taskIdentifier).stringValue];

    sessionModel.stateBlock(DownloadStateCompleted, error);//临时会掉完成
}

-(NSString*)getCachePath{
    return HSCachesDirectory;

}
@end
