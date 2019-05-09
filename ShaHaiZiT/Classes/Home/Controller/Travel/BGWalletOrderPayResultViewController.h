//
//  BGWalletOrderPayResultViewController.h
//  shzTravelC
//
//  Created by biao on 2018/6/13.
//  Copyright © 2018年 biao. All rights reserved.
//

#import "BGBaseViewController.h"

@interface BGWalletOrderPayResultViewController : BGBaseViewController

@property (nonatomic, assign) BOOL isPaySuccess;

@property (nonatomic, assign) BOOL isNew;

@property (nonatomic, copy) NSString *order_num;

@property (nonatomic, copy) NSString *payBalanceStr;

@property(nonatomic,assign) int isShop;

@property(nonatomic,copy) NSDictionary *addressDic;

@end
