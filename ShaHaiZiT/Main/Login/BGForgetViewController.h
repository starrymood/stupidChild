//
//  BGForgetViewController.h
//  shzTravelC
//
//  Created by 孙林茂 on 2018/5/7.
//  Copyright © 2018年 biao. All rights reserved.
//

#import "BGBaseViewController.h"
// 手机号码
typedef void(^phoneNumBlock)(NSString*);

@interface BGForgetViewController : BGBaseViewController
// 声明block属性
@property (nonatomic, copy) phoneNumBlock block;

// 声明block方法
- (void)text:(phoneNumBlock)block;

@end
