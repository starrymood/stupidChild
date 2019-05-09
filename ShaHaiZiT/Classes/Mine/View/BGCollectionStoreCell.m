//
//  BGCollectionStoreCell.m
//  shzTravelC
//
//  Created by biao on 2018/7/26.
//  Copyright © 2018年 biao. All rights reserved.
//

#import "BGCollectionStoreCell.h"
#import "BGCollectionStoreModel.h"
#import <UIImageView+WebCache.h>

@interface BGCollectionStoreCell()
@property (weak, nonatomic) IBOutlet UIImageView *imgView;
@property (weak, nonatomic) IBOutlet UILabel *shopNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *shopCollectionNumLabel;
@property (weak, nonatomic) IBOutlet UILabel *shopScoreLabel;
@property (weak, nonatomic) IBOutlet UIButton *cancelCollectionBtn;


@end
@implementation BGCollectionStoreCell


-(void)updataWithCellArray:(BGCollectionStoreModel *)model{
    
    // 图片
    self.imgView.layer.cornerRadius = 5;
   
    [self.imgView sd_setImageWithURL:[NSURL URLWithString:model.store_logo] placeholderImage:BGImage(@"img_placeholder")];
    // 名称
    self.shopNameLabel.text = model.store_name;
    // 收藏人数
    if ([Tool isBlankString:model.collect_number]) {
        model.collect_number = @"0";
    }
    self.shopCollectionNumLabel.text = [NSString stringWithFormat:@"%@人收藏",model.collect_number];
    // 分数
    self.shopScoreLabel.text =[NSString stringWithFormat:@"%.1f分", model.store_credit.doubleValue];

}
- (IBAction)btnEnterStoreClicked:(UIButton *)sender {
    if (self.enterStoreCellClicked) {
        self.enterStoreCellClicked();
    }
}
- (IBAction)btnCancelCollectionClicked:(UIButton *)sender {
    if (self.cancelCollectCellClicked) {
        self.cancelCollectCellClicked();
    }
}

- (void)awakeFromNib {
    [super awakeFromNib];
   
    self.cancelCollectionBtn.layer.borderWidth = 1.0;
    self.cancelCollectionBtn.layer.borderColor = kApp999Color.CGColor;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
