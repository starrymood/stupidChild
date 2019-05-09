//
//  AppDelegate.m
//  ShaHaiZiT
//
//  Created by biao on 2018/10/10.
//  Copyright © 2018年 biao. All rights reserved.
//

#import "AppDelegate.h"
#import "LaunchIntroductionView.h"
#import "BGTabBarController.h"
#import <RongIMKit/RongIMKit.h>
#import <UMCommon/UMCommon.h>
#import <UMShare/UMShare.h>
#import <UMAnalytics/MobClick.h>
#import <AlipaySDK/AlipaySDK.h>
#import "WXApi.h"
#import "AppDelegate+JPush.h"
#import "BGSystemApi.h"

@interface AppDelegate ()<WXApiDelegate,RCIMUserInfoDataSource,RCIMReceiveMessageDelegate,RCIMConnectionStatusDelegate>

@end

@implementation AppDelegate
-(BGTabBarController *)tabBarVC{
    if (!_tabBarVC) {
        _tabBarVC = BGTabBarController.new;
    }
    return _tabBarVC;
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    
    // 1. 注册``SonicURLProtocol``
    //    [NSURLProtocol registerClass:[SonicURLProtocol class]];
    // 2. 极光推送
    [self setJPush:application didFinishLaunchingWithOptions:launchOptions];
    // 3. 友盟分享和统计
    /* 设置友盟appkey */
#if DEBUG
    [UMConfigure initWithAppkey:UMENG_APPKEY channel:@"DEBUG"];
//    [UMConfigure setLogEnabled:YES];
#else
    [UMConfigure initWithAppkey:UMENG_APPKEY channel:@"App Store"];
    // 统计组件配置
    [MobClick setScenarioType:E_UM_NORMAL];
#endif
    
    
    //    [UMConfigure setLogEnabled:YES];
    // U-Share 平台设置
    [self configUSharePlatforms];
    // 4. 微信注册app
    [WXApi registerApp:WECHAT_AppIDprd];
    // 5. 初始化融云
    [[RCIM sharedRCIM] initWithAppKey:RongCloud_AppKey];
    [[RCIM sharedRCIM] setConnectionStatusDelegate:self];
    [Tool initHtmlRoot];
    
    if ([self valueForKeyJude:@"RCToken"]) {
        [BGSystemApi isLogin:nil succ:^(NSDictionary *response) {
            DLog(@"\n>>>[isLogin sucess]:%@",response);
            [self loginRongCloudWithToken:[self valueForKeyJude:@"RCToken"]];
        } failure:^(NSDictionary *response) {
            DLog(@"\n>>>[isLogin failure]:%@",response);
        }];
    }
    
    self.window = [[UIWindow alloc] initWithFrame:UIScreen.mainScreen.bounds];
    self.window.backgroundColor = [UIColor whiteColor];
    self.window.rootViewController = self.tabBarVC;
    [self.window makeKeyAndVisible];
    
    if (IS_iPhoneX) {
        [LaunchIntroductionView sharedWithImages:@[@"guideImagePage_X1",@"guideImagePage_X2",@"guideImagePage_X3",@"guideImagePage_X4",@"guideImagePage_X5",@"guideImagePage_X6"] buttonImage:@"bottom_experience" buttonFrame:CGRectMake((SCREEN_WIDTH-200)/2, SCREEN_HEIGHT-40-98-SafeAreaBottomHeight, 200, 40)];
    }else{
        [LaunchIntroductionView sharedWithImages:@[@"guideImagePage_1",@"guideImagePage_2",@"guideImagePage_3",@"guideImagePage_4",@"guideImagePage_5",@"guideImagePage_6"] buttonImage:@"bottom_experience" buttonFrame:CGRectMake((SCREEN_WIDTH-200)/2, SCREEN_HEIGHT-40-98, 200, 40)];
    }
    
    
    return YES;
}
/**
 友盟分享配置
 */
