//
//  LZNetworkHelper.h
//  LZHttpTask
//
//  Created by LZ on 2019/1/8.
//

#import <Foundation/Foundation.h>


/**
 * 任务状态
 */
typedef NS_ENUM(NSInteger, LZHttpTaskStatus) {
    LZHttpTaskStatusFinish,
    LZHttpTaskStatusExecuting
};


@interface LZHttpTask : NSObject

@property (nonatomic, strong, readonly) NSString *url;
@property (nonatomic, strong, readonly) NSDictionary *params;
@property (nonatomic, strong, readonly) NSDictionary *header;
@property (nonatomic, assign, readonly) NSUInteger identifier;
@property (nonatomic, strong, readonly) NSURLRequest *request;
@property (nonatomic, strong) NSURLSessionTask *task;

@property (nonatomic, assign) LZHttpTaskStatus taskStatus;

/**
 * 构建Task【由LZNetworkManager创建请求时进行构建】，业务使用方法不需要创建该对象
 */
- (instancetype)initWithTask:(NSURLSessionTask *) task
                     withUrl:(NSString *) url
                  withParams:(NSDictionary *)params
                  withHeader:(NSDictionary *) header;

/**
 * 取消网络任务请求，业务方进行调用
 */
- (void)cancel;

/**
 * 是否在请求中
 */
- (BOOL)isExecuting;
@end

