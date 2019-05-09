//
//  BGDouYinCell.m
//  ShaHaiZiT
//
//  Created by biao on 2019/1/20.
//  Copyright © 2019 biao. All rights reserved.
//

#import "BGDouYinCell.h"
#import <ZFPlayer/UIImageView+ZFCache.h>
#import <ZFPlayer/UIView+ZFFrame.h>
#import <ZFPlayer/UIImageView+ZFCache.h>
#import <ZFPlayer/ZFUtilities.h>
#import "ZFLoadingView.h"
#import <UIImageView+WebCache.h>
#import "BGCommunityApi.h"
#import "BGAirApi.h"
#import "MusicAlbumView.h"
#import "UIImage+Extension.h"

@interface BGDouYinCell()

@property (weak, nonatomic) IBOutlet UIImageView *coverImgView;
@property (weak, nonatomic) IBOutlet UILabel *titleeLabel;
@property (weak, nonatomic) IBOutlet UILabel *typeLabel;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *typeViewHeight;
@property (weak, nonatomic) IBOutlet UIButton *collectBtn;
@property (weak, nonatomic) IBOutlet UILabel *collectNumLabel;
@property (weak, nonatomic) IBOutlet UIButton *likeBtn;
@property (weak, nonatomic) IBOutlet UILabel *likeNumLabel;
@property (weak, nonatomic) IBOutlet UILabel *messageNumLabel;
@property (weak, nonatomic) IBOutlet UIImageView *headImgView;
@property (weak, nonatomic) IBOutlet UIButton *concernBtn;
@property(nonatomic,strong) MusicAlbumView *musicAlum;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *cameraTop;

@end

@implementation BGDouYinCell


