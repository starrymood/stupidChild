//
//  SHZCountryViewController.h
//  shahaizic
//
//  Created by 姜昊 on 2018/1/30.
//  Copyright © 2018年 姜昊. All rights reserved.
//  选择国家区号

#import "BGBaseViewController.h"

typedef void(^CountryBlock)(NSDictionary *countryDic);

@interface SHZCountryViewController : BGBaseViewController

@property (nonatomic, copy) CountryBlock countryBlock;

- (void)countryCellDic:(CountryBlock)block;

@end
