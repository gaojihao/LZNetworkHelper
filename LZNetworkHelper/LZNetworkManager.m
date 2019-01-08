//
//  LZNetworkHelper.h
//  LZNetworkManager
//
//  Created by LZ on 2019/1/8.
//

#import "LZNetworkManager.h"

#import "LZHttpResponse.h"
#import "LZHttpDownloadTask.h"
#import "LZNetworkManager+Cache.h"
#import <AFNetworking/AFNetworking.h>


@implementation LZFormFile
@end


@interface LZNetworkManager()

@property (nonatomic, strong) AFHTTPSessionManager *sessionManager;
@property (nonatomic, strong) NSMutableArray<LZHttpTask *> *httpTasks;

@end


@implementation LZNetworkManager

+ (instancetype)sharedManager {
    static LZNetworkManager *manager;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        manager = [[[self class] alloc] init];
    });
    return manager;
}

- (instancetype)init {
    if (self = [super init]) {
        _httpTasks = [[NSMutableArray alloc] init];
    }
    return self;
}

//MARK: Set Header
- (void)setHeaderFields:(NSDictionary *) fields {
    [self _setHeader:fields];
}

//MARK:  GET
- (LZHttpTask *)GET:(NSString *) url
         parameters:(NSDictionary *) params
         completion:(LZHttpCompletion) completion {
    return [self GET:url parameters:params cache:LZHttpResponseCachePolicyNone useCache:NO completion:completion];
}

- (LZHttpTask *)GET:(NSString *) url
         parameters:(NSDictionary *) params
              cache:(LZHttpResponseCachePolicy) cachePolicy
           useCache:(BOOL) useCache
         completion:(LZHttpCompletion) completion {
    return [self GET:url parameters:params headers:nil cache:LZHttpResponseCachePolicyNone useCache:useCache completion:completion];
}

- (LZHttpTask *)GET:(NSString *) url
         parameters:(NSDictionary *) params
            headers:(NSDictionary *) headers
              cache:(LZHttpResponseCachePolicy) cachePolicy
           useCache:(BOOL) useCache
         completion:(LZHttpCompletion) completion {
    
    // 读取缓存
    [self readCacheData:url params:params cache:useCache completion:completion];
    
    // 设置两种方式的heeader头参数
    NSDictionary *feilds = [self _setAllHeader:headers params:params url:url];
    
    NSURLSessionDataTask *task = [self.sessionManager GET:url parameters:params progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        // 删除已完成的task
        [self _removeTask:task];
        
        NSLog(@"get = request url:%@",task.originalRequest.URL.absoluteString);
        
        [self _successResponse:responseObject url:url params:params requestType:LZHttpRequestTypeGet task:task completion:completion];
        
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        // 删除已完成的task
        [self _removeTask:task];
        
        LZHttpResponse *response = [self _failureResponse:task error:error requestType:LZHttpRequestTypeGet ];
        completion ? completion(response) : nil;
    }];
    
    LZHttpTask *httpTask = [[LZHttpTask alloc] initWithTask:task withUrl:url withParams:params withHeader:feilds];
    [_httpTasks addObject:httpTask];
    return httpTask;
    
}

//MARK: POST
- (LZHttpTask *)POST:(NSString *) url
          parameters:(NSDictionary *) params
          completion:(LZHttpCompletion) completion {
    return [self POST:url parameters:params cache:LZHttpResponseCachePolicyNone useCache:NO completion:completion];
}

- (LZHttpTask *)POST:(NSString *) url
          parameters:(NSDictionary *) params
               cache:(LZHttpResponseCachePolicy) cachePolicy
            useCache:(BOOL) useCache
          completion:(LZHttpCompletion) completion {
    return [self POST:url parameters:params headers:nil cache:LZHttpResponseCachePolicyNone useCache:useCache completion:completion];
}

