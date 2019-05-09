//
//  BGLocalRecommendCell.m
//  ShaHaiZiT
//
//  Created by biao on 2019/3/27.
//  Copyright © 2019 biao. All rights reserved.
//

#import "BGLocalRecommendCell.h"
#import "BGLocalSpecialModel.h"
#import <UIImageView+WebCache.h>

@interface BGLocalRecommendCell()
@property (weak, nonatomic) IBOutlet UIImageView *picImgView;
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UILabel *briefLabel;

@end
@implementation BGLocalRecommendCell


- (void)updataWithCellArray:(BGLocalSpecialModel *)model{
    if ([Tool arrayIsNotEmpty:model.picture]) {
        [_picImgView sd_setImageWithURL:[NSURL URLWithString:model.picture[0]]];
    }
    self.nameLabel.text = model.title;
    self.briefLabel.text = model.recommended_reason;
    
}

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

@end
