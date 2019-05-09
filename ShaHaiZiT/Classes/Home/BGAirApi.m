//
//  BGAirApi.m
//  shzTravelC
//
//  Created by biao on 2018/8/20.
//  Copyright © 2018年 biao. All rights reserved.
//

#import "BGAirApi.h"

#define BGAirportGet(appendix) [NSString stringWithFormat:@"api/user/area/%@",appendix]
#define BGProductsPost(appendix) [NSString stringWithFormat:@"api/user/product/%@",appendix]
#define BGFavoritePost(appendix) [NSString stringWithFormat:@"api/user/collection/%@",appendix]
#define BGActivityPost(appendix) [NSString stringWithFormat:@"api/user/activity/%@",appendix]
#define BGCycleGet(appendix) [NSString stringWithFormat:@"api/user/banner/%@",appendix]
#define BGConsulateGet(appendix) [NSString stringWithFormat:@"api/user/consulate/%@",appendix]
#define BGTalentGet(appendix) [NSString stringWithFormat:@"/api/user/talent/%@",appendix]
#define BGTalentRecommendGet(appendix) [NSString stringWithFormat:@"/api/user/talent_recommend/%@",appendix]
#define BGMemoryGet(appendix) [NSString stringWithFormat:@"/api/user/memory/%@",appendix]
#define BGLandmarkGet(appendix) [NSString stringWithFormat:@"/api/user/landmark/%@",appendix]
#define BGAirCitysGet(appendix) [NSString stringWithFormat:@"/api/user/city_three_code/%@",appendix]
#define BGAirHotCitysGet(appendix) [NSString stringWithFormat:@"/api/user/city_three_code/%@",appendix]


@implementation BGAirApi

/**
 接机产品 - 通过机场的编号来获取产品信息
 */
+ (void)getProductInfoByAirId:(NSMutableDictionary *)param isCar:(BOOL)isCar succ:(processSuccResp)succBlock failure:(processfailedResp)failedBlock{
    
     NSString *url = isCar ? BGProductsPost(@"get-travel-product-by-region") : BGProductsPost(@"get-travel-product-by-airport");
    
    [WHAPIClient GET:url param:param tokenType:3 succ:^(NSDictionary *response) {
        if (succBlock) {
            succBlock(response);
        }
    } failure:^(NSDictionary *response) {
        if (failedBlock) {
            failedBlock(response);
        }
    }];
}

/**
 接机产品 - 通过产品编号获取车辆服务信息
 */
+ (void)getCarInfoById:(NSMutableDictionary *)param succ:(processSuccResp)succBlock failure:(processfailedResp)failedBlock{
    
    [WHAPIClient GET:BGProductsPost(@"get-travel-product-detail") param:param tokenType:1 succ:^(NSDictionary *response) {
        if (succBlock) {
            succBlock(response);
        }
    } failure:^(NSDictionary *response) {
        if (failedBlock) {
            failedBlock(response);
        }
    }];
}

/**
 精品线路 - 线路商品列表
 */
+ (void)getLineGoodsList:(NSMutableDictionary *)param succ:(processSuccResp)succBlock failure:(processfailedResp)failedBlock{
    
    [WHAPIClient GET:BGProductsPost(@"get-travel-product-by-region") param:param tokenType:3 succ:^(NSDictionary *response) {
        if (succBlock) {
            succBlock(response);
        }
    } failure:^(NSDictionary *response) {
        if (failedBlock) {
            failedBlock(response);
        }
    }];
}

/**
 搜索 - 获取某商品列表
 */
+ (void)searchAirCity:(NSMutableDictionary *)param category:(NSInteger)category succ:(processSuccResp)succBlock failure:(processfailedResp)failedBlock{
    
    NSString *url = (category<3) ? BGAirportGet(@"get-country-airport-by-name") : BGAirportGet(@"get-country-area-by-name");
    
    [WHAPIClient POST:url param:param tokenType:3 succ:^(NSDictionary *response) {
        if (succBlock) {
            succBlock(response);
        }
    } failure:^(NSDictionary *response) {
        if (failedBlock) {
            failedBlock(response);
        }
    }];
}

/**
 地区管理-查询洲与国家
 */
+ (void)getContinentList:(NSMutableDictionary *)param succ:(processSuccResp)succBlock failure:(processfailedResp)failedBlock{
    
    [WHAPIClient GET:BGAirportGet(@"get-continent-and-country") param:param tokenType:3 succ:^(NSDictionary *response) {
        if (succBlock) {
            succBlock(response);
        }
    } failure:^(NSDictionary *response) {
        if (failedBlock) {
            failedBlock(response);
        }
    }];
}

