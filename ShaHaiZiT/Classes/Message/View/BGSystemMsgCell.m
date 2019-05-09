//
//  BGSystemMsgCell.m
//  shzTravelC
//
//  Created by 孙林茂 on 2018/5/8.
//  Copyright © 2018年 biao. All rights reserved.
//

#import "BGSystemMsgCell.h"
#import "BGSysMsgModel.h"
#import <UIImageView+WebCache.h>

@interface BGSystemMsgCell()

@property (weak, nonatomic) IBOutlet UILabel *msgTimeLabel;
@property (weak, nonatomic) IBOutlet UILabel *msgContentLabel;
@property (weak, nonatomic) IBOutlet UIImageView *redImgView;

@end
@implementation BGSystemMsgCell

-(void)updataWithCellArray:(BGSysMsgModel *)model{
    
    if ([Tool isBlankString:model.is_receive]) {
        self.redImgView.hidden = model.is_read.intValue == 1? YES:NO;
    }else{
        self.redImgView.hidden = model.is_receive.intValue == 1? YES:NO;
    }
    
    if (model.create_time.length == 10) {
        _msgTimeLabel.text = [Tool dateFormatter:model.create_time.doubleValue dateFormatter:@"yyyy-MM-dd HH:mm"];
    }else{
        _msgTimeLabel.text = @"";
    }
    _msgContentLabel.text = model.title;
}



- (void)awakeFromNib {
    [super awakeFromNib];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
