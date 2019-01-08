//
//  LZNetworkHelper.h
//  LZNetworkConfiguration
//
//  Created by LZ on 2019/1/8.
//

#import <Foundation/Foundation.h>

@class LZHttpResponse;

/**
 * 缓存策略
 */
typedef NS_ENUM(NSInteger, LZHttpResponseCachePolicy) {
    LZHttpResponseCachePolicyNone,        // 不缓存，默认
    LZHttpResponseCachePolicyNormal      // 普通缓存，一直保持，不删除
};


/**
 * 请求类型
 */
typedef NS_ENUM(NSInteger, LZHttpRequestType) {
    LZHttpRequestTypeGet,
    LZHttpRequestTypePost,
    LZHttpRequestTypePut,
    LZHttpRequestTypeDelete,
    LZHttpRequestTypeUpload,
    LZHttpRequestTypeDownload,
    
    LZHttpRequestTypeCache  //没有网络请求
};


/**
 * 请求响应结果，成功和失败
 */
typedef void (^LZHttpCompletion) (LZHttpResponse *response);

/**
 * 上传进度
 */
typedef void (^LZHttpUploadProgress)(NSProgress *uploadProgress);

/**
 * 上传进度
 */
typedef void (^LZHttpDownloadProgress)(NSProgress *downloadProgress);



// =================================================================
// =================================================================
// =================================================================
/**
 * 配置信息协议，业务方必须实现该协议
 */
@protocol LZNetworkConfiguration <NSObject>

@optional
/**
 * 设置基础URL
 */
- (NSURL *)baseUrl;

/**
 * 设置基础http header头，在 LZNetworkManager 初始化时设置的固定值
 */
- (NSDictionary *)httpHeaderFields;

/**
 * 设置http header头，在请求接口数据时设置，例如，接口加密等动态计算的参数
 */
- (NSDictionary *)httpHeaderFields:(NSDictionary *) params;

/**
 * 设置http header头，在请求接口数据时设置，例如，接口加密等动态计算的参数
 */
- (NSDictionary *)httpHeaderFields:(NSDictionary *) params url:(NSString *) url;

/**
 * 处理请求数据，可进行解析处理，返回解析的后的数据
 */
- (id)response:(LZHttpResponse *) response completion:(LZHttpCompletion) completion;

/**
 * 网络异常
 */
- (void)networkError:(LZHttpResponse *) response;

/**
 * 用户缓存标识符，如果业务端需要缓存不同用户的数据，需要设置一个标识符，每个用户必须不一样
 */
- (NSString *)userIdentifier;


@end

