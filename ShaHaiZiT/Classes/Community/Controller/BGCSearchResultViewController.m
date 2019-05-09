//
//  BGCSearchResultViewController.m
//  shzTravelC
//
//  Created by biao on 2018/7/26.
//  Copyright © 2018年 biao. All rights reserved.
//

#import "BGCSearchResultViewController.h"
#import "BGCSearchArticleViewController.h"
#import "BGCSearchPersonViewController.h"
#import <NinaPagerView.h>
#import "BGCSearchViewController.h"

@interface BGCSearchResultViewController ()

@property (strong, nonatomic) NinaPagerView *ninaPagerView;

@end

@implementation BGCSearchResultViewController
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
    self.navigationItem.title = @"搜索结果";
    self.view.backgroundColor = kAppBgColor;
    
    //得到当前视图控制器中的所有控制器
    NSMutableArray *array = [self.navigationController.viewControllers mutableCopy];
    
    for (int i = 0; i < array.count; i++) {
        if ([array[i] isKindOfClass:[BGCSearchViewController class]]) {
            [array removeObjectAtIndex:i];
            //把删除后的控制器数组再次赋值
            [self.navigationController setViewControllers:[array copy] animated:YES];
        }
    }
    
    
    UIView *whiteView = UIView.new;
    whiteView.backgroundColor = kAppWhiteColor;
    whiteView.frame = CGRectMake(0, 0, SCREEN_WIDTH, SafeAreaTopHeight-kNavigationBarH+3);
    [self.view addSubview:whiteView];
    // 搜索框
    UIView *topView = UIView.new;
    topView.backgroundColor = kAppWhiteColor;
    topView.frame = CGRectMake(0, SafeAreaTopHeight-kNavigationBarH+3, SCREEN_WIDTH, kNavigationBarH);
    [self.view addSubview:topView];
    
    UIButton *button = UIButton.new;
    [button setImage:[UIImage imageNamed:@"btn_back_black"] forState:UIControlStateNormal];
    [button setImage:[UIImage imageNamed:@"btn_back_green"] forState:UIControlStateHighlighted];
    button.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
    
    @weakify(self);
    [[button rac_signalForControlEvents:(UIControlEventTouchUpInside)] subscribeNext:^(__kindof UIControl * _Nullable x) {
        @strongify(self);
        // 点击button的响应事件
        [self.navigationController popViewControllerAnimated:YES];
    }];
    button.frame = CGRectMake(15, 9, 40, 30);
    button.contentEdgeInsets = UIEdgeInsetsMake(0, 0, 0, 0);
    button.titleLabel.font = [UIFont systemFontOfSize:15];
    [topView addSubview:button];
    
    UIButton *searchBtn = [UIButton buttonWithType:(UIButtonTypeCustom)];
    searchBtn.frame = CGRectMake(41, 7, SCREEN_WIDTH-29-41, 30);
    searchBtn.backgroundColor = UIColorFromRGB(0xEBF1F6);
    searchBtn.clipsToBounds = YES;
    searchBtn.layer.cornerRadius = 15;
    
    [[searchBtn rac_signalForControlEvents:(UIControlEventTouchUpInside)] subscribeNext:^(__kindof UIControl * _Nullable x) {
        @strongify(self);
        // 点击button的响应事件
        BGCSearchViewController *searchVC = BGCSearchViewController.new;
        CATransition *transition = [CATransition animation];
        transition.type = kCATransitionFade;
        transition.subtype = kCATransitionFromBottom;
        [self.navigationController.view.layer addAnimation:transition forKey:kCATransition];
        [self.navigationController pushViewController:searchVC animated:NO];
    }];
    
    UIImageView *searchImgView = [[UIImageView alloc] initWithImage:BGImage(@"community_search")];
    searchImgView.frame = CGRectMake(14, 8, 16, 14);
    [searchBtn addSubview:searchImgView];
    
    UILabel *searchLabel = UILabel.new;
    searchLabel.frame = CGRectMake(35, 9, 100, 13);
    if ([Tool isBlankString:_keyword]) {
        [searchLabel setTextColor:kApp999Color];
        searchLabel.text = @"搜索";
    }else{
        [searchLabel setTextColor:kApp333Color];
        searchLabel.text = _keyword;
    }
    [searchLabel setFont:kFont(13)];
    [searchBtn addSubview:searchLabel];
    
    [topView addSubview:searchBtn];
    [self.view addSubview:self.ninaPagerView];
}
#pragma mark - NinaParaArrays
- (NSArray *)ninaTitleArray {
    return @[@"帖子",
             @"用户"];
}

- (NSArray *)ninaVCsArray {
    return @[@"BGCSearchArticleViewController",
             @"BGCSearchPersonViewController"];
}

#pragma mark - LazyLoad
- (NinaPagerView *)ninaPagerView {
    if (!_ninaPagerView) {
        NSArray *titleArray = [self ninaTitleArray];
        NSArray *vcsArray = [self ninaVCsArray];
        CGRect pagerRect = CGRectMake(0, 62, SCREEN_WIDTH, SCREEN_HEIGHT-62);
        _ninaPagerView = [[NinaPagerView alloc] initWithFrame:pagerRect WithTitles:titleArray WithObjects:vcsArray];
        _ninaPagerView.unSelectTitleColor = kApp333Color;
        _ninaPagerView.selectTitleColor = kAppMainColor;
        _ninaPagerView.topTabBackGroundColor = kAppWhiteColor;
        _ninaPagerView.underLineHidden = YES;
        _ninaPagerView.nina_autoBottomLineEnable = YES;
        _ninaPagerView.underlineColor = kAppMainColor;
        _ninaPagerView.topTabHeight = 35;
        _ninaPagerView.selectBottomLineHeight = 1;
        _ninaPagerView.ninaDefaultPage = _ninaDefaultPage;
        _ninaPagerView.titleFont = 12*SizeScale;
        
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
