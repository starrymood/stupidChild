//
//  BGLocalMemoryCell.m
//  ShaHaiZiT
//
//  Created by biao on 2019/3/28.
//  Copyright © 2019 biao. All rights reserved.
//

#import "BGLocalMemoryCell.h"
#import "BGLocalPersonModel.h"
#import <UIImageView+WebCache.h>

@interface BGLocalMemoryCell()
@property (weak, nonatomic) IBOutlet UILabel *timeLabel;
@property (weak, nonatomic) IBOutlet UILabel *cityLabel;
@property (weak, nonatomic) IBOutlet UIImageView *oneImgView;
@property (weak, nonatomic) IBOutlet UIImageView *twoImgView;
@property (weak, nonatomic) IBOutlet UIImageView *threeImgView;
@property (weak, nonatomic) IBOutlet UILabel *contentLabel;

@end
@implementation BGLocalMemoryCell


-(void)updataWithCellArr:(BGLocalPersonModel *)model{
    if (model.create_time.length>8) {
        self.timeLabel.text = [Tool dateFormatter:model.create_time.doubleValue dateFormatter:@"yyyy-MM-dd"];
    }else{
        self.timeLabel.text = @"0000-00-00";
    }
    self.cityLabel.text = [NSString stringWithFormat:@"%@%@",model.country_name,model.region_name];
    _oneImgView.hidden = YES;
    _twoImgView.hidden = YES;
    _threeImgView.hidden = YES;
    if ([Tool arrayIsNotEmpty:model.landscape_picture]) {
        for (int i = 0; i<model.landscape_picture.count; i++) {
            if (i==0) {
                _oneImgView.hidden = NO;
                [_oneImgView sd_setImageWithURL:[NSURL URLWithString:model.landscape_picture[i]]];
            }else if (i == 2){
                _twoImgView.hidden = NO;
                [_twoImgView sd_setImageWithURL:[NSURL URLWithString:model.landscape_picture[i-1]]];
                _threeImgView.hidden = NO;
                [_threeImgView sd_setImageWithURL:[NSURL URLWithString:model.landscape_picture[i]]];
            }
        }
    }
    
    self.contentLabel.text = model.content;
    
    
}

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
    self.layer.cornerRadius = 15.0;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
