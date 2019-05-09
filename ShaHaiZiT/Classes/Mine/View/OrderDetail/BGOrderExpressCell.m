//
//  BGOrderExpressCell.m
//  shzTravelC
//
//  Created by 孙林茂 on 2018/5/11.
//  Copyright © 2018年 biao. All rights reserved.
//

#import "BGOrderExpressCell.h"

@interface BGOrderExpressCell()
@property (weak, nonatomic) IBOutlet UIImageView *expressImgView;
@property (weak, nonatomic) IBOutlet UILabel *expressStatusLabel;
@property (weak, nonatomic) IBOutlet UILabel *expressNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *expressInfoLabel;
@property (weak, nonatomic) IBOutlet UILabel *expressTimeLabel;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *lineBottomHeight;

@end
@implementation BGOrderExpressCell

-(void)updataWithCellArray:(NSDictionary *)dic PayType:(int)payType{
    
   
    
    switch (payType) {  // 1：待付款；2：待发货；3：待收货；5：已完成；6：已关闭；7：售后
        case 2:{
            [self.expressImgView setImage:BGImage(@"mine_order_pendingSend")];
            self.expressStatusLabel.text = @"等待发货";
            [self.expressNameLabel removeFromSuperview];
            [self.expressInfoLabel removeFromSuperview];
            [self.expressTimeLabel removeFromSuperview];
            self.lineBottomHeight.constant = 0;
        }
            break;
        case 3:{
            [self.expressImgView setImage:BGImage(@"order_shipped_icon")];
            self.expressStatusLabel.text = @"卖家已发货";
            if ([Tool isBlankDictionary:dic]) {
                [self.expressNameLabel removeFromSuperview];
                [self.expressInfoLabel removeFromSuperview];
                [self.expressTimeLabel removeFromSuperview];
                self.lineBottomHeight.constant = 0;
            }else{
                self.expressNameLabel.text = BGdictSetObjectIsNil(dic[@"com"]);
                self.expressInfoLabel.text = BGdictSetObjectIsNil(dic[@"context"]);
                self.expressTimeLabel.text = BGdictSetObjectIsNil(dic[@"time"]);
            }
        }
            break;
        case 5:{
            [self.expressImgView setImage:BGImage(@"mine_order_done")];
            self.expressStatusLabel.text = @"交易已完成";
            if ([Tool isBlankDictionary:dic]) {
                [self.expressNameLabel removeFromSuperview];
                [self.expressInfoLabel removeFromSuperview];
                [self.expressTimeLabel removeFromSuperview];
                self.lineBottomHeight.constant = 0;
            }else{
                self.expressNameLabel.text = BGdictSetObjectIsNil(dic[@"com"]);
                self.expressInfoLabel.text = BGdictSetObjectIsNil(dic[@"context"]);
                self.expressTimeLabel.text = BGdictSetObjectIsNil(dic[@"time"]);
            }
        }
            break;
        case 6:{
            
        }
            break;
        case 7:{
            [self.expressImgView setImage:BGImage(@"order_after_sale_icon")];
            self.expressStatusLabel.text = @"申请售后";
            if ([Tool isBlankDictionary:dic]) {
                [self.expressNameLabel removeFromSuperview];
                [self.expressInfoLabel removeFromSuperview];
                [self.expressTimeLabel removeFromSuperview];
                self.lineBottomHeight.constant = 0;
            }else{
                self.expressNameLabel.text = BGdictSetObjectIsNil(dic[@"com"]);
                self.expressInfoLabel.text = BGdictSetObjectIsNil(dic[@"context"]);
                self.expressTimeLabel.text = BGdictSetObjectIsNil(dic[@"time"]);
            }
        }
            break;
        case 8:{
            [self.expressImgView setImage:BGImage(@"order_after_sale_icon")];
            self.expressStatusLabel.text = @"售后完成";
            if ([Tool isBlankDictionary:dic]) {
                [self.expressNameLabel removeFromSuperview];
                [self.expressInfoLabel removeFromSuperview];
                [self.expressTimeLabel removeFromSuperview];
                self.lineBottomHeight.constant = 0;
            }else{
                self.expressNameLabel.text = BGdictSetObjectIsNil(dic[@"com"]);
                self.expressInfoLabel.text = BGdictSetObjectIsNil(dic[@"context"]);
                self.expressTimeLabel.text = BGdictSetObjectIsNil(dic[@"time"]);
            }
        }
            break;
            
        default:
            break;
    }
}

@end
