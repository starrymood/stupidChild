//
//  BGSystemApi.m
//  shzTravelS
//
//  Created by 孙林茂 on 2018/5/25.
//  Copyright © 2018年 biao. All rights reserved.
//

#import "BGSystemApi.h"
#import <RongIMKit/RongIMKit.h>

#define BGSystemPost(appendix) [NSString stringWithFormat:@"api/user/member/%@",appendix]

@implementation BGSystemApi
// tokenType:(int)type //1:token 2:refreshToken  3:noToken 4:needToJson

/**
 发送注册短信验证码
 */
+ (void)sendRegistSMSCode:(NSMutableDictionary *)param succ:(processSuccResp)succBlock failure:(processfailedResp)failedBlock{
    
    [WHAPIClient POST:BGSystemPost(@"send-register-code") param:param tokenType:3 succ:^(NSDictionary *response) {
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
 发送找回短信验证码
 */
+ (void)sendFindSMSCode:(NSMutableDictionary *)param succ:(processSuccResp)succBlock failure:(processfailedResp)failedBlock{
    [WHAPIClient POST:BGSystemPost(@"send-find-code") param:param tokenType:3 succ:^(NSDictionary *response) {
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
 注册账号
 */
+ (void)regist:(NSMutableDictionary *)param succ:(processSuccResp)succBlock failure:(processfailedResp)failedBlock{
    __block typeof(self) weakSelf = self;
    
    [WHAPIClient POST:BGSystemPost(@"mobile-register") param:param tokenType:3 succ:^(NSDictionary *response) {
        NSDictionary *dicData = response[@"result"];
        if (dicData.count!=0) {
            NSString *headImgStr = BGdictSetObjectIsNil(dicData[@"face"]);
            if (![Tool isBlankString:headImgStr]) {
                UIImage *headImage = [UIImage imageWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:headImgStr]]];
                [weakSelf saveImage:headImage withName:@"currentImage.png"];
            }
            
            [self saveLoginInfoDefaults:dicData];
            NSString *rongCloudStr =  BGdictSetObjectIsNil(dicData[@"rong_cloud"]);
            [[BGAppDelegateHelper delegate] loginRongCloudWithToken:rongCloudStr];
        }
        
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
 通过手机登录
 */
+ (void)LoginByPhone:(NSMutableDictionary *)param succ:(processSuccResp)succBlock failure:(processfailedResp)failedBlock{
    __block typeof(self) weakSelf = self;
    
    [WHAPIClient POST:BGSystemPost(@"login") param:param tokenType:3 succ:^(NSDictionary *response) {
        NSDictionary *dicData = response[@"result"];
        if (dicData.count!=0) {
            NSString *headImgStr = BGdictSetObjectIsNil(dicData[@"face"]);
            if (![Tool isBlankString:headImgStr]) {
                UIImage *headImage = [UIImage imageWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:headImgStr]]];
                [weakSelf saveImage:headImage withName:@"currentImage.png"];
            }
            
            [self saveLoginInfoDefaults:dicData];
            NSString *rongCloudStr =  BGdictSetObjectIsNil(dicData[@"rong_cloud"]);
            [[BGAppDelegateHelper delegate] loginRongCloudWithToken:rongCloudStr];
        }
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
 找回密码
 */
+ (void)retrievePassword:(NSMutableDictionary *)param succ:(processSuccResp)succBlock failure:(processfailedResp)failedBlock{
    [WHAPIClient POST:BGSystemPost(@"mobile-change-password") param:param tokenType:1 succ:^(NSDictionary *response) {
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
 通过第三方登录
 */
+ (void)loginByThird:(NSMutableDictionary *)param succ:(processSuccResp)succBlock failure:(processfailedResp)failedBlock{
    __block typeof(self) weakSelf = self;

    [WHAPIClient POST:BGSystemPost(@"third-login") param:param tokenType:3 succ:^(NSDictionary *response) {
        NSDictionary *dicData = response[@"result"];
        if (dicData.count!=0) {
            NSString *headImgStr = BGdictSetObjectIsNil(dicData[@"face"]);
            if (![Tool isBlankString:headImgStr]) {
                UIImage *headImage = [UIImage imageWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:headImgStr]]];
                [weakSelf saveImage:headImage withName:@"currentImage.png"];
            }
            
            [self saveLoginInfoDefaults:dicData];
            NSString *rongCloudStr =  BGdictSetObjectIsNil(dicData[@"rong_cloud"]);
            [[BGAppDelegateHelper delegate] loginRongCloudWithToken:rongCloudStr];
        }
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
 是否登录
 */
+ (void)isLogin:(NSMutableDictionary *)param succ:(processSuccResp)succBlock failure:(processfailedResp)failedBlock{
    [WHAPIClient GET:BGSystemPost(@"is-login") param:nil tokenType:1 succ:^(NSDictionary *response) {
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
 根据融云UserId获取头像和昵称
 */
+ (void)getUserInfoByRCUserId:(NSMutableDictionary *)param succ:(processSuccResp)succBlock failure:(processfailedResp)failedBlock{
    
    [WHAPIClient GET:BGSystemPost(@"get-rong-cloud-info") param:param tokenType:1 succ:^(NSDictionary *response) {
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
 获取第三方登录验证码
 */
+ (void)sendThirdSMSCode:(NSMutableDictionary *)param succ:(processSuccResp)succBlock failure:(processfailedResp)failedBlock{
    
    [WHAPIClient POST:BGSystemPost(@"third-code") param:param tokenType:3 succ:^(NSDictionary *response) {
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
 获取个人信息
 */
+ (void)getUserInfo:(NSMutableDictionary *)param succ:(processSuccResp)succBlock failure:(processfailedResp)failedBlock{
    
    [WHAPIClient GET:BGSystemPost(@"info") param:param tokenType:1 succ:^(NSDictionary *response) {
        NSDictionary *dicData = response[@"result"];
        if (dicData.count!=0) {
            [self saveUserInfoDefaults:dicData];
        }
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
 修改个人信息
 */
+ (void)modifyUserInfo:(NSMutableDictionary *)param succ:(processSuccResp)succBlock failure:(processfailedResp)failedBlock{
    
    [WHAPIClient POST:BGSystemPost(@"save") param:param tokenType:1 succ:^(NSDictionary *response) {
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
 提交意见反馈
 */
+ (void)submitFeedback:(NSMutableDictionary *)param succ:(processSuccResp)succBlock failure:(processfailedResp)failedBlock{
    [WHAPIClient POST:BGSystemPost(@"add-advice") param:param tokenType:4 succ:^(NSDictionary *response) {
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
 获取用户海淘实名认证信息
 */
+ (void)getVerifyInfo:(NSMutableDictionary *)param succ:(processSuccResp)succBlock failure:(processfailedResp)failedBlock{
    
    [WHAPIClient GET:BGSystemPost(@"get-member-verified") param:param tokenType:1 succ:^(NSDictionary *response) {
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
 提交用户海淘实名认证信息
 */
+ (void)uploadVerifyInfo:(NSMutableDictionary *)param succ:(processSuccResp)succBlock failure:(processfailedResp)failedBlock{
    
    [WHAPIClient POST:BGSystemPost(@"add-member-verified") param:param tokenType:1 succ:^(NSDictionary *response) {
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
 获取我的推荐人列表
 */
+ (void)getMyRecommendList:(NSMutableDictionary *)param succ:(processSuccResp)succBlock failure:(processfailedResp)failedBlock{
    
    [WHAPIClient GET:BGSystemPost(@"get-invite-member-page") param:param tokenType:1 succ:^(NSDictionary *response) {
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
 获取未读消息数目
 */
+ (void)getMsgUnreadNum:(NSMutableDictionary *)param succ:(processSuccResp)succBlock failure:(processfailedResp)failedBlock{
    
    [WHAPIClient GET:@"/api/user/member/get-member-no-read-news" param:param tokenType:1 succ:^(NSDictionary *response) {
       [[NSNotificationCenter defaultCenter]postNotificationName:@"messageTipsActionOne" object:[NSString stringWithFormat:@"%@",BGdictSetObjectIsNil(response[@"result"][@"community_news"])]];
         [[NSNotificationCenter defaultCenter]postNotificationName:@"messageTipsActionTwo" object:[NSString stringWithFormat:@"%@",BGdictSetObjectIsNil(response[@"result"][@"activity_news"])]];
         [[NSNotificationCenter defaultCenter]postNotificationName:@"messageTipsActionThree" object:[NSString stringWithFormat:@"%@",BGdictSetObjectIsNil(response[@"result"][@"person_news"])]];
//        [[NSNotificationCenter defaultCenter]postNotificationName:@"messageTipsActionOne" object:@"2"];
//        [[NSNotificationCenter defaultCenter]postNotificationName:@"messageTipsActionTwo" object:@"3"];
//        [[NSNotificationCenter defaultCenter]postNotificationName:@"messageTipsActionThree" object:@"4"];
        
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
 保存图片到本地
 */
+ (void)saveImage:(UIImage *)currentImage withName:(NSString *)imageName{
    
    NSData *imgData = [self compressImage:currentImage toMaxFileSize:1000*1024];
    // 获取沙盒目录
    NSString *fullPath = [[NSHomeDirectory() stringByAppendingPathComponent:@"Documents"] stringByAppendingPathComponent:imageName];
    // 将图片写入文件
    [imgData writeToFile:fullPath atomically:NO];
}

/**
 裁剪图片
 */
+ (NSData *)compressImage:(UIImage *)image toMaxFileSize:(NSInteger)maxFileSize {
    CGFloat compression = 0.9f;
    CGFloat maxCompression = 0.1f;
    NSData *imageData = UIImageJPEGRepresentation(image, compression);
    while ([imageData length] > maxFileSize && compression > maxCompression) {
        compression -= 0.1;
        imageData = UIImageJPEGRepresentation(image, compression);
    }
    return imageData;
}

/**
 保存登录信息
 */
+ (void)saveLoginInfoDefaults:(NSDictionary *)loginData {
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setObject:BGdictSetObjectIsNil(loginData[@"token"]) forKey:@"Token"];//token
    [defaults setObject:BGdictSetObjectIsNil(loginData[@"rong_cloud"]) forKey:@"RCToken"];//融云token
    [defaults setObject:BGdictSetObjectIsNil(loginData[@"invite_code"]) forKey:@"inviteCode"];//邀请码
    [defaults setObject:BGdictSetObjectIsNil(loginData[@"shz"]) forKey:@"UserSHZ"];           //傻孩子账号

    [defaults synchronize];
    
    
    [self getUserInfo:nil succ:^(NSDictionary *response) {
         DLog(@"\n>>>[getUserInfo sucess]:%@",response);
    } failure:^(NSDictionary *response) {
         DLog(@"\n>>>[getUserInfo failure]:%@",response);
    }];
}

/**
 保存用户信息
 */
+ (void)saveUserInfoDefaults:(NSDictionary *)loginData {
    [self getMsgUnreadNum:nil succ:^(NSDictionary *response) {
        DLog(@"\n>>>[getMsgUnreadNum sucess]:%@",response);
       
    } failure:^(NSDictionary *response) {
        DLog(@"\n>>>[getMsgUnreadNum failure]:%@",response);
    }];
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
//    [defaults setObject:BGdictSetObjectIsNil(loginData[@"nick_name"]) forKey:@"UserNickname"];//用户昵称
    [defaults setObject:BGdictSetObjectIsNil(loginData[@"sex"]) forKey:@"UserSex"];//用户性别
    [defaults setObject:BGdictSetObjectIsNil(loginData[@"birthday"]) forKey:@"UserBDay"];//用户生日
    

   
    [defaults setObject:[NSString stringWithFormat:@"%@%@%@",BGdictSetObjectIsNil(loginData[@"province"]),BGdictSetObjectIsNil(loginData[@"city"]),BGdictSetObjectIsNil(loginData[@"region"])] forKey:@"UserArea"];//用户地址
    
    
    [defaults setObject:BGdictSetObjectIsNil(loginData[@"shz"]) forKey:@"UserSHZ"];           //傻孩子账号
    [defaults setObject:BGdictSetObjectIsNil(loginData[@"level_id"]) forKey:@"UserLevelID"];  //用户等级id
    [defaults setObject:BGdictSetObjectIsNil(loginData[@"mobile"]) forKey:@"UserMobile"];     //用户手机号
    [defaults setObject:BGdictSetObjectIsNil(loginData[@"level_id"]) forKey:@"UserLevel"];       //用户等级
    [defaults setObject:BGdictSetObjectIsNil(loginData[@"nickname"]) forKey:@"UserNickname"]; //用户昵称
    [defaults setObject:BGdictSetObjectIsNil(loginData[@"concern_count"]) forKey:@"UserConcern"];//关注
    [defaults setObject:BGdictSetObjectIsNil(loginData[@"fans_count"]) forKey:@"UserFans"];//粉丝
    [defaults setObject:BGdictSetObjectIsNil(loginData[@"collected_count"]) forKey:@"UserCollected"];//被收藏
    [defaults setObject:BGdictSetObjectIsNil(loginData[@"liked_count"]) forKey:@"UserLike"];//点赞
//    [defaults setObject:BGdictSetObjectIsNil(loginData[@"invite_code"]) forKey:@"inviteCode"];//邀请码
    [defaults setObject:BGdictSetObjectIsNil(loginData[@"signature"]) forKey:@"UserSignature"];//用户简介
    [defaults setObject:BGdictSetObjectIsNil(loginData[@"coupon_count"]) forKey:@"UserCoupon"];//优惠券数目
    [defaults setObject:BGdictSetObjectIsNil(loginData[@"pending_payment_count"]) forKey:@"OrderStatus1"];//待付款
    [defaults setObject:BGdictSetObjectIsNil(loginData[@"processing_count"]) forKey:@"OrderStatus2"];//进行中
    [defaults setObject:BGdictSetObjectIsNil(loginData[@"comment_count"]) forKey:@"OrderStatus3"];//待评价
    [defaults setObject:BGdictSetObjectIsNil(loginData[@"integral"]) forKey:@"UserIntegral"];//积分
    [defaults setObject:BGdictSetObjectIsNil(loginData[@"recommended_count"]) forKey:@"UserInviteCount"];//邀请人数
    [defaults synchronize];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"ChangeNickNameAndId" object:nil];
   
}

@end