- (void)configUSharePlatforms {
    /* 设置微信的appKey和appSecret */
    [[UMSocialManager defaultManager] setPlaform:UMSocialPlatformType_WechatSession appKey:WECHAT_AppIDprd appSecret:WECHAT_Appsecretprd redirectURL:@"http://mobile.umeng.com/social"];
    /*设置QQ平台的appID*/
    [[UMSocialManager defaultManager] setPlaform:UMSocialPlatformType_QQ appKey:QQ_AppIDprd appSecret:QQ_AppKeyprd redirectURL:@"http://mobile.umeng.com/social"];
    /*设置新浪平台的appID*/
    [[UMSocialManager defaultManager] setPlaform:UMSocialPlatformType_Sina appKey:Sina_AppIDprd appSecret:Sina_AppKeyprd redirectURL:@"https://sns.whalecloud.com/sina2/callback"];
    
}
// NOTE: 9.0以后使用新API接口  // 成功回调
- (BOOL)application:(UIApplication *)app openURL:(NSURL *)url options:(NSDictionary<NSString*, id> *)options
{
    BOOL result = [[UMSocialManager defaultManager]  handleOpenURL:url options:options];
    if (!result) {
        // 其他如支付等SDK的回调
        if ([url.host isEqualToString:@"safepay"]) {
            //跳转支付宝钱包进行支付，处理支付结果
            [[AlipaySDK defaultService] processOrderWithPaymentResult:url standbyCallback:^(NSDictionary *resultDic) {
                NSString *codeStr = [resultDic objectForKey:@"resultStatus"];
                NSString *payResultStr;
                if (codeStr.intValue == 9000) {
                    [WHIndicatorView toast:@"支付结果：成功！"];
                    payResultStr = @"paySucess";
                    [[NSNotificationCenter defaultCenter] postNotificationName:@"AlipaySuccessNotification" object:payResultStr];
                    
                }else{
                    [WHIndicatorView toast:@"支付结果：失败！"];
                    payResultStr = @"payFail";
                    [[NSNotificationCenter defaultCenter] postNotificationName:@"AlipaySuccessNotification" object:payResultStr];
                }
            }];
            return YES;
        }
        if ([url.scheme isEqualToString:WECHAT_AppIDprd]) {
            return [WXApi handleOpenURL:url delegate:(id<WXApiDelegate>)self];
        }
    }
    
    return result;
}

/*! @brief 发送一个sendReq后，收到微信的回应
 *
 * 收到一个来自微信的处理结果。调用一次sendReq后会收到onResp。
 * 可能收到的处理结果有SendMessageToWXResp、SendAuthResp等。
 */
- (void)onResp:(BaseResp *)resp
{
    if ([resp isKindOfClass:[PayResp class]]) {
        //支付返回结果，实际支付结果需要去微信服务器端查询
        NSString *payResultStr;
        switch (resp.errCode) {
            case WXSuccess:{
                [WHIndicatorView toast:@"支付结果：成功！"];
                payResultStr = @"paySucess";
                [[NSNotificationCenter defaultCenter] postNotificationName:@"WeChatSuccessNotification" object:payResultStr];
            }
                break;
            default:
                [WHIndicatorView toast:@"支付结果：失败！"];
                payResultStr = @"payFail";
                [[NSNotificationCenter defaultCenter] postNotificationName:@"WeChatSuccessNotification" object:payResultStr];
                break;
        }
        //        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:strTitle message:strMsg delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
        //        [alert show];
        
    }
}

