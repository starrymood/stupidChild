//
//  BGLocalPersonModel.h
//  ShaHaiZiT
//
//  Created by biao on 2019/3/26.
//  Copyright © 2019 biao. All rights reserved.
//

#import "BGBaseModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface BGLocalPersonModel : BGBaseModel

@property(nonatomic,copy) NSArray *year_line;
@property(nonatomic,copy) NSString *region_name;
@property(nonatomic,copy) NSString *travel_count;
@property(nonatomic,copy) NSString *country_name;
@property(nonatomic,copy) NSString *service_name;
@property(nonatomic,copy) NSString *service_id;
@property(nonatomic,copy) NSArray *tags;
@property(nonatomic,copy) NSString *region_id;
@property(nonatomic,copy) NSArray *talent_banner_picture;
@property(nonatomic,copy) NSString *talent_face;
@property(nonatomic,copy) NSString *talent_name;
@property(nonatomic,copy) NSString *talent_english_name;
@property(nonatomic,copy) NSString *talent_tag;
@property(nonatomic,copy) NSString *talent_introduction;
@property(nonatomic,copy) NSArray *characteristic_ids;

@property(nonatomic,copy) NSString *content;
@property(nonatomic,copy) NSString *create_time;
@property(nonatomic,copy) NSArray *landscape_picture;

@end

NS_ASSUME_NONNULL_END