- (LZHttpTask *)POST:(NSString *) url
          parameters:(NSDictionary *) params
             headers:(NSDictionary *) headers
               cache:(LZHttpResponseCachePolicy) cachePolicy
            useCache:(BOOL) useCache
          completion:(LZHttpCompletion) completion {
    
    // 读取缓存
    [self readCacheData:url params:params cache:useCache completion:completion];
    
    // 设置两种方式的heeader头参数
    NSDictionary *feilds = [self _setAllHeader:headers params:params url:url];
    
    NSURLSessionDataTask *task = [self.sessionManager POST:url parameters:params progress:^(NSProgress * _Nonnull uploadProgress) {
        
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        // 删除已完成的task
        [self _removeTask:task];
        
        NSLog(@"POST = request url:%@",task.originalRequest.URL.absoluteString);
        [self _successResponse:responseObject url:url params:params requestType:LZHttpRequestTypePost task:task completion:completion];
        
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        // 删除已完成的task
        [self _removeTask:task];
        
        LZHttpResponse *response = [self _failureResponse:task error:error requestType:LZHttpRequestTypePost ];
        completion ? completion(response) : nil;
        
    }];
    
    LZHttpTask *httpTask = [[LZHttpTask alloc] initWithTask:task withUrl:url withParams:params withHeader:feilds];
    [_httpTasks addObject:httpTask];
    return httpTask;
}

//MARK: Upload
- (LZHttpTask *)upload:(NSString *) url
            parameters:(NSDictionary *) params
           appendFiles:(NSString *) filePath
               headers:(NSDictionary *) headers
        uploadProgress:(LZHttpUploadProgress) progress
            completion:(LZHttpCompletion) completion {
    
    return [self upload:url parameters:params filePath:filePath headers:headers uploadProgress:progress completion:completion];
}


- (LZHttpTask *)upload:(NSString *) url
            parameters:(NSDictionary *) params
              filePath:(NSString *) filePath
               headers:(NSDictionary *) headers
        uploadProgress:(LZHttpUploadProgress) progress
            completion:(LZHttpCompletion) completion {
    
    NSMutableDictionary *newParams = [NSMutableDictionary dictionaryWithDictionary:params];
    
    NSData *fileData = [newParams objectForKey:@"file"];
    [newParams removeObjectForKey:@"file"];
    
    LZFormFile *formFile = [[LZFormFile alloc] init];
    
    if (filePath) {
        formFile.filePathURL =  [NSURL fileURLWithPath:filePath];
    } else {
        formFile.filename = @"photo.jpg";
        formFile.mineType = @"image/jpeg";
    }
    
    if ([newParams objectForKey:@"fileName"]) {
        formFile.name = newParams[@"fileName"];
    } else {
        formFile.name = @"file";
    }
    formFile.data = fileData;
    
    return [self upload:url parameters:newParams appendFormFiles:@[formFile] headers:headers uploadProgress:progress completion:completion];
}

- (LZHttpTask *)upload:(NSString *)url
            parameters:(NSDictionary *)params
       appendFormFiles:(NSArray<LZFormFile *> *)formFiles
               headers:(NSDictionary *) headers
        uploadProgress:(LZHttpUploadProgress)progress
            completion:(LZHttpCompletion) completion{
    
    // 设置两种方式的heeader头参数
    NSDictionary *feilds = [self _setAllHeader:headers params:params url:url];
    
    NSURLSessionDataTask *task = [self.sessionManager POST:url parameters:params constructingBodyWithBlock:^(id<AFMultipartFormData>  _Nonnull formData) {
        for (LZFormFile *formFile in formFiles) {
            if (formFile.filePathURL) {
                [formData appendPartWithFileURL:formFile.filePathURL name:formFile.name error:nil];            
            } else if (formFile.data) {
                [formData appendPartWithFileData:formFile.data
                                            name:formFile.name
                                        fileName:[self _emptyString:formFile.filename]
                                        mimeType:[self _emptyString:formFile.mineType]];
            }
        }
        
    } progress:^(NSProgress * _Nonnull uploadProgress) {
        if (progress) {
            progress(uploadProgress);
        }
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        // 删除已完成的task
        [self _removeTask:task];
        
        [self _successResponse:responseObject url:url params:params requestType:LZHttpRequestTypeUpload task:task completion:completion];
        
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        // 删除已完成的task
        [self _removeTask:task];
        
        LZHttpResponse *response = [self _failureResponse:task error:error requestType:LZHttpRequestTypeUpload];
        completion ? completion(response) : nil;
    }];
    
    LZHttpTask *httpTask = [[LZHttpTask alloc] initWithTask:task withUrl:url withParams:params withHeader:feilds];
    [_httpTasks addObject:httpTask];
    return httpTask;
}



//MARK: Download

- (LZHttpTask *)download:(NSString *) url
              parameters:(NSDictionary *) params
        downloadProgress:(LZHttpDownloadProgress)progress
              completion:(LZHttpCompletion) completion {
    return [self download:url parameters:params headers:nil downloadProgress:progress completion:completion];
}

