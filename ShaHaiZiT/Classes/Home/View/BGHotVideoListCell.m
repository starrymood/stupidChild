//
//  BGHotVideoListCell.m
//  shzTravelC
//
//  Created by biao on 2018/7/23.
//  Copyright © 2018年 biao. All rights reserved.
//

#import "BGHotVideoListCell.h"
#import "BGHomeHotVideoModel.h"
#import <UIImageView+WebCache.h>

@interface BGHotVideoListCell()
@property (weak, nonatomic) IBOutlet UILabel *videoTitleLabel;
@property (weak, nonatomic) IBOutlet UIImageView *videoImgView;
@property (weak, nonatomic) IBOutlet UIButton *videoConcernBtn;
@property (weak, nonatomic) IBOutlet UIButton *videoCollectionBtn;
@property (weak, nonatomic) IBOutlet UIButton *videoWatchBtn;

@end
@implementation BGHotVideoListCell


-(void)updataWithCellArray:(BGHomeHotVideoModel *)model{
    self.videoTitleLabel.text = model.video_title;
    [self.videoImgView sd_setImageWithURL:[NSURL URLWithString:model.video_image] placeholderImage:BGImage(@"img_cycle_placeholder")];
    [self.videoConcernBtn setTitle:[NSString stringWithFormat:@"%@人",model.like_count] forState:(UIControlStateNormal)];
    [self.videoCollectionBtn setTitle:[NSString stringWithFormat:@"%@人",model.collect_count] forState:(UIControlStateNormal)];
//    [self.videoWatchBtn setTitle:[NSString stringWithFormat:@"%@人观看",model.watch_number] forState:(UIControlStateNormal)];
}

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
