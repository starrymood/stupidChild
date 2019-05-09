//
//  BGAfterSaleMemberCell.m
//  shzTravelC
//
//  Created by biao on 2018/6/24.
//  Copyright © 2018年 biao. All rights reserved.
//

#import "BGAfterSaleMemberCell.h"
#import <UIImageView+WebCache.h>

@interface BGAfterSaleMemberCell()
@property (weak, nonatomic) IBOutlet UIImageView *headImgView;
@property (weak, nonatomic) IBOutlet UILabel *timeLabel;
@property (weak, nonatomic) IBOutlet UILabel *moneyLabel;
@property (weak, nonatomic) IBOutlet UILabel *typeLabel;
@property (weak, nonatomic) IBOutlet UILabel *reasonLabel;
@property (weak, nonatomic) IBOutlet UILabel *detailLabel;

@end
@implementation BGAfterSaleMemberCell


- (void)updataWithCellArray:(NSDictionary *)dic{
    
    [self.headImgView sd_setImageWithURL:[NSURL URLWithString:BGdictSetObjectIsNil(dic[@"face"])] placeholderImage:BGImage(@"headImg_placeholder")];
    
    NSString *timeStr = [NSString stringWithFormat:@"%@",BGdictSetObjectIsNil(dic[@"regtime"])];
    if (timeStr.length == 10) {
        self.timeLabel.text = [NSString stringWithFormat:@"%@",[Tool dateFormatter:timeStr.doubleValue dateFormatter:@"yyyy-MM-dd HH:mm:ss"]];
    }
    NSString *moneyStr = [NSString stringWithFormat:@"%@",BGdictSetObjectIsNil(dic[@"apply_alltotal"])];
    self.moneyLabel.text = [NSString stringWithFormat:@"退款金额:   ¥ %.2f",moneyStr.doubleValue];
    self.typeLabel.text = [NSString stringWithFormat:@"售后类型:   %@",BGdictSetObjectIsNil(dic[@"remark"])];
    self.reasonLabel.text = [NSString stringWithFormat:@"退款原因:   %@",BGdictSetObjectIsNil(dic[@"reason"])];
    self.detailLabel.text = [NSString stringWithFormat:@"问题描述:   %@",BGdictSetObjectIsNil(dic[@"reason_detail"])];

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
