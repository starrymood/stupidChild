//
//  BGEssayDetailBottomView.m
//  shzTravelC
//
//  Created by biao on 2018/7/30.
//  Copyright © 2018年 biao. All rights reserved.
//

#import "BGEssayDetailBottomView.h"
#import "BGEssayDetailModel.h"
#import "BGCommunityApi.h"
#import "BGAirApi.h"

@interface BGEssayDetailBottomView()

@property (weak, nonatomic) IBOutlet UIButton *likeBtn;
@property (weak, nonatomic) IBOutlet UIButton *collectionBtn;
@property (nonatomic, assign) BOOL isChangeToFull;
@property (nonatomic, assign) BOOL isLike;
@property (nonatomic, assign) BOOL isCollection;

@end
@implementation BGEssayDetailBottomView

- (instancetype)initWithFrame:(CGRect)frame {
    
    if (self = [super initWithFrame:frame]) {
        
        NSBundle *bundle = [NSBundle bundleForClass:[self class]];
        
        NSArray *viewArray =  [bundle loadNibNamed:@"BGEssayDetailBottomView" owner:self options:nil];
        
        self = viewArray[0];
        
        self.frame = frame;
        
    }
    return  self;
}

-(void)updataWithModel:(BGEssayDetailModel *)model{
    
    [self.likeBtn setTitle:[NSString stringWithFormat:@"赞 %@",model.like_count] forState:(UIControlStateNormal)];
    if (model.is_like.intValue == 1) {
        _isLike = YES;
        [self.likeBtn setImage:BGImage(@"essay_bottom_like_selected") forState:(UIControlStateNormal)];
        [self.likeBtn setTitleColor:kAppMainColor forState:(UIControlStateNormal)];
    }else{
        _isLike = NO;
        if (model.type.intValue == 2 && _isChangeToFull) {
            [self.likeBtn setImage:BGImage(@"essay_bottom_like_default_white") forState:(UIControlStateNormal)];
            [self.likeBtn setTitleColor:kAppWhiteColor forState:(UIControlStateNormal)];
        }else{
            [self.likeBtn setImage:BGImage(@"essay_bottom_like_default") forState:(UIControlStateNormal)];
            [self.likeBtn setTitleColor:kApp333Color forState:(UIControlStateNormal)];
        }
       
    }
    
    [self.collectionBtn setTitle:[NSString stringWithFormat:@"收藏 %@",model.collect_count] forState:(UIControlStateNormal)];
    if (model.is_collect.intValue == 1) {
        _isCollection = YES;
        [self.collectionBtn setImage:BGImage(@"essay_bottom_collection_selected") forState:(UIControlStateNormal)];
        [self.collectionBtn setTitleColor:kAppMainColor forState:(UIControlStateNormal)];
    }else{
        if (model.type.intValue == 2 && _isChangeToFull) {
            _isCollection = NO;
            [self.collectionBtn setImage:BGImage(@"essay_bottom_collection_white") forState:(UIControlStateNormal)];
            [self.collectionBtn setTitleColor:kAppWhiteColor forState:(UIControlStateNormal)];
        }else{
            [self.collectionBtn setImage:BGImage(@"essay_bottom_collection_default") forState:(UIControlStateNormal)];
            [self.collectionBtn setTitleColor:kApp333Color forState:(UIControlStateNormal)];
        }
    }
    
    [self.commentBtn setTitle:[NSString stringWithFormat:@"评论 %@",model.review_count] forState:(UIControlStateNormal)];
    [self.commentBtn setImage:BGImage(@"essay_bottom_comment_selected") forState:(UIControlStateNormal)];
    [self.commentBtn setTitleColor:kAppMainColor forState:(UIControlStateNormal)];
    
    @weakify(self);
    [[_likeBtn rac_signalForControlEvents:(UIControlEventTouchUpInside)] subscribeNext:^(__kindof UIControl * _Nullable x) {
        @strongify(self);
        // 点击button的响应事件
        if (![Tool isLogin]) {
            [WHIndicatorView toast:@"请先登录!"];
            [BGAppDelegateHelper showLoginViewController];
            return;
        }
        [ProgressHUDHelper showLoading];
        NSMutableDictionary *param = [[NSMutableDictionary alloc] init];
        [param setObject:model.post_id forKey:@"like_id"];
        [param setObject:model.type forKey:@"type"];
        __weak __typeof(self) weakSelf = self;
        [BGCommunityApi modifyLikeStatus:param succ:^(NSDictionary *response) {
            DLog(@"\n>>>[modifyLikeStatus sucess]:%@",response);
            if (model.is_like.intValue == 1) {
                [WHIndicatorView toast:@"取消点赞"];
                weakSelf.isLike = NO;
                [self.likeBtn setTitle:[NSString stringWithFormat:@"赞 %d",model.like_count.intValue-1] forState:(UIControlStateNormal)];
                if (model.type.intValue == 2 && weakSelf.isChangeToFull) {
                    [self.likeBtn setImage:BGImage(@"essay_bottom_like_default_white") forState:(UIControlStateNormal)];
                    [self.likeBtn setTitleColor:kAppWhiteColor forState:(UIControlStateNormal)];
                }else{
                    [self.likeBtn setImage:BGImage(@"essay_bottom_like_default") forState:(UIControlStateNormal)];
                    [self.likeBtn setTitleColor:kApp333Color forState:(UIControlStateNormal)];
                }
                model.like_count = [NSString stringWithFormat:@"%d",model.like_count.intValue -1];
                model.is_like = @"0";
            }else{
                [WHIndicatorView toast:@"已点赞"];
                 weakSelf.isLike = YES;
                [self.likeBtn setTitle:[NSString stringWithFormat:@"赞 %d",model.like_count.intValue+1] forState:(UIControlStateNormal)];
                [self.likeBtn setImage:BGImage(@"essay_bottom_like_selected") forState:(UIControlStateNormal)];
                [self.likeBtn setTitleColor:kAppMainColor forState:(UIControlStateNormal)];
                model.like_count = [NSString stringWithFormat:@"%d",model.like_count.intValue +1];
                model.is_like = @"1";
            }
        } failure:^(NSDictionary *response) {
            DLog(@"\n>>>[modifyLikeStatus failure]:%@",response);
        }];
    }];
    
    [[_collectionBtn rac_signalForControlEvents:(UIControlEventTouchUpInside)] subscribeNext:^(__kindof UIControl * _Nullable x) {
        @strongify(self);
        if (![Tool isLogin]) {
            [WHIndicatorView toast:@"请先登录!"];
            [BGAppDelegateHelper showLoginViewController];
            return;
        }
        [ProgressHUDHelper showLoading];
        NSMutableDictionary *param = [[NSMutableDictionary alloc] init];
        [param setObject:model.post_id forKey:@"collect_id"];
        if ([Tool isBlankString:model.video_title]) {
            [param setObject:@"3" forKey:@"category"];
        }else{
            [param setObject:@"4" forKey:@"category"];
        }
        // 点击button的响应事件
        
            __weak __typeof(self) weakSelf = self;
            [BGAirApi addAndCancelFavoriteAction:param succ:^(NSDictionary *response) {
                DLog(@"\n>>>[cancelFavoriteAction success]:%@",response);
                if (model.is_collect.intValue == 1) {
                    [WHIndicatorView toast:@"取消收藏"];
                    weakSelf.isCollection = NO;
                    [self.collectionBtn setTitle:[NSString stringWithFormat:@"收藏 %d",model.collect_count.intValue-1] forState:(UIControlStateNormal)];
                    
                    if (model.type.intValue == 2 && weakSelf.isChangeToFull) {
                        [self.collectionBtn setImage:BGImage(@"essay_bottom_collection_white") forState:(UIControlStateNormal)];
                        [self.collectionBtn setTitleColor:kAppWhiteColor forState:(UIControlStateNormal)];
                    }else{
                        [self.collectionBtn setImage:BGImage(@"essay_bottom_collection_default") forState:(UIControlStateNormal)];
                        [self.collectionBtn setTitleColor:kApp333Color forState:(UIControlStateNormal)];
                    }
                    model.collect_count = [NSString stringWithFormat:@"%d",model.collect_count.intValue -1];
                    model.is_collect = @"0";
                }else{
                    [WHIndicatorView toast:@"已收藏"];
                    self.isCollection = YES;
                    [self.collectionBtn setTitle:[NSString stringWithFormat:@"收藏 %d",model.collect_count.intValue+1] forState:(UIControlStateNormal)];
                    [self.collectionBtn setImage:BGImage(@"essay_bottom_collection_selected") forState:(UIControlStateNormal)];
                    [self.collectionBtn setTitleColor:kAppMainColor forState:(UIControlStateNormal)];
                    model.collect_count = [NSString stringWithFormat:@"%d",model.collect_count.intValue +1];
                    model.is_collect = @"1";
                }
               
            } failure:^(NSDictionary *response) {
                DLog(@"\n>>>[cancelFavoriteAction failure]:%@",response);
            }];
    }];
}
-(void)updataColorWithModel:(BGEssayDetailModel *)model{
    self.isChangeToFull = model.isChangeToFull;
    if (_isLike) {
        [self.likeBtn setImage:BGImage(@"essay_bottom_like_selected") forState:(UIControlStateNormal)];
        [self.likeBtn setTitleColor:kAppMainColor forState:(UIControlStateNormal)];
    }else{
        if (model.type.intValue == 2 && _isChangeToFull) {
            [self.likeBtn setImage:BGImage(@"essay_bottom_like_default_white") forState:(UIControlStateNormal)];
            [self.likeBtn setTitleColor:kAppWhiteColor forState:(UIControlStateNormal)];
        }else{
            [self.likeBtn setImage:BGImage(@"essay_bottom_like_default") forState:(UIControlStateNormal)];
            [self.likeBtn setTitleColor:kApp333Color forState:(UIControlStateNormal)];
        }
        
    }
    
    if (_isCollection) {
        [self.collectionBtn setImage:BGImage(@"essay_bottom_collection_selected") forState:(UIControlStateNormal)];
        [self.collectionBtn setTitleColor:kAppMainColor forState:(UIControlStateNormal)];
    }else{
        if (model.type.intValue == 2 && _isChangeToFull) {
            [self.collectionBtn setImage:BGImage(@"essay_bottom_collection_white") forState:(UIControlStateNormal)];
            [self.collectionBtn setTitleColor:kAppWhiteColor forState:(UIControlStateNormal)];
        }else{
            [self.collectionBtn setImage:BGImage(@"essay_bottom_collection_default") forState:(UIControlStateNormal)];
            [self.collectionBtn setTitleColor:kApp333Color forState:(UIControlStateNormal)];
        }
    }
}

@end
