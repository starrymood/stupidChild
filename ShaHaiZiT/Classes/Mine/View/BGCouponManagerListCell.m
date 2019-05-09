//
//  BGCouponManagerListCell.m
//  shzTravelC
//
//  Created by 孙林茂 on 2018/5/11.
//  Copyright © 2018年 biao. All rights reserved.
//

#import "BGCouponManagerListCell.h"
#import "BGCouponModel.h"

@interface BGCouponManagerListCell()

@property (weak, nonatomic) IBOutlet UIImageView *couponBgImgView;
@property (weak, nonatomic) IBOutlet UILabel *moneyLabel;
@property (weak, nonatomic) IBOutlet UILabel *couponTypeLabel;
@property (weak, nonatomic) IBOutlet UIImageView *couponTypeImgView;
@property (weak, nonatomic) IBOutlet UILabel *couponNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *couponTimeLabel;
@property (weak, nonatomic) IBOutlet UILabel *couponRemarkLabel;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *couponNameLeftConstraint;

@end
@implementation BGCouponManagerListCell

-(void)updataSelectCouponWithArray:(BGCouponModel *)model{
    // 金额
    self.moneyLabel.text = [NSString stringWithFormat:@"￥%@",model.denomination];
    NSMutableAttributedString *moneyStr = [[NSMutableAttributedString alloc] initWithString:self.moneyLabel.text];
    [moneyStr addAttribute:NSFontAttributeName
                     value:[UIFont systemFontOfSize:10]
                     range:[self.moneyLabel.text rangeOfString:@"￥"]];
    self.moneyLabel.attributedText = moneyStr;
    
    self.couponTypeLabel.text = model.limit_content;
    self.couponRemarkLabel.text = model.remark;
    self.couponNameLabel.text = model.coupon_name;
    self.couponNameLeftConstraint.constant = 44;
    self.couponUseBtn.hidden = NO;
    self.couponUseBtn.userInteractionEnabled = NO;
    self.userInteractionEnabled = YES;
    
    self.couponTimeLabel.text = [NSString stringWithFormat:@"有效期至：%@",[Tool dateFormatter:model.validity_period.doubleValue dateFormatter:@"yyyy-MM-dd HH:mm:ss"]];
    // 券类型
    if (model.is_full_reduction.intValue == 1) {  // 无限制
        [self.couponBgImgView setImage:BGImage(@"coupon_bg_yellow")];
        [self.couponTypeImgView setImage:BGImage(@"coupon_type_money")];
        
    }else{ // 满减
        [self.couponBgImgView setImage:BGImage(@"coupon_bg_red")];
        [self.couponTypeImgView setImage:BGImage(@"coupon_type_reduce")];
    }
    
}
-(void)updataWithCellArray:(BGCouponModel *)model codeType:(NSInteger)codeType{
    
    // 金额
    self.moneyLabel.text = [NSString stringWithFormat:@"￥%@",model.denomination];
    NSMutableAttributedString *moneyStr = [[NSMutableAttributedString alloc] initWithString:self.moneyLabel.text];
    [moneyStr addAttribute:NSFontAttributeName
                     value:[UIFont systemFontOfSize:10]
                     range:[self.moneyLabel.text rangeOfString:@"￥"]];
    self.moneyLabel.attributedText = moneyStr;
    
    self.couponTypeLabel.text = model.limit_content;
    self.couponRemarkLabel.text = model.remark;
    self.couponNameLabel.text = model.coupon_name;
    self.couponNameLeftConstraint.constant = 44;
    self.couponUseBtn.hidden = NO;
    
    if (codeType == 1) {
        
        self.couponTimeLabel.text = [NSString stringWithFormat:@"有效期至：%@",[Tool dateFormatter:model.validity_period.doubleValue dateFormatter:@"yyyy-MM-dd HH:mm:ss"]];
        // 券类型
        if (model.is_full_reduction.intValue == 1) {  // 无限制
            [self.couponBgImgView setImage:BGImage(@"coupon_bg_yellow")];
            [self.couponTypeImgView setImage:BGImage(@"coupon_type_money")];
            
        }else{ // 满减
            [self.couponBgImgView setImage:BGImage(@"coupon_bg_red")];
            [self.couponTypeImgView setImage:BGImage(@"coupon_type_reduce")];
            
            
        }
    }else{
        self.moneyLabel.textColor = kApp666Color;
        self.couponTypeLabel.textColor = kApp666Color;
        self.couponRemarkLabel.textColor = kApp666Color;
        self.couponNameLabel.textColor = kApp666Color;
        self.couponTimeLabel.textColor = kApp999Color;
        [self.couponBgImgView setImage:BGImage(@"coupon_bg_grey")];
        self.couponNameLeftConstraint.constant = 8;
        self.couponUseBtn.hidden = YES;
        [self.couponTypeImgView setImage:nil];
        
        self.couponTimeLabel.text = [NSString stringWithFormat:@"%@ %@",[Tool dateFormatter:model.validity_period.doubleValue dateFormatter:@"yyyy-MM-dd HH:mm:ss"],(codeType == 2)?@"已使用":@"已过期"];
    }
}

@end
