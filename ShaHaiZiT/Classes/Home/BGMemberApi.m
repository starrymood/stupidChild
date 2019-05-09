//
//  BGMemberApi.m
//  shzTravelC
//
//  Created by biao on 2018/6/2.
//  Copyright © 2018年 biao. All rights reserved.
//

#import "BGMemberApi.h"

#define BGCouponGet(appendix) [NSString stringWithFormat:@"api/user/coupon/%@",appendix]
#define BGAddressPost(appendix) [NSString stringWithFormat:@"api/user/address/%@",appendix]
#define BGMemberNewsPost(appendix) [NSString stringWithFormat:@"api/user/news/%@",appendix]
#define BGTravelPost(appendix) [NSString stringWithFormat:@"api/user/qiniu/%@",appendix]

@implementation BGMemberApi

/**
 查询商品可用优惠券
 */
+ (void)getUseCouponList:(NSMutableDictionary *)param succ:(processSuccResp)succBlock failure:(processfailedResp)failedBlock{
    
    [WHAPIClient GET:BGCouponGet(@"get-member-unused-coupon-by-busness") param:param tokenType:1 succ:^(NSDictionary *response) {
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
 获取优惠券列表
 */
+ (void)getCouponList:(NSMutableDictionary *)param succ:(processSuccResp)succBlock failure:(processfailedResp)failedBlock{
    
    [WHAPIClient GET:BGCouponGet(@"get-member-coupon-page") param:param tokenType:1 succ:^(NSDictionary *response) {
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
 获取领券中心列表
 */
+ (void)getCenterCouponList:(NSMutableDictionary *)param succ:(processSuccResp)succBlock failure:(processfailedResp)failedBlock{
    
    [WHAPIClient GET:BGCouponGet(@"get-coupon-center") param:param tokenType:1 succ:^(NSDictionary *response) {
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
 领取优惠券
 */
+ (void)getCouponAction:(NSMutableDictionary *)param succ:(processSuccResp)succBlock failure:(processfailedResp)failedBlock{
    
    [WHAPIClient GET:BGCouponGet(@"member-collect-coupons") param:param tokenType:1 succ:^(NSDictionary *response) {
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
 获取所有地区列表
 */
+ (void)getAllAddressList:(NSMutableDictionary *)param succ:(processSuccResp)succBlock failure:(processfailedResp)failedBlock{
    
    [WHAPIClient GET:BGAddressPost(@"get-address-parent") param:param tokenType:3 succ:^(NSDictionary *response) {
        if (succBlock) {
            succBlock(response);
        }
    } failure:^(NSDictionary *response) {
        if (failedBlock) {
            failedBlock(response);
        }
    }];
}
/* ***************************** 分隔线 *****************************  */

/**
 获取七牛云Key
 */
+ (void)getQiniuKey:(NSMutableDictionary *)param succ:(processSuccResp)succBlock failure:(processfailedResp)failedBlock{
    
    [WHAPIClient GET:BGTravelPost(@"get-qiniu-key") param:param tokenType:1 succ:^(NSDictionary *response) {
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
 获取消息列表
 */
+ (void)getMessageList:(NSMutableDictionary *)param succ:(processSuccResp)succBlock failure:(processfailedResp)failedBlock{
    
    [WHAPIClient POST:BGMemberNewsPost(@"get-news-by-title") param:param tokenType:1 succ:^(NSDictionary *response) {
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
 获取系统消息首页
 */
+ (void)getSystemMessageHome:(NSMutableDictionary *)param succ:(processSuccResp)succBlock failure:(processfailedResp)failedBlock{
    
    [WHAPIClient GET:BGMemberNewsPost(@"get-member-news-type") param:param tokenType:1 succ:^(NSDictionary *response) {
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
 选中某条消息并设为已读
 */
+ (void)markTheMessageIsRead:(NSMutableDictionary *)param succ:(processSuccResp)succBlock failure:(processfailedResp)failedBlock{
    
    [WHAPIClient GET:BGMemberNewsPost(@"read-news") param:param tokenType:1 succ:^(NSDictionary *response) {
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
 获取系统消息
 */
+ (void)getSystemMessage:(NSMutableDictionary *)param succ:(processSuccResp)succBlock failure:(processfailedResp)failedBlock{
    
    [WHAPIClient GET:@"/api/user/person_news/get-member-person-news" param:param tokenType:1 succ:^(NSDictionary *response) {
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
 获取活动消息
 */
+ (void)getActivityMessage:(NSMutableDictionary *)param succ:(processSuccResp)succBlock failure:(processfailedResp)failedBlock{
    
    [WHAPIClient GET:@"/api/user/activity_news/get-member-activity-news" param:param tokenType:1 succ:^(NSDictionary *response) {
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
 获取社区消息
 */
+ (void)getCommunityMessage:(NSMutableDictionary *)param succ:(processSuccResp)succBlock failure:(processfailedResp)failedBlock{
    
    [WHAPIClient GET:@"/api/user/community_news/get-member-community-news" param:param tokenType:1 succ:^(NSDictionary *response) {
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
 确认领取佣金
 */
+ (void)confirmReceiveAction:(NSMutableDictionary *)param succ:(processSuccResp)succBlock failure:(processfailedResp)failedBlock{
    
    [WHAPIClient POST:@"/api/user/person_news/confirm-receive" param:param tokenType:1 succ:^(NSDictionary *response) {
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
