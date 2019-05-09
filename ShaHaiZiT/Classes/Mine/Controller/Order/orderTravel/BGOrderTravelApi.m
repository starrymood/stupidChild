//
//  BGOrderTravelApi.m
//  shzTravelC
//
//  Created by biao on 2018/8/25.
//  Copyright © 2018年 biao. All rights reserved.
//

#import "BGOrderTravelApi.h"

#define BGOrderPost(appendix) [NSString stringWithFormat:@"api/user/order/%@",appendix]
#define BGReviewPost(appendix) [NSString stringWithFormat:@"api/user/product/%@",appendix]
@implementation BGOrderTravelApi

/**
 获取订单信息列表
 */
+ (void)getOrderList:(NSMutableDictionary *)param succ:(processSuccResp)succBlock failure:(processfailedResp)failedBlock{
    
    [WHAPIClient GET:BGOrderPost(@"get-member-travel-order-page") param:param tokenType:1 succ:^(NSDictionary *response) {
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
 获取订单详情
 */
+ (void)getOrderDetail:(NSMutableDictionary *)param succ:(processSuccResp)succBlock failure:(processfailedResp)failedBlock{
    
    [WHAPIClient GET:BGOrderPost(@"get-member-home-order-detail") param:param tokenType:1 succ:^(NSDictionary *response) {
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
 商品评价 - 添加商品评价
 */
+ (void)addProductReview:(NSMutableDictionary *)param succ:(processSuccResp)succBlock failure:(processfailedResp)failedBlock{
    
    [WHAPIClient POST:BGOrderPost(@"add-product-review") param:param tokenType:4 succ:^(NSDictionary *response) {
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
 商品评价 - 获取某商品的评价列表
 */
+ (void)getTCommentList:(NSMutableDictionary *)param succ:(processSuccResp)succBlock failure:(processfailedResp)failedBlock{
    
    int tokenType = 3;
    if ([Tool isLogin]) {
        tokenType = 1;
    }
    [WHAPIClient GET:BGReviewPost(@"get-product-review-page") param:param tokenType:tokenType succ:^(NSDictionary *response) {
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
 接机产品 - 用户填写接机预定信息
 */
+ (void)uploadPreInfo:(NSMutableDictionary *)param succ:(processSuccResp)succBlock failure:(processfailedResp)failedBlock{
    
    [WHAPIClient POST:BGOrderPost(@"add-member-requirement") param:param tokenType:4 succ:^(NSDictionary *response) {
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
 接机产品 - 获取用户填写的需求信息
 */
+ (void)getRequirementInfoById:(NSMutableDictionary *)param succ:(processSuccResp)succBlock failure:(processfailedResp)failedBlock{
    
    [WHAPIClient GET:BGOrderPost(@"get-member-order-detail") param:param tokenType:1 succ:^(NSDictionary *response) {
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
 支付订单 - 创建订单
 */
+ (void)createOrderByProductId:(NSMutableDictionary *)param succ:(processSuccResp)succBlock failure:(processfailedResp)failedBlock{
    
    [WHAPIClient POST:BGOrderPost(@"create-member-order") param:param tokenType:1 succ:^(NSDictionary *response) {
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
 支付订单 - 支付出行订单
 */
+ (void)payTravelOrder:(NSMutableDictionary *)param succ:(processSuccResp)succBlock failure:(processfailedResp)failedBlock{
    
    [WHAPIClient POST:BGOrderPost(@"pay-order") param:param tokenType:1 succ:^(NSDictionary *response) {
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
 用户填写私人定制单信息
 */
+ (void)uploadPrivateOrderInfo:(NSMutableDictionary *)param succ:(processSuccResp)succBlock failure:(processfailedResp)failedBlock{
    
    [WHAPIClient POST:BGOrderPost(@"get-private-custom-product") param:param tokenType:1 succ:^(NSDictionary *response) {
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
 用户确认签证已收货
 */
+ (void)confirmVisaReceived:(NSMutableDictionary *)param succ:(processSuccResp)succBlock failure:(processfailedResp)failedBlock{
    
    [WHAPIClient POST:BGOrderPost(@"confirm-receipt") param:param tokenType:1 succ:^(NSDictionary *response) {
        if (succBlock) {
            succBlock(response);
        }
    } failure:^(NSDictionary *response) {
        if (failedBlock) {
            failedBlock(response);
        }
    }];
}

@end
