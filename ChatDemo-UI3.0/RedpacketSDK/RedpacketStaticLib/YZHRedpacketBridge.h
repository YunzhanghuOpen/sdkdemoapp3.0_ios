//
//  RedpacketUserAccount.h
//  ChatDemo-UI3.0
//
//  Created by Mr.Yang on 16/3/1.
//  Copyright © 2016年 Mr.Yang. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "YZHRedpacketBridgeProtocol.h"

@interface RedpacketRegisitModel : NSObject

<<<<<<< HEAD
@interface RPThirdPayMentInfo : NSObject

@property (nonatomic, copy) NSString *weChatPayID;
@property (nonatomic, copy) NSString *dKey;
@property (nonatomic, copy) NSString *sessionID;
@property (nonatomic, copy) NSString *imei;

+ (RPThirdPayMentInfo *)payInfoWithDKey:(NSString *)dKey
                            sessionID:(NSString *)sessionID
                                andImei:(NSString *)imei;


@end

@interface YZHRedpacketBridge : NSObject

@property (nonatomic, weak) id <YZHRedpacketBridgeDelegate> delegate;

@property (nonatomic, weak) id <YZHRedpacketBridgeDataSource>dataSource;
=======
//  签名方式
+ (RedpacketRegisitModel *)signModelWithAppUserId:(NSString *)appUserId     //  App的用户ID
                                       signString:(NSString *)sign          //  当前用户的签名
                                          partner:(NSString *)partner       //  在云账户注册的合作者
                                     andTimeStamp:(NSString *)timeStamp;    //  签名的时间戳
>>>>>>> c274304e4a1b5a83f00f1dbb2ec62caac9cad7e7

//  环信的方式
+ (RedpacketRegisitModel *)easeModelWithAppKey:(NSString *)appkey           //  环信的注册商户Key
                                      appToken:(NSString *)appToken         //  环信IM的Token
                                  andAppUserId:(NSString *)appUserId;       //  环信IM的用户ID

<<<<<<< HEAD
/**
 *  支付宝回调当前APP时的URL Scheme, 默认为当前App的Bundle Identifier
 */
@property (nonatomic, copy)  NSString *redacketURLScheme;


/**
 *  第三方支付信息
 */
@property (nonatomic, strong) RPThirdPayMentInfo *payMentInfo;


+ (YZHRedpacketBridge *)sharedBridge;
=======
//  容联云的方式
+ (RedpacketRegisitModel *)rongCloudModelWithAppId:(NSString *)appId        //  容联云的AppId
                                         appUserId:(NSString *)appUserId;   //  容联云的用户ID
>>>>>>> c274304e4a1b5a83f00f1dbb2ec62caac9cad7e7

@end


@interface YZHRedpacketBridge : NSObject

<<<<<<< HEAD
/**
 *  签名无需每次都要请求，请求前请先调用下列方法判断是否需要更新签名
 */
- (BOOL)isNeedUpdateSignWithUserId:(NSString *)userId;
=======
@property (nonatomic, weak) id <YZHRedpacketBridgeDelegate> delegate;
>>>>>>> c274304e4a1b5a83f00f1dbb2ec62caac9cad7e7

@property (nonatomic, weak) id <YZHRedpacketBridgeDataSource>dataSource;

/** 是否是调试模式, 默认为NO */
@property (nonatomic, assign)   BOOL isDebug;

/** 支付宝回调当前APP时的URL Scheme, 默认为当前App的Bundle Identifier */
@property (nonatomic, copy)  NSString *redacketURLScheme;

+ (YZHRedpacketBridge *)sharedBridge;

@end


/** 已经不再使用的API，请注意修改(可以将以下内容直接删除) */
@interface YZHRedpacketBridge (Deprecated)

/** 是否需要更新签名 */
- (BOOL)isNeedUpdateSignWithUserId:(NSString *)userId __deprecated_msg("方法已经停用，请实现Delegate中的redpacketFetchRegisitParam:withError:");

/** 签名注册Token */
- (void)configWithSign:(NSString *)sign
                     partner:(NSString *)partner
                   appUserId:(NSString *)appUserid
                   timeStamp:(long)timeStamp __deprecated_msg("方法命名不规范，已经停用, 请使用上边的方法");

/** 环信IM的注册方式 */
- (NSString *)configWithAppKey:(NSString *)appKey
                     appUserId:(NSString *)appUserId
                       imToken:(NSString *)imToken __deprecated_msg("方法已经停用，请实现Delegate中的redpacketFetchRegisitParam:withError:");

@end
