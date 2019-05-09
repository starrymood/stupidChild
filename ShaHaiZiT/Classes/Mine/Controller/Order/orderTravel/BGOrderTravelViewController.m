//
//  BGOrderTravelViewController.m
//  ShaHaiZiT
//
//  Created by biao on 2018/12/27.
//  Copyright © 2018 biao. All rights reserved.
//

#import "BGOrderTravelViewController.h"
#import "BGOrderPayViewController.h"
#import "BGOrderProcessingViewController.h"
#import "BGOrderCommentViewController.h"
#import "BGOrderDoneViewController.h"
#import <NinaPagerView.h>

@interface BGOrderTravelViewController ()

@property (strong, nonatomic) NinaPagerView *ninaPagerView;

@end

@implementation BGOrderTravelViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor = kAppBgColor;
    [self.view addSubview:self.ninaPagerView];
}


#pragma mark - NinaParaArrays
- (NSArray *)ninaTitleArray {
    return @[@"待付款",
             @"进行中",
             @"待评价",
             @"已完成"];
}

- (NSArray *)ninaVCsArray {
    return @[@"BGOrderPayViewController",
             @"BGOrderProcessingViewController",
             @"BGOrderCommentViewController",
             @"BGOrderDoneViewController"];
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
        
        NSString *str = BGGetUserDefaultObjectForKey(@"TravelOrderDefaultNum");
        if (str.integerValue == 100) {
            
        }else{
            _ninaPagerView.ninaDefaultPage = str.integerValue;
            BGSetUserDefaultObjectForKey(@"100", @"TravelOrderDefaultNum");
        }
        _ninaPagerView.titleFont = 13*SizeScale;
        
    }
    return _ninaPagerView;
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