- (void)updataWithCellArray:(BGEssayDetailModel *)model pic:(NSString *)pic{
    [_musicAlum startAnimation:12];
     __weak __typeof(self) wself = self;
    [_musicAlum.album sd_setImageWithURL:[NSURL URLWithString:model.face] completed:^(UIImage * _Nullable image, NSError * _Nullable error, SDImageCacheType cacheType, NSURL * _Nullable imageURL) {
        if(!error) {
            wself.musicAlum.album.image = [image drawCircleImage];
        }
    }];
    self.likeBtn.userInteractionEnabled = YES;
    self.concernBtn.userInteractionEnabled = YES;
    self.collectBtn.userInteractionEnabled = YES;
    self.shareBtn.userInteractionEnabled = YES;
    self.messageBtn.userInteractionEnabled = YES;
    [self.coverImgView setImageWithURLString:pic placeholder:[UIImage imageNamed:@"community_douyin_placeholder"]];
    if ([Tool isBlankString:model.nickname]) {
        model.nickname = @"暂无昵称";
    }
    self.titleeLabel.text = [NSString stringWithFormat:@"@%@（视频发布者）\n%@\n%@",model.nickname,model.post_title,model.content];
    self.typeLabel.text = model.category_name;
    CGSize typeSize = [Tool textSizeWithText:model.category_name Font:kFont(18) limitWidth:250];
    self.typeViewHeight.constant = typeSize.width+29+14;
    
    self.messageNumLabel.text = model.review_count;
    self.collectNumLabel.text = model.collect_count;
    self.likeNumLabel.text = model.like_count;
    
    NSString *collectionStr = model.is_collect.intValue==1 ? @"community_douyin_collected":@"community_douyin_collect";
    [self.collectBtn setImage:BGImage(collectionStr) forState:(UIControlStateNormal)];
    
    NSString *likeStr = model.is_like.intValue==1 ? @"community_douyin_likeddd":@"community_douyin_like";
    [self.likeBtn setImage:BGImage(likeStr) forState:(UIControlStateNormal)];
    
    NSString *concernStr = model.is_concern.intValue==1 ? @"community_douyin_added":@"community_douyin_add";
    [self.concernBtn setImage:BGImage(concernStr) forState:(UIControlStateNormal)];
    
    [self.headImgView sd_setImageWithURL:[NSURL URLWithString:model.face] placeholderImage:BGImage(@"img_placeholder")];
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(headImgViewClick)];
    [_headImgView addGestureRecognizer:tap];
    
    
    @weakify(self);
    [[[[self.concernBtn rac_signalForControlEvents:(UIControlEventTouchUpInside)] takeUntil:self.rac_prepareForReuseSignal] takeUntil:self.rac_prepareForReuseSignal] subscribeNext:^(__kindof UIControl * _Nullable x) {
        @strongify(self);
        // 点击button的响应事件
        if (![Tool isLogin]) {
            [WHIndicatorView toast:@"请先登录!"];
            [BGAppDelegateHelper showLoginViewController];
            return;
        }
        NSMutableDictionary *param = [[NSMutableDictionary alloc] init];
        [param setObject:model.member_id forKey:@"member_id"];
        [param setObject:@"1" forKey:@"type"];
        [ProgressHUDHelper showLoading];
        __weak __typeof(self) weakSelf = self;
        [BGCommunityApi modifyConcernStatus:param succ:^(NSDictionary *response) {
            DLog(@"\n>>>[modifyConcernStatus sucess]:%@",response);
            if (model.is_concern.intValue == 1) {
//                [WHIndicatorView toast:@"取消关注"];
                [weakSelf.concernBtn setImage:BGImage(@"community_douyin_add") forState:(UIControlStateNormal)];
                model.is_concern = @"0";
            }else{
//                [WHIndicatorView toast:@"关注成功"];
                [weakSelf.concernBtn setImage:BGImage(@"community_douyin_added") forState:(UIControlStateNormal)];
                model.is_concern = @"1";
            }
        } failure:^(NSDictionary *response) {
            DLog(@"\n>>>[modifyConcernStatus failure]:%@",response);
        }];
    }];
    [[[[self.likeBtn rac_signalForControlEvents:(UIControlEventTouchUpInside)] takeUntil:self.rac_prepareForReuseSignal] takeUntil:self.rac_prepareForReuseSignal] subscribeNext:^(__kindof UIControl * _Nullable x) {
        @strongify(self);
        // 点击button的响应事件
        if (![Tool isLogin]) {
            [WHIndicatorView toast:@"请先登录!"];
            [BGAppDelegateHelper showLoginViewController];
            return;
        }
        [ProgressHUDHelper showLoading];
        NSMutableDictionary *param = [[NSMutableDictionary alloc] init];
        [param setObject:model.ID forKey:@"like_id"];
        [param setObject:@"1" forKey:@"type"];
        __weak __typeof(self) weakSelf = self;
        [BGCommunityApi modifyLikeStatus:param succ:^(NSDictionary *response) {
            DLog(@"\n>>>[modifyLikeStatus sucess]:%@",response);
            if (model.is_like.intValue == 1) {
//                [WHIndicatorView toast:@"取消点赞"];
                [weakSelf.likeBtn setImage:BGImage(@"community_douyin_like") forState:(UIControlStateNormal)];
                model.like_count = [NSString stringWithFormat:@"%d",model.like_count.intValue -1];
                weakSelf.likeNumLabel.text = model.like_count;
                model.is_like = @"0";
            }else{
//                [WHIndicatorView toast:@"已点赞"];
                [weakSelf.likeBtn setImage:BGImage(@"community_douyin_likeddd") forState:(UIControlStateNormal)];
                model.like_count = [NSString stringWithFormat:@"%d",model.like_count.intValue +1];
                weakSelf.likeNumLabel.text = model.like_count;
                model.is_like = @"1";
            }
        } failure:^(NSDictionary *response) {
            DLog(@"\n>>>[modifyLikeStatus failure]:%@",response);
        }];
    }];
    [[[[self.collectBtn rac_signalForControlEvents:(UIControlEventTouchUpInside)] takeUntil:self.rac_prepareForReuseSignal] takeUntil:self.rac_prepareForReuseSignal] subscribeNext:^(__kindof UIControl * _Nullable x) {
        @strongify(self);
        if (![Tool isLogin]) {
            [WHIndicatorView toast:@"请先登录!"];
            [BGAppDelegateHelper showLoginViewController];
            return;
        }
        [ProgressHUDHelper showLoading];
        NSMutableDictionary *param = [[NSMutableDictionary alloc] init];
        [param setObject:model.ID forKey:@"collect_id"];
        [param setObject:@"3" forKey:@"category"];
        // 点击button的响应事件
        
        __weak __typeof(self) weakSelf = self;
        [BGAirApi addAndCancelFavoriteAction:param succ:^(NSDictionary *response) {
            DLog(@"\n>>>[cancelFavoriteAction success]:%@",response);
            if (model.is_collect.intValue == 1) {
//                [WHIndicatorView toast:@"取消收藏"];
                
               [weakSelf.collectBtn setImage:BGImage(@"community_douyin_collect") forState:(UIControlStateNormal)];
                model.collect_count = [NSString stringWithFormat:@"%d",model.collect_count.intValue -1];
                weakSelf.collectNumLabel.text = model.collect_count;
                model.is_collect = @"0";
            }else{
//                [WHIndicatorView toast:@"已收藏"];
                [weakSelf.collectBtn setImage:BGImage(@"community_douyin_collected") forState:(UIControlStateNormal)];
                model.collect_count = [NSString stringWithFormat:@"%d",model.collect_count.intValue +1];
                weakSelf.collectNumLabel.text = model.collect_count;
                model.is_collect = @"1";
            }
            
        } failure:^(NSDictionary *response) {
            DLog(@"\n>>>[cancelFavoriteAction failure]:%@",response);
        }];
    }];
    
}
-(void)headImgViewClick{
    if (self.headImgViewClicked) {
        self.headImgViewClicked();
    }
}

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
    if (@available(iOS 11.0, *)) {
        // iOS 11.0 及以后的版本
        self.cameraTop.constant = -36;
    } else {
        // iOS 11.0 之前
        self.cameraTop.constant = -36-(SafeAreaTopHeight-44);
    }
    _musicAlum = [MusicAlbumView new];
    _musicAlum.frame = CGRectMake(SCREEN_WIDTH-11-50, SCREEN_HEIGHT-SafeAreaBottomHeight-50-20, 50, 50);
    [self.contentView addSubview:_musicAlum];
    [_musicAlum resetView];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
