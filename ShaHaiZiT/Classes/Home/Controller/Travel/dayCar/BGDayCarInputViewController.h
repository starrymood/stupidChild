//
//  BGDayCarInputViewController.h
//  shzTravelC
//
//  Created by biao on 2018/8/23.
//  Copyright © 2018年 biao. All rights reserved.
//

#import "BGBaseViewController.h"

@class BGAirPriceInfoModel;
@interface BGDayCarInputViewController : BGBaseViewController

@property (nonatomic, copy) NSString *product_id;

@property (nonatomic, strong) BGAirPriceInfoModel *fModel;

@end
