//
//  BGAfterSaleStoreCell.m
//  shzTravelC
//
//  Created by biao on 2018/6/24.
//  Copyright © 2018年 biao. All rights reserved.
//

#import "BGAfterSaleStoreCell.h"
#import <UIImageView+WebCache.h>

@interface BGAfterSaleStoreCell ()
@property (weak, nonatomic) IBOutlet UIImageView *headImgView;
@property (weak, nonatomic) IBOutlet UILabel *statusLabel;
@property (weak, nonatomic) IBOutlet UILabel *timeLabel;
@property (weak, nonatomic) IBOutlet UILabel *noteLabel;

@end
@implementation BGAfterSaleStoreCell

- (void)updataWithCellArray:(NSDictionary *)dic isStore:(BOOL)isStore{

    if (isStore) {
        int status = [NSString stringWithFormat:@"%@",BGdictSetObjectIsNil(dic[@"create_status"])].intValue;
        if (status == 0) {
            self.statusLabel.text = @"商家通过退款申请";
        }else{
            self.statusLabel.text = @"商家拒绝退款申请";
        }
    }else{
        int status = [NSString stringWithFormat:@"%@",BGdictSetObjectIsNil(dic[@"refund_status"])].intValue;
        if (status == 0) {
            self.statusLabel.text = @"退款成功";
        }else{
            self.statusLabel.text = @"退款失败";
        }
    }
    
    [self.headImgView sd_setImageWithURL:[NSURL URLWithString:BGdictSetObjectIsNil(dic[@"store_logo"])] placeholderImage:BGImage(@"headImg_placeholder")];
    
    NSString *timeStr;
    if (isStore) {
        timeStr = [NSString stringWithFormat:@"%@",BGdictSetObjectIsNil(dic[@"create_time"])];
    }else{
         timeStr = [NSString stringWithFormat:@"%@",BGdictSetObjectIsNil(dic[@"refund_time"])];
    }
    if (timeStr.length == 10) {
        self.timeLabel.text = [NSString stringWithFormat:@"%@",[Tool dateFormatter:timeStr.doubleValue dateFormatter:@"yyyy-MM-dd HH:mm:ss"]];
    }
    NSString *refundStr;
    if (isStore) {
        refundStr = BGdictSetObjectIsNil(dic[@"create_remark"]);
    }else{
        refundStr = BGdictSetObjectIsNil(dic[@"refund_remark"]);
    }
    self.noteLabel.text = [NSString stringWithFormat:@"备注:   %@",refundStr];

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
