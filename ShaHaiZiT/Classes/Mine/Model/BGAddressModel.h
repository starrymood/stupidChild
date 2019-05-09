//
//  BGAddressModel.h
//  shzTravelC
//
//  Created by biao on 2018/6/8.
//  Copyright © 2018年 biao. All rights reserved.
//

#import "BGBaseModel.h"

@interface BGAddressModel : BGBaseModel

/*
 {
 town_id : 0,
 province : 北京,
 city_id : 2901,
 zip : ,
 member_id : 52,
 country : <null>,
 province_id : 1,
 tel : ,
 region : 城区以外,
 shipAddressName : <null>,
 region_id : 2906,
 city : 昌平区,
 addr_id : 11,
 name : 你好,
 town : ,
 isDel : 0,
 mobile : 17051335257,
 def_addr : 1,
 addressToBeEdit : <null>,
 addr : Joy,
 remark : <null>
 }
 */

@property (nonatomic, copy) NSString *ID;
@property (nonatomic, copy) NSString *province_name;
@property (nonatomic, copy) NSString *city_name;
@property (nonatomic, copy) NSString *region_name;
@property (nonatomic, copy) NSString *address_detail;
@property (nonatomic, copy) NSString *name;
@property (nonatomic, copy) NSString *mobile;
@property (nonatomic, copy) NSString *is_default;
@property (nonatomic, copy) NSString *province_id;
@property (nonatomic, copy) NSString *city_id;
@property (nonatomic, copy) NSString *region_id;


@end
