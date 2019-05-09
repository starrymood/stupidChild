//
//  BGAirCategoryCell.m
//  shzTravelC
//
//  Created by biao on 2018/8/20.
//  Copyright © 2018年 biao. All rights reserved.
//

#import "BGAirCategoryCell.h"
#import "BGAirportCategoryModel.h"

@interface BGAirCategoryCell()
@property (weak, nonatomic) IBOutlet UIButton *nameBtn;
@property (weak, nonatomic) IBOutlet UIImageView *selectedIndicator;
@property (nonatomic, assign) BOOL isShowIndicator;

@end
@implementation BGAirCategoryCell

- (void)awakeFromNib {
    [super awakeFromNib];
    
}

- (void)updataWithCellArray:(BGAirportCategoryModel *)model isShow:(BOOL)isShow{
    [self.nameBtn setTitle:model.name forState:(UIControlStateNormal)];
    if (isShow) {
        self.nameBtn.backgroundColor = kAppWhiteColor;
        self.backgroundColor = kAppWhiteColor;
    }else{
        self.nameBtn.backgroundColor = kAppBgColor;
        self.backgroundColor = kAppBgColor;
    }
    if (isShow) {
        if (model.ID.intValue == 24) {
            self.nameBtn.tag = 3333;
        }
        _isShowIndicator = isShow;
    }

}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
    if (_isShowIndicator) {
        self.selectedIndicator.hidden = !selected;
    }else{
        self.selectedIndicator.hidden = YES;
    }

    if(selected){
        [self.nameBtn setTitleColor:kAppMainColor forState:(UIControlStateNormal)];
        [self.nameBtn.titleLabel setFont:[UIFont boldSystemFontOfSize:13]];
        if (_isShowIndicator) {
            self.nameBtn.backgroundColor = kAppBgColor;
        }
    }else{
        if (_isShowIndicator) {
            if (self. nameBtn.tag == 3333) {
                [self.nameBtn setTitleColor:UIColorFromRGB(0xFF4848) forState:(UIControlStateNormal)];
            }else{
                [self.nameBtn setTitleColor:kApp666Color forState:(UIControlStateNormal)];
            }
            self.nameBtn.backgroundColor = kAppClearColor;

        }
        [self.nameBtn setTitleColor:kApp666Color forState:(UIControlStateNormal)];

        [self.nameBtn.titleLabel setFont:kFont(13)];
    }
}

@end
