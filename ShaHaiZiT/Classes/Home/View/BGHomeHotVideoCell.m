//
//  BGHomeHotVideoCell.m
//  ShaHaiZiT
//
//  Created by biao on 2018/11/21.
//  Copyright © 2018 biao. All rights reserved.
//

#import "BGHomeHotVideoCell.h"
#import "BGHomeHotVideoModel.h"
#import <UIImageView+WebCache.h>

@interface BGHomeHotVideoCell()
@property (weak, nonatomic) IBOutlet UIImageView *videoImgView;
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UILabel *englishNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *tagLabel;
@property (weak, nonatomic) IBOutlet UILabel *countryNameLabel;

@end
@implementation BGHomeHotVideoCell

-(void)updataWithCellArray:(BGHomeHotVideoModel *)model{
    [self.videoImgView sd_setImageWithURL:[NSURL URLWithString:model.talent_cover_picture] placeholderImage:BGImage(@"img_placeholder")];
    self.nameLabel.text = model.talent_name;
    self.englishNameLabel.text = model.talent_english_name;
    self.tagLabel.text = model.talent_tag;
    self.countryNameLabel.text = model.country_name;

}
- (void)awakeFromNib {
    [super awakeFromNib];
}

@end
