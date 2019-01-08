//
//  LZNetworkHelper.h
//  LZError
//
//  Created by LZ on 2019/1/8.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSUInteger, LZErrorCode) {
    LZErrorLogout = 10106,
    LZErrorClosure = 10122,
};

@interface LZError : NSObject

/** 原始Error */
@property (nonatomic, strong) NSError *originalError;
@property(nonatomic)NSInteger code;
@property(nonatomic,strong)NSString *desc;//message
@property(nonatomic,strong)NSString *warningDesc;
@property(nonatomic,strong)NSString *notice;
@property(nonatomic,strong)NSString *warningOperation;
@property(nonatomic,assign)BOOL isCache;
@property (nonatomic, assign) NSInteger type;

+ (id)errorWithCode:(NSInteger)code desc:(NSString *)desc;
+ (id)errorWithCode:(NSInteger)code desc:(NSString *)desc warningDesc:(NSString *)warningDesc;

@end