- (LZHttpTask *)download:(NSString *) url
              parameters:(NSDictionary *) params
                 headers:(NSDictionary *) headers
        downloadProgress:(LZHttpDownloadProgress)progress
              completion:(LZHttpCompletion) completion {
    // 设置两种方式的heeader头参数
    NSDictionary *feilds = [self _setAllHeader:headers params:params url:url];
    
    NSString *nsUrl = url;
    if ([self _baseUrl]) {
        nsUrl = [[[self _baseUrl] absoluteString] stringByAppendingString:url];
    }
    
    NSMutableURLRequest *request =[self.sessionManager.requestSerializer requestWithMethod:@"GET" URLString:nsUrl parameters:params error:nil];
    NSURLSessionDownloadTask *task = nil;
    task = [self.sessionManager downloadTaskWithRequest:request progress:progress destination:^NSURL * _Nonnull(NSURL * _Nonnull targetPath, NSURLResponse * _Nonnull response) {
        //保存的文件路径
        NSString *fileName = [NSString stringWithFormat:@"%f%@", [[NSDate date] timeIntervalSince1970], response.suggestedFilename];
        NSString *fullPath = [[NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) lastObject] stringByAppendingPathComponent:fileName];
        
        return [NSURL fileURLWithPath:fullPath];
    } completionHandler:^(NSURLResponse * _Nonnull response, NSURL * _Nullable filePath, NSError * _Nullable error) {
        if (!error) {
            NSData *responseObject = [NSData dataWithContentsOfURL:filePath];
            [self _successResponse:responseObject url:url params:params requestType:LZHttpRequestTypeDownload task:nil completion:completion];
            
            // 删除已经下载的数据
            NSFileManager *fileManager = [NSFileManager defaultManager];
            [fileManager removeItemAtURL:filePath error:nil];
            //            NSLog(@"下载数据完成，删除操作 %@", res ? @"成功" : @"失败");
        } else {
            LZHttpResponse *response = [self _failureResponse:nil error:error requestType:LZHttpRequestTypeDownload ];
            completion ? completion(response) : nil;
        }
    }];
    
    [task resume];
    
    LZHttpTask *httpTask = [[LZHttpTask alloc] initWithTask:task withUrl:url withParams:params withHeader:feilds];
    [_httpTasks addObject:httpTask];
    return httpTask;
}


- (LZHttpDownloadTask *)download:(NSString *) url
              parameters:(NSDictionary *) params
                 headers:(NSDictionary *) headers
             tmpFilePath:(NSString *)tmpFileDir
             dstFilePath:(NSString *)dstFilePath
        downloadProgress:(LZHttpDownloadProgress)progress
              completion:(LZHttpCompletion) completion {
    
    // 设置两种方式的heeader头参数
    NSDictionary *feilds = [self _setAllHeader:headers params:params url:url];
    
    NSString *nsUrl = url;
    if ([self _baseUrl]) {
        nsUrl = [[[self _baseUrl] absoluteString] stringByAppendingString:url];
    }
    
    NSMutableURLRequest *request =[self.sessionManager.requestSerializer requestWithMethod:@"GET" URLString:nsUrl parameters:params error:nil];
    NSURLSessionDownloadTask *task = nil;
    
    NSData *downloadData = [NSData dataWithContentsOfFile:[tmpFileDir stringByAppendingPathComponent:@"file.db"]];
    if (downloadData) {
        [self moveToTempFile:tmpFileDir];
        task = [self.sessionManager downloadTaskWithResumeData:downloadData progress:^(NSProgress * _Nonnull downloadProgress) {
            progress(downloadProgress);
        } destination:^NSURL * _Nonnull(NSURL * _Nonnull targetPath, NSURLResponse * _Nonnull response) {
            //保存的文件路径
            return [NSURL fileURLWithPath:dstFilePath];
        } completionHandler:^(NSURLResponse * _Nonnull response, NSURL * _Nullable filePath, NSError * _Nullable error) {
            if (!error) {
                NSData *responseObject = [NSData dataWithContentsOfURL:filePath];
                [self _successResponse:responseObject url:url params:params requestType:LZHttpRequestTypeDownload task:nil completion:completion];
                
                // 删除已经下载的数据
                NSFileManager *fileManager = [NSFileManager defaultManager];
                [fileManager removeItemAtURL:filePath error:nil];
                [fileManager removeItemAtPath:[tmpFileDir stringByAppendingPathComponent:@"file.db"] error:nil];
            } else {
                LZHttpResponse *response = [self _failureResponse:nil error:error requestType:LZHttpRequestTypeDownload ];
                completion ? completion(response) : nil;
            }
        }];
    } else {
        task = [self.sessionManager downloadTaskWithRequest:request progress:progress destination:^NSURL * _Nonnull(NSURL * _Nonnull targetPath, NSURLResponse * _Nonnull response) {
            //保存的文件路径
            return [NSURL fileURLWithPath:dstFilePath];
        } completionHandler:^(NSURLResponse * _Nonnull response, NSURL * _Nullable filePath, NSError * _Nullable error) {
            if (!error) {
                NSData *responseObject = [NSData dataWithContentsOfURL:filePath];
                [self _successResponse:responseObject url:url params:params requestType:LZHttpRequestTypeDownload task:nil completion:completion];
                
                // 删除已经下载的数据
                NSFileManager *fileManager = [NSFileManager defaultManager];
                [fileManager removeItemAtURL:filePath error:nil];
                [fileManager removeItemAtPath:[tmpFileDir stringByAppendingPathComponent:@"file.db"] error:nil];
                //            NSLog(@"下载数据完成，删除操作 %@", res ? @"成功" : @"失败");
            } else {
                LZHttpResponse *response = [self _failureResponse:nil error:error requestType:LZHttpRequestTypeDownload ];
                completion ? completion(response) : nil;
            }
        }];
    }
    //执行Task
    [task resume];
    
    LZHttpDownloadTask *downloadTask = [[LZHttpDownloadTask alloc] initWithTask:task withUrl:url withParams:params withHeader:feilds];
    downloadTask.tmpFileDir = tmpFileDir;
    [_httpTasks addObject:downloadTask];
    return downloadTask;
}

