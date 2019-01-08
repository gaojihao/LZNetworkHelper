//
//  LZNetworkHelper.h
//  LZNetworkManager+Cache
//
//  Created by LZ on 2019/1/8.
//

#import "LZNetworkManager.h"

typedef NS_ENUM(NSInteger, LZDataType) {
    LZDataTypeCache         = 0,
    LZDataTypeNetwork
};

@interface LZNetworkManager (Cache)

/**
 * 读取缓存数据
 */
- (void)readCacheData:(NSString *) url
               params:(NSDictionary *) params
                cache:(BOOL) cache
              completion:(LZHttpCompletion) completion;



/**
 * 保存缓存数据到文件中
 */
- (void)saveCacheData:(NSDictionary *)data
             filePath:(NSString *)url
               params:(NSDictionary *)params;

@end
