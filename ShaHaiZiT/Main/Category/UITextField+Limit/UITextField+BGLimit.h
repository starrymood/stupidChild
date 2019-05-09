//
//  UITextField+BGLimit.h
//  LLBike
//
//  Created by biao on 2017/8/8.
//  Copyright © 2017年 ZZLL. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UITextField (BGLimit)
@property (nonatomic)NSInteger maxLenght;//字符最大长度
@property (nonatomic,strong)NSArray* digitsChars;//输入字符

@end
