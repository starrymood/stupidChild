//
//  AppDelegate+JPush.h
//  shahaizic
//
//  Created by 孙林茂 on 2018/3/22.
//  Copyright © 2018年 樱兰网络. All rights reserved.
//

#import "AppDelegate.h"
#import "JPUSHService.h"
// iOS10注册APNs所需头文件
#ifdef NSFoundationVersionNumber_iOS_9_x_Max
#import <UserNotifications/UserNotifications.h>
#endif

@interface AppDelegate (JPush)<JPUSHRegisterDelegate>
//极光推送初始化方法
- (void)setJPush:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions;
//进入后台的方法
- (void)JPushDidEnterBackground:(UIApplication *)application;
//将要进入前台的时候的方法
- (void)JPushWillEnterForeground:(UIApplication *)application;

@end