/**
 地区管理-通过父编号获取地区区域列表
 */
+ (void)getAreaListById:(NSMutableDictionary *)param succ:(processSuccResp)succBlock failure:(processfailedResp)failedBlock{
    
    [WHAPIClient GET:BGAirportGet(@"get-country-area-transfer") param:param tokenType:3 succ:^(NSDictionary *response) {
        if (succBlock) {
            succBlock(response);
        }
    } failure:^(NSDictionary *response) {
        if (failedBlock) {
            failedBlock(response);
        }
    }];
}

/**
 地区管理-获取地区区域详细信息
 */
+ (void)getAreaDetailInfo:(NSMutableDictionary *)param succ:(processSuccResp)succBlock failure:(processfailedResp)failedBlock{
    
    [WHAPIClient GET:BGAirportGet(@"get-recommend-airport") param:param tokenType:3 succ:^(NSDictionary *response) {
        if (succBlock) {
            succBlock(response);
        }
    } failure:^(NSDictionary *response) {
        if (failedBlock) {
            failedBlock(response);
        }
    }];
}

/**
 获取偏好列表
 */
+ (void)getPreferenceList:(NSMutableDictionary *)param succ:(processSuccResp)succBlock failure:(processfailedResp)failedBlock{
    
    [WHAPIClient GET:BGProductsPost(@"get-private-custom-product") param:param tokenType:3 succ:^(NSDictionary *response) {
        if (succBlock) {
            succBlock(response);
        }
    } failure:^(NSDictionary *response) {
        if (failedBlock) {
            failedBlock(response);
        }
    }];
}

/**
 添加或取消收藏
 */
+ (void)addAndCancelFavoriteAction:(NSMutableDictionary *)param succ:(processSuccResp)succBlock failure:(processfailedResp)failedBlock{
    
    [WHAPIClient POST:BGFavoritePost(@"add-or-cancel-collection") param:param tokenType:1 succ:^(NSDictionary *response) {
        if (succBlock) {
            succBlock(response);
        }
    } failure:^(NSDictionary *response) {
        if (failedBlock) {
            failedBlock(response);
        }
    }];
    
}

/**
 获取用户收藏列表
 */
+ (void)getUserCollectionList:(NSMutableDictionary *)param succ:(processSuccResp)succBlock failure:(processfailedResp)failedBlock{
    
    [WHAPIClient GET:BGFavoritePost(@"get-member-collection") param:param tokenType:1 succ:^(NSDictionary *response) {
        if (succBlock) {
            succBlock(response);
        }
    } failure:^(NSDictionary *response) {
        if (failedBlock) {
            failedBlock(response);
        }
    }];
    
}

/**
 活动 - 获取活动首页
 */
+ (void)getNewActivityInfo:(NSMutableDictionary *)param succ:(processSuccResp)succBlock failure:(processfailedResp)failedBlock{
    
    [WHAPIClient GET:BGActivityPost(@"get-processing-activity") param:nil tokenType:3 succ:^(NSDictionary *response) {
        if (succBlock) {
            succBlock(response);
        }
    } failure:^(NSDictionary *response) {
        if (failedBlock) {
            failedBlock(response);
        }
    }];
}

/**
 活动 - 活动列表
 */
+ (void)getActivityList:(NSMutableDictionary *)param type:(NSInteger)type succ:(processSuccResp)succBlock failure:(processfailedResp)failedBlock{
    
    int tokenType;
    NSString *url;
    if (type==1) {
        tokenType = 3;
        url = BGActivityPost(@"get-past-activity");
    }else{
        tokenType = 1;
        url = (type == 2)? BGActivityPost(@"get-member-registration-activity"):BGActivityPost(@"get-member-past-registration-activity");
    }
    
    [WHAPIClient GET:url param:param tokenType:tokenType succ:^(NSDictionary *response) {
        if (succBlock) {
            succBlock(response);
        }
    } failure:^(NSDictionary *response) {
        if (failedBlock) {
            failedBlock(response);
        }
    }];
}

/**
 获取领券中心的轮播图信息
 */
+ (void)getCouponCycleInfo:(NSMutableDictionary *)param succ:(processSuccResp)succBlock failure:(processfailedResp)failedBlock{
    
    [WHAPIClient GET:BGCycleGet(@"get-coupon-banner-list") param:param tokenType:3 succ:^(NSDictionary *response) {
        if (succBlock) {
            succBlock(response);
        }
    } failure:^(NSDictionary *response) {
        if (failedBlock) {
            failedBlock(response);
        }
    }];
}

