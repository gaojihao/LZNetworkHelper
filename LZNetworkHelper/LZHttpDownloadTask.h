//
//  LZNetworkHelper.h
//  LZHttpDownloadTask
//
//  Created by LZ on 2019/1/8.
//

#import "LZHttpTask.h"

@interface LZHttpDownloadTask : LZHttpTask
@property (nonatomic, strong) NSString *tmpFileDir;
@property (nonatomic, strong) NSURLSessionDownloadTask *downloadTask;
- (void)cancelTask;
@end
