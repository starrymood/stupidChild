//
//  BGOrderTravelApi.h
//  shzTravelC
//
//  Created by biao on 2018/8/25.
//  Copyright © 2018年 biao. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface BGOrderTravelApi : NSObject

/**
 获取订单信息列表
 */
+ (void)getOrderList:(NSMutableDictionary *)param succ:(processSuccResp)succBlock failure:(processfailedResp)failedBlock;

/**
 获取订单详情
 */
+ (void)getOrderDetail:(NSMutableDictionary *)param succ:(processSuccResp)succBlock failure:(processfailedResp)failedBlock;

/**
 商品评价 - 添加商品评价
 */
+ (void)addProductReview:(NSMutableDictionary *)param succ:(processSuccResp)succBlock failure:(processfailedResp)failedBlock;

/**
 商品评价 - 获取某商品的评价列表
 */
+ (void)getTCommentList:(NSMutableDictionary *)param succ:(processSuccResp)succBlock failure:(processfailedResp)failedBlock;

/**
 接机产品 - 用户填写接机预定信息
 */
+ (void)uploadPreInfo:(NSMutableDictionary *)param succ:(processSuccResp)succBlock failure:(processfailedResp)failedBlock;

/**
 接机产品 - 获取用户填写的需求信息
 */
+ (void)getRequirementInfoById:(NSMutableDictionary *)param succ:(processSuccResp)succBlock failure:(processfailedResp)failedBlock;

/**
 支付订单 - 创建订单
 */
+ (void)createOrderByProductId:(NSMutableDictionary *)param succ:(processSuccResp)succBlock failure:(processfailedResp)failedBlock;

/**
 支付订单 - 支付出行订单
 */
+ (void)payTravelOrder:(NSMutableDictionary *)param succ:(processSuccResp)succBlock failure:(processfailedResp)failedBlock;

/**
 用户填写私人定制单信息
 */
+ (void)uploadPrivateOrderInfo:(NSMutableDictionary *)param succ:(processSuccResp)succBlock failure:(processfailedResp)failedBlock;

/**
 用户确认签证已收货
 */
+ (void)confirmVisaReceived:(NSMutableDictionary *)param succ:(processSuccResp)succBlock failure:(processfailedResp)failedBlock;

@end
