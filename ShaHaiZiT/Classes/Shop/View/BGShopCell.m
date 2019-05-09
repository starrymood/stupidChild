//
//  BGShopCell.m
//  shzTravelC
//
//  Created by 孙林茂 on 2018/5/8.
//  Copyright © 2018年 biao. All rights reserved.
//

#import "BGShopCell.h"
#import "BGShopShowModel.h"
#import "UIImageView+WebCache.h"

@interface BGShopCell()
@property (weak, nonatomic) IBOutlet UIImageView *imgView;
@property (weak, nonatomic) IBOutlet UILabel *shopNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *shopSpecLabel;
@property (weak, nonatomic) IBOutlet UILabel *shopPriceLabel;
@property (weak, nonatomic) IBOutlet UILabel *shopBrandLabel;

@property (weak, nonatomic) IBOutlet UIButton *showSelfBtn; // 自营

@property (weak, nonatomic) IBOutlet UIButton *showSaleBtn; // 限时特价

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *showSaleLeft;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *showPriceTop;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *contentHeight;

@end
@implementation BGShopCell

- (void)updataWithCellArray:(BGShopShowModel *)model {
    self.layer.borderColor = kApp999Color.CGColor;
    self.layer.borderWidth = 0.5;
     // 图片
    self.imgView.layer.cornerRadius = 5;
    self.showSaleBtn.layer.cornerRadius = 2;
    self.showSaleBtn.layer.borderColor = kAppRedColor.CGColor;
    self.showSaleBtn.layer.borderWidth = 1;
    [self.imgView sd_setImageWithURL:[NSURL URLWithString:model.original] placeholderImage:BGImage(@"img_placeholder")];
    
    // 名称
    self.shopNameLabel.text = model.name;
    CGFloat staticHeight = 112;
    // 简介
    if ([Tool isBlankString:model.goods_description]) {
        self.shopSpecLabel.hidden = YES;
        self.showPriceTop.constant = 6;
        staticHeight = staticHeight - 25;
        self.contentHeight.constant = staticHeight;
    }else{
        self.shopSpecLabel.hidden = NO;
        self.showPriceTop.constant = 30.5;
    }
    self.shopSpecLabel.text = model.goods_description;
    // 价格
    self.shopPriceLabel.text =[NSString stringWithFormat:@"¥%.2f", model.price.doubleValue];
    // 品牌
    self.shopBrandLabel.text = model.brand_name;
    // 是否显示自营
    if ([Tool isBlankString:model.store_name]) {
        self.showSelfBtn.hidden = YES;
        self.showSaleLeft.constant = 10;
    }else{
        self.showSelfBtn.hidden = NO;
        self.showSaleLeft.constant = 37;
    }
    // 是否显示 显示特价
    self.showSaleBtn.hidden = YES;
    staticHeight = staticHeight - 17;
    self.contentHeight.constant = staticHeight;
}


@end
