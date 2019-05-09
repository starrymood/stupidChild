//
//  BGShopBargainCell.m
//  ShaHaiZiT
//
//  Created by biao on 2019/1/19.
//  Copyright © 2019 biao. All rights reserved.
//

#import "BGShopBargainCell.h"
#import "BGShopBargainModel.h"
#import <UIImageView+WebCache.h>

@interface BGShopBargainCell()
@property (weak, nonatomic) IBOutlet UIImageView *imgView;
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UILabel *priceLabel;
@property (weak, nonatomic) IBOutlet UILabel *numLabel;
@property (weak, nonatomic) IBOutlet UIButton *sureBtn;

@end
@implementation BGShopBargainCell

- (void)updataWithCellArray:(BGShopBargainModel *)model{
    [self.imgView sd_setImageWithURL:[NSURL URLWithString:model.good_image] placeholderImage:BGImage(@"img_placeholder")];
    self.nameLabel.text = model.good_name;
    self.priceLabel.text = [NSString stringWithFormat:@"价值¥%@",model.good_price];
    self.numLabel.text = [NSString stringWithFormat:@"%@人已获得",model.number];
    if ([Tool isBlankString:model.msg_id]) {
        [self.sureBtn setTitle:@"点击享折扣" forState:(UIControlStateNormal)];
    }else{
         [self.sureBtn setTitle:@"继续砍价" forState:(UIControlStateNormal)];
    }
}

- (IBAction)btnSureClickedAction:(UIButton *)sender {
    if (self.sureBtnClicked) {
        self.sureBtnClicked();
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
