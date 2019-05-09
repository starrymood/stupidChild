//
//  BGShopApi.h
//  ShaHaiZiT
//
//  Created by biao on 2018/12/24.
//  Copyright © 2018 biao. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface BGShopApi : NSObject

/**
 获取首页数据
 */
+ (void)getHomePageInfo:(NSMutableDictionary *)param succ:(processSuccResp)succBlock failure:(processfailedResp)failedBlock;

/**
 获取首页商品
 */
+ (void)getHomeGoodsList:(NSMutableDictionary *)param succ:(processSuccResp)succBlock failure:(processfailedResp)failedBlock;

/**
 获取商品列表
 */
+ (void)getGoodsList:(NSMutableDictionary *)param succ:(processSuccResp)succBlock failure:(processfailedResp)failedBlock;

/**
 获取商品分类
 */
+ (void)getGoodsSort:(NSMutableDictionary *)param succ:(processSuccResp)succBlock failure:(processfailedResp)failedBlock;

/**
 获取收藏商品列表
 */
+ (void)getFavoriteList:(NSMutableDictionary *)param succ:(processSuccResp)succBlock failure:(processfailedResp)failedBlock;

/**
 获取商品详情
 */
+ (void)getGoodsDetails:(NSMutableDictionary *)param succ:(processSuccResp)succBlock failure:(processfailedResp)failedBlock;

/**
 获取店铺轮播图片
 */
+ (void)getShopHomeCycle:(NSMutableDictionary *)param succ:(processSuccResp)succBlock failure:(processfailedResp)failedBlock;

/**
 获取店铺要显示的商品
 */
+ (void)getShopHomeGoods:(NSMutableDictionary *)param succ:(processSuccResp)succBlock failure:(processfailedResp)failedBlock;

/**
 添加商品到购物车
 */
+ (void)addGoodsToCart:(NSMutableDictionary *)param succ:(processSuccResp)succBlock failure:(processfailedResp)failedBlock;

/**
 从购物车删除商品
 */
+ (void)deleteGoodsFromCart:(NSMutableDictionary *)param succ:(processSuccResp)succBlock failure:(processfailedResp)failedBlock;

/**
 更新购物车商品数量
 */
+ (void)updateGoodsNum:(NSMutableDictionary *)param succ:(processSuccResp)succBlock failure:(processfailedResp)failedBlock;

/**
 获取购物车商品列表
 */
+ (void)getCartGoodsList:(NSMutableDictionary *)param succ:(processSuccResp)succBlock failure:(processfailedResp)failedBlock;

/**
 获取评论列表
 */
+ (void)getCommentList:(NSMutableDictionary *)param succ:(processSuccResp)succBlock failure:(processfailedResp)failedBlock;

/**
 发表评论
 */
+ (void)postComment:(NSMutableDictionary *)param succ:(processSuccResp)succBlock failure:(processfailedResp)failedBlock;

/**
 获取收货地址列表
 */
+ (void)getAddressList:(NSMutableDictionary *)param succ:(processSuccResp)succBlock failure:(processfailedResp)failedBlock;

/**
 添加收货地址
 */
+ (void)addNewAddress:(NSMutableDictionary *)param succ:(processSuccResp)succBlock failure:(processfailedResp)failedBlock;

/**
 删除收货地址
 */
+ (void)deleteAddress:(NSMutableDictionary *)param succ:(processSuccResp)succBlock failure:(processfailedResp)failedBlock;

/**
 编辑收货地址
 */
+ (void)editAddress:(NSMutableDictionary *)param succ:(processSuccResp)succBlock failure:(processfailedResp)failedBlock;

/**
 设置默认收货地址
 */
+ (void)setDefaultAddress:(NSMutableDictionary *)param succ:(processSuccResp)succBlock failure:(processfailedResp)failedBlock;

/**
 获取默认收货地址
 */
+ (void)getDefaultAddress:(NSMutableDictionary *)param succ:(processSuccResp)succBlock failure:(processfailedResp)failedBlock;

/**
 获取砍价商品列表
 */
+ (void)getBargainList:(NSMutableDictionary *)param succ:(processSuccResp)succBlock failure:(processfailedResp)failedBlock;

/**
 获取砍价商品详情
 */
+ (void)getBargainDetail:(NSMutableDictionary *)param succ:(processSuccResp)succBlock failure:(processfailedResp)failedBlock;

/**
 获取砍价分享信息
 */
+ (void)getBargainShareInfo:(NSMutableDictionary *)param succ:(processSuccResp)succBlock failure:(processfailedResp)failedBlock;

@end

NS_ASSUME_NONNULL_END
