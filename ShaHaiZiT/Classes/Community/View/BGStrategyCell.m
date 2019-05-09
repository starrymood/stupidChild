//
//  BGStrategyCell.m
//  shzTravelC
//
//  Created by biao on 2018/7/19.
//  Copyright © 2018年 biao. All rights reserved.
//

#import "BGStrategyCell.h"
#import "BGStrategyModel.h"
#import "UIImageView+WebCache.h"

@interface BGStrategyCell()
@property (weak, nonatomic) IBOutlet UIImageView *imgView;
@property (weak, nonatomic) IBOutlet UILabel *titleeLabel;
@property (weak, nonatomic) IBOutlet UIImageView *userImgView;
@property (weak, nonatomic) IBOutlet UILabel *userNameLabel;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *imgBottomDistance;
@property (weak, nonatomic) IBOutlet UIImageView *likeImgView;
@property (weak, nonatomic) IBOutlet UILabel *watchNumLabel;

@end
@implementation BGStrategyCell

- (void)updataWithCellArray:(BGStrategyModel *)model{
    NSString *postTitleStr ,*clickNumStr;
    postTitleStr = [Tool isBlankString:model.post_title]? model.postTitle:model.post_title;
    clickNumStr  = [Tool isBlankString:model.click_number]? model.clickNumber:model.click_number;
    NSInteger lineNum = [self needLinesWithWidth:(self.width-16) text:postTitleStr];
    switch (lineNum) {
        case 1:
            self.imgBottomDistance.constant = 73;
            self.titleeLabel.numberOfLines = 1;
            break;
        case 2:
            self.imgBottomDistance.constant = 89;
            self.titleeLabel.numberOfLines = 2;
            break;
            
        default:
            self.imgBottomDistance.constant = 105;
            self.titleeLabel.numberOfLines = 3;
            break;
    }
    
//    NSString *imgUrl = [model.picture stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]];
    [self.imgView sd_setImageWithURL:[NSURL URLWithString:model.picture] placeholderImage:BGImage(@"img_placeholder")];
    self.titleeLabel.text = postTitleStr;
    self.userNameLabel.text = model.nickname;
    [self.userImgView sd_setImageWithURL:[NSURL URLWithString:model.face] placeholderImage:BGImage(@"defaultUserIcon")];
    if (clickNumStr.integerValue>0) {
        self.watchNumLabel.hidden = NO;
        self.likeImgView.hidden = NO;
        self.watchNumLabel.text = clickNumStr;
        if ([model.is_like isEqualToString:@"1"]) {
            [self.likeImgView setImage:BGImage(@"community_cell_like")];
        }else{
            [self.likeImgView setImage:BGImage(@"community_cell_dislike")];
        }
    }
    
    
}
- (NSInteger)needLinesWithWidth:(CGFloat)width text:(NSString *)text{
    //创建一个labe
    UILabel * label = [[UILabel alloc]init];
    //font和当前label保持一致
    label.font = kFont(13);
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
@end
