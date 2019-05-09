//
//  BGMineHeaderView.m
//  shzTravelC
//
//  Created by biao on 2018/7/18.
//  Copyright © 2018年 biao. All rights reserved.
//

#import "BGMineHeaderView.h"

@implementation BGMineHeaderView

- (instancetype)initWithFrame:(CGRect)frame {
    
    if (self = [super initWithFrame:frame]) {
        
        NSBundle *bundle = [NSBundle bundleForClass:[self class]];
        
        NSArray *viewArray =  [bundle loadNibNamed:@"BGMineHeaderView" owner:self options:nil];
        
        self = viewArray[0];
        
        [self setLayout];
        
        
        self.frame = frame;
        
        
    }
    return  self;
}

-(void)setLayout{
    
    self.headImgView.layer.borderWidth = 1;
    self.headImgView.layer.borderColor = kAppWhiteColor.CGColor;
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(headImgViewClick)];
    [_headImgView addGestureRecognizer:tap];
    
    /*
     self.mineNameLabel.shadowColor = kAppBlackColor;
     self.mineNameLabel.shadowOffset = CGSizeMake(1, 1);
     self.shzIdLabel.shadowColor = kAppBlackColor;
     self.shzIdLabel.shadowOffset = CGSizeMake(1, 1);
     self.mineAutographLabel.shadowColor = kAppBlackColor;
     self.mineAutographLabel.shadowOffset = CGSizeMake(1, 1);

    UIView *shadowView = [[UIView alloc]initWithFrame:_headImgView.frame];
    
    [self.clearView addSubview:shadowView];
    
    shadowView.layer.shadowColor = UIColorFromRGB(0x2642AB).CGColor;
    
    shadowView.layer.shadowOffset = CGSizeMake(2, 5);
    
    shadowView.layer.shadowOpacity = 0.4;
    
    shadowView.layer.shadowRadius = 5.0;
    
    shadowView.layer.cornerRadius = 5.0;
    
    shadowView.clipsToBounds = NO;
    
    [shadowView addSubview:_headImgView];
    */
}
-(void)headImgViewClick{
    if (self.headImgBtnClick) {
        self.headImgBtnClick();
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

@end
