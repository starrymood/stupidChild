//
//  WHIndicatorView.m
//  wehomec
//
//  Created by spikedeng on 2017/3/14.
//  Copyright © 2017年 JiangHao. All rights reserved.
//

#import "WHIndicatorView.h"
#import "WH_errorBox.h"

@implementation WHIndicatorView

+ (void)toast:(NSString *)message{
    CGFloat screenHeight = CGRectGetHeight(BGWindow.frame);
   // CGFloat fontUnitWidth = 40;
    WH_errorBox *errorView = [[WH_errorBox alloc] initWithFrame:CGRectMake(70, screenHeight/2+100, 0, 0) superView:BGWindow];
    [errorView setErrorText:message];

    //toast 显示在keyboard上
    UIWindow *window = [[[UIApplication sharedApplication] delegate] window];
    NSArray *windows = [UIApplication sharedApplication].windows;
    for (id windowView in windows) {
        NSString *viewName = NSStringFromClass([windowView class]);
        if ([@"UIRemoteKeyboardWindow" isEqualToString:viewName]) {
            window = windowView;
            break;
        }
    }
    [window addSubview:errorView];
}

@end
