//
//  BGAppDelegateHelper.h
//  shzTravelC
//
//  Created by 孙林茂 on 2018/5/4.
//  Copyright © 2018年 biao. All rights reserved.
//

#import <Foundation/Foundation.h>
@class AppDelegate;

@interface BGAppDelegateHelper : NSObject

+ (UIViewController *)delegateRootViewController;

+ (void)showLoginViewController;

+ (UIViewController *)topViewController;

+ (void)setRootViewController:(UIViewController *)rootViewController;

+ (void)setCustomTabBarControllerAsRootViewController;

+ (AppDelegate *)delegate;

@end
