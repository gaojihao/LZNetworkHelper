//
//  LZNetworkHelper.h
//  LZError
//
//  Created by LZ on 2019/1/8.
//

#import "LZError.h"

@implementation LZError

+ (id)errorWithCode:(NSInteger)code desc:(NSString *)desc {
    return [self errorWithCode:code desc:desc warningDesc:nil];
}

+ (id)errorWithCode:(NSInteger)code desc:(NSString *)desc warningDesc:(NSString *)warningDesc {
    LZError *error = [[LZError alloc] init];
    error.code = code;
    error.desc = desc;
    error.warningDesc = warningDesc;
    return error;
}

@end
