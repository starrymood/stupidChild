//
//  BGHomeLineTwoCell.m
//  shzTravelC
//
//  Created by biao on 2018/7/23.
//  Copyright © 2018年 biao. All rights reserved.
//

#import "BGHomeLineTwoCell.h"
#import <UIImageView+WebCache.h>
#import "BGAirProductModel.h"

@interface BGHomeLineTwoCell()
@property (weak, nonatomic) IBOutlet UIImageView *lineImgView;
@property (weak, nonatomic) IBOutlet UILabel *lineTitleLabel;
@property (weak, nonatomic) IBOutlet UILabel *lineBriefLabel;
@property (weak, nonatomic) IBOutlet UILabel *priceLabel;

@end
@implementation BGHomeLineTwoCell

-(void)updataWithCellArr:(BGAirProductModel *)model{
    [self.lineImgView sd_setImageWithURL:[NSURL URLWithString:model.main_picture] placeholderImage:BGImage(@"img_placeholder")];
    self.lineTitleLabel.text = model.product_name;
    self.lineBriefLabel.text = model.product_introduction;
    self.priceLabel.text = model.product_price;
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
