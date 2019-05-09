//
//  BGAirPayInfoModel.h
//  shzTravelC
//
//  Created by biao on 2018/8/21.
//  Copyright © 2018年 biao. All rights reserved.
//

#import "BGBaseModel.h"

@interface BGAirPayInfoModel : BGBaseModel

@property(nonatomic,copy) NSArray *car_pictures;
@property(nonatomic,copy) NSString *model_name;
@property(nonatomic,copy) NSString *conversion_ratio;
@property(nonatomic,copy) NSString *integer_count;
@property(nonatomic,copy) NSString *airport_name;
@property(nonatomic,copy) NSString *country_name;
@property(nonatomic,copy) NSString *region_name;
@property(nonatomic,copy) NSString *coupon_number;
@property (nonatomic, copy) NSString *contact;
@property(nonatomic,copy) NSString *contact_number;
@property (nonatomic, copy) NSString *audit_number;
@property (nonatomic, copy) NSString *member_baggage_number;
@property (nonatomic, copy) NSString *children_number;
@property (nonatomic, copy) NSString *flight_number;
@property(nonatomic,copy) NSString *baggage_number;
@property(nonatomic,copy) NSString *passenger_number;
@property(nonatomic,copy) NSString *destination;
@property(nonatomic,copy) NSArray *service_configuration;
@property(nonatomic,copy) NSString *product_price;
@property(nonatomic,copy) NSString *start_time;
@property(nonatomic,copy) NSString *remark;
@property(nonatomic,copy) NSString *unsubscribe_content;
@property(nonatomic,copy) NSString *unsubscribe_title;
@property(nonatomic,copy) NSString *departure;
@property(nonatomic,copy) NSString *recommended;
@property(nonatomic,copy) NSString *product_name;
@property(nonatomic,copy) NSString *route_price;
@property(nonatomic,copy) NSString *member_play_days;
@property(nonatomic,copy) NSString *model_price;

@end
