//
//  BGPurseApi.h
//  shzTravelS
//
//  Created by 孙林茂 on 2018/5/26.
//  Copyright © 2018年 biao. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface BGPurseApi : NSObject

/**
 获取钱包余额
 */
+ (void)getPurseBalance:(NSMutableDictionary *)param succ:(processSuccResp)succBlock failure:(processfailedResp)failedBlock;

/**
 获取钱包账户明细
 */
+ (void)getPurseDetail:(NSMutableDictionary *)param succ:(processSuccResp)succBlock failure:(processfailedResp)failedBlock;

/**
 提现
 */
+ (void)withDraw:(NSMutableDictionary *)param succ:(processSuccResp)succBlock failure:(processfailedResp)failedBlock;

/**
 获取银行卡列表
 */
+ (void)getBankCardList:(NSMutableDictionary *)param succ:(processSuccResp)succBlock failure:(processfailedResp)failedBlock;

/**
 删除银行卡
 */
+ (void)deleteBankCard:(NSMutableDictionary *)param succ:(processSuccResp)succBlock failure:(processfailedResp)failedBlock;

/**
 获取默认银行卡
 */
+ (void)getDefaultBankCard:(NSMutableDictionary *)param succ:(processSuccResp)succBlock failure:(processfailedResp)failedBlock;

/**
 设置默认银行卡
 */
+ (void)setDefaultBankCard:(NSMutableDictionary *)param succ:(processSuccResp)succBlock failure:(processfailedResp)failedBlock;

/**
 添加银行卡
 */
+ (void)addBankCard:(NSMutableDictionary *)param succ:(processSuccResp)succBlock failure:(processfailedResp)failedBlock;

/**
 获取银行列表
 */
+ (void)getBankNameList:(NSMutableDictionary *)param succ:(processSuccResp)succBlock failure:(processfailedResp)failedBlock;

/**
 用户充值
 */
+ (void)rechargePay:(NSMutableDictionary *)param succ:(processSuccResp)succBlock failure:(processfailedResp)failedBlock;

/**
 获取佣金明细
 */
+ (void)getPurseCommissionDetail:(NSMutableDictionary *)param succ:(processSuccResp)succBlock failure:(processfailedResp)failedBlock;

@end
