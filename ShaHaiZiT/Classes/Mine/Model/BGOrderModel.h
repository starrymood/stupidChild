//
//  BGOrderModel.h
//  shzTravelC
//
//  Created by biao on 2018/6/19.
//  Copyright © 2018年 biao. All rights reserved.
//

#import "BGBaseModel.h"

@interface BGOrderModel : BGBaseModel



@property (nonatomic, copy) NSArray *goods_list;

@property (nonatomic, copy) NSString *need_pay_money;
@property (nonatomic, copy) NSString *order_number;
@property (nonatomic, copy) NSString *total_num;
@property (nonatomic, copy) NSString *status;
@property(nonatomic,copy) NSString *review_state;

@property (nonatomic, copy) NSString *create_time;

@end
