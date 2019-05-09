//
//  BGOrderShopApi.h
//  ShaHaiZiT
//
//  Created by biao on 2018/12/27.
//  Copyright © 2018 biao. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface BGOrderShopApi : NSObject

/**
 确认订单,立即购买
 */
+ (void)firmOrder:(NSMutableDictionary *)param FirmType:(BOOL)isFirm succ:(processSuccResp)succBlock failure:(processfailedResp)failedBlock;

/**
 创建付款订单
 */
+ (void)createPayOrder:(NSMutableDictionary *)param succ:(processSuccResp)succBlock failure:(processfailedResp)failedBlock;

/**
 获取订单信息列表
 */
+ (void)getOrderList:(NSMutableDictionary *)param succ:(processSuccResp)succBlock failure:(processfailedResp)failedBlock;

/**
 获取订单详情
 */
+ (void)getOrderDetail:(NSMutableDictionary *)param succ:(processSuccResp)succBlock failure:(processfailedResp)failedBlock;

/**
 获取待支付订单详情
 */
+ (void)getOrderPayDetail:(NSMutableDictionary *)param succ:(processSuccResp)succBlock failure:(processfailedResp)failedBlock;

/**
 取消订单
 */
+ (void)cancelOrder:(NSMutableDictionary *)param succ:(processSuccResp)succBlock failure:(processfailedResp)failedBlock;

/**
 提醒发货
 */
+ (void)remindDelivery:(NSMutableDictionary *)param succ:(processSuccResp)succBlock failure:(processfailedResp)failedBlock;

/**
 确认收货
 */
+ (void)confirmReceived:(NSMutableDictionary *)param succ:(processSuccResp)succBlock failure:(processfailedResp)failedBlock;

/**
 提交售后信息
 */
+ (void)submitAfterSaleInfo:(NSMutableDictionary *)param succ:(processSuccResp)succBlock failure:(processfailedResp)failedBlock;

/**
 获取售后类型和原因
 */
+ (void)getAfterSaleTypeAndReason:(NSMutableDictionary *)param succ:(processSuccResp)succBlock failure:(processfailedResp)failedBlock;

/**
 获取售后详情
 */
+ (void)getAfterSaleDetail:(NSMutableDictionary *)param succ:(processSuccResp)succBlock failure:(processfailedResp)failedBlock;

/**
 获取服务详情
 */
+ (void)getAfterSaleServiceDetail:(NSMutableDictionary *)param succ:(processSuccResp)succBlock failure:(processfailedResp)failedBlock;

/**
 获取售后退款金额
 */
+ (void)getAfterSaleRefundMoney:(NSMutableDictionary *)param succ:(processSuccResp)succBlock failure:(processfailedResp)failedBlock;

/**
 支付订单 - 支付商城订单
 */
+ (void)payShopOrder:(NSMutableDictionary *)param succ:(processSuccResp)succBlock failure:(processfailedResp)failedBlock;

@end

NS_ASSUME_NONNULL_END
