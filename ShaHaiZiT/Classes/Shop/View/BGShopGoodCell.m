//
//  BGShopGoodCell.m
//  ShaHaiZiT
//
//  Created by biao on 2019/4/19.
//  Copyright © 2019 biao. All rights reserved.
//

#import "BGShopGoodCell.h"
#import "BGShopShowModel.h"
#import "UIImageView+WebCache.h"

@interface BGShopGoodCell()
@property (weak, nonatomic) IBOutlet UIImageView *shopImgView;
@property (weak, nonatomic) IBOutlet UILabel *shopNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *shopPriceLabel;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *imgBottomHeight;

@end
@implementation BGShopGoodCell

- (void)updataWithCellArray:(BGShopShowModel *)model {
   
    [self.shopImgView sd_setImageWithURL:[NSURL URLWithString:model.original] placeholderImage:BGImage(@"img_placeholder")];
    
    // 名称
    self.shopNameLabel.text = model.name;
   
    // 价格
    self.shopPriceLabel.text =[NSString stringWithFormat:@"¥%.2f", model.price.doubleValue];
    CGFloat staticHeight = 91;
    self.imgBottomHeight.constant = staticHeight;
}

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

@end
