//
//  BGOrderShopViewController.m
//  shzTravelC
//
//  Created by biao on 2018/8/25.
//  Copyright © 2018年 biao. All rights reserved.
//

#import "BGOrderShopViewController.h"
#import "NinaPagerView.h"
#import "BGPendingPaymentViewController.h"
#import "BGPendingSendViewController.h"
#import "BGPendingReceiveViewController.h"
#import "BGFinishViewController.h"
#import "BGAfterSaleViewController.h"
#import "BGAllOrderViewController.h"

@interface BGOrderShopViewController ()

@property (strong, nonatomic) NinaPagerView *ninaPagerView;

@end

@implementation BGOrderShopViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor = kAppBgColor;
    [self.view addSubview:self.ninaPagerView];
    
}

#pragma mark - NinaParaArrays
- (NSArray *)ninaTitleArray {
    return @[@"待付款",
             @"待发货",
             @"待收货",
             @"已完成",
             @"售后",
             @"全部"];
}

- (NSArray *)ninaVCsArray {
    return @[@"BGPendingPaymentViewController",
             @"BGPendingSendViewController",
             @"BGPendingReceiveViewController",
             @"BGFinishViewController",
             @"BGAfterSaleViewController",
             @"BGAllOrderViewController"];
}

#pragma mark - LazyLoad
- (NinaPagerView *)ninaPagerView {
    if (!_ninaPagerView) {
        NSArray *titleArray = [self ninaTitleArray];
        NSArray *vcsArray = [self ninaVCsArray];
        CGRect pagerRect = CGRectMake(0, 6, SCREEN_WIDTH, SCREEN_HEIGHT-SafeAreaTopHeight-6-6-45);
        _ninaPagerView = [[NinaPagerView alloc] initWithFrame:pagerRect WithTitles:titleArray WithObjects:vcsArray];
        _ninaPagerView.unSelectTitleColor = kApp333Color;
        _ninaPagerView.selectTitleColor = kAppMainColor;
        _ninaPagerView.topTabBackGroundColor = kAppWhiteColor;
        _ninaPagerView.underLineHidden = YES;
        _ninaPagerView.topTabHeight = 40;
        _ninaPagerView.nina_autoBottomLineEnable = YES;
        _ninaPagerView.underlineColor = kAppMainColor;
        _ninaPagerView.selectBottomLineHeight = 1;
        
        NSString *str = BGGetUserDefaultObjectForKey(@"ShopOrderDefaultNum");
        if (str.integerValue == 100) {
            
        }else{
            _ninaPagerView.ninaDefaultPage = str.integerValue;
            BGSetUserDefaultObjectForKey(@"100", @"ShopOrderDefaultNum");
        }
        _ninaPagerView.titleFont = 13*SizeScale;
        
    }
    return _ninaPagerView;
}

-(void)changeDefaultPageWithPage:(NSInteger)pageNum{
    [_ninaPagerView setNinaChosenPage:pageNum];
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
