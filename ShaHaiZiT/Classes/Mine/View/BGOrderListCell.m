//
//  BGOrderListCell.m
//  ShaHaiZiT
//
//  Created by biao on 2018/11/29.
//  Copyright © 2018 biao. All rights reserved.
//

#import "BGOrderListCell.h"
#import "BGOrderListModel.h"
#import <UIImageView+WebCache.h>

@interface BGOrderListCell()
@property (weak, nonatomic) IBOutlet UILabel *orderNumLabel;
@property (weak, nonatomic) IBOutlet UILabel *orderStatusLabel;
@property (weak, nonatomic) IBOutlet UIImageView *productImgView;
@property (weak, nonatomic) IBOutlet UILabel *orderTitleeLabel;
@property (weak, nonatomic) IBOutlet UILabel *serviceTimeLabel;
@property (weak, nonatomic) IBOutlet UILabel *serviceGuideLabel;
@property (weak, nonatomic) IBOutlet UILabel *amountLabel;
@property (weak, nonatomic) IBOutlet UILabel *payLabel;
@property (weak, nonatomic) IBOutlet UIButton *firstBtn;
@property (weak, nonatomic) IBOutlet UIButton *secondBtn;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *payLabelRight;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *titleeLabelHeight;


@end
@implementation BGOrderListCell

-(void)updataWithCellArray:(BGOrderListModel *)model{
    _payLabelRight.constant = 10;
    _orderTitleeLabel.numberOfLines = 1;
    _titleeLabelHeight.constant = 14;
    [self.orderStatusLabel setTextColor:UIColorFromRGB(0xFF5656)];
    self.orderNumLabel.text = [NSString stringWithFormat:@"订单号：%@",model.order_number];
    if ([Tool isBlankString:model.main_picture]) {
        [self.productImgView sd_setImageWithURL:[NSURL URLWithString:model.picture] placeholderImage:BGImage(@"img_placeholder")];
    }else{
        [self.productImgView sd_setImageWithURL:[NSURL URLWithString:model.main_picture] placeholderImage:BGImage(@"img_placeholder")];
    }
    
    self.orderTitleeLabel.text = model.product_name;
    self.amountLabel.text = [NSString stringWithFormat:@"¥ %@",model.order_amount];
    self.payLabel.text = [NSString stringWithFormat:@"¥ %@",model.pay_amount];
   
    switch (model.product_set_cd.intValue) {
        case 1:
        case 2:{
            self.serviceTimeLabel.text = [NSString stringWithFormat:@"行程时间：%@",[Tool dateFormatter:model.start_time.doubleValue dateFormatter:@"yyyy-MM-dd HH:mm"]];
        }
            break;
        case 3:{
            NSString *aStr = [Tool dateFormatter:model.start_time.doubleValue dateFormatter:@"yyyy年MM月dd日"];
            NSString *bStr = [Tool dateFormatter:model.end_time.doubleValue dateFormatter:@"MM月dd日"];
            self.serviceTimeLabel.text = [NSString stringWithFormat:@"行程时间：%@-%@",aStr,bStr];
        }
            break;
        case 6:{
            self.serviceTimeLabel.text = @"";
            _orderTitleeLabel.numberOfLines = 2;
            _titleeLabelHeight.constant = 35;
        }
            break;
            
        default:{
            self.serviceTimeLabel.text = [NSString stringWithFormat:@"行程时间：%@",[Tool dateFormatter:model.start_time.doubleValue dateFormatter:@"yyyy-MM-dd"]];
        }
            break;
    }
    self.serviceGuideLabel.text = [Tool isBlankString:model.guide_name]?@"": [NSString stringWithFormat:@"行程司导：%@",model.guide_name];

    switch (model.order_status.intValue) {
        case 0:{
            self.orderStatusLabel.text = @"待付款";
            self.firstBtn.hidden = NO;
            self.secondBtn.hidden = YES;
            [self.firstBtn setTitle:@"确认支付" forState:(UIControlStateNormal)];
            
        }
            break;
        case 1:{
            if ([Tool isBlankString:model.guide_name]) {
                self.firstBtn.hidden = YES;
                self.secondBtn.hidden = YES;
            }else{
                self.firstBtn.hidden = NO;
                self.secondBtn.hidden = NO;
                [self.firstBtn setTitle:@"发私聊" forState:(UIControlStateNormal)];
                [self.secondBtn setTitle:@"打电话" forState:(UIControlStateNormal)];
                _payLabelRight.constant = 110;
            }
            if (model.is_start.intValue == 0) {
                self.orderStatusLabel.text = @"未开始";
                [self.orderStatusLabel setTextColor:UIColorFromRGB(0xFF5656)];
                
            }else{
                self.orderStatusLabel.text = @"已开始";
                [self.orderStatusLabel setTextColor:kAppMainColor];
            }
        }
            break;
        case 2:{
            self.orderStatusLabel.text = @"待评价";
            self.firstBtn.hidden = NO;
            self.secondBtn.hidden = YES;
            [self.firstBtn setTitle:@"评价订单" forState:(UIControlStateNormal)];
        }
            break;
        case 4:{
            self.orderStatusLabel.text = @"已完成";
            self.firstBtn.hidden = YES;
            self.secondBtn.hidden = YES;
        }
            break;
        default:{
            self.orderStatusLabel.text = @"未知状态";
            self.firstBtn.hidden = YES;
            self.secondBtn.hidden = YES;
        }
            break;
    }
    if (model.product_set_cd.intValue == 6) {
        self.orderStatusLabel.text = @"";
        if (model.order_status.intValue==1) {
            self.firstBtn.hidden = NO;
            self.secondBtn.hidden = YES;
            [self.firstBtn setTitle:@"确认完成" forState:(UIControlStateNormal)];
        }
    }
    
    
}

- (IBAction)btnFirstClicked:(UIButton *)sender {
    if (self.firstBtnClicked) {
        self.firstBtnClicked();
    }
}
- (IBAction)btnSecondClicked:(UIButton *)sender {
    if (self.secondBtnClicked) {
        self.secondBtnClicked();
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
