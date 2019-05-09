//
//  BGAjustNumButton.h
//  LLMall
//
//  Created by biao on 2016/11/8.
//  Copyright © 2016年 ZZLL. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface BGAjustNumButton : UIView

/**
 *  边框颜色，默认值是浅灰色
 */
@property (nonatomic, assign) UIColor *lineColor;

/**
 *  文本框内容
 */
@property (nonatomic, copy) NSString *currentNum;

/**
 *  文本框内容改变后的回调
 */
@property (nonatomic, copy) void (^callBack) (NSString *currentNum);

@end
