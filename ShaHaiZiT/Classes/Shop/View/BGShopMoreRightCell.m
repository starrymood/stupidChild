//
//  BGShopMoreRightCell.m
//  shzTravelC
//
//  Created by 孙林茂 on 2018/5/10.
//  Copyright © 2018年 biao. All rights reserved.
//

#import "BGShopMoreRightCell.h"
#import "BGShopSortsModel.h"
#import <UIImageView+WebCache.h>

@interface BGShopMoreRightCell()
@property (weak, nonatomic) IBOutlet UILabel *shopNameLabel;
@property (weak, nonatomic) IBOutlet UIImageView *shopBGImgView;

@end

@implementation BGShopMoreRightCell

- (void)updataWithCellArray:(BGShopSortsModel *)model{
    [_shopBGImgView sd_setImageWithURL:[NSURL URLWithString:model.main_pic] placeholderImage:BGImage(@"img_placeholder")];
    _shopNameLabel.text = model.name;
}

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

@end
