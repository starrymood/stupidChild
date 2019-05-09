//
//  BGWalletCouponViewController.m
//  shzTravelC
//
//  Created by 孙林茂 on 2018/5/10.
//  Copyright © 2018年 biao. All rights reserved.
//

#import "BGWalletCouponViewController.h"
#import "NinaPagerView.h"
#import "BGCouponNotUsedViewController.h"
#import "BGCouponAlreadyUsedViewController.h"
#import "BGCouponExpiredViewController.h"
#import "BGWebViewController.h"

@interface BGWalletCouponViewController ()

@property (strong, nonatomic) NinaPagerView *ninaPagerView;

@property (weak, nonatomic) IBOutlet UIView *couponView;

@end

@implementation BGWalletCouponViewController
-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    self.navigationController.navigationBarHidden = YES;
}
-(void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    self.navigationController.navigationBarHidden = NO;
}
- (void)viewDidLoad {
    [super viewDidLoad];
    [self.couponView addSubview:self.ninaPagerView];
}

#pragma mark - NinaParaArrays
- (NSArray *)ninaTitleArray {
    return @[@"未使用",
             @"已使用",
             @"已过期"];
}

- (NSArray *)ninaVCsArray {
    return @[@"BGCouponNotUsedViewController",
             @"BGCouponAlreadyUsedViewController",
             @"BGCouponExpiredViewController"];
}

#pragma mark - LazyLoad
- (NinaPagerView *)ninaPagerView {
    if (!_ninaPagerView) {
        NSArray *titleArray = [self ninaTitleArray];
        NSArray *vcsArray = [self ninaVCsArray];
        CGRect pagerRect = CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT-SafeAreaTopHeight);
        _ninaPagerView = [[NinaPagerView alloc] initWithFrame:pagerRect WithTitles:titleArray WithObjects:vcsArray];
        _ninaPagerView.underlineColor = kAppMainColor;
        _ninaPagerView.unSelectTitleColor = kApp333Color;
        _ninaPagerView.selectTitleColor = kAppMainColor;
        _ninaPagerView.topTabBackGroundColor = kAppWhiteColor;
        _ninaPagerView.underLineHidden = YES;
        _ninaPagerView.topTabHeight = 44;
        _ninaPagerView.nina_autoBottomLineEnable = YES;
        _ninaPagerView.underlineColor = kAppMainColor;
        _ninaPagerView.selectBottomLineHeight = 1;

        _ninaPagerView.titleFont = 14*SizeScale;
        
    }
    return _ninaPagerView;
}
- (IBAction)btnGuideClicked:(UIButton *)sender {
    BGWebViewController *webVC = [[BGWebViewController alloc] init];
    webVC.url = BGWebPages(@"instructions.html");
    [self.navigationController pushViewController:webVC animated:YES];
}

- (IBAction)btnBackClicked:(UIButton *)sender {
    [self.navigationController popViewControllerAnimated:YES];
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
