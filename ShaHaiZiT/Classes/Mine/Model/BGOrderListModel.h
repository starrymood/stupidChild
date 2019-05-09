//
//  BGOrderListModel.h
//  ShaHaiZiT
//
//  Created by biao on 2018/11/29.
//  Copyright © 2018 biao. All rights reserved.
//

#import "BGBaseModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface BGOrderListModel : BGBaseModel

@property(nonatomic,copy) NSString *main_picture;
@property(nonatomic,copy) NSString *paymemnt_start_time;
@property(nonatomic,copy) NSString *payment_deadline;
@property(nonatomic,copy) NSString *order_status;
@property(nonatomic,copy) NSString *pay_amount;
@property(nonatomic,copy) NSString *start_time;
@property(nonatomic,copy) NSString *end_time;
@property(nonatomic,copy) NSString *product_set_cd;
@property(nonatomic,copy) NSString *order_amount;
@property(nonatomic,copy) NSString *order_number;
@property(nonatomic,copy) NSString *product_name;
@property(nonatomic,copy) NSString *is_start;
@property(nonatomic,copy) NSString *phone;
@property(nonatomic,copy) NSString *guide_name;
@property(nonatomic,copy) NSString *guide_rong_id;
@property(nonatomic,copy) NSString *picture;

@end

NS_ASSUME_NONNULL_END
