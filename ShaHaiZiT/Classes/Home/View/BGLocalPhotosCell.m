//
//  BGLocalPhotosCell.m
//  ShaHaiZiT
//
//  Created by biao on 2019/3/28.
//  Copyright © 2019 biao. All rights reserved.
//

#import "BGLocalPhotosCell.h"
#import <UIImageView+WebCache.h>

@interface BGLocalPhotosCell()
@property (weak, nonatomic) IBOutlet UIImageView *photoImgView;

@end
@implementation BGLocalPhotosCell

-(void)updataWithCellArr:(NSString *)picUrl{
    [_photoImgView sd_setImageWithURL:[NSURL URLWithString:picUrl]];
    
}

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

@end
