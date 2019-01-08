//
//  LZNetworkHelper.h
//  LZHttpDownloadTask
//
//  Created by LZ on 2019/1/8.
//

#import "LZHttpDownloadTask.h"

@implementation LZHttpDownloadTask

- (instancetype)initWithTask:(NSURLSessionTask *) task
                     withUrl:(NSString *) url
                  withParams:(NSDictionary *)params
                  withHeader:(NSDictionary *) header {
    
    if (self = [super initWithTask:task withUrl:url withParams:params withHeader:header]) {
        self.downloadTask = (NSURLSessionDownloadTask *)task;
    }
    return self;
    
}

- (void)cancelTask {
    [self.downloadTask cancelByProducingResumeData:^(NSData * _Nullable resumeData) {
        [resumeData writeToFile:[self.tmpFileDir stringByAppendingPathComponent:@"file.db"] atomically:YES];
        NSArray *pathArr = [[NSFileManager defaultManager]subpathsAtPath:NSTemporaryDirectory()];
        for (NSString *fileName in pathArr) {
            if ([fileName rangeOfString:@"CFNetworkDownload"].length>0) {
                NSString *downloadPath = [self.tmpFileDir stringByAppendingPathComponent:fileName];
                NSString *path = [NSTemporaryDirectory() stringByAppendingPathComponent:fileName];
                NSError *error = nil;
                [[NSFileManager defaultManager] moveItemAtPath:path toPath:downloadPath error:&error];
                if (error) {
                    NSLog(@"%@", error);
                }
            }
        }
    }];
}

@end