/**
 获取精品线路的轮播图信息
 */
+ (void)getRouteCycleInfo:(NSMutableDictionary *)param succ:(processSuccResp)succBlock failure:(processfailedResp)failedBlock{
    
    [WHAPIClient GET:BGCycleGet(@"get-route-banner-list") param:param tokenType:3 succ:^(NSDictionary *response) {
        if (succBlock) {
            succBlock(response);
        }
    } failure:^(NSDictionary *response) {
        if (failedBlock) {
            failedBlock(response);
        }
    }];
}

/**
 获取推荐城市列表
 */
+ (void)getRecommendCityList:(NSMutableDictionary *)param succ:(processSuccResp)succBlock failure:(processfailedResp)failedBlock{
    
    [WHAPIClient GET:BGAirportGet(@"get-recommend-region") param:param tokenType:3 succ:^(NSDictionary *response) {
        if (succBlock) {
            succBlock(response);
        }
    } failure:^(NSDictionary *response) {
        if (failedBlock) {
            failedBlock(response);
        }
    }];
}

/**
 获取推荐国家列表
 */
+ (void)getRecommendCountryList:(NSMutableDictionary *)param succ:(processSuccResp)succBlock failure:(processfailedResp)failedBlock{
    
    [WHAPIClient GET:BGAirportGet(@"get-recommend-country") param:param tokenType:3 succ:^(NSDictionary *response) {
        if (succBlock) {
            succBlock(response);
        }
    } failure:^(NSDictionary *response) {
        if (failedBlock) {
            failedBlock(response);
        }
    }];
}

/**
 通过父编号获取国家区域列表
 */
+ (void)getCityListByRegionID:(NSMutableDictionary *)param succ:(processSuccResp)succBlock failure:(processfailedResp)failedBlock{
    
    [WHAPIClient GET:BGAirportGet(@"get-country-area-by-parentId") param:param tokenType:3 succ:^(NSDictionary *response) {
        if (succBlock) {
            succBlock(response);
        }
    } failure:^(NSDictionary *response) {
        if (failedBlock) {
            failedBlock(response);
        }
    }];
}

/**
 获取景点产品详细信息
 */
+ (void)getSpotInfoByID:(NSMutableDictionary *)param succ:(processSuccResp)succBlock failure:(processfailedResp)failedBlock{
    
    [WHAPIClient GET:BGProductsPost(@"get-scenic-spot-detail") param:param tokenType:3 succ:^(NSDictionary *response) {
        if (succBlock) {
            succBlock(response);
        }
    } failure:^(NSDictionary *response) {
        if (failedBlock) {
            failedBlock(response);
        }
    }];
}

/**
 获取签证列表信息
 */
+ (void)getVisaList:(NSMutableDictionary *)param succ:(processSuccResp)succBlock failure:(processfailedResp)failedBlock{
    
    [WHAPIClient GET:BGProductsPost(@"get-travel-product-by-country") param:param tokenType:3 succ:^(NSDictionary *response) {
        if (succBlock) {
            succBlock(response);
        }
    } failure:^(NSDictionary *response) {
        if (failedBlock) {
            failedBlock(response);
        }
    }];
}

/**
 获取国家领事馆说明
 */
+ (void)getConsulateInfo:(NSMutableDictionary *)param succ:(processSuccResp)succBlock failure:(processfailedResp)failedBlock{
    
    [WHAPIClient GET:BGConsulateGet(@"get-consulate-detail") param:param tokenType:3 succ:^(NSDictionary *response) {
        if (succBlock) {
            succBlock(response);
        }
    } failure:^(NSDictionary *response) {
        if (failedBlock) {
            failedBlock(response);
        }
    }];
}

/**
 获取更多达人列表
 */
+ (void)getLocalPersonList:(NSMutableDictionary *)param succ:(processSuccResp)succBlock failure:(processfailedResp)failedBlock{
    
    [WHAPIClient GET:BGTalentGet(@"get-talent-page") param:param tokenType:3 succ:^(NSDictionary *response) {
        if (succBlock) {
            succBlock(response);
        }
    } failure:^(NSDictionary *response) {
        if (failedBlock) {
            failedBlock(response);
        }
    }];
    
}

/**
 获取达人详细信息
 */
