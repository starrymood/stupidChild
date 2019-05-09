//
//  BGAttentionCell.m
//  shzTravelC
//
//  Created by biao on 2018/7/19.
//  Copyright © 2018年 biao. All rights reserved.
//

#import "BGAttentionCell.h"
#import "BGAttentionModel.h"
#import <UIImageView+WebCache.h>

@interface BGAttentionCell()
@property (weak, nonatomic) IBOutlet UIImageView *headImgView;
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UIButton *attentionBtn;
@property (weak, nonatomic) IBOutlet UIView *guideInfoView;
@property (weak, nonatomic) IBOutlet UILabel *signatureLabel;
@property (weak, nonatomic) IBOutlet UILabel *guideLevelLabel;
@property (weak, nonatomic) IBOutlet UILabel *guideOrderNumLabel;

@end
@implementation BGAttentionCell

-(void)updataWithArray:(BGAttentionModel *)model listType:(int)listType{
    switch (listType) {
        case 1:{
            self.attentionBtn.hidden = NO;
            self.accessoryType = UITableViewCellAccessoryNone;
            self.signatureLabel.hidden = NO;
            self.guideInfoView.hidden = YES;
            self.signatureLabel.text = model.signature;
        }
            break;
        case 2:{
            self.attentionBtn.hidden = YES;
            self.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
            self.signatureLabel.hidden = NO;
            self.guideInfoView.hidden = YES;
            self.signatureLabel.text = model.signature;
        }
            break;
        case 3:{
            self.attentionBtn.hidden = YES;
            self.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
            self.signatureLabel.hidden = YES;
            self.guideInfoView.hidden = NO;

            self.guideLevelLabel.text = model.level_name;
            [self.guideLevelLabel setTextColor:UIColorFromRGB([self numberWithHexString:model.color])];

            self.guideOrderNumLabel.text = [NSString stringWithFormat:@"%@笔订单",model.order_quantity];
        }
            break;
            
        default:
            break;
    }
    
    self.nameLabel.text = model.nickname;
    [self.headImgView sd_setImageWithURL:[NSURL URLWithString:model.face] placeholderImage:BGImage(@"headImg_placeholder")];
    if (model.is_concern.intValue == 1) {
        [self.attentionBtn setTitle:@"已关注" forState:(UIControlStateNormal)];
        [self.attentionBtn setTitleColor:kApp666Color forState:(UIControlStateNormal)];
        self.attentionBtn.layer.borderColor = kApp666Color.CGColor;
    }else{
        [self.attentionBtn setTitle:@"关注" forState:(UIControlStateNormal)];
        [self.attentionBtn setTitleColor:kAppMainColor forState:(UIControlStateNormal)];
        self.attentionBtn.layer.borderColor = kAppMainColor.CGColor;
    }
}

- (void)awakeFromNib {
    [super awakeFromNib];
    self.attentionBtn.layer.borderColor = kAppMainColor.CGColor;
    self.attentionBtn.layer.borderWidth = 1.0;
    self.attentionBtn.layer.cornerRadius = _attentionBtn.height*0.5;
}
- (IBAction)btnConcernClicked:(UIButton *)sender {
    if (self.concernClicked) {
        self.concernClicked(sender);
    }
}
- (NSInteger)numberWithHexString:(NSString *)hexString{
    
    const char *hexChar = [hexString cStringUsingEncoding:NSUTF8StringEncoding];
    
    int hexNumber;
    
    sscanf(hexChar, "%x", &hexNumber);
    
    return (NSInteger)hexNumber;
}
- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
