//
//  BGHomeLineCell.m
//  shzTravelC
//
//  Created by biao on 2018/7/23.
//  Copyright © 2018年 biao. All rights reserved.
//

#import "BGHomeLineCell.h"
#import <UIImageView+WebCache.h>
#import "BGAirProductModel.h"

@interface BGHomeLineCell()
@property (weak, nonatomic) IBOutlet UIImageView *lineImgView;
@property (weak, nonatomic) IBOutlet UILabel *lineTitleLabel;
@property (weak, nonatomic) IBOutlet UILabel *lineBriefLabel;
@property (weak, nonatomic) IBOutlet UILabel *priceLabel;
@property (weak, nonatomic) IBOutlet UIImageView *oneImgView;
@property (weak, nonatomic) IBOutlet UILabel *oneALabel;
@property (weak, nonatomic) IBOutlet UILabel *oneBLabel;
@property (weak, nonatomic) IBOutlet UIImageView *twoImgView;
@property (weak, nonatomic) IBOutlet UIImageView *threeImgView;
@property (weak, nonatomic) IBOutlet UIImageView *fourImgView;
@property (weak, nonatomic) IBOutlet UILabel *twoALabel;
@property (weak, nonatomic) IBOutlet UILabel *twoBLabel;
@property (weak, nonatomic) IBOutlet UILabel *threeALabel;
@property (weak, nonatomic) IBOutlet UILabel *threeBLabel;
@property (weak, nonatomic) IBOutlet UILabel *fourALabel;
@property (weak, nonatomic) IBOutlet UILabel *fourBLabel;
@property (weak, nonatomic) IBOutlet UIView *oneView;
@property (weak, nonatomic) IBOutlet UIView *twoView;
@property (weak, nonatomic) IBOutlet UIView *threeView;
@property (weak, nonatomic) IBOutlet UIView *fourView;
@property (weak, nonatomic) IBOutlet UIButton *bigBtn;
@property (weak, nonatomic) IBOutlet UIButton *oneBtn;
@property (weak, nonatomic) IBOutlet UIButton *twoBtn;
@property (weak, nonatomic) IBOutlet UIButton *threeBtn;
@property (weak, nonatomic) IBOutlet UIButton *fourBtn;

@end
@implementation BGHomeLineCell

-(void)updataWithCellArr:(NSArray *)dataArr{
    
    self.oneView.hidden = YES;
    self.twoView.hidden = YES;
    self.threeView.hidden = YES;
    self.fourView.hidden = YES;
    self.oneBtn.userInteractionEnabled = NO;
    self.twoBtn.userInteractionEnabled = NO;
    self.threeBtn.userInteractionEnabled = NO;
    self.fourBtn.userInteractionEnabled = NO;
    
    BGAirProductModel *bigModel = dataArr[0];
    self.bigBtn.tag = bigModel.product_id.integerValue+2000;
    [self.lineImgView sd_setImageWithURL:[NSURL URLWithString:bigModel.main_picture] placeholderImage:BGImage(@"img_placeholder")];
    self.lineTitleLabel.text = bigModel.product_name;
    self.lineBriefLabel.text = bigModel.product_introduction;
    self.priceLabel.text = bigModel.product_price;
    
    if (dataArr.count>1) {
        self.oneView.hidden = NO;
         self.oneBtn.userInteractionEnabled = YES;
        BGAirProductModel *oneModel = dataArr[1];
        self.oneBtn.tag = oneModel.product_id.integerValue+2000;
        [self.oneImgView sd_setImageWithURL:[NSURL URLWithString:oneModel.main_picture] placeholderImage:BGImage(@"img_placeholder")];
        self.oneALabel.text = oneModel.product_name;
        self.oneBLabel.text = oneModel.product_introduction;
        if (dataArr.count>2) {
            self.twoView.hidden = NO;
            self.twoBtn.userInteractionEnabled = YES;
            BGAirProductModel *twoModel = dataArr[2];
            self.twoBtn.tag = twoModel.product_id.integerValue+2000;
            [self.twoImgView sd_setImageWithURL:[NSURL URLWithString:twoModel.main_picture] placeholderImage:BGImage(@"img_placeholder")];
            self.twoALabel.text = twoModel.product_name;
            self.twoBLabel.text = twoModel.product_introduction;
            if (dataArr.count>3) {
                self.threeView.hidden = NO;
                self.threeBtn.userInteractionEnabled = YES;
                BGAirProductModel *threeModel = dataArr[3];
                self.threeBtn.tag = threeModel.product_id.integerValue+2000;
                [self.threeImgView sd_setImageWithURL:[NSURL URLWithString:threeModel.main_picture] placeholderImage:BGImage(@"img_placeholder")];
                self.threeALabel.text = threeModel.product_name;
                self.threeBLabel.text = threeModel.product_introduction;
                if (dataArr.count>4) {
                    self.fourView.hidden = NO;
                    self.fourBtn.userInteractionEnabled = YES;
                    BGAirProductModel *fourModel = dataArr[4];
                    self.fourBtn.tag = fourModel.product_id.integerValue+2000;
                    [self.fourImgView sd_setImageWithURL:[NSURL URLWithString:fourModel.main_picture] placeholderImage:BGImage(@"img_placeholder")];
                    self.fourALabel.text = fourModel.product_name;
                    self.fourBLabel.text = fourModel.product_introduction;
                }
            }
        }
    }
}

- (IBAction)jumpBtnClickedAction:(UIButton *)sender {
    if (self.jumpToDetailBtnClick) {
        self.jumpToDetailBtnClick(sender.tag-2000);
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