+ (void)getLocalPersonDetails:(NSMutableDictionary *)param succ:(processSuccResp)succBlock failure:(processfailedResp)failedBlock{
    
    [WHAPIClient GET:BGTalentGet(@"get-talent-detail") param:param tokenType:3 succ:^(NSDictionary *response) {
        if (succBlock) {
            succBlock(response);
        }
    } failure:^(NSDictionary *response) {
        if (failedBlock) {
            failedBlock(response);
        }
    }];
}

/**
 获取达人推荐最新的一条数据
 */
+ (void)getLocalPersonRecommendNew:(NSMutableDictionary *)param succ:(processSuccResp)succBlock failure:(processfailedResp)failedBlock{
    
    [WHAPIClient GET:BGTalentRecommendGet(@"get-recent-talent-recommend") param:param tokenType:3 succ:^(NSDictionary *response) {
        if (succBlock) {
            succBlock(response);
        }
    } failure:^(NSDictionary *response) {
        if (failedBlock) {
            failedBlock(response);
        }
    }];
}

/**
 获取达人推荐分页数据
 */
+ (void)getLocalPersonRecommendList:(NSMutableDictionary *)param succ:(processSuccResp)succBlock failure:(processfailedResp)failedBlock{
    
    [WHAPIClient GET:BGTalentRecommendGet(@"get-talent-recommend-page") param:param tokenType:3 succ:^(NSDictionary *response) {
        if (succBlock) {
            succBlock(response);
        }
    } failure:^(NSDictionary *response) {
        if (failedBlock) {
            failedBlock(response);
        }
    }];
}

/**
 获取当前达人的什么时候的记忆
 */
+ (void)getLocalPersonMemoryByYear:(NSMutableDictionary *)param succ:(processSuccResp)succBlock failure:(processfailedResp)failedBlock{
    
    [WHAPIClient GET:BGMemoryGet(@"get-recent-memory") param:param tokenType:3 succ:^(NSDictionary *response) {
        if (succBlock) {
            succBlock(response);
        }
    } failure:^(NSDictionary *response) {
        if (failedBlock) {
            failedBlock(response);
        }
    }];
}

/**
 获取旅游记忆分页数据
 */
+ (void)getLocalPersonMemoryList:(NSMutableDictionary *)param succ:(processSuccResp)succBlock failure:(processfailedResp)failedBlock{
    
    [WHAPIClient GET:BGMemoryGet(@"get-travel-memory-page") param:param tokenType:3 succ:^(NSDictionary *response) {
        if (succBlock) {
            succBlock(response);
        }
    } failure:^(NSDictionary *response) {
        if (failedBlock) {
            failedBlock(response);
        }
    }];
}

/**
 获取地标与美食列表
 */
+ (void)getFoodLocationList:(NSMutableDictionary *)param succ:(processSuccResp)succBlock failure:(processfailedResp)failedBlock{
    
    [WHAPIClient GET:BGLandmarkGet(@"get-landmark-page") param:param tokenType:3 succ:^(NSDictionary *response) {
        if (succBlock) {
            succBlock(response);
        }
    } failure:^(NSDictionary *response) {
        if (failedBlock) {
            failedBlock(response);
        }
    }];
    
}

/**
 获取地标与美食详情
 */
+ (void)getFoodLocationDetail:(NSMutableDictionary *)param succ:(processSuccResp)succBlock failure:(processfailedResp)failedBlock{
    
    [WHAPIClient GET:BGLandmarkGet(@"get-landmark-detail") param:param tokenType:3 succ:^(NSDictionary *response) {
        if (succBlock) {
            succBlock(response);
        }
    } failure:^(NSDictionary *response) {
        if (failedBlock) {
            failedBlock(response);
        }
    }];
}


+ (void)getAirFlyCityListsDetail:(NSMutableDictionary *)param Succ:(processSuccResp)successBlock failure:(processfailedResp)failureBlock {
    [WHAPIClient GET:BGAirCitysGet(@"get-city-three-code") param:param tokenType:3 succ:^(NSDictionary *response) {
        if (successBlock) {
            successBlock(response);
        }
    } failure:^(NSDictionary *response) {
        if (failureBlock) {
            failureBlock(response);
        }
    }];
}

+ (void)getAirFlyHotCityListsDetail:(NSMutableDictionary *)param Succ:(processSuccResp)successBlock failure:(processfailedResp)failureBlock {
    [WHAPIClient GET:BGAirCitysGet(@"get-hot-city") param:param tokenType:3 succ:^(NSDictionary *response) {
        if (successBlock) {
            successBlock(response);
        }
    } failure:^(NSDictionary *response) {
        if (failureBlock) {
            failureBlock(response);
        }
    }];
}


@end
