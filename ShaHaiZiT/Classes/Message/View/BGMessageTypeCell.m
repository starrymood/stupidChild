//
//  BGMessageTypeCell.m
//  ShaHaiZiT
//
//  Created by biao on 2018/11/23.
//  Copyright © 2018 biao. All rights reserved.
//

#import "BGMessageTypeCell.h"
#import "BGSysMsgModel.h"
#import <UIImageView+WebCache.h>
#import <YYText.h>

@interface BGMessageTypeCell()

@property (weak, nonatomic) IBOutlet UIImageView *msgHeadImgView;
@property (weak, nonatomic) IBOutlet YYLabel *msgContentLabel;
@property (weak, nonatomic) IBOutlet UILabel *msgTimeLabel;
@property (weak, nonatomic) IBOutlet UIImageView *redImgView;

@end
@implementation BGMessageTypeCell

-(void)updataWithCellArray:(BGSysMsgModel *)model{
    
    self.redImgView.hidden = model.is_read.intValue == 1? YES:NO;
  

    [self.msgHeadImgView sd_setImageWithURL:[NSURL URLWithString:model.face] placeholderImage:BGImage(@"img_placeholder")];
    UITapGestureRecognizer * tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(tapAction:)];
    [self.msgHeadImgView addGestureRecognizer:tap];
    if (model.create_time.length == 10) {
        _msgTimeLabel.text = [Tool dateFormatter:model.create_time.doubleValue dateFormatter:@"yyyy-MM-dd HH:mm:ss"];
    }else{
        _msgTimeLabel.text = @"";
    }
    __weak typeof(self) weakself = self;

    switch (model.type.intValue) {
        case 1:{
            NSString *str = [NSString stringWithFormat:@"%@ 关注了您",model.nickname];
            NSMutableAttributedString *attri = [[NSMutableAttributedString alloc] initWithString:str];
            [attri yy_setTextHighlightRange:NSMakeRange(0, model.nickname.length) color:UIColorFromRGB(0xFFA400) backgroundColor:kAppClearColor tapAction:^(UIView * _Nonnull containerView, NSAttributedString * _Nonnull text, NSRange range, CGRect rect) {
                if (weakself.userHomepageBtnClicked) {
                    weakself.userHomepageBtnClicked();
                }
            }];
            
             self.msgContentLabel.attributedText = attri;
        }
            break;
        case 2:{
            NSString *str = [NSString stringWithFormat:@"%@ 点赞了您发布的《%@》",model.nickname,model.title];
            NSMutableAttributedString *attri = [[NSMutableAttributedString alloc] initWithString:str];
            [attri yy_setTextHighlightRange:NSMakeRange(0, model.nickname.length) color:UIColorFromRGB(0xFFA400) backgroundColor:kAppClearColor tapAction:^(UIView * _Nonnull containerView, NSAttributedString * _Nonnull text, NSRange range, CGRect rect) {
                if (weakself.userHomepageBtnClicked) {
                    weakself.userHomepageBtnClicked();
                }
            }];
            [attri yy_setTextHighlightRange:NSMakeRange(str.length-model.title.length-2, model.title.length+2) color:UIColorFromRGB(0x10A497) backgroundColor:kAppClearColor tapAction:^(UIView * _Nonnull containerView, NSAttributedString * _Nonnull text, NSRange range, CGRect rect) {
                if (weakself.communityEssayBtnClicked) {
                    weakself.communityEssayBtnClicked();
                }
            }];
            
            self.msgContentLabel.attributedText = attri;
        }
            break;
        case 3:{
            NSString *str = [NSString stringWithFormat:@"%@ 在您发布的《%@》中发表了评论\"%@\"",model.nickname,model.title,model.content];
            NSMutableAttributedString *attri = [[NSMutableAttributedString alloc] initWithString:str];
            [attri yy_setTextHighlightRange:NSMakeRange(0, model.nickname.length) color:UIColorFromRGB(0xFFA400) backgroundColor:kAppClearColor tapAction:^(UIView * _Nonnull containerView, NSAttributedString * _Nonnull text, NSRange range, CGRect rect) {
                if (weakself.userHomepageBtnClicked) {
                    weakself.userHomepageBtnClicked();
                }
            }];
            [attri yy_setTextHighlightRange:NSMakeRange(model.nickname.length+6, model.title.length+2) color:UIColorFromRGB(0x10A497) backgroundColor:kAppClearColor tapAction:^(UIView * _Nonnull containerView, NSAttributedString * _Nonnull text, NSRange range, CGRect rect) {
                if (weakself.communityEssayBtnClicked) {
                    weakself.communityEssayBtnClicked();
                }
            }];
            [attri yy_setTextHighlightRange:NSMakeRange(str.length-model.content.length-2, model.content.length+2) color:UIColorFromRGB(0x7B8AD7) backgroundColor:kAppClearColor tapAction:^(UIView * _Nonnull containerView, NSAttributedString * _Nonnull text, NSRange range, CGRect rect) {
                if (weakself.communityCommentBtnClicked) {
                    weakself.communityCommentBtnClicked();
                }
            }];
            self.msgContentLabel.attributedText = attri;
        }
            break;
        case 4:{
            NSString *str = [NSString stringWithFormat:@"%@ 收藏了您发布的《%@》",model.nickname,model.title];
            NSMutableAttributedString *attri = [[NSMutableAttributedString alloc] initWithString:str];
            [attri yy_setTextHighlightRange:NSMakeRange(0, model.nickname.length) color:UIColorFromRGB(0xFFA400) backgroundColor:kAppClearColor tapAction:^(UIView * _Nonnull containerView, NSAttributedString * _Nonnull text, NSRange range, CGRect rect) {
                if (weakself.userHomepageBtnClicked) {
                    weakself.userHomepageBtnClicked();
                }
            }];
            [attri yy_setTextHighlightRange:NSMakeRange(str.length-model.title.length-2, model.title.length+2) color:UIColorFromRGB(0x10A497) backgroundColor:kAppClearColor tapAction:^(UIView * _Nonnull containerView, NSAttributedString * _Nonnull text, NSRange range, CGRect rect) {
                if (weakself.communityEssayBtnClicked) {
                    weakself.communityEssayBtnClicked();
                }
            }];
            self.msgContentLabel.attributedText = attri;
        }
            break;
            
        default:{
            self.msgContentLabel.text = @"未知消息";
        }
            break;
    }
    
}
-(void)tapAction:(UITapGestureRecognizer *)tap{
   
    if (self.userHomepageBtnClicked) {
        self.userHomepageBtnClicked();
    }
}


- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
    _msgContentLabel.textColor = kApp333Color;
    _msgContentLabel.font = kFont(13);
    _msgContentLabel.numberOfLines = 2;
    _msgContentLabel.preferredMaxLayoutWidth = SCREEN_WIDTH-78;
    
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
