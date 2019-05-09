//
//  BGEssayCommentCell.m
//  shzTravelC
//
//  Created by biao on 2018/7/31.
//  Copyright © 2018年 biao. All rights reserved.
//

#import "BGEssayCommentCell.h"
#import "BGEssayCommentFirstModel.h"
#import <UIImageView+WebCache.h>
#import "BGEssayCommentSModel.h"
#import "BGEssayCommentFirstModel.h"


@interface BGEssayCommentCell()
@property (weak, nonatomic) IBOutlet UIImageView *firstHeadImgView;
@property (weak, nonatomic) IBOutlet UILabel *firstNickNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *firstContentLabel;
@property (weak, nonatomic) IBOutlet UILabel *firstPostTimeLabel;
@property (weak, nonatomic) IBOutlet UIImageView *sHeadImgView;

@property (weak, nonatomic) IBOutlet UILabel *sContentLabel;
@property (weak, nonatomic) IBOutlet UILabel *sPostTimeLabel;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *sViewHeight;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *firstContentHeight;

@property (weak, nonatomic) IBOutlet UIView *sView;

@end
@implementation BGEssayCommentCell


- (void)updataWithCellArray:(BGEssayCommentFirstModel *)model{
    if (model.is_review_like.intValue == 1) {
        [_firstLikeBtn setImage:BGImage(@"essay_bottom_like_green") forState:(UIControlStateNormal)];
        [_firstLikeBtn setTitle:model.review_like_count forState:(UIControlStateNormal)];
        [_firstLikeBtn setTitleColor:kAppMainColor forState:(UIControlStateNormal)];
    }else{
        [_firstLikeBtn setImage:BGImage(@"essay_bottom_like_white") forState:(UIControlStateNormal)];
        [_firstLikeBtn setTitle:model.review_like_count forState:(UIControlStateNormal)];
        [_firstLikeBtn setTitleColor:kApp666Color forState:(UIControlStateNormal)];
    }
    
    [self.firstHeadImgView sd_setImageWithURL:[NSURL URLWithString:model.face] placeholderImage:BGImage(@"defaultUserIcon")];
    self.firstNickNameLabel.text = model.nickname;
    
    NSInteger lineNum = [self needLinesWithWidth:(SCREEN_WIDTH-30-29) text:model.review_body];
    self.firstContentHeight.constant = lineNum*14.5;
    self.firstContentLabel.text = model.review_body;
    self.firstPostTimeLabel.text = [Tool dateFormatter:model.create_time.doubleValue dateFormatter:@"yyyy-MM-dd HH:mm"];
    
    if ([Tool arrayIsNotEmpty:model.children_review]) {
        [self.sView setHidden:NO];
        BGEssayCommentSModel *sModel = [BGEssayCommentSModel mj_objectWithKeyValues:model.children_review[0]];
        
        NSInteger sLineNum = [self needLinesWithWidth:(SCREEN_WIDTH-30-12-10-29) text:sModel.review_body];
        
        
        if (model.children_review.count>1) {
            self.sViewHeight.constant = 85+(sLineNum-1)*14.5;
            [self.sAllReplyBtn setHidden:NO];
            [self.sAllReplyBtn setTitle:[NSString stringWithFormat:@"共%@条回复 >",model.children_review_count] forState:(UIControlStateNormal)];
        }else{
            self.sViewHeight.constant = 85+(sLineNum-1)*14.5-28;
            [self.sAllReplyBtn setHidden:YES];
        }
        [self.sHeadImgView sd_setImageWithURL:[NSURL URLWithString:sModel.face] placeholderImage:BGImage(@"defaultUserIcon")];
        [self.sFirstUserBtn setTitle:sModel.nickname forState:(UIControlStateNormal)];
        [self.sSUserBtn setTitle:sModel.replay_nickname forState:(UIControlStateNormal)];
        self.sContentLabel.text = sModel.review_body;
        self.sPostTimeLabel.text = [Tool dateFormatter:sModel.create_time.doubleValue dateFormatter:@"yyyy-MM-dd HH:mm"];
        
    }else{
        [self.sView setHidden:YES];
        self.sViewHeight.constant = 0;
    }
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