- (void)moveToTempFile:(NSString *)tmpFileDir {
    NSArray *paths = [[NSFileManager defaultManager]subpathsAtPath:tmpFileDir];
    for (NSString *fileName in paths) {
        if ([fileName rangeOfString:@"CFNetworkDownload"].length>0) {
            NSString *path = [NSTemporaryDirectory() stringByAppendingPathComponent:fileName];
            //反向移动
            [[NSFileManager defaultManager]copyItemAtPath:[tmpFileDir stringByAppendingPathComponent:fileName] toPath:path error:nil];
        }
    }
}



//MARK: Cancel
- (void)cancelAllTask {
    [_httpTasks enumerateObjectsUsingBlock:^(LZHttpTask *  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        [obj cancel];
    }];
    [_httpTasks removeAllObjects];
}

//MARK: set & get
- (AFHTTPSessionManager *)sessionManager {
    if (!_sessionManager) {
        
        if ([self _baseUrl]) {
            _sessionManager = [[AFHTTPSessionManager alloc] initWithBaseURL:[self _baseUrl]];
        } else {
            _sessionManager = [[AFHTTPSessionManager alloc] init];
        }
        _sessionManager.requestSerializer = [AFHTTPRequestSerializer serializer];
        _sessionManager.requestSerializer.timeoutInterval = 60;
        _sessionManager.requestSerializer.cachePolicy = NSURLRequestReloadIgnoringLocalCacheData;
        
        AFJSONResponseSerializer *response = [AFJSONResponseSerializer serializer];
        response.removesKeysWithNullValues = YES;
        _sessionManager.responseSerializer = response;
        _sessionManager.responseSerializer.acceptableContentTypes = [NSSet setWithObjects:@"application/json", @"text/json", @"text/javascript",@"text/html", nil];
        
        // 初始化时设置头信息
        [self _setHttpHeaderFields];
    }
    return _sessionManager;
}

//MARK: private method

- (NSURL *)_baseUrl{
    if (self.configuration && [self.configuration respondsToSelector:@selector(baseUrl)]) {
        NSURL *url = [self.configuration baseUrl];
        if ([url.absoluteString stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]].length == 0) {
            return nil;
        }
        return url;
    }
    return nil;
}

- (void)_setHttpHeaderFields {
    if (self.configuration && [self.configuration respondsToSelector:@selector(httpHeaderFields)]) {
        NSDictionary *dic =  [self.configuration httpHeaderFields];
        [self _setHeader:dic];
    }
}

- (NSDictionary *)_setHttpHeaderFields:(NSDictionary *)params {
    if (self.configuration && [self.configuration respondsToSelector:@selector(httpHeaderFields:)]) {
        NSDictionary *dic = [self.configuration httpHeaderFields:params];
        [self _setHeader:dic];
        return dic;
    }
    return nil;
}

