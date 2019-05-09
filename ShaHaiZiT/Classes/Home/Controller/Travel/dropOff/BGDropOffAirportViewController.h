//
//  BGDropOffAirportViewController.h
//  shzTravelC
//
//  Created by biao on 2018/8/21.
//  Copyright © 2018年 biao. All rights reserved.
//

#import "BGBaseViewController.h"

@class BGAirPriceInfoModel;
@interface BGDropOffAirportViewController : BGBaseViewController

@property (nonatomic, copy) NSString *product_id;

@property (nonatomic, strong) BGAirPriceInfoModel *fModel;

@end
