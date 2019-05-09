//
//  BGOrderDetailModel.h
//  ShaHaiZiT
//
//  Created by biao on 2018/11/29.
//  Copyright © 2018 biao. All rights reserved.
//

#import "BGBaseModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface BGOrderDetailModel : BGBaseModel

@property(nonatomic,copy) NSString *audit_number;
@property(nonatomic,copy) NSString *airport_name;
@property(nonatomic,copy) NSString *flight_number;
@property(nonatomic,copy) NSString *order_status;
@property(nonatomic,copy) NSString *children_number;
@property(nonatomic,copy) NSString *order_number;
@property(nonatomic,copy) NSString *order_amount;
@property(nonatomic,copy) NSString *destination;
@property(nonatomic,copy) NSString *product_set_name;
@property(nonatomic,copy) NSString *product_set_cd;
@property(nonatomic,copy) NSString *product_id;
@property(nonatomic,copy) NSString *country_name;
@property(nonatomic,copy) NSString *pay_start_time;
@property(nonatomic,copy) NSString *pay_amount;
@property(nonatomic,copy) NSString *pay_end_time;
@property(nonatomic,copy) NSString *baggage_number;
@property(nonatomic,copy) NSString *start_time;
@property(nonatomic,copy) NSString *end_time;
@property(nonatomic,copy) NSString *dis_amount;
@property(nonatomic,copy) NSString *remark;
@property(nonatomic,copy) NSString *region_name;
@property(nonatomic,copy) NSString *departure;
@property(nonatomic,copy) NSString *product_name;
@property(nonatomic,copy) NSString *is_accept;
@property(nonatomic,copy) NSString *is_concern;
@property(nonatomic,copy) NSString *food_preference;
@property(nonatomic,copy) NSString *travel_preference;
@property(nonatomic,copy) NSString *room_preference;
@property(nonatomic,copy) NSString *guide_member_id;

@property(nonatomic,copy) NSString *phone;
@property(nonatomic,copy) NSString *rong_id;
@property(nonatomic,copy) NSString *model_name;
@property(nonatomic,copy) NSString *number_plate;
@property(nonatomic,copy) NSString *nickname;
@property(nonatomic,copy) NSString *submit_time;
@property(nonatomic,copy) NSString *contact;
@property(nonatomic,copy) NSString *contact_number;

@end

NS_ASSUME_NONNULL_END
