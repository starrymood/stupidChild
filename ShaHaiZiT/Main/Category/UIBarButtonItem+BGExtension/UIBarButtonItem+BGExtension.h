//
//  UIBarButtonItem+BGExtension.h
//  LLLive
//
//  Created by biao on 2017/2/8.
//  Copyright © 2017年 ZZLL. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIBarButtonItem (BGExtension)
+ (instancetype)itemWithImage:(NSString *)image highImage:(NSString *)highImage target:(id)target action:(SEL)action;
@end
