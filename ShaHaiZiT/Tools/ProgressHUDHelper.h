//
//  ProgressHUDHelper.h
//  wehomec
//
//  Created by hsg on 2017/8/23.
//  Copyright © 2017年 JiangHao. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface ProgressHUDHelper : NSObject

#pragma mark  loading
/**
 *  显示正在加载
 *
 *  @param view view
 */
+ (void)showLoading:(UIView *)view;

+ (void)showLoading;

+ (void)showIndeterminateLoadingView:(UIView *)view message:(NSString *)message;
#pragma mark  remove all hud
/**
 *  移除hub
 *
 *  @param view view
 */
+ (void)removeFromView:(UIView *)view;

+ (void)removeLoading;

@end
