//
//  ProgressHUDHelper.m
//  wehomec
//
//  Created by hsg on 2017/8/23.
//  Copyright © 2017年 JiangHao. All rights reserved.
//

#import "ProgressHUDHelper.h"
#import <MBProgressHUD.h>

@implementation ProgressHUDHelper

#pragma mark  loading

+ (void)showLoading
{
    [self showIndeterminateLoadingView:[[UIApplication sharedApplication] keyWindow] message:@""]; // 数据加载中...
}

+ (void)showLoading:(UIView *)view
{
    [self showIndeterminateLoadingView:view message:@""];
}

+ (void)removeLoading
{
    [self removeFromView:[[UIApplication sharedApplication] keyWindow]];
}

+ (void)showIndeterminateLoadingView:(UIView *)view message:(NSString *)message {
    
    MBProgressHUD *hud=[self getLoadingHub:view];
    
    BOOL haveIndeterminateHud=false;
    
    if(hud)
    {
        if(hud.mode==MBProgressHUDModeIndeterminate)
        {
            haveIndeterminateHud=YES;
        }
    }
    
    if(haveIndeterminateHud)
    {
        hud.label.text = message;
    }
    else
    {
        [self removeFromView:view];
        MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:view animated:YES];
        // Configure for text only and offset down
        hud.mode = MBProgressHUDModeIndeterminate;
        hud.label.text=message;
        hud.margin = 10.f;
        [hud setY:20.f];
        hud.label.font = [UIFont systemFontOfSize:12];
    }
}

#pragma mark  remove all hud

+ (void)removeFromView:(UIView *)view
{
    NSArray *views=view.subviews;
    for (UIView *view in views) {
        if ([view isKindOfClass:[MBProgressHUD class]]) {
            [view removeFromSuperview];
        }
    }
}


#pragma mark  exist hub

/**
 *  是否有加载hub
 *
 *  @param view currentView
 *
 *  @return BOOL
 */
+ (BOOL)haveLoadingView:(UIView *)view {
    BOOL isLoading=NO;
    
    NSArray *views=view.subviews;
    for (UIView *view in views) {
        if ([view isKindOfClass:[MBProgressHUD class]]) {
            MBProgressHUD *hud=(MBProgressHUD *)view;
            if(hud.mode==MBProgressHUDModeIndeterminate) {
                isLoading=YES;
                break;
            }
        }
    }
    
    return isLoading;
}

+ (MBProgressHUD *)getLoadingHub:(UIView *)view {
    MBProgressHUD *hub=nil;
    NSArray *views=view.subviews;
    for (UIView *view in views) {
        if ([view isKindOfClass:[MBProgressHUD class]]) {
            hub=(MBProgressHUD *)view;
            break;
        }
    }
    return  hub;
}

@end
