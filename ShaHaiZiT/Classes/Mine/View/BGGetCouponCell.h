//
//  BGGetCouponCell.h
//  shzTravelC
//
//  Created by biao on 2018/11/1.
//  Copyright © 2018年 biao. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN
@class BGCouponModel;
@interface BGGetCouponCell : UITableViewCell

-(void)updataWithCellArray:(BGCouponModel *)model;
@property (weak, nonatomic) IBOutlet UIButton *getCouponBtn;

@end

NS_ASSUME_NONNULL_END
