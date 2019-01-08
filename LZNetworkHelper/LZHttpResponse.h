//
//  LZNetworkHelper.h
//  LZHttpResponse
//
//  Created by LZ on 2019/1/8.
//

#import <Foundation/Foundation.h>

#import "LZError.h"
#import "LZNetworkConfiguration.h"

@interface LZHttpResponse : NSObject

/** 返回数据 */
@property (nonatomic, strong, readonly) id responseObject;

/** 业务状态码，非http状态码 */
@property (nonatomic, assign, readonly) NSInteger statusCode;

/** 业务状态详细描述信息*/
@property (nonatomic, copy, nullable, readonly) NSString* message;

/** 错误详情 */
@property (nonatomic, strong, readonly) LZError *error;

/** 是否来自缓存 */
@property (nonatomic, assign, readonly) BOOL isCache;

///** 当前数据的缓存类型 */
//@property (nonatomic, assign, readonly) LZHttpResponseCachePolicy cachePolicy;
//
/** 请求类型 */
@property (nonatomic, assign, readonly) LZHttpRequestType requestType;
//
///** 响应对象 */
@property (nonatomic, strong, readonly) NSURLSessionTask *sessionTask;

/**
 * 构建Response【由LZNetworkManager 响应时进行构建】，业务使用方法不需要创建该对象
 */
- (instancetype)initWithResponseObject:(id) responseObject
                            statusCode:(NSInteger) statusCode
                               message:(nullable NSString*) message
                                 error:(LZError *) error
                               isCache:(BOOL) isCache
                           requestType:(LZHttpRequestType) requestType
                                  task:(NSURLSessionTask *) sessionTask;
@end




