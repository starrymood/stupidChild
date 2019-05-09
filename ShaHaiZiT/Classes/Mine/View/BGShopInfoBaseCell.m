//
//  BGShopInfoBaseCell.m
//  shzTravelC
//
//  Created by 孙林茂 on 2018/5/11.
//  Copyright © 2018年 biao. All rights reserved.
//

#import "BGShopInfoBaseCell.h"
#import "BGShopModel.h"
#import <UIImageView+WebCache.h>

@interface BGShopInfoBaseCell()
@property (weak, nonatomic) IBOutlet UIImageView *goodsImgView;
@property (weak, nonatomic) IBOutlet UILabel *goodsNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *goodsSpecsLabel;
@property (weak, nonatomic) IBOutlet UILabel *goodsPriceLabel;
@property (weak, nonatomic) IBOutlet UILabel *goodsNumLabel;
@property (weak, nonatomic) IBOutlet UIButton *applyAfterSaleBtn;
@property (nonatomic, copy) NSString *itemId;
@property (nonatomic, copy) NSString *itemNum;

@end
@implementation BGShopInfoBaseCell


-(void)updataWithCellArray:(BGShopModel *)model orderStatus:(int)status{
    
    _itemId = model.item_id;
    _itemNum = model.num;
    
    if (status == 5) {
        if (model.sellback_state.intValue == 0) {
            self.applyAfterSaleBtn.hidden = NO;
            [self.applyAfterSaleBtn setTitle:@"申请售后" forState:(UIControlStateNormal)];
        }
    }else if (status == 7 || status == 8){
        self.applyAfterSaleBtn.hidden = NO;

        switch (model.sellback_state.intValue) {
            case 0:{
                [self.applyAfterSaleBtn setTitle:@"申请售后" forState:(UIControlStateNormal)];
            }
                break;
            case 1:{
                [self.applyAfterSaleBtn setTitle:@"申请售后中" forState:(UIControlStateNormal)];
            }
                break;
            case 2:{
                [self.applyAfterSaleBtn setTitle:@"售后完成" forState:(UIControlStateNormal)];
            }
                break;
            case 3:{
                [self.applyAfterSaleBtn setTitle:@"售后拒绝" forState:(UIControlStateNormal)];
            }
                break;
            case 4:{
                [self.applyAfterSaleBtn setTitle:@"商家已通过" forState:(UIControlStateNormal)];
            }
                break;
                
            default:
                break;
        }
        
    }else{
        self.applyAfterSaleBtn.hidden = YES;
    }
    
    
        [self.goodsImgView sd_setImageWithURL:[NSURL URLWithString:model.goods_picture] placeholderImage:BGImage(@"img_placeholder")];
    
        self.goodsNameLabel.text = model.name;
   

    self.goodsSpecsLabel.text = model.norm_name;
    self.goodsPriceLabel.text = [NSString stringWithFormat:@"¥ %.2f",model.price.doubleValue];
    self.goodsNumLabel.text = [NSString stringWithFormat:@"x %@",model.num];
    
}

- (void)awakeFromNib {
    [super awakeFromNib];
    self.applyAfterSaleBtn.layer.borderColor = kAppMainColor.CGColor;
    self.applyAfterSaleBtn.layer.borderWidth = 1;
    self.applyAfterSaleBtn.layer.cornerRadius = 5;
}


- (IBAction)btnApplyForAfterSaleActionClicked:(UIButton *)sender {
    if (self.afterSaleBtnClick) {
        self.afterSaleBtnClick(_itemId, [NSString stringWithFormat:@"%@:%@",_itemNum,sender.titleLabel.text]);
    }
}

@end
