//
//  BGSelectCouponViewController.h
//  ShaHaiZiT
//
//  Created by biao on 2018/11/28.
//  Copyright © 2018 biao. All rights reserved.
//

#import "BGBaseViewController.h"

NS_ASSUME_NONNULL_BEGIN
typedef void(^CallBackCouponBlock) (NSString *amountStr , NSString *couponIdStr);


@interface BGSelectCouponViewController : BGBaseViewController

@property (nonatomic, copy) NSString *goodsPriceStr;
@property(nonatomic,assign) NSInteger couponType; // 1、接机；2、送机；3、包车4、私人5、线路6、商城
@property (nonatomic, copy) CallBackCouponBlock callBackCouponBlock;

@end

NS_ASSUME_NONNULL_END