- (NSDictionary *)_setHttpHeaderFields:(NSDictionary *)params url:(NSString *) url {
    if (self.configuration && [self.configuration respondsToSelector:@selector(httpHeaderFields: url:)]) {
        NSDictionary *dic = [self.configuration httpHeaderFields:params url:url];
        [self _setHeader:dic];
        return dic;
    }
    return nil;
}


- (NSDictionary *)_setAllHeader:(NSDictionary *)headers params:(NSDictionary *)params url:(NSString *) url {
    // 设置两种方式的heeader头参数
    [self _setHeader:headers];
    NSDictionary *feilds = [self _setHttpHeaderFields:params];
    return feilds ? feilds : [self _setHttpHeaderFields:params url:url];
}

//MARK: 设置头字段
- (void)_setHeader:(NSDictionary *)fields {
    if (!fields || !fields.count) return;
    
    NSArray<NSString *> *allKeys = [fields allKeys];
    [allKeys enumerateObjectsUsingBlock:^(NSString * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        NSString *value = fields[obj];
        [self.sessionManager.requestSerializer setValue:value forHTTPHeaderField:obj];
    }];
    
}

//MARK: 数据请求成功处理
- (void )_successResponse:(id) responseObject
                      url:(NSString *) url
                   params:(NSDictionary *) params
              requestType:(LZHttpRequestType) requestType
                     task:(NSURLSessionDataTask *) task
               completion:(LZHttpCompletion) completion {

    LZHttpResponse *httpResponse;
    NSString* _responseMessage = nil;
    if ([responseObject isKindOfClass:[NSDictionary class]]) {
        _responseMessage = responseObject[@"message"];
    }
    
    if (self.configuration && [self.configuration respondsToSelector:@selector(response: completion:)]) {
        LZHttpResponse *tmpResponse = [[LZHttpResponse alloc] initWithResponseObject:responseObject
                                                                          statusCode:0
                                                                             message:_responseMessage
                                                                               error:nil
                                                                             isCache:NO
                                                                         requestType:requestType
                                                                                task:task];
        id newResponseObject = [self.configuration response:tmpResponse completion:completion];
        
        
        httpResponse = [[LZHttpResponse alloc] initWithResponseObject:newResponseObject
                                                           statusCode:0
                                                              message:_responseMessage
                                                                error:nil
                                                              isCache:NO
                                                          requestType:requestType
                                                                 task:task];
    } else {
        httpResponse = [[LZHttpResponse alloc] initWithResponseObject:responseObject
                                                           statusCode:0
                                                              message:_responseMessage
                                                                error:nil
                                                              isCache:NO
                                                          requestType:requestType
                                                                 task:task];
        if (completion) completion(httpResponse);
    }
    
    if (requestType == LZHttpRequestTypeGet || requestType == LZHttpRequestTypePost) {
        [self saveCacheData:httpResponse.responseObject filePath:url params:params];
    }
    
}



//MARK: 数据请求失败处理
- (LZHttpResponse *)_failureResponse:(NSURLSessionDataTask *)task error:(NSError *)error requestType:(LZHttpRequestType) requestType{
    
    LZError *LZerror = [LZError errorWithCode:(int)error.code desc:error.description];
    LZerror.desc = @"网络不给力";
    LZerror.originalError = error;
    
    NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *)task.response;
    LZHttpResponse *response = [[LZHttpResponse alloc] initWithResponseObject:nil
                                                                   statusCode:httpResponse.statusCode
                                                                      message:nil
                                                                        error:LZerror
                                                                      isCache:NO
                                                                  requestType:requestType
                                                                         task:task];
    
    if (self.configuration && [self.configuration respondsToSelector:@selector(networkError:)]) {
        [self.configuration networkError:response];
    }
    
    
    return response;
}

- (NSString *)_emptyString:(NSString*)string {
    if ([string isKindOfClass:[NSNumber class]]) {
        return [NSString stringWithFormat:@"%@",string];
    }
    if (!string || ![string length]) {
        return @"";
    } else {
        return string;
    }
}


- (void)_removeTask:(NSURLSessionDataTask *)task {
    [_httpTasks enumerateObjectsUsingBlock:^(LZHttpTask * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if (obj.identifier == task.taskIdentifier) {
            [self.httpTasks removeObject:obj];
            *stop = YES;
            obj.taskStatus = LZHttpTaskStatusFinish;
        }
    }];
}


@end

