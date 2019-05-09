//
//  UITabBar+badge.h
//  wehomec
//
//  Created by Lion on 17/5/10.
//  Copyright © 2017年 JiangHao. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UITabBar (badge)
- (void)showBadgeOnItemIndex:(int)index;   //显示小红点

- (void)hideBadgeOnItemIndex:(int)index; //隐藏小红点

@end
