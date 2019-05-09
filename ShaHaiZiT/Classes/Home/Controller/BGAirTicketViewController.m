//
//  BGAirTicketViewController.m
//  ShaHaiZiT
//
//  Created by biao on 2019/5/6.
//  Copyright © 2019 biao. All rights reserved.
//

#import "BGAirTicketViewController.h"
#import <NinaPagerView.h>
#import "BGAirOneViewController.h"
#import "BGAirTwoViewController.h"
#import "BGAirMoreViewController.h"

@interface BGAirTicketViewController ()

@property (strong, nonatomic) NinaPagerView *ninaPagerView;

@end

@implementation BGAirTicketViewController

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
    
}

#pragma mark - NinaParaArrays
- (NSArray *)ninaTitleArray {
    return @[@"单程",
             @"往返",
             @"国际多程"];
}

- (NSArray *)ninaVCsArray {
    return @[@"BGAirOneViewController",
             @"BGAirTwoViewController",
             @"BGAirMoreViewController"];
}

#pragma mark - LazyLoad
- (NinaPagerView *)ninaPagerView {
    if (!_ninaPagerView) {
        NSArray *titleArray = [self ninaTitleArray];
        NSArray *vcsArray = [self ninaVCsArray];
        CGRect pagerRect = CGRectMake(0, 1, SCREEN_WIDTH, SCREEN_HEIGHT-SafeAreaTopHeight);
        _ninaPagerView = [[NinaPagerView alloc] initWithFrame:pagerRect WithTitles:titleArray WithObjects:vcsArray];
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
