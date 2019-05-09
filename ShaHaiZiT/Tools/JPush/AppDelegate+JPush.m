//
//  AppDelegate+JPush.m
//  shahaizic
//
//  Created by 孙林茂 on 2018/3/22.
//  Copyright © 2018年 樱兰网络. All rights reserved.
//

#import "AppDelegate+JPush.h"
#import "TXAlertView.h"
#import <RongIMKit/RongIMKit.h>

#define isIOS10 ([[UIDevice currentDevice].systemVersion floatValue] >= 10.0)
#define isIOS8 ([[UIDevice currentDevice].systemVersion floatValue] >= 8.0)

typedef NS_ENUM(NSInteger,JPushType) {
    JPushTypeText = 1,//推送消息类型
    JPushTypeURL  = 2,
    RongCloudText = 3,
};

@implementation AppDelegate (JPush)

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"  #set#
- (void)setJPush:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions{
    if (isIOS10) {
        JPUSHRegisterEntity * entity = [[JPUSHRegisterEntity alloc] init];
        entity.types = UNAuthorizationOptionAlert|UNAuthorizationOptionBadge|UNAuthorizationOptionSound;
        [JPUSHService registerForRemoteNotificationConfig:entity delegate:self];
    }else if (isIOS8) {
        //可以添加自定义categories
        [JPUSHService registerForRemoteNotificationTypes:(UIUserNotificationTypeBadge |
                                                          UIUserNotificationTypeSound |
                                                          UIUserNotificationTypeAlert)
                                              categories:nil];
    }
    BOOL isProduction;
    NSString *channel;
#if DEBUG
    isProduction = NO;
    channel = @"App Hoc";
#else
    isProduction = YES;
    channel = @"App Store";
#endif
    //如不需要使用IDFA，advertisingIdentifier 可为nil
    [JPUSHService setupWithOption:launchOptions appKey:JPUSH_APPKEY
                          channel:channel
                 apsForProduction:isProduction
            advertisingIdentifier:nil];
    [JPUSHService setLogOFF];
  
    //iOS 10以下 ios 7以上程序杀死的时候点击收到的通知进行的跳转操作
    if (launchOptions && !isIOS10){
        NSDictionary *pushDict = launchOptions[UIApplicationLaunchOptionsRemoteNotificationKey];
        [self handleNotification:pushDict];

    }
}

#pragma clang diagnostic pop

#pragma mark 极光推送的代理的方法 #注册#
- (void)application:(UIApplication *)application
didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken {
    [JPUSHService registerDeviceToken:deviceToken];
    NSString *token =
    [[[[deviceToken description] stringByReplacingOccurrencesOfString:@"<"
                                                           withString:@""]
      stringByReplacingOccurrencesOfString:@">"
      withString:@""]
     stringByReplacingOccurrencesOfString:@" "
     withString:@""];
    
    [[RCIMClient sharedRCIMClient] setDeviceToken:token];
}

//ios 7以上 iOS10 以下处理前台和后台通知的做法
- (void)application:(UIApplication *)application
didReceiveRemoteNotification:(NSDictionary *)userInfo
fetchCompletionHandler:
(void (^)(UIBackgroundFetchResult))completionHandler {
    [JPUSHService handleRemoteNotification:userInfo];

   //前台与后台的处理
    if (application.applicationState == UIApplicationStateActive) {
       
        __weak __typeof(&*self)weakSelf = self;
        [TXAlertView showAlertWithTitle:@"收到一条消息" message:userInfo[@"aps"][@"alert"] cancelButtonTitle:@"好的" style:TXAlertViewStyleAlert buttonIndexBlock:^(NSInteger buttonIndex) {
            if (buttonIndex == 1) {
                [weakSelf handleNotification:userInfo];
            }
        } otherButtonTitles:@"去看看", nil];
    }else{
        //当程序在后台运行的时候处理的通知
        [self handleNotification:userInfo];
    }
   
    completionHandler(UIBackgroundFetchResultNewData);
}


#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
//ios 10程序在前台收到通知处理  #ios11前台收到消息#
- (void)jpushNotificationCenter:(UNUserNotificationCenter *)center willPresentNotification:(UNNotification *)notification withCompletionHandler:(void (^)(NSInteger))completionHandler {
    NSDictionary * userInfo = notification.request.content.userInfo;
   
    if([notification.request.trigger isKindOfClass:[UNPushNotificationTrigger class]]) {
        
            [JPUSHService handleRemoteNotification:userInfo];

        //ios 10前台获取推送消息内容
        //前台收到消息直接对消息处理 不点击
        DLog(@"\n>>>jpush通知");

    }else {
        // 判断为本地通知
        DLog(@"\n>>>本地通知");
        
    }
    
    completionHandler(UNNotificationPresentationOptionBadge|UNNotificationPresentationOptionSound|UNNotificationPresentationOptionAlert); // 需要执行这个方法，选择是否提醒用户，有Badge、Sound、Alert三种类型可以设置
}

//ios 10在这里处理通知点击跳转  #应用打开时提醒#
- (void)jpushNotificationCenter:(UNUserNotificationCenter *)center didReceiveNotificationResponse:(UNNotificationResponse *)response withCompletionHandler:(void (^)(void))completionHandler {
    NSDictionary * userInfo = response.notification.request.content.userInfo;
    if([response.notification.request.trigger isKindOfClass:[UNPushNotificationTrigger class]]) {
       
            //ios  无论程序在前台或者程序在后台点击的跳转处理
            [JPUSHService handleRemoteNotification:userInfo];
            [self handleNotification:userInfo];
                   
        DLog(@"\n>>>jpush头部条幅点击事件");

    }else {
        // 判断为本地通知
        DLog(@"\n>>>本地通知头部条幅点击事件");
        [[NSNotificationCenter defaultCenter] postNotificationName:@"selectIndexRongCloudMessage" object:nil];
    }
    completionHandler();  // 系统要求执行这个方法
}

#pragma clang diagnostic pop
//点击推送弹窗进行的处理 #应用后台时提醒#
- (void)handleNotification:(NSDictionary *)userInfo{
    
    NSInteger messageType = 0;

    NSString *businessStr = BGdictSetObjectIsNil(userInfo[@"_j_business"]);
    if (![Tool isBlankString:businessStr]) {
        messageType = JPushTypeText;
    }
    
    NSString *mutableContentStr = BGdictSetObjectIsNil(userInfo[@"aps"][@"mutable-content"]);
    if (![Tool isBlankString:mutableContentStr]) {
        messageType = RongCloudText;
    }
//    [WHIndicatorView toast:[NSString stringWithFormat:@"%zd",messageType]];
    //待确认订单消息
    switch (messageType) {
        case JPushTypeText:{
            //根据消息类型的区分进行相应的跳转处理
//            [[NSNotificationCenter defaultCenter] postNotificationName:@"selectIndexSystemMessage" object:nil];
        }
            break;
        case RongCloudText:{
            //根据消息类型的区分进行相应的跳转处理
            [[NSNotificationCenter defaultCenter] postNotificationName:@"selectIndexRongCloudMessage" object:nil];
        }
            break;
        
        default:
            break;
    }
}

- (void)JPushDidEnterBackground:(UIApplication *)application{
    //重新设置徽标
    [JPUSHService resetBadge];
    [JPUSHService setBadge:0];
    [[UIApplication sharedApplication] setApplicationIconBadgeNumber:0];
}

- (void)JPushWillEnterForeground:(UIApplication *)application{
    [application setApplicationIconBadgeNumber:0];
}


@end

