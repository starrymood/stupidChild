//
//  BGAddReceiveAddressViewController.h
//  shzTravelC
//
//  Created by 孙林茂 on 2018/5/12.
//  Copyright © 2018年 biao. All rights reserved.
//

#import "BGBaseViewController.h"

@class BGAddressModel;

typedef void(^refreshEditBlock)(void);

@interface BGAddReceiveAddressViewController : BGBaseViewController

@property (nonatomic, copy) refreshEditBlock refreshEditBlock;

@property (nonatomic, strong) BGAddressModel *model;

@property (nonatomic, assign) BOOL isCanSelect;

@end
