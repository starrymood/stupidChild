//
//  BGAirPriceInfoModel.h
//  shzTravelC
//
//  Created by biao on 2018/8/20.
//  Copyright © 2018年 biao. All rights reserved.
//

#import "BGBaseModel.h"

@interface BGAirPriceInfoModel : BGBaseModel

@property (nonatomic, copy) NSString *service_id;
@property (nonatomic, copy) NSString *service_name;
@property (nonatomic, copy) NSString *recommended;
@property(nonatomic,copy) NSString *model_name;
@property(nonatomic,copy) NSString *region_name;
@property (nonatomic, copy) NSString *product_name;
@property (nonatomic, copy) NSString *airport_name;
@property(nonatomic,copy) NSString *product_introduction;
@property (nonatomic, copy) NSArray *review_list;
@property(nonatomic,copy) NSString *product_set_name;
@property(nonatomic,copy) NSString *product_set_cd;
@property(nonatomic,copy) NSString *country_name;
@property (nonatomic, copy) NSString *review_count;
@property(nonatomic,copy) NSArray *service_configuration;
@property(nonatomic,copy) NSString *product_price;
@property (nonatomic, copy) NSString *passenger_number;
@property (nonatomic, copy) NSString *baggage_number;
@property(nonatomic,copy) NSArray *car_pictures;
@property(nonatomic,copy) NSString *remark;
@property(nonatomic,copy) NSString *unsubscribe_content;
@property(nonatomic,copy) NSString *unsubscribe_title;
@property(nonatomic,copy) NSString *service_duration;
@property(nonatomic,copy) NSString *service_mileage;
@property(nonatomic,copy) NSString *product_content;

@end
