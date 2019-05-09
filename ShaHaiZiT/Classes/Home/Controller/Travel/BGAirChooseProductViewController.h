//
//  BGAirChooseProductViewController.h
//  shzTravelC
//
//  Created by biao on 2018/8/20.
//  Copyright © 2018年 biao. All rights reserved.
//

#import "BGBaseViewController.h"

@interface BGAirChooseProductViewController : BGBaseViewController

@property (nonatomic, copy) NSString *airport_id;

@property (nonatomic, assign) NSInteger category; // 1、接机，2、送机、3、包车、4、线路

@property (nonatomic, copy) NSString *titleStr;

@end
