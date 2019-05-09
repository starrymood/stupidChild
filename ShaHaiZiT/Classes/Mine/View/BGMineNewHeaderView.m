//
//  BGMineNewHeaderView.m
//  ShaHaiZiT
//
//  Created by biao on 2018/12/28.
//  Copyright © 2018 biao. All rights reserved.
//

#import "BGMineNewHeaderView.h"

@implementation BGMineNewHeaderView

- (instancetype)initWithFrame:(CGRect)frame {
    
    if (self = [super initWithFrame:frame]) {
        
        NSBundle *bundle = [NSBundle bundleForClass:[self class]];
        
        NSArray *viewArray =  [bundle loadNibNamed:@"BGMineNewHeaderView" owner:self options:nil];
        
        self = viewArray[0];
        
        [self setLayout];
        
        
        self.frame = frame;
        
        
    }
    return  self;
}

-(void)setLayout{
    if (IS_iPhoneX) {
        self.messageBtnTop.constant = 46.5;
    }else{
        self.messageBtnTop.constant = 31.5;
    }
    self.headImgView.layer.borderWidth = 1;
    self.headImgView.layer.borderColor = kAppWhiteColor.CGColor;
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(headImgViewClick)];
    [_headImgView addGestureRecognizer:tap];
}
-(void)headImgViewClick{
    if ([Tool isLogin]) {
        if (self.headImgBtnClick) {
            self.headImgBtnClick();
        }
    }else{
        [BGAppDelegateHelper showLoginViewController];
    }
}
- (IBAction)attentionBtnClicked:(UIButton *)sender {
    if (self.attentionBtnClick) {
        self.attentionBtnClick();
    }
}
- (IBAction)fansBtnClicked:(UIButton *)sender {
    if (self.fansBtnClick) {
        self.fansBtnClick();
    }
}
- (IBAction)btnLoginClicked:(UIButton *)sender {
    [BGAppDelegateHelper showLoginViewController];
}
- (IBAction)editBtnClicked:(UIButton *)sender {
    if ([Tool isLogin]) {
        if (self.editBtnClick) {
            self.editBtnClick();
        }
    }else{
        [BGAppDelegateHelper showLoginViewController];
    }
}
- (IBAction)recommendBtnClicked:(UIButton *)sender {
    if (self.recommendBtnClick) {
        self.recommendBtnClick();
    }
}

- (IBAction)settingBtnClicked:(UIButton *)sender {
    if ([Tool isLogin]) {
        if (self.settingBtnClick) {
            self.settingBtnClick();
        }
    }else{
        [BGAppDelegateHelper showLoginViewController];
    }
}

@end