- (void)getUserInfoWithUserId:(NSString *)userId completion:(void (^)(RCUserInfo *userInfo))completion{
    
    // 所有的用户名 和 头像url 信息均需要通过自己的服务器去获取
    // 登录用户的id 请替换成自己的id
    
    dispatch_async(dispatch_get_main_queue(), ^{
        NSMutableDictionary *param = [NSMutableDictionary dictionary];
        [param setObject:userId forKey:@"userId"];
        [BGSystemApi getUserInfoByRCUserId:param succ:^(NSDictionary *response) {
            DLog(@"\n>>>[getUserInfoByRCUserId success]:%@",response);
            NSDictionary *dataDic = response[@"result"];
            RCUserInfo *user = [[RCUserInfo alloc]init];
            user.userId = userId ;
            user.name = BGdictSetObjectIsNil(dataDic[@"memberName"]);
            user.portraitUri = BGdictSetObjectIsNil(dataDic[@"face"]);
            completion(user);
        } failure:^(NSDictionary *response) {
            DLog(@"\n>>>[getUserInfoByRCUserId failure]:%@",response);
            // 返回除登录用户以外 其它聊天对象的信息
            // 注意 如果是通过服务器 获取用户信息 可以在 为获取前设置默认的返回值
            //  获取到返回值后 重新调用融云的接口刷新用户信息
            RCUserInfo *user = [[RCUserInfo alloc]init];
            NSString *path = @"http://img.shahaizhi.com/FniXklLSzzQ7GstH9BB1vcI_DrSm";
            //            NSString *path = [[NSBundle mainBundle] pathForResource:@"rongcloud_placeholder_img.png" ofType:nil];
            user.userId = userId ;
            user.name   = @"傻孩子客服" ;
            user.portraitUri = path ;
            completion(user);
        }];
        
    });
    
}
- (void)loginRongCloudWithToken:(NSString *)token{
    [[RCIM sharedRCIM] connectWithToken:token     success:^(NSString *userId) {
        DLog(@"登陆成功。当前登录的用户ID：%@", userId);
        [[RCIM sharedRCIM] setUserInfoDataSource:self];
        [[RCIM sharedRCIM] setReceiveMessageDelegate:self];
        [RCIM sharedRCIM].enablePersistentUserInfoCache = YES;
        
        BGSetUserDefaultObjectForKey(userId, @"RCUserId"); // 融云userId
        
        NSString *fullPath = [[NSHomeDirectory() stringByAppendingPathComponent:@"Documents"] stringByAppendingPathComponent:@"currentImage.png"];
        NSString *picUrl = fullPath;
        NSString *name = [self valueForKeyJude:@"UserNickname"] ?: @"我";
        RCUserInfo *user = [[RCUserInfo alloc]initWithUserId:userId name:name portrait:picUrl];
        [RCIM sharedRCIM].currentUserInfo = user;
        
    } error:^(RCConnectErrorCode status) {
        DLog(@"登陆的错误码为:%zd", status);

    } tokenIncorrect:^{
        //token过期或者不正确。
        //如果设置了token有效期并且token过期，请重新请求您的服务器获取新的token
        //如果没有设置token有效期却提示token错误，请检查您客户端和服务器的appkey是否匹配，还有检查您获取token的流程。
        //那么您需要请求您的服务器重新获取 Token 并调用 connectWithToken 来连接（但是注意避免无限循环，以免影响 App 用户体验
        DLog(@"token错误");
        [Tool logoutRongCloudAction];
    }];
}
-(void)onRCIMReceiveMessage:(RCMessage *)message left:(int)left{
    dispatch_async(dispatch_get_main_queue(), ^{
        [self setBadageNum];
    });
}
-(void)setBadageNum{
    
    int unreadMsgCount = [[RCIMClient sharedRCIMClient] getUnreadCount:@[@(ConversationType_PRIVATE),@(ConversationType_CUSTOMERSERVICE)]];
    // 设置tabbar 的icon
    UITabBarController *tabbar = (UITabBarController *)[UIApplication sharedApplication].keyWindow.rootViewController ;
    if ([tabbar isKindOfClass:[UITabBarController class]]) {
       [[NSNotificationCenter defaultCenter]postNotificationName:@"messageTipsAction" object:[NSString stringWithFormat:@"%d",unreadMsgCount]];
    }
}
- (void)onRCIMConnectionStatusChanged:(RCConnectionStatus)status{
    
    if (status == 6 || status == 31004 || status == 31011) {
        [WHIndicatorView toast:@"您的账号已在其他设备上登录"];
        [Tool logoutRongCloudAction];
    }
}

-(NSString *)valueForKeyJude:(NSString *)key{
    NSString *valueStr = [NSString stringWithFormat:@"%@", BGGetUserDefaultObjectForKey(key)];
    if ([Tool isBlankString:valueStr]) {
        return nil;
    }else{
        return valueStr;
    }
}
- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
}


- (void)applicationDidEnterBackground:(UIApplication *)application {
    
    [self JPushDidEnterBackground:application];
}


- (void)applicationWillEnterForeground:(UIApplication *)application {
    
    [self JPushWillEnterForeground:application];
}


- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}


- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}


@end
