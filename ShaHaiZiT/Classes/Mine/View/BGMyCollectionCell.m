//
//  BGMyCollectionCell.m
//  shzTravelC
//
//  Created by 孙林茂 on 2018/5/11.
//  Copyright © 2018年 biao. All rights reserved.
//

#import "BGMyCollectionCell.h"
#import "BGShopShowModel.h"
#import "UIImageView+WebCache.h"

@interface BGMyCollectionCell()
@property (weak, nonatomic) IBOutlet UIImageView *imgView;
@property (weak, nonatomic) IBOutlet UILabel *shopNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *shopSpecLabel;
@property (weak, nonatomic) IBOutlet UILabel *shopPriceLabel;
@property (weak, nonatomic) IBOutlet UIButton *showSelfBtn;
@property (weak, nonatomic) IBOutlet UIButton *showSaleBtn;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *showSaleLeft;
@end

@implementation BGMyCollectionCell


-(void)updataWithCellArray:(BGShopShowModel *)model {
    // 图片
    self.imgView.layer.cornerRadius = 5;
    self.showSaleBtn.layer.cornerRadius = 2;
    self.showSaleBtn.layer.borderColor = kAppRedColor.CGColor;
    self.showSaleBtn.layer.borderWidth = 1;
    [self.imgView sd_setImageWithURL:[NSURL URLWithString:model.original] placeholderImage:BGImage(@"img_placeholder")];
    // 名称
    self.shopNameLabel.text = model.name;
    // 规格
    self.shopSpecLabel.text = model.goods_description;
    // 价格
    self.shopPriceLabel.text =[NSString stringWithFormat:@"¥%.2f", model.price.doubleValue];
    // 是否显示自营
    if ([model.store_name isEqualToString:@"平台自营"]) {
        self.showSelfBtn.hidden = NO;
    }else{
        self.showSelfBtn.hidden = YES;
        self.showSaleLeft.constant = 10;
    }
    // 是否显示 显示特价
    if ([Tool isBlankString:model.tag_name]) {
        self.showSaleBtn.hidden = YES;
    }else{
        [self.showSaleBtn setTitle:model.tag_name forState:(UIControlStateNormal)];
        self.showSaleBtn.hidden = NO;
    }
}

- (IBAction)btnDeleteCellClicked:(UIButton *)sender {
    if (self.deleteCellClicked) {
        self.deleteCellClicked();
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
