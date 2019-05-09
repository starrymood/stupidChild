//
//  BGMyAttentionViewController.m
//  shzTravelC
//
//  Created by biao on 2018/7/19.
//  Copyright © 2018年 biao. All rights reserved.
//

#import "BGMyAttentionViewController.h"
#import <NinaPagerView.h>
#import "BGMyAttentionPersonViewController.h"
#import "BGMyAttentionGuideViewController.h"

@interface BGMyAttentionViewController ()

@property (strong, nonatomic) NinaPagerView *ninaPagerView;

@end

@implementation BGMyAttentionViewController
-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    self.navigationController.navigationBarHidden = NO;
    self.navigationController.navigationBar.translucent = NO;
}
-(void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    self.navigationController.navigationBar.translucent = YES;
}
- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.navigationItem.title = @"我的关注";
    self.view.backgroundColor = kAppBgColor;
    [self.view addSubview:self.ninaPagerView];
    
}

#pragma mark - NinaParaArrays
- (NSArray *)ninaTitleArray {
    return @[@"用户",
             @"司导"];
}

- (NSArray *)ninaVCsArray {
    return @[@"BGMyAttentionPersonViewController",
             @"BGMyAttentionGuideViewController"];
}

#pragma mark - LazyLoad
- (NinaPagerView *)ninaPagerView {
    if (!_ninaPagerView) {
        NSArray *titleArray = [self ninaTitleArray];
        NSArray *vcsArray = [self ninaVCsArray];
        CGRect pagerRect = CGRectMake(0, 3, SCREEN_WIDTH, SCREEN_HEIGHT-SafeAreaTopHeight);
        _ninaPagerView = [[NinaPagerView alloc] initWithFrame:pagerRect WithTitles:titleArray WithObjects:vcsArray];
        _ninaPagerView.unSelectTitleColor = kApp333Color;
        _ninaPagerView.selectTitleColor = kAppMainColor;
        _ninaPagerView.topTabBackGroundColor = kAppWhiteColor;
        _ninaPagerView.underLineHidden = YES;
        _ninaPagerView.nina_autoBottomLineEnable = YES;
        _ninaPagerView.underlineColor = kAppMainColor;
        _ninaPagerView.topTabHeight = 53;
        _ninaPagerView.selectBottomLineHeight = 1;
        _ninaPagerView.titleFont = 16*SizeScale;
        
    }
    return _ninaPagerView;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
