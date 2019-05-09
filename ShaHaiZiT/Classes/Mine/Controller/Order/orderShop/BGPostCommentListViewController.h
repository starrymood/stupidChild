//
//  BGPostCommentListViewController.h
//  shzTravelC
//
//  Created by biao on 2018/6/29.
//  Copyright © 2018年 biao. All rights reserved.
//

#import "BGBaseViewController.h"

@interface BGPostCommentListViewController : BGBaseViewController

@property (nonatomic, copy) NSString *order_number;

@property (nonatomic, copy) NSArray *orderItems;

@property (nonatomic,copy) void(^postBtnClicked)(void);

@end
