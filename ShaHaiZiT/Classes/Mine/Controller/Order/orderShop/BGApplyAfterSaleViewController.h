//
//  BGApplyAfterSaleViewController.h
//  shzTravelC
//
//  Created by biao on 2018/6/22.
//  Copyright © 2018年 biao. All rights reserved.
//

#import "BGBaseViewController.h"

@interface BGApplyAfterSaleViewController : BGBaseViewController

@property (nonatomic, copy) NSString *itemId;
@property (nonatomic, copy) NSString *order_number;
@property (nonatomic, copy) NSString *creatTime;
@property (nonatomic, assign) NSInteger maxNum;

@property (nonatomic, assign) BOOL isDetail;

@end
