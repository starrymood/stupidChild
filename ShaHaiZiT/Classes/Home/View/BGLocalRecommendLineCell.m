//
//  BGLocalRecommendLineCell.m
//  ShaHaiZiT
//
//  Created by biao on 2019/3/27.
//  Copyright © 2019 biao. All rights reserved.
//

#import "BGLocalRecommendLineCell.h"
#import <UIImageView+WebCache.h>
#import "BGAirProductModel.h"

@interface BGLocalRecommendLineCell()
@property (weak, nonatomic) IBOutlet UIImageView *picImgView;
@property (weak, nonatomic) IBOutlet UILabel *briefLabel;
@property (weak, nonatomic) IBOutlet UILabel *priceLabel;

@end
@implementation BGLocalRecommendLineCell


-(void)updataWithCellArr:(BGAirProductModel *)model{
    [self.picImgView sd_setImageWithURL:[NSURL URLWithString:model.main_picture] placeholderImage:BGImage(@"img_placeholder")];
    self.briefLabel.text = model.product_introduction;
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
