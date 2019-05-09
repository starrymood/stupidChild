//
//  BGShopCommentCell.m
//  shzTravelC
//
//  Created by 孙林茂 on 2018/5/10.
//  Copyright © 2018年 biao. All rights reserved.
//

#import "BGShopCommentCell.h"
#import "BGShopCommentModel.h"
#import <UIImageView+WebCache.h>

@interface BGShopCommentCell()
@property (weak, nonatomic) IBOutlet UIImageView *headImgView;
@property (weak, nonatomic) IBOutlet UILabel *nickNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *contentLabel;
@property (weak, nonatomic) IBOutlet UILabel *timeLabel;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *contentBottomHeight;
@property (weak, nonatomic) IBOutlet UIImageView *picOneImgView;
@property (weak, nonatomic) IBOutlet UIImageView *picTwoImgView;
@property (weak, nonatomic) IBOutlet UIImageView *picThreeImgView;
@property (strong, nonatomic) UIImageView *actionImageView;
@property (strong, nonatomic) UIView *backView;
@property (nonatomic, assign) CGRect rect;

@end
@implementation BGShopCommentCell

- (void)updataWithCellArray:(BGShopCommentModel *)model{
    
    if ([Tool arrayIsNotEmpty:model.pictures]) {
        
        self.contentBottomHeight.constant = (SCREEN_WIDTH-15*2-10*2)/3.0+20;
        for (int i = 0; i<model.pictures.count; i++) {
            NSString *originalStr = model.pictures[i];
            switch (i) {
                case 0:{
                    self.picOneImgView.hidden = NO;
                    [self.picOneImgView sd_setImageWithURL:[NSURL URLWithString:originalStr] placeholderImage:BGImage(@"img_placeholder")];
                    [self.picOneImgView addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(picTapActionOne:)]];
                }
                    break;
                case 1:{
                    self.picTwoImgView.hidden = NO;
                    [self.picTwoImgView sd_setImageWithURL:[NSURL URLWithString:originalStr] placeholderImage:BGImage(@"img_placeholder")];
                    [self.picTwoImgView addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(picTapActionTwo:)]];
                }
                    break;
                case 2:{
                    self.picThreeImgView.hidden = NO;
                    [self.picThreeImgView sd_setImageWithURL:[NSURL URLWithString:originalStr] placeholderImage:BGImage(@"img_placeholder")];
                    [self.picThreeImgView addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(picTapActionThree:)]];
                }
                    break;
                    
                default:
                    break;
            }
        }
        
    }else{
        self.contentBottomHeight.constant = 10;
        [self.picOneImgView setHidden:YES];
        [self.picTwoImgView setHidden:YES];
        [self.picThreeImgView setHidden:YES];
    }
    
    
    [self.headImgView sd_setImageWithURL:[NSURL URLWithString:model.face] placeholderImage:BGImage(@"img_placeholder")];
    self.nickNameLabel.text = model.nickname;
    self.contentLabel.text = [Tool isBlankString:model.content]? @"此用户没有填写评价。":model.content;
    if (model.create_time.length > 5) {
        self.timeLabel.text = [Tool dateFormatter:model.create_time.doubleValue dateFormatter:@"yyyy-MM-dd"];
    }
    
}
- (void)picTapActionOne:(UIGestureRecognizer *)gr{
    [self picTapAction:gr imgTag:1];
}
- (void)picTapActionTwo:(UIGestureRecognizer *)gr{
    [self picTapAction:gr imgTag:2];
}
- (void)picTapActionThree:(UIGestureRecognizer *)gr{
    [self picTapAction:gr imgTag:3];
}
- (void)picTapAction:(UIGestureRecognizer *)gr imgTag:(NSInteger)imgTag{

    _backView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height)];
    _backView.backgroundColor = [UIColor blackColor];
    [_backView addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(backTapAction)]];
    [[UIApplication sharedApplication].delegate.window addSubview:_backView];
    UIWindow *window = [[[UIApplication sharedApplication] delegate] window];
    if (imgTag == 1) {
        _actionImageView = [[UIImageView alloc] initWithImage:self.picOneImgView.image];
        _actionImageView.frame= [_picOneImgView convertRect: _picOneImgView.bounds toView:window];
    }else if (imgTag == 2){
        _actionImageView = [[UIImageView alloc] initWithImage:self.picTwoImgView.image];
        _actionImageView.frame= [_picTwoImgView convertRect: _picTwoImgView.bounds toView:window];
    }else{
        _actionImageView = [[UIImageView alloc] initWithImage:self.picThreeImgView.image];
        _actionImageView.frame= [_picThreeImgView convertRect: _picThreeImgView.bounds toView:window];
    }
    self.rect = _actionImageView.frame;
    [[UIApplication sharedApplication].delegate.window addSubview:_actionImageView];
    __weak __typeof(self) weakSelf = self;
    [UIView animateWithDuration:.3 animations:^{
        UIImage *image = [Tool fixOrientation:weakSelf.actionImageView.image];
        CGFloat fixelW = CGImageGetWidth(image.CGImage);
        CGFloat fixelH = CGImageGetHeight(image.CGImage);
        weakSelf.actionImageView.frame = CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, fixelH * [UIScreen mainScreen].bounds.size.width / fixelW);
        weakSelf.actionImageView.center = weakSelf.backView.center;
    }];
}

- (void)backTapAction{
    __weak __typeof(self) weakSelf = self;
    [UIView animateWithDuration:.2 animations:^{
        weakSelf.actionImageView.frame = weakSelf.rect;
        weakSelf.backView.alpha = .3;
    } completion:^(BOOL finished) {
        [weakSelf.backView removeFromSuperview];
        [weakSelf.actionImageView removeFromSuperview];
    }];
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
