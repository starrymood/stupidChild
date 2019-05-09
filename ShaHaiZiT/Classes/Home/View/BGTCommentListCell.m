//
//  BGTCommentListCell.m
//  shzTravelC
//
//  Created by biao on 2018/8/28.
//  Copyright © 2018年 biao. All rights reserved.
//

#import "BGTCommentListCell.h"
#import "BGAirPriceCommentModel.h"
#import <UIImageView+WebCache.h>
#import "HXPhotoPicker.h"

static const CGFloat kPhotoViewMargin = 21.0;
@interface BGTCommentListCell()
@property (weak, nonatomic) IBOutlet UIImageView *cHeadImgView;
@property (weak, nonatomic) IBOutlet UILabel *cNickNameLabel;
@property (weak, nonatomic) IBOutlet UIImageView *cGradesImgView;
@property (weak, nonatomic) IBOutlet UITextView *cNoteView;
@property (weak, nonatomic) IBOutlet UILabel *cTimeLabel;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *noteViewHeight;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *picViewHeight;
@property (strong, nonatomic) HXPhotoManager *manager;
@property (nonatomic, strong) HXPhotoView *photoView;
@property (weak, nonatomic) IBOutlet UIView *picView;

@end
@implementation BGTCommentListCell
-(HXPhotoView *)photoView{
    if (!_photoView) {
        _photoView = [HXPhotoView photoManager:self.manager];
        _photoView.frame = CGRectMake(kPhotoViewMargin, 5, SCREEN_WIDTH - kPhotoViewMargin * 2, 0);
        _photoView.lineCount = 3;
        _photoView.editEnabled = NO;
        _photoView.showAddCell = NO;
        _photoView.previewShowDeleteButton = NO;
        _photoView.spacing = kPhotoViewMargin*0.5;
        _photoView.hideDeleteButton = YES;
        _photoView.backgroundColor = [UIColor whiteColor];
        
    }
    return _photoView;
}
- (HXPhotoManager *)manager
{
    if (!_manager) {
        _manager = [[HXPhotoManager alloc] initWithType:HXPhotoManagerSelectedTypePhoto];
        _manager.configuration.openCamera = NO;
//        _manager.configuration.showDeleteNetworkPhotoAlert = NO;
        _manager.configuration.saveSystemAblum = NO;
        _manager.configuration.photoMaxNum = 0;
        _manager.configuration.maxNum = 0;
        _manager.configuration.photoCanEdit = NO;
    }
    return _manager;
}

- (void)updataWithCellArray:(BGAirPriceCommentModel *)model{
    
    _noteViewHeight.constant = 30;
     [_cHeadImgView sd_setImageWithURL:[NSURL URLWithString:model.face] placeholderImage:BGImage(@"defaultUserIcon")];
    _cNickNameLabel.text = model.nickname;
    
    _cTimeLabel.text = [Tool dateFormatter:model.create_time.doubleValue dateFormatter:@"yyyy.MM.dd"];
    NSArray *starNameArr = @[@"comment_star_one",@"comment_star_two",@"comment_star_three",@"comment_star_four",@"comment_star_five"];
    if (starNameArr.count>model.satisfaction_level.intValue-1) {
        [_cGradesImgView setImage:BGImage(starNameArr[model.satisfaction_level.intValue-1])];
    }
    _cNoteView.text = model.content;
    
    self.noteViewHeight.constant = [self heightForString:self.cNoteView andWidth:SCREEN_WIDTH-42];
    [self.manager clearSelectedList];
    if ([Tool arrayIsNotEmpty:model.picture]) {
         _picViewHeight.constant = (SCREEN_WIDTH - kPhotoViewMargin * 3)/3*((model.picture.count-1)/3+1)+kPhotoViewMargin;
        [_picView addSubview:self.photoView];
        NSMutableArray *array = [NSMutableArray arrayWithArray:model.picture];
        [self.manager addNetworkingImageToAlbum:array selected:YES];
        [_photoView refreshView];
    }else{
        if (_photoView) {
            [_photoView removeFromSuperview];
        }
        _picViewHeight.constant = 1;
    }
}


- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}
- (float)heightForString:(UITextView *)textView andWidth:(float)width{
    CGSize sizeToFit = [textView sizeThatFits:CGSizeMake(width, MAXFLOAT)];
    return sizeToFit.height;
}
- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
