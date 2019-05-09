//
//  BGEssayCommentOneCell.m
//  shzTravelC
//
//  Created by biao on 2018/8/1.
//  Copyright © 2018年 biao. All rights reserved.
//

#import "BGEssayCommentOneCell.h"
#import "BGEssayCommentSModel.h"
#import <UIImageView+WebCache.h>

@interface BGEssayCommentOneCell()

@property (weak, nonatomic) IBOutlet UIImageView *sHeadImgView;
@property (weak, nonatomic) IBOutlet UILabel *sContentLabel;
@property (weak, nonatomic) IBOutlet UILabel *sPostTimeLabel;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *sContentHeight;



@end
@implementation BGEssayCommentOneCell

- (void)updataWithCellArray:(BGEssayCommentSModel *)model{
    
    NSInteger lineNum = [self needLinesWithWidth:(SCREEN_WIDTH-10-10-10-25-10-12) text:model.review_body];
    self.sContentHeight.constant = lineNum*14.5;
    [self.sHeadImgView sd_setImageWithURL:[NSURL URLWithString:model.face] placeholderImage:BGImage(@"defaultUserIcon")];
    [self.sFirstUserBtn setTitle:model.nickname forState:(UIControlStateNormal)];
    [self.sSUserBtn setTitle:model.replay_nickname forState:(UIControlStateNormal)];
    self.sContentLabel.text = model.review_body;
    self.sPostTimeLabel.text = [Tool dateFormatter:model.create_time.doubleValue dateFormatter:@"yyyy-MM-dd HH:mm"];
    
    
}


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
