//
//  LZNetworkHelper.h
//  LZHttpResponse
//
//  Created by LZ on 2019/1/8.
//

#import "LZHttpResponse.h"

@interface LZHttpResponse()

/** 返回数据 */
@property (nonatomic, strong) id responseObject;

/** 业务状态码，非http状态码 */
@property (nonatomic, assign) NSInteger statusCode;

/** 业务状态详细描述信息*/
@property (nonatomic, copy, nullable) NSString* message;

/** 错误详情 */
@property (nonatomic, strong) LZError *error;

/** 是否来自缓存 */
@property (nonatomic, assign) BOOL isCache;

/** 请求类型 */
@property (nonatomic, assign) LZHttpRequestType requestType;

///** 响应对象 */
@property (nonatomic, strong) NSURLSessionTask *sessionTask;

@end

@implementation LZHttpResponse

- (instancetype)initWithResponseObject:(id) responseObject
                            statusCode:(NSInteger) statusCode
                               message:(nullable NSString*) message
                                 error:(LZError *) error
                               isCache:(BOOL) isCache
                           requestType:(LZHttpRequestType) requestType
                                  task:(NSURLSessionTask *) sessionTask {
    
    if (self = [super init]) {
        self.responseObject = responseObject;
        self.statusCode = statusCode;
        self.message = message;
        self.error = error;
        self.isCache = isCache;
        self.requestType = requestType;
        self.sessionTask = sessionTask;
    }
    return self;
}
@end
