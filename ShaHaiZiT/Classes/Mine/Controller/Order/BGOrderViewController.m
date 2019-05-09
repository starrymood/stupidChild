//
//  BGOrderViewController.m
//  ShaHaiZiT
//
//  Created by biao on 2018/11/20.
//  Copyright © 2018 biao. All rights reserved.
//

#import "BGOrderViewController.h"
#import "NinaPagerView.h"
#import "BGOrderShopViewController.h"
#import "BGOrderTravelViewController.h"
#import "BGWalletOrderPayResultViewController.h"

@interface BGOrderViewController ()<NinaPagerViewDelegate>

@property (strong, nonatomic) NinaPagerView *ninaPagerView;

@end

@implementation BGOrderViewController

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
    
    NSMutableArray *array = [self.navigationController.viewControllers mutableCopy];
    for (int i = 0; i < array.count; i++) {
        if ([array[i] isKindOfClass:[BGWalletOrderPayResultViewController class]]) {
            [array removeObjectAtIndex:i];
            [self.navigationController setViewControllers:[array copy] animated:YES];
        }
    }
    self.navigationItem.title = @"我的订单";
    self.view.backgroundColor = kAppBgColor;
    self.navigationItem.leftBarButtonItem = [UIBarButtonItem itemWithImage:@"btn_back_black" highImage:@"btn_back_green" target:self action:@selector(clickedBackItem:)];
    [self.view addSubview:self.ninaPagerView];
    
}
- (void)clickedBackItem:(UIBarButtonItem *)btn{
    [self.navigationController popToRootViewControllerAnimated:YES];
}
#pragma mark - NinaParaArrays
- (NSArray *)ninaTitleArray {
    return @[@"商品订单",
             @"包车订单"];
}

- (NSArray *)ninaVCsArray {
    return @[@"BGOrderShopViewController",
             @"BGOrderTravelViewController"];
}

#pragma mark - LazyLoad
- (NinaPagerView *)ninaPagerView {
    if (!_ninaPagerView) {
        NSArray *titleArray = [self ninaTitleArray];
        NSArray *vcsArray = [self ninaVCsArray];
        CGRect pagerRect = CGRectMake(0, 6, SCREEN_WIDTH, SCREEN_HEIGHT-SafeAreaTopHeight-6);
        _ninaPagerView = [[NinaPagerView alloc] initWithFrame:pagerRect WithTitles:titleArray WithObjects:vcsArray];
        _ninaPagerView.unSelectTitleColor = kApp333Color;
        _ninaPagerView.selectTitleColor = kAppMainColor;
        _ninaPagerView.topTabBackGroundColor = kAppWhiteColor;
        _ninaPagerView.underLineHidden = YES;
        _ninaPagerView.topTabHeight = 45;
        _ninaPagerView.nina_autoBottomLineEnable = YES;
        _ninaPagerView.underlineColor = kAppMainColor;
        _ninaPagerView.selectBottomLineHeight = 1;
        _ninaPagerView.delegate = self;
        
        _ninaPagerView.ninaDefaultPage = _ninaDefaultPage;
        _ninaPagerView.titleFont = 15*SizeScale;
        
    }
    return _ninaPagerView;
}
- (void)ninaCurrentPageIndex:(NSInteger)currentPage currentObject:(id)currentObject lastObject:(id)lastObject{
    if (currentPage == 0) {
        BGOrderShopViewController *shopVC = (BGOrderShopViewController *)currentObject;
        if (_isJump) {
            [shopVC changeDefaultPageWithPage:_jumpNum];
            _isJump = NO;
        }
        
    }else if (currentPage == 1) {
        BGOrderTravelViewController *travelVC = (BGOrderTravelViewController *)currentObject;
        if (_isJump) {
            [travelVC changeDefaultPageWithPage:_jumpNum];
            _isJump = NO;
        }
    }
    
}
-(void)changeDefaultPageWithPage:(NSInteger)pageNum{
    [_ninaPagerView setNinaChosenPage:pageNum];
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
