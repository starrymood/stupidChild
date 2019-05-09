//
//  BGAirProductCell.m
//  shzTravelC
//
//  Created by biao on 2018/8/20.
//  Copyright © 2018年 biao. All rights reserved.
//

#import "BGAirProductCell.h"
#import "BGAirProductModel.h"
#import <UIImageView+WebCache.h>

@interface BGAirProductCell()
@property (weak, nonatomic) IBOutlet UIImageView *productImgView;
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UILabel *carNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *peopleLabel;
@property (weak, nonatomic) IBOutlet UILabel *popularLabel;
@property (weak, nonatomic) IBOutlet UILabel *priceLabel;

@end
@implementation BGAirProductCell


- (void)updataWithCellArray:(BGAirProductModel *)model{
    [self.productImgView sd_setImageWithURL:[NSURL URLWithString:model.main_picture] placeholderImage:BGImage(@"img_placeholder")];
    if (model.product_price.doubleValue == 0) {
        self.priceLabel.text = model.product_price;
    }else{
        self.priceLabel.text = [NSString stringWithFormat:@"¥ %.2f",model.product_price.doubleValue];
    }
    
    self.nameLabel.text = model.product_name;
    self.carNameLabel.text = model.model_name;
    NSMutableAttributedString *attributedStr = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"最多可坐%@人",model.passenger_number]];
    [attributedStr setAttributes:@{NSFontAttributeName:kFont(9),NSForegroundColorAttributeName:kApp999Color} range:NSMakeRange(0, attributedStr.length)];
    [attributedStr setAttributes:@{NSFontAttributeName:kFont(9),NSForegroundColorAttributeName:kAppMainColor} range:NSMakeRange(4, attributedStr.length-5)];
    
    self.peopleLabel.attributedText = attributedStr;
    
//    NSMutableAttributedString *attributedBookStr = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"已预订%@次",model.book_count]];
//    [attributedBookStr setAttributes:@{NSFontAttributeName:kFont(9),NSForegroundColorAttributeName:kApp999Color} range:NSMakeRange(0, attributedBookStr.length-2)];
//    [attributedBookStr setAttributes:@{NSFontAttributeName:kFont(9),NSForegroundColorAttributeName:UIColorFromRGB(0xFF4848)} range:NSMakeRange(3, attributedBookStr.length-4)];
//    
//    self.popularLabel.attributedText = attributedBookStr;
}

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

@end
