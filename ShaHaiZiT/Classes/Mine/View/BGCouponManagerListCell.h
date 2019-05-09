//
//  BGCouponManagerListCell.h
//  shzTravelC
//
//  Created by 孙林茂 on 2018/5/11.
//  Copyright © 2018年 biao. All rights reserved.
//

#import <UIKit/UIKit.h>
@class BGCouponModel;
@interface BGCouponManagerListCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UIButton *couponUseBtn;

-(void)updataWithCellArray:(BGCouponModel *)model codeType:(NSInteger)codeType; //1:未使用  2:已使用  3:已过期
-(void)updataSelectCouponWithArray:(BGCouponModel *)model;

@end
