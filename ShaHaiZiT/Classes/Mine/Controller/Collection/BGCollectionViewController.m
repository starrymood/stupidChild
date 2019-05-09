//
//  BGCollectionViewController.m
//  shzTravelC
//
//  Created by 孙林茂 on 2018/5/11.
//  Copyright © 2018年 biao. All rights reserved.
//

#import "BGCollectionViewController.h"
#import <NinaPagerView.h>
#import "BGCollectionVideosViewController.h"
#import "BGCollectionUpdatingsViewController.h"
#import "BGCollectionLineViewController.h"
#import "BGCollectionGoodsViewController.h"
#import "BGCollectionStoreViewController.h"

@interface BGCollectionViewController ()

@property (strong, nonatomic) NinaPagerView *ninaPagerView;

@end

@implementation BGCollectionViewController

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

    self.navigationItem.title = @"我的收藏";
    self.view.backgroundColor = kAppBgColor;
    [self.view addSubview:self.ninaPagerView];
    
}

#pragma mark - NinaParaArrays
- (NSArray *)ninaTitleArray {
    return @[@"视频",
             @"帖子",
             @"线路",
             @"商品",
             @"店铺"];
}

- (NSArray *)ninaVCsArray {
    return @[@"BGCollectionVideosViewController",
             @"BGCollectionUpdatingsViewController",
             @"BGCollectionLineViewController",
             @"BGCollectionGoodsViewController",
             @"BGCollectionStoreViewController"];
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
        _ninaPagerView.nina_autoBottomLineEnable = YES;
        _ninaPagerView.underlineColor = kAppMainColor;
        _ninaPagerView.topTabHeight = 42;
        _ninaPagerView.selectBottomLineHeight = 1;
        _ninaPagerView.titleFont = 14*SizeScale;
        
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
