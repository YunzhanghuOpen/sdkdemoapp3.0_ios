//
//  YZHRedpacketBridgeProtocol.h
//  RedpacketLib
//
//  Created by Mr.Yang on 16/4/8.
//  Copyright © 2016年 Mr.Yang. All rights reserved.
//

#ifndef YZHRedpacketBridgeProtocol_h
#define YZHRedpacketBridgeProtocol_h

#pragma mark - huawei change
//  如果成功就传值，如果失败就传nil
typedef void(^updateDkeyAndSessionIDBlock)(NSString *dKey, NSString *sessionID, NSError *error);

#pragma mark - huawei end

@class RedpacketUserInfo;

@protocol YZHRedpacketBridgeDataSource <NSObject>

/**
 *  主动获取App用户的用户信息
 *
 *  @return 用户信息Info
 */
- (RedpacketUserInfo *)redpacketUserInfo;

@end


@protocol YZHRedpacketBridgeDelegate <NSObject>
@required
/**
 *  SDK错误处理代理
 *
 *  @param error 错误内容
 *  @param code  错误码
 *  @discussion
    1.通过ImToken获取红包Token, 红包Token过期后，请求红包Token时，ImToken过期触发回调，刷新ImToken后，重新注册红包Token。
    2.通过Sign获取红包Token， 红包Token过期后，直接触发。
    错误码： 20304  环信IMToken验证错误
    错误码： 1001 Token相关错误
 */
- (void)redpacketError:(NSString *)error withErrorCode:(NSInteger)code;

//  更新Dkey 和 sessionID的回调 （请尽量保证成功）
- (void)redpacketUpdateDkeyAndSessionID:(updateDkeyAndSessionIDBlock)updateBlock;

@end


#endif /* YZHRedpacketBridgeProtocol_h */
