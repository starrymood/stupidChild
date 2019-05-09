//
//  BGMineCustomThreeCell.m
//  LLLive
//
//  Created by biao on 2017/2/27.
//  Copyright © 2017年 ZZLL. All rights reserved.
//

#import "BGMineCustomThreeCell.h"

@implementation BGMineCustomThreeCell

- (void)awakeFromNib {
    [super awakeFromNib];
    
    _profileHeadImgView.layer.borderWidth = 1.0;
    _profileHeadImgView.layer.borderColor = [UIColor whiteColor].CGColor;

}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
