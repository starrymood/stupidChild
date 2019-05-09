//
//  BGShoppingCartCell.m
//  LLMall
//
//  Created by biao on 2016/11/8.
//  Copyright © 2016年 ZZLL. All rights reserved.
//

#import "BGShoppingCartCell.h"
#import "BGAjustNumButton.h"
#import "BGShopModel.h"
#import <UIImageView+WebCache.h>

@interface BGShoppingCartCell()

@property (weak, nonatomic) IBOutlet UILabel *goodsTitleLabel;
@property (weak, nonatomic) IBOutlet UILabel *goodsDetailLabel;
@property (weak, nonatomic) IBOutlet UILabel *goodsPriceLabel;
@property (weak, nonatomic) IBOutlet UIImageView *goodsImgView;
@property(assign,nonatomic)BOOL selectState;//选中状态
@property (nonatomic,strong) BGAjustNumButton *btn;

@end
@implementation BGShoppingCartCell
- (void)updataWithCellArray:(BGShopModel *)model {
    self.goodsTitleLabel.text = model.name;
    self.goodsDetailLabel.text = model.norm_name;
    self.goodsPriceLabel.text = [NSString stringWithFormat:@"¥%.2f",model.price.doubleValue];
    [self.goodsImgView sd_setImageWithURL:[NSURL URLWithString:model.goods_picture] placeholderImage:BGImage(@"img_placeholder")];
    _btn.currentNum = [NSString stringWithFormat:@"%@",model.num];
    
    if (model.selectState)
    {
        _selectState = NO;
        [self.isSelectBtn setImage:[UIImage imageNamed:@"shopping_cart_selected"] forState:UIControlStateNormal];
        
    }else{
        _selectState = YES;
        [self.isSelectBtn setImage:[UIImage imageNamed:@"shopping_cart_default"] forState:UIControlStateNormal];
    }
}


- (void)awakeFromNib {
    [super awakeFromNib];
    
    // BGAjustNumButton
    self.btn = [[BGAjustNumButton alloc] init];
    [_btn setFrame:CGRectMake(SCREEN_WIDTH-15-95, 82, 95, 23)];
    // 边框颜色
    _btn.lineColor = [UIColor lightGrayColor];
    // 内容更改的block回调
    __weak typeof (self)weakself = self;
    _btn.callBack = ^(NSString *currentNum){
        weakself.numChangeBtnClicked(currentNum);
    };
    [self addSubview:_btn];
    
    
    
}

// 选择按钮的响应事件
- (IBAction)goodsSelectedBtnClickedAction:(UIButton *)sender {
    if (self.singleSelectClicked) {
        self.singleSelectClicked();
    }
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
    
    // Configure the view for the selected state
}

@end
