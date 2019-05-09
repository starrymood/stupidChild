//
//  BGMemberApi.h
//  shzTravelC
//
//  Created by biao on 2018/6/2.
//  Copyright © 2018年 biao. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface BGMemberApi : NSObject

/**
 查询商品可用优惠券
 */
+ (void)getUseCouponList:(NSMutableDictionary *)param succ:(processSuccResp)succBlock failure:(processfailedResp)failedBlock;

/**
 获取优惠券列表
 */
+ (void)getCouponList:(NSMutableDictionary *)param succ:(processSuccResp)succBlock failure:(processfailedResp)failedBlock;

/**
 获取领券中心列表
 */
+ (void)getCenterCouponList:(NSMutableDictionary *)param succ:(processSuccResp)succBlock failure:(processfailedResp)failedBlock;

/**
 领取优惠券
 */
+ (void)getCouponAction:(NSMutableDictionary *)param succ:(processSuccResp)succBlock failure:(processfailedResp)failedBlock;

/**
 获取所有地区列表
 */
+ (void)getAllAddressList:(NSMutableDictionary *)param succ:(processSuccResp)succBlock failure:(processfailedResp)failedBlock;


/* ***************************** 分隔线 *****************************  */

/**
 获取七牛云Key
 */
+ (void)getQiniuKey:(NSMutableDictionary *)param succ:(processSuccResp)succBlock failure:(processfailedResp)failedBlock;

/**
 获取消息列表
 */
+ (void)getMessageList:(NSMutableDictionary *)param succ:(processSuccResp)succBlock failure:(processfailedResp)failedBlock;

/**
 获取系统消息首页
 */
+ (void)getSystemMessageHome:(NSMutableDictionary *)param succ:(processSuccResp)succBlock failure:(processfailedResp)failedBlock;

/**
 选中某条消息并设为已读
 */
+ (void)markTheMessageIsRead:(NSMutableDictionary *)param succ:(processSuccResp)succBlock failure:(processfailedResp)failedBlock;

/**
 获取系统消息
 */
+ (void)getSystemMessage:(NSMutableDictionary *)param succ:(processSuccResp)succBlock failure:(processfailedResp)failedBlock;

/**
 获取活动消息
 */
+ (void)getActivityMessage:(NSMutableDictionary *)param succ:(processSuccResp)succBlock failure:(processfailedResp)failedBlock;

/**
 获取社区消息
 */
+ (void)getCommunityMessage:(NSMutableDictionary *)param succ:(processSuccResp)succBlock failure:(processfailedResp)failedBlock;

/**
 确认领取佣金
 */
+ (void)confirmReceiveAction:(NSMutableDictionary *)param succ:(processSuccResp)succBlock failure:(processfailedResp)failedBlock;

@end
