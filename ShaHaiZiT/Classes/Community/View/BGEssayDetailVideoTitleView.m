//
//  BGEssayDetailVideoTitleView.m
//  shzTravelC
//
//  Created by biao on 2018/8/14.
//  Copyright © 2018年 biao. All rights reserved.
//

#import "BGEssayDetailVideoTitleView.h"
#import "BGEssayDetailModel.h"
#import "BGCommunityApi.h"
#import <UIImageView+WebCache.h>

@interface BGEssayDetailVideoTitleView()
@property (weak, nonatomic) IBOutlet UIImageView *headImgView;
@property (weak, nonatomic) IBOutlet UILabel *nickNameLabel;
@property (nonatomic, assign) BOOL isConcern;


@end
@implementation BGEssayDetailVideoTitleView

- (instancetype)initWithFrame:(CGRect)frame {
    
    if (self = [super initWithFrame:frame]) {
        
        NSBundle *bundle = [NSBundle bundleForClass:[self class]];
        
        NSArray *viewArray =  [bundle loadNibNamed:@"BGEssayDetailVideoTitleView" owner:self options:nil];
        
        self = viewArray[0];
        
        self.frame = frame;
        
    }
    return  self;
}

-(void)updataWithModel:(BGEssayDetailModel *)model{
    
    [self.headImgView sd_setImageWithURL:[NSURL URLWithString:model.face] placeholderImage:BGImage(@"defaultUserIcon")];
    
    self.nickNameLabel.text = model.nickname;
    
    if (model.is_concern.intValue == 1) {
        _isConcern = YES;
        [self.concernBtn setTitle:@"已关注" forState:(UIControlStateNormal)];
        [self.concernBtn setBackgroundColor:kAppClearColor];
        self.concernBtn.layer.borderColor = kAppWhiteColor.CGColor;
    }else{
        _isConcern = NO;
        [self.concernBtn setTitle:@"关注" forState:(UIControlStateNormal)];
        [self.concernBtn setBackgroundColor:kAppMainColor];
        self.concernBtn.layer.borderColor = kAppMainColor.CGColor;
    }
    @weakify(self);
    [[self.concernBtn rac_signalForControlEvents:(UIControlEventTouchUpInside)] subscribeNext:^(__kindof UIControl * _Nullable x) {
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
            if (weakSelf.isConcern) {
                [WHIndicatorView toast:@"取消关注成功"];
                [weakSelf.concernBtn setTitle:@"关注" forState:(UIControlStateNormal)];
                [weakSelf.concernBtn setBackgroundColor:kAppMainColor];
                weakSelf.concernBtn.layer.borderColor = kAppMainColor.CGColor;
                weakSelf.isConcern = NO;
            }else{
                [WHIndicatorView toast:@"关注成功"];
                
                [weakSelf.concernBtn setTitle:@"已关注" forState:(UIControlStateNormal)];
                [weakSelf.concernBtn setBackgroundColor:kAppClearColor];
                weakSelf.concernBtn.layer.borderColor = kAppWhiteColor.CGColor;
                weakSelf.isConcern = YES;
            }
        } failure:^(NSDictionary *response) {
            DLog(@"\n>>>[modifyConcernStatus failure]:%@",response);
        }];
    }];
}

@end
