//
//  WGCityListViewController.m
//  ShaHaiZiT
//
//  Created by DY on 2019/5/9.
//  Copyright © 2019 biao. All rights reserved.
//

#import "WGCityListViewController.h"
#import <NinaPagerView.h>
#import "WGHomeCountryVC.h"
#import "WGForeignCountryVC.h"

@interface WGCityListViewController ()

@property (strong, nonatomic) NinaPagerView *ninaPagerView;
@property (nonatomic,strong)  UIView *lineView;

@end

@implementation WGCityListViewController

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
    
    self.navigationItem.title = @"机票";
    self.view.backgroundColor = kAppBgColor;
    [self.view addSubview:self.ninaPagerView];
    [self.view addSubview:self.lineView];
    
}

#pragma mark - NinaParaArrays
- (NSArray *)ninaTitleArray {
    return @[@"国内",
             @"国际/港澳台"];
}

- (NSArray *)ninaVCsArray {
    return @[@"WGHomeCountryVC",
             @"WGForeignCountryVC"];
}

- (UIView *)lineView {
    if (!_lineView) {
        _lineView = [[UIView alloc] initWithFrame:CGRectMake(SCREEN_WIDTH/2 -1, 10, 0.7, 23)];
        _lineView.backgroundColor = [UIColor colorWithRed:0.91 green:0.91 blue:0.91 alpha:1.00];
    }
    return _lineView;
}


#pragma mark - LazyLoad
- (NinaPagerView *)ninaPagerView {
    if (!_ninaPagerView) {
        NSArray *titleArray = [self ninaTitleArray];
        NSArray *vcsArray = [self ninaVCsArray];
        CGRect pagerRect = CGRectMake(0, 1, SCREEN_WIDTH, SCREEN_HEIGHT-SafeAreaTopHeight);
        _ninaPagerView = [[NinaPagerView alloc] initWithFrame:pagerRect WithTitles:titleArray WithObjects:vcsArray];
        _ninaPagerView.backgroundColor = [UIColor redColor];
        _ninaPagerView.unSelectTitleColor = kApp333Color;
        _ninaPagerView.selectTitleColor = kAppMainColor;
        _ninaPagerView.topTabBackGroundColor = kAppWhiteColor;
        _ninaPagerView.underLineHidden = YES;
        _ninaPagerView.nina_autoBottomLineEnable = YES;
        _ninaPagerView.underlineColor = kAppMainColor;
        _ninaPagerView.topTabHeight = 43;
        _ninaPagerView.selectBottomLineHeight = 5;
        _ninaPagerView.titleFont = 15*SizeScale;
        _ninaPagerView.titleScale = 1.0;
        _ninaPagerView.loadWholePages = YES;
        
    }
    return _ninaPagerView;
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
