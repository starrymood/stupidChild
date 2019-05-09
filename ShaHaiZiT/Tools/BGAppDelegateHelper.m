//
//  BGAppDelegateHelper.m
//  shzTravelC
//
//  Created by 孙林茂 on 2018/5/4.
//  Copyright © 2018年 biao. All rights reserved.
//

#import "BGAppDelegateHelper.h"
#import "AppDelegate.h"
#import "BGLoginViewController.h"
#import "BGNavigationViewController.h"

@implementation BGAppDelegateHelper

+ (UIViewController *)delegateRootViewController
{
    return [self delegate].window.rootViewController;
}

+ (void)showLoginViewController
{
    @synchronized (self) {
        if(![self isShowLoginViewController]) {
            BGLoginViewController *loginVC = BGLoginViewController.new;
            BGNavigationViewController *nav = [[BGNavigationViewController alloc] initWithRootViewController:loginVC];
            [[self delegate].window.rootViewController presentViewController:nav animated:YES completion:nil];
        }
    }
}
+ (BOOL)isShowLoginViewController {
    UIViewController *vc = [BGAppDelegateHelper topViewController];
    return [vc isKindOfClass:BGLoginViewController.class];
}
+ (UIViewController *)topViewController
{
    return [self topViewController:[self delegate].window.rootViewController];
}
+ (UIViewController *)topViewController:(UIViewController *)rootViewController
{
    if (rootViewController.presentedViewController == nil) {
        return rootViewController;
    }
    
    if ([rootViewController.presentedViewController isKindOfClass:[UINavigationController class]]) {
        UINavigationController *navigationController = (UINavigationController *)rootViewController.presentedViewController;
        UIViewController *lastViewController = [[navigationController viewControllers] lastObject];
        return [self topViewController:lastViewController];
    }
    UIViewController *presentedViewController = (UIViewController *)rootViewController.presentedViewController;
    return [self topViewController:presentedViewController];
}

+ (void)setRootViewController:(UIViewController *)rootViewController{
    AppDelegate *delegate = [self delegate];
    delegate.window.rootViewController = rootViewController;
}
+ (void)setCustomTabBarControllerAsRootViewController {
    UIViewController *vc = (UIViewController *)[self delegate].tabBarVC;
    [self setRootViewController:vc];
    
}
+ (AppDelegate *)delegate {
    return (AppDelegate *)[UIApplication sharedApplication].delegate;
}
@end
