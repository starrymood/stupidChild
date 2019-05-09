//
//  BGAirportCategoryModel.h
//  shzTravelC
//
//  Created by biao on 2018/8/20.
//  Copyright © 2018年 biao. All rights reserved.
//

#import "BGBaseModel.h"

@interface BGAirportCategoryModel : BGBaseModel

@property (nonatomic, copy) NSString *country_id;

@property (nonatomic, copy) NSString *country_name;


@property(nonatomic,copy) NSString *parentId;


@property (nonatomic, copy) NSString *ID;
@property (nonatomic, copy) NSString *name;
@property(nonatomic,copy) NSArray *children;

@property (nonatomic, copy) NSString *airport_id;
@property (nonatomic, copy) NSString *picture;
@property (nonatomic, copy) NSString *region_id;
@property (nonatomic, copy) NSString *region_name;
@property (nonatomic, copy) NSString *airport_name;
@property(nonatomic,copy) NSString *sort;

@end
