//
//  LZNetworkHelper.h
//  LZHttpTask
//
//  Created by LZ on 2019/1/8.
//

#import "LZHttpTask.h"

@interface LZHttpTask()

@property (nonatomic, strong) NSString *url;
@property (nonatomic, strong) NSDictionary *params;
@property (nonatomic, strong) NSDictionary *header;
@property (nonatomic, assign) NSUInteger identifier;

@property (nonatomic, strong) NSURLRequest *request;

@end


@implementation LZHttpTask

- (instancetype)initWithTask:(NSURLSessionTask *) task
                     withUrl:(NSString *) url
                  withParams:(NSDictionary *)params
                  withHeader:(NSDictionary *) header {
    
    if (self = [super init]) {
        self.task = task;
        self.url = url;
        self.params = params;
        self.header = header;
        self.identifier = task.taskIdentifier;
        self.request = task.originalRequest;
        self.taskStatus = LZHttpTaskStatusExecuting;
    }
    return self;
    
}
- (void)cancel {
    [self.task cancel];
    self.taskStatus = LZHttpTaskStatusFinish;
    
    // 结束后，没有从集合容器中删除 Task
}

/**
 * 是否在请求中
 */
- (BOOL)isExecuting {
    return self.taskStatus == LZHttpTaskStatusExecuting;
}
@end

