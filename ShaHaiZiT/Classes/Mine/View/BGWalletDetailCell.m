//
//  BGWalletDetailCell.m
//  shzTravelC
//
//  Created by biao on 2018/6/8.
//  Copyright © 2018年 biao. All rights reserved.
//

#import "BGWalletDetailCell.h"
#import "BGWalletDetailModel.h"

@interface  BGWalletDetailCell()
@property (weak, nonatomic) IBOutlet UILabel *typeLabel;
@property (weak, nonatomic) IBOutlet UILabel *timeLabel;
@property (weak, nonatomic) IBOutlet UILabel *moneyLabel;
@property (weak, nonatomic) IBOutlet UILabel *balanceLabel;

@end
@implementation BGWalletDetailCell

-(void)updataWithAwardArray:(BGWalletDetailModel *)model{
    
    NSString *sysStr = @"";
    NSInteger status = [NSString stringWithFormat:@"%@",model.withdraw_status].integerValue;

    switch (model.type.intValue) {
        case 1:{
            self.typeLabel.text = @"充值";
            sysStr = @"+";
            self.moneyLabel.textColor = UIColorFromRGB(0xFF4949);
            if (status == 0) {
                NSString *str = self.typeLabel.text;
                self.typeLabel.text = [NSString stringWithFormat:@"%@ (进行中)",str];
            }
        }
            break;
        case 2:{
            self.typeLabel.text = @"提现";
            sysStr = @"-";
            self.moneyLabel.textColor = kApp333Color;
            if (status == 0) {
                NSString *str = self.typeLabel.text;
                self.typeLabel.text = [NSString stringWithFormat:@"%@ (进行中)",str];
            }
        }
            break;
        case 3:{
            self.typeLabel.text = @"在线支付";
            sysStr = @"-";
            self.moneyLabel.textColor = kApp333Color;
        }
            break;
        case 4:{
            self.typeLabel.text = @"退款";
            sysStr = @"+";
            self.moneyLabel.textColor = UIColorFromRGB(0xFF4949);
            if (status == 0) {
                NSString *str = self.typeLabel.text;
                self.typeLabel.text = [NSString stringWithFormat:@"%@ (进行中)",str];
            }
        }
            break;
            
        default:
            self.typeLabel.text = @"其它";
            sysStr = @"-";
            self.moneyLabel.textColor = kApp333Color;
            if (status == 0) {
                NSString *str = self.typeLabel.text;
                self.typeLabel.text = [NSString stringWithFormat:@"%@ (进行中)",str];
            }
            break;
    }
    
    self.moneyLabel.text = [NSString stringWithFormat:@"%@%.2f",sysStr,model.arrival_money.doubleValue];
    self.balanceLabel.text = [NSString stringWithFormat:@"余额：¥ %@",model.money];
    
    if (model.create_time.length > 9) {
        _timeLabel.text = [Tool dateFormatter:model.create_time.doubleValue dateFormatter:@"yyyy-MM-dd HH:mm:ss"];
    }else{
        _timeLabel.text = @"";
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
