//
//  BGHotVideoCell.m
//  shzTravelC
//
//  Created by biao on 2018/7/23.
//  Copyright © 2018年 biao. All rights reserved.
//

#import "BGHotVideoCell.h"
#import "BGHomeHotVideoModel.h"
#import <UIImageView+WebCache.h>

@interface BGHotVideoCell()
@property (weak, nonatomic) IBOutlet UIImageView *videoImgView;
@property (weak, nonatomic) IBOutlet UILabel *areaNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *areaRecommendationLabel;

@end
@implementation BGHotVideoCell


-(void)updataWithCellArray:(BGHomeHotVideoModel *)model isFood:(BOOL)isFood{
       
    [self.videoImgView sd_setImageWithURL:[NSURL URLWithString:model.cover_picture] placeholderImage:BGImage(@"img_placeholder")];
    self.areaRecommendationLabel.text = model.title;
    if (isFood) {
        self.areaNameLabel.text = model.country_name;
    }else{
        self.areaNameLabel.text = [NSString stringWithFormat:@"%@-%@",model.country_name,model.region_name];
    }
}

- (void)awakeFromNib {
    [super awakeFromNib];
}

@end
