//
//  BGSystemApi.h
//  shzTravelS
//
//  Created by 孙林茂 on 2018/5/25.
//  Copyright © 2018年 biao. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface BGSystemApi : NSObject

/**
 发送注册短信验证码
 */
+ (void)sendRegistSMSCode:(NSMutableDictionary *)param succ:(processSuccResp)succBlock failure:(processfailedResp)failedBlock;

/**
 发送找回短信验证码
 */
+ (void)sendFindSMSCode:(NSMutableDictionary *)param succ:(processSuccResp)succBlock failure:(processfailedResp)failedBlock;

/**
 注册账号
 */
+ (void)regist:(NSMutableDictionary *)param succ:(processSuccResp)succBlock failure:(processfailedResp)failedBlock;

/**
 通过手机登录
 */
+ (void)LoginByPhone:(NSMutableDictionary *)param succ:(processSuccResp)succBlock failure:(processfailedResp)failedBlock;

/**
 找回密码
 */
+ (void)retrievePassword:(NSMutableDictionary *)param succ:(processSuccResp)succBlock failure:(processfailedResp)failedBlock;

/**
 通过第三方登录
 */
+ (void)loginByThird:(NSMutableDictionary *)param succ:(processSuccResp)succBlock failure:(processfailedResp)failedBlock;

/**
 是否登录
 */
+ (void)isLogin:(NSMutableDictionary *)param succ:(processSuccResp)succBlock failure:(processfailedResp)failedBlock;

/**
 根据融云UserId获取头像和昵称
 */
+ (void)getUserInfoByRCUserId:(NSMutableDictionary *)param succ:(processSuccResp)succBlock failure:(processfailedResp)failedBlock;

/**
 获取第三方登录验证码
 */
+ (void)sendThirdSMSCode:(NSMutableDictionary *)param succ:(processSuccResp)succBlock failure:(processfailedResp)failedBlock;

/**
 获取个人信息
 */
+ (void)getUserInfo:(NSMutableDictionary *)param succ:(processSuccResp)succBlock failure:(processfailedResp)failedBlock;

/**
 修改个人信息
 */
+ (void)modifyUserInfo:(NSMutableDictionary *)param succ:(processSuccResp)succBlock failure:(processfailedResp)failedBlock;

/**
 提交意见反馈
 */
+ (void)submitFeedback:(NSMutableDictionary *)param succ:(processSuccResp)succBlock failure:(processfailedResp)failedBlock;

/**
 获取用户海淘实名认证信息
 */
+ (void)getVerifyInfo:(NSMutableDictionary *)param succ:(processSuccResp)succBlock failure:(processfailedResp)failedBlock;

/**
 提交用户海淘实名认证信息
 */
+ (void)uploadVerifyInfo:(NSMutableDictionary *)param succ:(processSuccResp)succBlock failure:(processfailedResp)failedBlock;

/**
 获取我的推荐人列表
 */
+ (void)getMyRecommendList:(NSMutableDictionary *)param succ:(processSuccResp)succBlock failure:(processfailedResp)failedBlock;

/**
 获取未读消息数目
 */
+ (void)getMsgUnreadNum:(NSMutableDictionary *)param succ:(processSuccResp)succBlock failure:(processfailedResp)failedBlock;

@end
