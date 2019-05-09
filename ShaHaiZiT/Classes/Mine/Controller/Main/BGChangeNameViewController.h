//
//  BGChangeNameViewController.h
//  shzTravelC
//
//  Created by 孙林茂 on 2018/5/9.
//  Copyright © 2018年 biao. All rights reserved.
//

#import "BGBaseViewController.h"

typedef void(^refreshEditBlock)(void);

@interface BGChangeNameViewController : BGBaseViewController

@property (nonatomic, copy) refreshEditBlock refreshEditBlock;

@property (nonatomic,copy)NSString *viewType;//1昵称 2个性签名 3性别
@property (nonatomic,copy)NSString *textFieldName;

@end
