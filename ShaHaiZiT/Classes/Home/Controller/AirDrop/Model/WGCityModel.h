//
//  WGCityModel.h
//  ShaHaiZiT
//
//  Created by DY on 2019/5/9.
//  Copyright © 2019 biao. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface WGCityModel : NSObject


/*
 city_cn : 兰州,
 id : 113,
 count : 0,
 city_en : LANZHOU,
 country_name : 中国,
 country_code : CN,
 four_code : ZLLL,
 name : 兰州机场,
 three_code : LHW
 */
@property(nonatomic,  copy) NSString *city_cn;
@property(nonatomic,  copy) NSString *Id;
@property(nonatomic,  copy) NSString *city_en;
@property(nonatomic,  copy) NSString *three_code;


@end

NS_ASSUME_NONNULL_END
