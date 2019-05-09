//
//  BGPurseApi.m
//  shzTravelS
//
//  Created by 孙林茂 on 2018/5/26.
//  Copyright © 2018年 biao. All rights reserved.
//

#import "BGPurseApi.h"

#define BGPursePost(appendix) [NSString stringWithFormat:@"api/user/wallet/%@",appendix]
@implementation BGPurseApi

/**
 获取钱包余额
 */
+ (void)getPurseBalance:(NSMutableDictionary *)param succ:(processSuccResp)succBlock failure:(processfailedResp)failedBlock{
    
    [WHAPIClient GET:BGPursePost(@"get-member-account") param:param tokenType:1 succ:^(NSDictionary *response) {
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
 获取钱包账户明细
 */
+ (void)getPurseDetail:(NSMutableDictionary *)param succ:(processSuccResp)succBlock failure:(processfailedResp)failedBlock{
    
    [WHAPIClient GET:BGPursePost(@"get-member-account-detail") param:param tokenType:1 succ:^(NSDictionary *response) {
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
 提现
 */
+ (void)withDraw:(NSMutableDictionary *)param succ:(processSuccResp)succBlock failure:(processfailedResp)failedBlock{
    
    [WHAPIClient POST:BGPursePost(@"member-withdrawal") param:param tokenType:4 succ:^(NSDictionary *response) {
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
 获取银行卡列表
 */
+ (void)getBankCardList:(NSMutableDictionary *)param succ:(processSuccResp)succBlock failure:(processfailedResp)failedBlock{
    [WHAPIClient GET:BGPursePost(@"get-member-bank-list") param:param tokenType:1 succ:^(NSDictionary *response) {
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
 删除银行卡
 */
+ (void)deleteBankCard:(NSMutableDictionary *)param succ:(processSuccResp)succBlock failure:(processfailedResp)failedBlock{
    
    [WHAPIClient POST:BGPursePost(@"member-delete-bank") param:param tokenType:1 succ:^(NSDictionary *response) {
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
 获取默认银行卡
 */
+ (void)getDefaultBankCard:(NSMutableDictionary *)param succ:(processSuccResp)succBlock failure:(processfailedResp)failedBlock{
    
    [WHAPIClient GET:BGPursePost(@"get-default-member-bank") param:param tokenType:1 succ:^(NSDictionary *response) {
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
 设置默认银行卡
 */
+ (void)setDefaultBankCard:(NSMutableDictionary *)param succ:(processSuccResp)succBlock failure:(processfailedResp)failedBlock{
    
    [WHAPIClient POST:BGPursePost(@"update-member-bank-default") param:param tokenType:1 succ:^(NSDictionary *response) {
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
 添加银行卡
 */
+ (void)addBankCard:(NSMutableDictionary *)param succ:(processSuccResp)succBlock failure:(processfailedResp)failedBlock{
    
    [WHAPIClient POST:BGPursePost(@"add-member-bank") param:param tokenType:4 succ:^(NSDictionary *response) {
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
 获取银行列表
 */
+ (void)getBankNameList:(NSMutableDictionary *)param succ:(processSuccResp)succBlock failure:(processfailedResp)failedBlock{
    
    [WHAPIClient GET:BGPursePost(@"get-bank-list") param:param tokenType:3 succ:^(NSDictionary *response) {
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
 用户充值
 */
+ (void)rechargePay:(NSMutableDictionary *)param succ:(processSuccResp)succBlock failure:(processfailedResp)failedBlock{
    
    [WHAPIClient POST:BGPursePost(@"member-recharge") param:param tokenType:1 succ:^(NSDictionary *response) {
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
 获取佣金明细
 */
+ (void)getPurseCommissionDetail:(NSMutableDictionary *)param succ:(processSuccResp)succBlock failure:(processfailedResp)failedBlock{
    
    [WHAPIClient GET:BGPursePost(@"get-member-commission-details") param:param tokenType:1 succ:^(NSDictionary *response) {
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
