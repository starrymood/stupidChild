//
//  BGAirRightCell.m
//  shzTravelC
//
//  Created by biao on 2018/8/20.
//  Copyright © 2018年 biao. All rights reserved.
//

#import "BGAirRightCell.h"
#import "BGAirportCategoryModel.h"
#import <UIImageView+WebCache.h>

@interface BGAirRightCell()
@property (weak, nonatomic) IBOutlet UIImageView *airBgImgView;
@property (weak, nonatomic) IBOutlet UILabel *airCityLabel;
@property (weak, nonatomic) IBOutlet UILabel *airPortLabel;
@property (weak, nonatomic) IBOutlet UILabel *carLabel;

@end
@implementation BGAirRightCell

- (void)updataWithCellArray:(BGAirportCategoryModel *)model isCar:(BOOL)isCar{
    if (isCar) {
        self.carLabel.hidden = NO;
        self.airCityLabel.hidden = YES;
        self.airPortLabel.hidden = YES;
        if ([Tool isBlankString:model.region_name]) {
            if ([Tool isBlankString:model.name]) {
                self.carLabel.text = [NSString stringWithFormat:@"%@",model.country_name];
            }else{
                self.carLabel.text = [NSString stringWithFormat:@"%@",model.name];
            }
            
        }else{
            self.carLabel.text = [NSString stringWithFormat:@"%@",model.region_name];
        }
        
        self.carLabel.adjustsFontSizeToFitWidth = YES;
        self.carLabel.minimumScaleFactor =0.5;
        [self.airBgImgView sd_setImageWithURL:[NSURL URLWithString:model.picture] placeholderImage:BGImage(@"img_placeholder")];
    }else{
        self.carLabel.hidden = YES;
        self.airCityLabel.hidden = NO;
        self.airPortLabel.hidden = NO;
        self.airCityLabel.text = model.region_name;
        self.airPortLabel.text = model.airport_name;
        self.airCityLabel.adjustsFontSizeToFitWidth = YES;
        self.airPortLabel.adjustsFontSizeToFitWidth = YES;
        [self.airBgImgView sd_setImageWithURL:[NSURL URLWithString:model.picture] placeholderImage:BGImage(@"img_placeholder")];
    }
    
}
- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

@end
