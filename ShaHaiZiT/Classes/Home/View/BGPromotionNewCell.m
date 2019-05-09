//
//  BGPromotionNewCell.m
//  shzTravelC
//
//  Created by biao on 2018/9/13.
//  Copyright © 2018年 biao. All rights reserved.
//

#import "BGPromotionNewCell.h"
#import "BGPromotionNewModel.h"
#import <UIImageView+WebCache.h>

@interface BGPromotionNewCell()
@property (weak, nonatomic) IBOutlet UIImageView *imgView;
@property (weak, nonatomic) IBOutlet UILabel *titleeLabel;
@property (weak, nonatomic) IBOutlet UILabel *subTitleLabel;
@property (weak, nonatomic) IBOutlet UILabel *timeLabel;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *subTitleHeight;

@end
@implementation BGPromotionNewCell

-(void)updataWithCellArray:(BGPromotionNewModel *)model{
    NSString *pictureStr = [Tool isBlankString:model.mainPicture]? model.main_picture:model.mainPicture;
    [self.imgView sd_setImageWithURL:[NSURL URLWithString:pictureStr] placeholderImage:BGImage(@"img_cycle_placeholder")];
    
    NSString *titleStr = [Tool isBlankString:model.activityTitle]? model.activity_title:model.activityTitle;
    self.titleeLabel.text = titleStr;
    self.subTitleLabel.text = @"活动";
    NSString *subtitleStr = [Tool isBlankString:model.activity_subtitle]? model.activitySubtitle:model.activity_subtitle;
    NSInteger lineNum = [self needLinesWithWidth:(SCREEN_WIDTH-25-20) text:subtitleStr];
    self.subTitleLabel.numberOfLines = lineNum;
    self.subTitleHeight.constant = lineNum*14.5;
    self.subTitleLabel.text = subtitleStr;
NSString *start_time = [Tool isBlankString:model.start_time]? model.startTime:model.start_time;
    NSString *end_time = [Tool isBlankString:model.end_time]? model.endTime:model.end_time;
    NSString *aStr = [Tool dateFormatter:start_time.doubleValue dateFormatter:@"yyyy-MM-dd HH:ss"];
    NSString *bStr = [Tool dateFormatter:end_time.doubleValue dateFormatter:@"yyyy-MM-dd HH:ss"];
    self.timeLabel.text = [NSString stringWithFormat:@"%@--%@",aStr,bStr];
}

/**
 显示当前文字需要几行
 
 @param width 给定一个宽度
 @return 返回行数
 */
- (NSInteger)needLinesWithWidth:(CGFloat)width text:(NSString *)text{
    //创建一个labe
    UILabel * label = [[UILabel alloc]init];
    //font和当前label保持一致
    label.font = kFont(12);
    NSInteger sum = 0;
    //总行数受换行符影响，所以这里计算总行数，需要用换行符分隔这段文字，然后计算每段文字的行数，相加即是总行数。
    NSArray * splitText = [text componentsSeparatedByString:@"\n"];
    for (NSString * sText in splitText) {
        label.text = sText;
        //获取这段文字一行需要的size
        CGSize textSize = [label systemLayoutSizeFittingSize:CGSizeZero];
        //size.width/所需要的width 向上取整就是这段文字占的行数
        NSInteger lines = ceilf(textSize.width/width);
        //当是0的时候，说明这是换行，需要按一行算。
        lines = lines == 0?1:lines;
        sum += lines;
    }
    if ([Tool isBlankString:text]) {
        return 0;
    }
    return sum;
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
