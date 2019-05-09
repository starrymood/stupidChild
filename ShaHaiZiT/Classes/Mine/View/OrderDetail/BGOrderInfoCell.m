//
//  BGOrderInfoCell.m
//  shzTravelC
//
//  Created by 孙林茂 on 2018/5/11.
//  Copyright © 2018年 biao. All rights reserved.
//

#import "BGOrderInfoCell.h"

@interface BGOrderInfoCell()
@property (weak, nonatomic) IBOutlet UILabel *goodsPriceLabel;
@property (weak, nonatomic) IBOutlet UILabel *goodsFreightLabel;
@property (weak, nonatomic) IBOutlet UILabel *goodsActivityLabel;

@end
@implementation BGOrderInfoCell

- (void)updataWithCellArray:(NSDictionary *)dic isPay:(BOOL)isPay{
    
    if (isPay) {
        self.goodsPriceLabel.text = [NSString stringWithFormat:@"¥ %.2f",[BGdictSetObjectIsNil(dic[@"total_account"]) doubleValue]];
        self.goodsFreightLabel.text = [NSString stringWithFormat:@"¥ %.2f",[BGdictSetObjectIsNil(dic[@"ship_account"]) doubleValue]];
        self.goodsActivityLabel.text = [NSString stringWithFormat:@"¥ -%.2f",[BGdictSetObjectIsNil(dic[@"activity_account"]) doubleValue]];
    }else{
        self.goodsPriceLabel.text = [NSString stringWithFormat:@"¥ %.2f",[BGdictSetObjectIsNil(dic[@"goods_amount"]) doubleValue]];
        self.goodsFreightLabel.text = [NSString stringWithFormat:@"¥ %.2f",[BGdictSetObjectIsNil(dic[@"shipping_amount"]) doubleValue]];
        self.goodsCouponLabel.text = [NSString stringWithFormat:@"¥ -%.2f",[BGdictSetObjectIsNil(dic[@"discount"]) doubleValue]];
        self.goodsActivityLabel.text = [NSString stringWithFormat:@"¥ -%.2f",[BGdictSetObjectIsNil(dic[@"act_discount"]) doubleValue]];
    }
    
}


@end
