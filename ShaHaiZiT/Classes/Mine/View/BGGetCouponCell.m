//
//  BGGetCouponCell.m
//  shzTravelC
//
//  Created by biao on 2018/11/1.
//  Copyright © 2018年 biao. All rights reserved.
//

#import "BGGetCouponCell.h"
#import "BGCouponModel.h"

@interface BGGetCouponCell()
@property (weak, nonatomic) IBOutlet UILabel *couponNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *couponMoneyLabel;
@property (weak, nonatomic) IBOutlet UILabel *couponContentLabel;

@end
@implementation BGGetCouponCell

-(void)updataWithCellArray:(BGCouponModel *)model{
    self.couponNameLabel.text = model.coupon_name;
    self.couponMoneyLabel.text = model.denomination;
    if ([Tool isBlankString:model.full_amount]) {
        self.couponContentLabel.text = @"";
    }else{
        self.couponContentLabel.text = [NSString stringWithFormat:@"满%@可用",model.full_amount];
    }
}

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
