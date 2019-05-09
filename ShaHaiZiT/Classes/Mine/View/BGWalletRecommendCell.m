//
//  BGWalletRecommendCell.m
//  ShaHaiZiT
//
//  Created by biao on 2019/1/11.
//  Copyright © 2019 biao. All rights reserved.
//

#import "BGWalletRecommendCell.h"
#import "BGWalletDetailModel.h"

@interface BGWalletRecommendCell()
@property (weak, nonatomic) IBOutlet UILabel *timeLabel;
@property (weak, nonatomic) IBOutlet UILabel *moneyLabel;

@end
@implementation BGWalletRecommendCell

-(void)updataWithAwardArray:(BGWalletDetailModel *)model{
    self.timeLabel.text = [Tool dateFormatter:model.create_time.doubleValue dateFormatter:@"yyyy.MM.dd"];
    self.moneyLabel.text = [NSString stringWithFormat:@"+%@元",model.commission_price];
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
