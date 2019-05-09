//
//  BGCommunityViewController.m
//  shzTravelC
//
//  Created by biao on 2018/7/18.
//  Copyright © 2018年 biao. All rights reserved.
//

#import "BGCommunityViewController.h"
#import <SPPageMenu.h>
#import "BGStrategyAViewController.h"
#import "BGCSearchViewController.h"
#import "BGCommunityApi.h"
#import "BGCommunityTypeModel.h"
#import "BGPublishUpdatingsViewController.h"
#import "BGCommunityMsgViewController.h"
#import "BGSystemApi.h"
#import <JSBadgeView.h>

#define pageMenuH 45
#define scrollViewHeight (SCREEN_HEIGHT-SafeAreaTopHeight-pageMenuH-kTabBarH-6)
@interface BGCommunityViewController ()<SPPageMenuDelegate,UIScrollViewDelegate>

@property (strong, nonatomic) SPPageMenu *pageMenu;
@property (nonatomic, copy) NSArray *titleArr;
@property (nonatomic, copy) NSArray *idArr;
@property (nonatomic, strong) UIButton *publishBtn;
@property (nonatomic, weak) UIScrollView *scrollView;
@property (nonatomic, strong) NSMutableArray *myChildViewControllers;
@property (nonatomic, strong) UIButton *messageBtn;
@property (nonatomic, strong) JSBadgeView *badgeView;

@end

