//
//  BGOrderPayInfoCell.m
//  shzTravelC
//
//  Created by 孙林茂 on 2018/5/11.
//  Copyright © 2018年 biao. All rights reserved.
//

#import "BGOrderPayInfoCell.h"

@interface BGOrderPayInfoCell()
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *uploadTimeDistance;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *payTimeDistance;
@property (weak, nonatomic) IBOutlet UILabel *orderIdLabel;
@property (weak, nonatomic) IBOutlet UILabel *orderUploadTimeLabel;
@property (weak, nonatomic) IBOutlet UILabel *orderPayWayLabel;
@property (weak, nonatomic) IBOutlet UILabel *orderPayTimeLabel;
@property (weak, nonatomic) IBOutlet UILabel *orderPayMoneyLabel;
@property (weak, nonatomic) IBOutlet UILabel *orderSendTimeLabel;
@property (nonatomic) int isPayType;    // 1：待付款；2：待发货；3：待收货；5：已完成；6：已关闭；7：售后

@end
@implementation BGOrderPayInfoCell

-(void)updataWithCellArray:(NSDictionary *)dic PayType:(int)payType{
    switch (payType) {
        case 1:{
            [self.orderPayWayLabel removeFromSuperview];
            [self.orderPayTimeLabel removeFromSuperview];
            [self.orderPayMoneyLabel removeFromSuperview];
            [self.orderSendTimeLabel removeFromSuperview];
            _uploadTimeDistance.constant = 10;
            self.orderIdLabel.text = [NSString stringWithFormat:@"订单编号:   %@",BGdictSetObjectIsNil(dic[@"order_number"])];
            self.orderUploadTimeLabel.text = [NSString stringWithFormat:@"提交时间:   %@",[Tool dateFormatter:[BGdictSetObjectIsNil(dic[@"create_time"]) doubleValue] dateFormatter:@"yyyy-MM-dd HH:mm:ss"]];
        }
            break;
        case 2:{
            [self.orderSendTimeLabel removeFromSuperview];
            _uploadTimeDistance.constant = 88;
            _payTimeDistance.constant = 10;
        }
            
        case 3:{
            
        }

        case 5:{
           
        }
        case 7:{
            
        }
        case 8:{
            self.orderIdLabel.text = [NSString stringWithFormat:@"订单编号:   %@",BGdictSetObjectIsNil(dic[@"order_number"])];
            self.orderUploadTimeLabel.text = [NSString stringWithFormat:@"提交时间:   %@",[Tool dateFormatter:[BGdictSetObjectIsNil(dic[@"create_time"]) doubleValue] dateFormatter:@"yyyy-MM-dd HH:mm:ss"]];
            self.orderPayWayLabel.text = [NSString stringWithFormat:@"支付方式:   %@",BGdictSetObjectIsNil(dic[@"payment_name"])];
            self.orderPayMoneyLabel.text = [NSString stringWithFormat:@"实付金额:   ¥ %.2f",[BGdictSetObjectIsNil(dic[@"pay_money"]) doubleValue]];
            self.orderPayTimeLabel.text = [NSString stringWithFormat:@"付款时间:   %@",[Tool dateFormatter:[BGdictSetObjectIsNil(dic[@"pay_time"]) doubleValue] dateFormatter:@"yyyy-MM-dd HH:mm:ss"]];
            if (![Tool isBlankString:BGdictSetObjectIsNil(dic[@"allocation_time"])]) {
                self.orderSendTimeLabel.text = [NSString stringWithFormat:@"发货时间:   %@",[Tool dateFormatter:[BGdictSetObjectIsNil(dic[@"allocation_time"]) doubleValue] dateFormatter:@"yyyy-MM-dd HH:mm:ss"]];
            }
            
        }
            break;
        case 6:{
            [self.orderPayWayLabel removeFromSuperview];
            [self.orderPayTimeLabel removeFromSuperview];
            [self.orderPayMoneyLabel removeFromSuperview];
            [self.orderSendTimeLabel removeFromSuperview];
            _uploadTimeDistance.constant = 10;
            self.orderIdLabel.text = [NSString stringWithFormat:@"订单编号:   %@",BGdictSetObjectIsNil(dic[@"order_number"])];
            self.orderUploadTimeLabel.text = [NSString stringWithFormat:@"提交时间:   %@",[Tool dateFormatter:[BGdictSetObjectIsNil(dic[@"create_time"]) doubleValue] dateFormatter:@"yyyy-MM-dd HH:mm:ss"]];
        }
            break;
            
        default:
            break;
    }
    
    
}





@end
