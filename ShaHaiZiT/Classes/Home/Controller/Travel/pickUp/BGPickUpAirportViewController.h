//
//  BGPickUpAirportViewController.h
//  shzTravelC
//
//  Created by biao on 2018/8/13.
//  Copyright © 2018年 biao. All rights reserved.
//

#import "BGBaseViewController.h"

@class BGAirPriceInfoModel;
@interface BGPickUpAirportViewController : BGBaseViewController

@property (nonatomic, copy) NSString *product_id;

@property (nonatomic, strong) BGAirPriceInfoModel *fModel;

@end
