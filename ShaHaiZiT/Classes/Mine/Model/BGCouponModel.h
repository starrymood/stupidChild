//
//  BGCouponModel.h
//  shzTravelC
//
//  Created by biao on 2018/6/5.
//  Copyright © 2018年 biao. All rights reserved.
//

#import "BGBaseModel.h"

@interface BGCouponModel : BGBaseModel


@property(nonatomic,copy) NSString *denomination;         // 优惠券金额
@property(nonatomic,copy) NSString *ID;                   // 优惠券id
@property(nonatomic,copy) NSString *limit_content;        // 优惠券限额
@property(nonatomic,copy) NSString *coupon_name;          // 优惠券名称
@property(nonatomic,copy) NSString *validity_period;      // 优惠券有效时长
@property(nonatomic,copy) NSString *full_amount;          // 优惠券满减限制
@property(nonatomic,copy) NSString *remark;
@property(nonatomic,copy) NSString *business;
@property(nonatomic,copy) NSString *is_full_reduction;
@property(nonatomic,copy) NSString *coupon_id;
@property(nonatomic,copy) NSString *limit_amount;




@end
