//
//  BGAirApi.h
//  shzTravelC
//
//  Created by biao on 2018/8/20.
//  Copyright © 2018年 biao. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface BGAirApi : NSObject

/**
 接机产品 - 通过机场的编号来获取产品信息
 */
+ (void)getProductInfoByAirId:(NSMutableDictionary *)param isCar:(BOOL)isCar succ:(processSuccResp)succBlock failure:(processfailedResp)failedBlock;

/**
 接机产品 - 通过产品编号获取车辆服务信息
 */
+ (void)getCarInfoById:(NSMutableDictionary *)param succ:(processSuccResp)succBlock failure:(processfailedResp)failedBlock;

/**
 精品线路 - 线路商品列表
 */
+ (void)getLineGoodsList:(NSMutableDictionary *)param succ:(processSuccResp)succBlock failure:(processfailedResp)failedBlock;

/**
 搜索 - 获取某商品列表
 */
+ (void)searchAirCity:(NSMutableDictionary *)param category:(NSInteger)category succ:(processSuccResp)succBlock failure:(processfailedResp)failedBlock;

/**
 地区管理-查询洲与国家
 */
+ (void)getContinentList:(NSMutableDictionary *)param succ:(processSuccResp)succBlock failure:(processfailedResp)failedBlock;

/**
 地区管理-通过父编号获取地区区域列表
 */
+ (void)getAreaListById:(NSMutableDictionary *)param succ:(processSuccResp)succBlock failure:(processfailedResp)failedBlock;
/**
 地区管理-获取地区区域详细信息
 */
+ (void)getAreaDetailInfo:(NSMutableDictionary *)param succ:(processSuccResp)succBlock failure:(processfailedResp)failedBlock;

/**
 获取偏好列表
 */
+ (void)getPreferenceList:(NSMutableDictionary *)param succ:(processSuccResp)succBlock failure:(processfailedResp)failedBlock;

/**
 添加或取消收藏
 */
+ (void)addAndCancelFavoriteAction:(NSMutableDictionary *)param succ:(processSuccResp)succBlock failure:(processfailedResp)failedBlock;

/**
 获取用户收藏列表
 */
+ (void)getUserCollectionList:(NSMutableDictionary *)param succ:(processSuccResp)succBlock failure:(processfailedResp)failedBlock;

/**
 活动 - 获取活动首页
 */
+ (void)getNewActivityInfo:(NSMutableDictionary *)param succ:(processSuccResp)succBlock failure:(processfailedResp)failedBlock;

/**
 活动 - 活动列表
 */
+ (void)getActivityList:(NSMutableDictionary *)param type:(NSInteger)type succ:(processSuccResp)succBlock failure:(processfailedResp)failedBlock;

/**
 获取领券中心的轮播图信息
 */
+ (void)getCouponCycleInfo:(NSMutableDictionary *)param succ:(processSuccResp)succBlock failure:(processfailedResp)failedBlock;

/**
 获取精品线路的轮播图信息
 */
+ (void)getRouteCycleInfo:(NSMutableDictionary *)param succ:(processSuccResp)succBlock failure:(processfailedResp)failedBlock;

/**
 获取推荐城市列表
 */
+ (void)getRecommendCityList:(NSMutableDictionary *)param succ:(processSuccResp)succBlock failure:(processfailedResp)failedBlock;

/**
 获取推荐国家列表
 */
+ (void)getRecommendCountryList:(NSMutableDictionary *)param succ:(processSuccResp)succBlock failure:(processfailedResp)failedBlock;

/**
 通过父编号获取国家区域列表
 */
+ (void)getCityListByRegionID:(NSMutableDictionary *)param succ:(processSuccResp)succBlock failure:(processfailedResp)failedBlock;

/**
 获取景点产品详细信息
 */
+ (void)getSpotInfoByID:(NSMutableDictionary *)param succ:(processSuccResp)succBlock failure:(processfailedResp)failedBlock;

/**
 获取签证列表信息
 */
+ (void)getVisaList:(NSMutableDictionary *)param succ:(processSuccResp)succBlock failure:(processfailedResp)failedBlock;

/**
 获取国家领事馆说明
 */
+ (void)getConsulateInfo:(NSMutableDictionary *)param succ:(processSuccResp)succBlock failure:(processfailedResp)failedBlock;

/**
 获取更多达人列表
 */
+ (void)getLocalPersonList:(NSMutableDictionary *)param succ:(processSuccResp)succBlock failure:(processfailedResp)failedBlock;

/**
 获取达人详细信息
 */
+ (void)getLocalPersonDetails:(NSMutableDictionary *)param succ:(processSuccResp)succBlock failure:(processfailedResp)failedBlock;

/**
 获取达人推荐最新的一条数据
 */
+ (void)getLocalPersonRecommendNew:(NSMutableDictionary *)param succ:(processSuccResp)succBlock failure:(processfailedResp)failedBlock;

/**
 获取达人推荐分页数据
 */
+ (void)getLocalPersonRecommendList:(NSMutableDictionary *)param succ:(processSuccResp)succBlock failure:(processfailedResp)failedBlock;

/**
 获取当前达人的什么时候的记忆
 */
+ (void)getLocalPersonMemoryByYear:(NSMutableDictionary *)param succ:(processSuccResp)succBlock failure:(processfailedResp)failedBlock;

/**
 获取旅游记忆分页数据
 */
+ (void)getLocalPersonMemoryList:(NSMutableDictionary *)param succ:(processSuccResp)succBlock failure:(processfailedResp)failedBlock;

/**
 获取地标与美食列表
 */
+ (void)getFoodLocationList:(NSMutableDictionary *)param succ:(processSuccResp)succBlock failure:(processfailedResp)failedBlock;

/**
 获取地标与美食详情
 */
+ (void)getFoodLocationDetail:(NSMutableDictionary *)param succ:(processSuccResp)succBlock failure:(processfailedResp)failedBlock;

/**
 获取机票模块城市列表
 @param param 参数
 */
+ (void)getAirFlyCityListsDetail:(NSMutableDictionary *)param Succ:(processSuccResp)successBlock failure:(processfailedResp)failureBlock;

/**
 获取机票模块中热门城市列表

 @param param 必要参数
 */
+ (void)getAirFlyHotCityListsDetail:(NSMutableDictionary *)param Succ:(processSuccResp)successBlock failure:(processfailedResp)failureBlock;

@end
