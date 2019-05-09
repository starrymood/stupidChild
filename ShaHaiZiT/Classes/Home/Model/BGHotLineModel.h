//
//  BGHotLineModel.h
//  ShaHaiZiT
//
//  Created by biao on 2018/11/21.
//  Copyright © 2018 biao. All rights reserved.
//

#import "BGBaseModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface BGHotLineModel : BGBaseModel

@property(nonatomic,copy) NSString *is_collect;
@property(nonatomic,copy) NSString *service_id;
@property(nonatomic,copy) NSString *model_name;
@property(nonatomic,copy) NSString *region_name;
@property(nonatomic,copy) NSString *recommended;
@property(nonatomic,copy) NSString *service_name;
@property(nonatomic,copy) NSString *product_content;
@property(nonatomic,copy) NSString *product_introduction;
@property(nonatomic,copy) NSString *product_name;
@property (nonatomic, copy) NSArray *review_list;
@property(nonatomic,copy) NSString *product_set_name;
@property(nonatomic,copy) NSString *country_name;
@property(nonatomic,copy) NSString *ID;
@property(nonatomic,copy) NSString *product_set_cd;
@property (nonatomic, copy) NSArray *product_schedule;
@property(nonatomic,copy) NSString *review_count;
@property (nonatomic, copy) NSArray *service_configuration;
@property(nonatomic,copy) NSString *product_price;
@property(nonatomic,copy) NSString *play_days;
@property(nonatomic,copy) NSString *baggage_number;
@property(nonatomic,copy) NSString *passenger_number;
@property(nonatomic,copy) NSString *unsubscribe_content;
@property(nonatomic,copy) NSString *remark;
@property (nonatomic, copy) NSArray *car_pictures;
@property(nonatomic,copy) NSString *unsubscribe_title;


@end

NS_ASSUME_NONNULL_END