@implementation BGCommunityViewController
-(JSBadgeView *)badgeView{
    if (!_badgeView) {
        self.badgeView = [[JSBadgeView alloc] initWithParentView:_messageBtn alignment:(JSBadgeViewAlignmentTopRight)];
        _badgeView.badgeOverlayColor = [UIColor clearColor];
        _badgeView.badgeStrokeColor = [UIColor redColor];
        _badgeView.badgeShadowSize = CGSizeZero;
        _badgeView.badgePositionAdjustment = CGPointMake(-10, 5);
    }
    return _badgeView;
}
- (NSMutableArray *)myChildViewControllers {
    
    if (!_myChildViewControllers) {
        _myChildViewControllers = [NSMutableArray array];
        
    }
    return _myChildViewControllers;
}

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
    
    [self loadSubViews]; 
    [self loadData];
}
-(void)loadSubViews{
    self.navigationItem.title = @"社区";
    self.view.backgroundColor = kAppBgColor;
     [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(messageTipsActionOne:) name:@"messageTipsActionOne" object:nil];
      self.navigationItem.leftBarButtonItem = [UIBarButtonItem itemWithImage:@"home_search_new" highImage:@"home_search_new" target:self action:@selector(clickedSearchItem)];
    self.messageBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [_messageBtn setImage:BGImage(@"home_message") forState:UIControlStateNormal];
    [_messageBtn setImage:BGImage(@"home_message") forState:UIControlStateHighlighted];
    _messageBtn.bounds = CGRectMake(0, 0, 70, 30);
    _messageBtn.imageEdgeInsets = UIEdgeInsetsMake(0, 0, 0, -30);
    _messageBtn.contentEdgeInsets = UIEdgeInsetsZero;
    @weakify(self);
    [[_messageBtn rac_signalForControlEvents:(UIControlEventTouchUpInside)] subscribeNext:^(__kindof UIControl * _Nullable x) {
        @strongify(self);
        // 点击button的响应事件
        if (![Tool isLogin]) {
            [WHIndicatorView toast:@"请先登录!"];
            [BGAppDelegateHelper showLoginViewController];
            return;
        }
        BGCommunityMsgViewController *messageVC = BGCommunityMsgViewController.new;
        [self.navigationController pushViewController:messageVC animated:YES];
    }];
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:_messageBtn];
    self.publishBtn = [UIButton buttonWithType:(UIButtonTypeCustom)];
    _publishBtn.frame = CGRectMake((SCREEN_WIDTH-104)*0.5, SCREEN_HEIGHT-SafeAreaTopHeight-SafeAreaBottomHeight-kTabBarH-7-35, 104, 35);
    [_publishBtn setBackgroundImage:[self imageWithColor:[UIColor colorWithWhite:1 alpha:0.4]] forState:UIControlStateNormal];
    [_publishBtn setBackgroundImage:[self imageWithColor:[UIColor colorWithWhite:1 alpha:0.9]] forState:UIControlStateHighlighted];
    [_publishBtn setTitleColor:kApp333Color forState:(UIControlStateNormal)];
    [_publishBtn setTitleColor:kApp333Color forState:(UIControlStateHighlighted)];
    [_publishBtn setTitle:@"发布新动态" forState:(UIControlStateNormal)];
    [_publishBtn.titleLabel setFont:kFont(13)];
    _publishBtn.layer.masksToBounds = YES;
    _publishBtn.layer.cornerRadius = _publishBtn.height*0.5;
    
    [[_publishBtn rac_signalForControlEvents:(UIControlEventTouchUpInside)] subscribeNext:^(__kindof UIControl * _Nullable x) {
        @strongify(self);
        // 点击button的响应事件
        if (![Tool isLogin]) {
            [WHIndicatorView toast:@"请先登录!"];
            [BGAppDelegateHelper showLoginViewController];
            return;
        }
        BGPublishUpdatingsViewController *updatingVC = BGPublishUpdatingsViewController.new;
        updatingVC.isEdit = NO;
        [self.navigationController pushViewController:updatingVC animated:YES];
    }];
   /*
    // 搜索框
    UIView *topView = UIView.new;
    topView.backgroundColor = kAppWhiteColor;
    topView.frame = CGRectMake(0, 3, SCREEN_WIDTH, 54);
    [self.view addSubview:topView];
    UIButton *searchBtn = [UIButton buttonWithType:(UIButtonTypeCustom)];
    searchBtn.frame = CGRectMake(29, 9, SCREEN_WIDTH-29*2, 36);
    searchBtn.backgroundColor = UIColorFromRGB(0xEBF1F6);
    searchBtn.clipsToBounds = YES;
    searchBtn.layer.cornerRadius = 18;
    
    [[searchBtn rac_signalForControlEvents:(UIControlEventTouchUpInside)] subscribeNext:^(__kindof UIControl * _Nullable x) {
        @strongify(self);
        // 点击button的响应事件
        // @@ 添加登录判断
        if (![Tool isLogin]) {
            [WHIndicatorView toast:@"请先登录!"];
            [BGAppDelegateHelper showLoginViewController];
            return;
        }
        
        BGCSearchViewController *searchVC = BGCSearchViewController.new;
        CATransition *transition = [CATransition animation];
        transition.type = kCATransitionFade;
        transition.subtype = kCATransitionFromBottom;
        [self.navigationController.view.layer addAnimation:transition forKey:kCATransition];
        [self.navigationController pushViewController:searchVC animated:NO];
       
    }];
    
    UIImageView *searchImgView = [[UIImageView alloc] initWithImage:BGImage(@"community_search")];
    searchImgView.frame = CGRectMake(14, 11, 16, 14);
    [searchBtn addSubview:searchImgView];
    
    UILabel *searchLabel = UILabel.new;
    searchLabel.frame = CGRectMake(35, 12, 100, 13);
    [searchLabel setTextColor:kApp999Color];
    searchLabel.text = @"搜索";
    [searchLabel setFont:kFont(13)];
    [searchBtn addSubview:searchLabel];
    
    [topView addSubview:searchBtn];
    */
}
-(void)clickedSearchItem{
    
    // @@ 添加登录判断
    if (![Tool isLogin]) {
        [WHIndicatorView toast:@"请先登录!"];
        [BGAppDelegateHelper showLoginViewController];
        return;
    }
    
    BGCSearchViewController *searchVC = BGCSearchViewController.new;
    CATransition *transition = [CATransition animation];
    transition.type = kCATransitionFade;
    transition.subtype = kCATransitionFromBottom;
    [self.navigationController.view.layer addAnimation:transition forKey:kCATransition];
    [self.navigationController pushViewController:searchVC animated:NO];
}
-(void)loadData{
    [ProgressHUDHelper showLoading];
   __weak __typeof(self) weakSelf = self;
    [BGCommunityApi getTypeList:nil succ:^(NSDictionary *response) {
        DLog(@"\n>>>[getTypeList sucess]:%@",response);
        [weakSelf hideNodateView];
        NSMutableArray *arr = [NSMutableArray array];
        arr = [BGCommunityTypeModel mj_objectArrayWithKeyValuesArray:BGdictSetObjectIsNil(response[@"result"])];
        NSMutableArray *tempTitleArr = [NSMutableArray array];
        NSMutableArray *tempIdArr = [NSMutableArray array];
        for (BGCommunityTypeModel *model in arr) {
            [tempTitleArr addObject:model.categoryName];
            [tempIdArr addObject:model.ID];
        }
        weakSelf.titleArr = [NSArray arrayWithArray:tempTitleArr];
        weakSelf.idArr = [NSArray arrayWithArray:tempIdArr];
        [weakSelf.view addSubview:weakSelf.pageMenu];

        [weakSelf.view addSubview:weakSelf.publishBtn];
        if ([Tool isLogin]) {
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                [BGSystemApi getMsgUnreadNum:nil succ:^(NSDictionary *response) {
                    DLog(@"\n>>>[getMsgUnreadNum sucess]:%@",response);
                } failure:^(NSDictionary *response) {
                    DLog(@"\n>>>[getMsgUnreadNum failure]:%@",response);
                }];
            });
        }
    } failure:^(NSDictionary *response) {
        DLog(@"\n>>>[getTypeList failure]:%@",response);
        [ProgressHUDHelper removeLoading];
        [weakSelf shownoNetWorkViewWithType:0];
        [weakSelf setRefreshBlock:^{
            [weakSelf loadData];
        }];
    }];
}

