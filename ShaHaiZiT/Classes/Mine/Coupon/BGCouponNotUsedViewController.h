//
//  BGCouponNotUsedViewController.h
//  shzTravelC
//
//  Created by 孙林茂 on 2018/5/10.
//  Copyright © 2018年 biao. All rights reserved.
//

#import "BGBaseViewController.h"

typedef void(^CallBackCouponBlock) (NSString *amountStr , NSString *couponIdStr);


typedef void(^refreshEditBlock)(void);
@interface BGCouponNotUsedViewController : BGBaseViewController

@property (nonatomic, assign) BOOL isCanSelect;
@property (nonatomic, copy) NSString *goodsPriceStr;
@property (nonatomic, copy) CallBackCouponBlock callBackCouponBlock;

@end
