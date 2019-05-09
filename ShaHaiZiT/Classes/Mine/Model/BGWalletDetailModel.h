//
//  BGWalletDetailModel.h
//  shzTravelC
//
//  Created by biao on 2018/6/8.
//  Copyright © 2018年 biao. All rights reserved.
//

#import "BGBaseModel.h"

@interface BGWalletDetailModel : BGBaseModel

@property (nonatomic, copy) NSString *money;

@property (nonatomic, copy) NSString *ID;

@property (nonatomic, copy) NSString *withdraw_status;

@property (nonatomic, copy) NSString *create_time;

@property(nonatomic,copy) NSString *type;

@property(nonatomic,copy) NSString *arrival_money;

@property(nonatomic,copy) NSString *commission_price;

@end