#pragma mark - LazyLoad
- (SPPageMenu *)pageMenu {
    if (!_pageMenu) {
        _pageMenu = [[SPPageMenu alloc] initWithFrame:CGRectMake(0, 6, SCREEN_WIDTH, pageMenuH) trackerStyle:SPPageMenuTrackerStyleLineAttachment];
        [_pageMenu setItems:self.titleArr selectedItemIndex:0];
        _pageMenu.selectedItemTitleColor = kAppMainColor;
        _pageMenu.unSelectedItemTitleColor = kAppDefaultLabelColor;
        _pageMenu.tracker.backgroundColor = kAppMainColor;
        _pageMenu.itemTitleFont = [UIFont fontWithName:@"PingFangSC-Semibold" size:14];
        [_pageMenu setTrackerHeight:4.0 cornerRadius:2];
        _pageMenu.trackerWidth = 28;
        _pageMenu.dividingLine.hidden = YES;
        _pageMenu.delegate = self;
        for (int i = 0; i<self.idArr.count; i++) {
            BGStrategyAViewController *vc = BGStrategyAViewController.new;
            vc.classification_id = self.idArr[i];
            [self addChildViewController:vc];
            [self.myChildViewControllers addObject:vc];
        }
        UIScrollView *scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 6+pageMenuH, SCREEN_WIDTH, scrollViewHeight)];
        scrollView.delegate = self;
        scrollView.pagingEnabled = YES;
        scrollView.showsHorizontalScrollIndicator = NO;
        [self.view addSubview:scrollView];
        _scrollView = scrollView;
        
        // 这一行赋值，可实现pageMenu的跟踪器时刻跟随scrollView滑动的效果
        self.pageMenu.bridgeScrollView = self.scrollView;
        
        // pageMenu.selectedItemIndex就是选中的item下标
        if (self.pageMenu.selectedItemIndex < self.myChildViewControllers.count) {
            BGStrategyAViewController *baseVc = self.myChildViewControllers[self.pageMenu.selectedItemIndex];
            [scrollView addSubview:baseVc.view];
            baseVc.view.frame = CGRectMake(SCREEN_WIDTH*self.pageMenu.selectedItemIndex, 0, SCREEN_WIDTH, scrollViewHeight);
            scrollView.contentOffset = CGPointMake(SCREEN_WIDTH*self.pageMenu.selectedItemIndex, 0);
            scrollView.contentSize = CGSizeMake(self.titleArr.count*SCREEN_WIDTH, 0);
        }
    }
    return _pageMenu;
}
#pragma mark - SPPageMenu的代理方法

- (void)pageMenu:(SPPageMenu *)pageMenu itemSelectedAtIndex:(NSInteger)index {

}

- (void)pageMenu:(SPPageMenu *)pageMenu itemSelectedFromIndex:(NSInteger)fromIndex toIndex:(NSInteger)toIndex {
    
    // 如果fromIndex与toIndex之差大于等于2,说明跨界面移动了,此时不动画.
    if (labs(toIndex - fromIndex) >= 2) {
        [self.scrollView setContentOffset:CGPointMake(SCREEN_WIDTH * toIndex, 0) animated:NO];
    } else {
        [self.scrollView setContentOffset:CGPointMake(SCREEN_WIDTH * toIndex, 0) animated:YES];
    }
    if (self.myChildViewControllers.count <= toIndex) {return;}
    
    BGStrategyAViewController *targetViewController = self.myChildViewControllers[toIndex];
    // 如果已经加载过，就不再加载
    if ([targetViewController isViewLoaded]) return;
    
    targetViewController.view.frame = CGRectMake(SCREEN_WIDTH * toIndex, 0, SCREEN_WIDTH, scrollViewHeight);
    [_scrollView addSubview:targetViewController.view];
    
}
/**
 颜色转换为背景图片
 */
- (UIImage *)imageWithColor:(UIColor *)color {
    CGRect rect = CGRectMake(0.0f, 0.0f, 1.0f, 1.0f);
    UIGraphicsBeginImageContext(rect.size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    CGContextSetFillColorWithColor(context, [color CGColor]);
    CGContextFillRect(context, rect);
    
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return image;
}
-(void)messageTipsActionOne:(NSNotification *)no{
    NSString *status = [no object];
    if (status.intValue>0) {
        self.badgeView.badgeText = status;
        [self.badgeView setNeedsLayout];
    }else{
        self.badgeView.badgeText = nil;
    }
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
