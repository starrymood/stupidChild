//
//  BGBankCardCell.m
//  shzTravelC
//
//  Created by 孙林茂 on 2018/5/12.
//  Copyright © 2018年 biao. All rights reserved.
//

#import "BGBankCardCell.h"
#import "BGMyBankCardModel.h"
#import <UIImageView+WebCache.h>

@interface BGBankCardCell()
@property (weak, nonatomic) IBOutlet UIImageView *bankBgImgView;
@property (weak, nonatomic) IBOutlet UILabel *bankNumLabel;
@property (weak, nonatomic) IBOutlet UIImageView *bankSelectImgView;

@end
@implementation BGBankCardCell

- (void)awakeFromNib {
    [super awakeFromNib];
}
- (void)updataWithCellArray:(BGMyBankCardModel *)model{
    int is_default = [NSString stringWithFormat:@"%@",model.is_default].intValue;
    if (is_default == 1) {
        [_bankSelectImgView setHidden:NO];
    }else{
        [_bankSelectImgView setHidden:YES];
    }
   [_bankBgImgView sd_setImageWithURL:[NSURL URLWithString:model.background_url]];
    _bankNumLabel.text = model.bank_number;
}
- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
