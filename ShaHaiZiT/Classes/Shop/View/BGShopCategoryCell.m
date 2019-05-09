//
//  BGShopCategoryCell.m
//  shzTravelC
//
//  Created by 孙林茂 on 2018/5/10.
//  Copyright © 2018年 biao. All rights reserved.
//

#import "BGShopCategoryCell.h"
#import "BGShopCategoryModel.h"

@interface BGShopCategoryCell()
@property (weak, nonatomic) IBOutlet UIButton *nameBtn;


@end
@implementation BGShopCategoryCell

- (void)awakeFromNib {
    [super awakeFromNib];

}

- (void)updataWithCellArray:(BGShopCategoryModel *)model{
    [self.nameBtn setTitle:model.name forState:(UIControlStateNormal)];
    [self.nameBtn setTitle:model.name forState:(UIControlStateHighlighted)];
}


- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
    if (selected) {
        [self.nameBtn setTitleColor:kAppWhiteColor forState:(UIControlStateNormal)];
        [self.nameBtn setTitleColor:kAppWhiteColor forState:(UIControlStateHighlighted)];
        [self.nameBtn setBackgroundColor:kAppMainColor];
        [self.nameBtn.titleLabel setFont:[UIFont systemFontOfSize:13]];
        self.nameBtn.layer.cornerRadius = 13;
    }else{
        [self.nameBtn setTitleColor:kApp333Color forState:(UIControlStateNormal)];
        [self.nameBtn setTitleColor:kApp333Color forState:(UIControlStateHighlighted)];
        [self.nameBtn setBackgroundColor:kAppWhiteColor];
        [self.nameBtn.titleLabel setFont:kFont(13)];
        self.nameBtn.layer.cornerRadius = 0;
    }
    

    
}

@end
