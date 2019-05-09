//
//  SHZSelectTimeViewController.h
//  shahaizic
//
//  Created by 彪哥 on 2018/1/10.
//  Copyright © 2018年 彪哥. All rights reserved.
//  选择时间页

#import "BGBaseViewController.h"

typedef void(^TimeBlock)(NSDate *startDate, NSDate *endDate);

@interface SHZSelectTimeViewController : UIViewController

@property (strong, nonatomic) NSDate *startDate;
@property (strong, nonatomic) NSDate *endDate;
@property (nonatomic, copy) TimeBlock timeBlock;

- (void)carStartTimeToEndTime:(TimeBlock)block;

@end
