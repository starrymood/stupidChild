//
//  BGHomeViewController.m
//  shzTravelC
//
//  Created by 孙林茂 on 2018/5/4.
//  Copyright © 2018年 biao. All rights reserved.
//

#import "BGHomeViewController.h"
#import "SELUpdateAlert.h"
#import <SDCycleScrollView.h>
#import "BGWebViewController.h"
#import "BGTravelHomeBtn.h"
#import "BGHotVideoCell.h"
#import "BGHomeLineCell.h"
#import "BGPersonalTailorViewController.h"
#import "BGCommunityApi.h"
#import "BGHomeCycleModel.h"
#import "BGHomeHotVideoModel.h"
#import "BGLineHotViewController.h"
#import "RCDCustomerServiceViewController.h"
#import "BGAirProductModel.h"
#import "BGLineDetailViewController.h"
#import "BGAreaSelectViewController.h"
#import "BGLocalPersonListViewController.h"
#import "BGHomeHotAreaModel.h"
#import "BGHomeHotVideoCell.h"
#import "BGHomePreSearchViewController.h"
#import "BGHomeAirSelectView.h"
#import "BGVisaViewController.h"
#import "BGConversationListViewController.h"
#import <JSBadgeView.h>
#import "BGLocalPersonDetailViewController.h"
#import "BGHomeHotCityView.h"
#import "BGFoodLocationDetailViewController.h"
#import "BGLoveFoodListViewController.h"
#import "BGLoveLocationListViewController.h"
#import "BGAirTicketViewController.h"

enum {
    BGCollectionViewLocalPerson, // 本地达人
    BGCollectionViewLoveFood, // 人气美食
    BGCollectionViewLoveLocation // 网红时尚地标
};
@interface BGHomeViewController ()<UICollectionViewDataSource,UICollectionViewDelegate,UITableViewDelegate,UITableViewDataSource>

@property (nonatomic, strong) SDCycleScrollView *topCycleScrollView;
@property (nonatomic, strong) SDCycleScrollView *bannerCycleScrollView;
@property (nonatomic, strong) SDCycleScrollView *adCycleScrollView;

@property (nonatomic,strong) UICollectionView *personCollectionView;
@property (nonatomic,strong) UICollectionView *foodCollectionView;
@property (nonatomic,strong) UICollectionView *locationCollectionView;

@property (nonatomic, strong) UIView *itemBtnsView;
@property(nonatomic,strong) BGHomeHotCityView *hotCityView;
@property (nonatomic, strong) UITableView *tableView;

@property (nonatomic, strong) NSMutableArray *personDataArr;
@property (nonatomic, strong) NSMutableArray *foodDataArr;
@property (nonatomic, strong) NSMutableArray *locationDataArr;
@property (nonatomic, strong) NSMutableArray *lineDataArr;

// 页数
@property (nonatomic, copy) NSString *pageNum;

@property (nonatomic, strong) UIButton *messageBtn;
@property (nonatomic, strong) JSBadgeView *badgeView;
@property (nonatomic, strong) UIView *backView;
@property(nonatomic,strong) BGHomeAirSelectView *airSelectView;

@end

@implementation BGHomeViewController
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
-(BGHomeAirSelectView *)airSelectView{
    if (!_airSelectView) {
        self.airSelectView = [[BGHomeAirSelectView alloc] initWithFrame:CGRectMake(SCREEN_WIDTH*0.2, (SCREEN_HEIGHT-SafeAreaTopHeight-SCREEN_WIDTH*0.6*319/561)*0.5, SCREEN_WIDTH*0.6, SCREEN_WIDTH*0.6*319/561)];
        self.airSelectView.alpha = 0.0;
    }
    return _airSelectView;
}
-(UIView *)backView{
    if (!_backView) {
        self.backView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT)];
        _backView.backgroundColor = [UIColor clearColor];
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(canaleCallBack)];
        [_backView addGestureRecognizer:tap];
    }
    return _backView;
}
-(NSMutableArray *)personDataArr {
    if (!_personDataArr) {
        self.personDataArr = [NSMutableArray array];
    }
    return _personDataArr;
}

-(NSMutableArray *)locationDataArr {
    if (!_locationDataArr) {
        self.locationDataArr = [NSMutableArray array];
    }
    return _locationDataArr;
}

-(NSMutableArray *)lineDataArr{
    if (!_lineDataArr) {
        self.lineDataArr = [NSMutableArray array];
    }
    return _lineDataArr;
}

-(NSMutableArray *)foodDataArr {
    if (!_foodDataArr) {
        self.foodDataArr = [NSMutableArray array];
    }
    return _foodDataArr;
}
-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    self.navigationController.navigationBarHidden = NO;
   self.navigationController.navigationBar.translucent = YES;
    if ([Tool isLogin]) {
        int unreadMsgCount = [[RCIMClient sharedRCIMClient] getUnreadCount:@[@(ConversationType_PRIVATE),@(ConversationType_CUSTOMERSERVICE)]];
         [[NSNotificationCenter defaultCenter]postNotificationName:@"messageTipsAction" object:[NSString stringWithFormat:@"%d",unreadMsgCount]];
    }
    
}
-(void)viewDidLoad{
    [super viewDidLoad];
    
    [self loadSubViews];
    [self refreshView];
   
}
#pragma mark UITableView + 下拉刷新 隐藏时间
- (void)refreshView
{
    // 设置回调（一旦进入刷新状态，就调用target的action，也就是调用self的loadNewData方法）
    __weak __typeof(self) weakSelf = self;
    
    // 设置回调（一旦进入刷新状态就会调用这个refreshingBlock）
    self.tableView.mj_header = [MJRefreshNormalHeader headerWithRefreshingBlock:^{
        // 设置自动切换透明度(在导航栏下面自动隐藏)
        weakSelf.tableView.mj_header.automaticallyChangeAlpha = YES;
         weakSelf.pageNum = @"1";
        [weakSelf loadData];
        [weakSelf.tableView.mj_header endRefreshing];
    }];
    // 上拉刷新
    self.tableView.mj_footer = [MJRefreshAutoNormalFooter footerWithRefreshingBlock:^{
        //每次刷新,页码都加一页
        NSInteger nowPindex = [weakSelf.pageNum integerValue]+1;
        weakSelf.pageNum = [NSString stringWithFormat:@"%zd",nowPindex];
        [weakSelf loadLineData];
//        [weakSelf.tableView.mj_footer endRefreshing];
    }];
    [self loadData];
}
-(void)loadData{

    //    [ProgressHUDHelper showLoading];
    __weak typeof(self) weakSelf = self;
    [BGCommunityApi getHomepageData:nil succ:^(NSDictionary *response) {
         DLog(@"\n>>>[getHomepageData sucess]:%@",response);
        [weakSelf hideNodateView];
        [weakSelf loadLineData];
        // 轮播图 1
        NSArray *topCycleArr = BGdictSetObjectIsNil(response[@"result"][@"banner_list"]);
        NSMutableArray *topImgArray = [NSMutableArray array];
        for (NSDictionary *dic in topCycleArr) {
            [topImgArray addObject:BGdictSetObjectIsNil(dic[@"bannerImages"])];
        }
        weakSelf.topCycleScrollView.imageURLStringsGroup = topImgArray;
        
        // 轮播图 2
        NSArray *bannerCycleArr = BGdictSetObjectIsNil(response[@"result"][@"poster_list"]);
        weakSelf.bannerCycleScrollView.imageURLStringsGroup = bannerCycleArr;
        
        // 轮播图 3
        NSArray *adCycleArr = BGdictSetObjectIsNil(response[@"result"][@"advertisement_list"]);
        weakSelf.adCycleScrollView.imageURLStringsGroup = adCycleArr;
        
        weakSelf.personDataArr = [BGHomeHotVideoModel mj_objectArrayWithKeyValuesArray:BGdictSetObjectIsNil(response[@"result"][@"talent_list"])];
        [weakSelf.personCollectionView reloadData];
        
        weakSelf.foodDataArr = [BGHomeHotVideoModel mj_objectArrayWithKeyValuesArray:BGdictSetObjectIsNil(response[@"result"][@"food_list"])];
        [weakSelf.foodCollectionView reloadData];
        
        weakSelf.locationDataArr = [BGHomeHotVideoModel mj_objectArrayWithKeyValuesArray:BGdictSetObjectIsNil(response[@"result"][@"landmark_list"])];
        [weakSelf.locationCollectionView reloadData];
        
        NSMutableArray *hotCityArr = [BGHomeHotAreaModel mj_objectArrayWithKeyValuesArray:BGdictSetObjectIsNil(response[@"result"][@"region_list"])];
        [weakSelf.hotCityView updataWithCellArray:[NSArray arrayWithArray:hotCityArr]];
        
    } failure:^(NSDictionary *response) {
         DLog(@"\n>>>[getHomepageData failure]:%@",response);
        [ProgressHUDHelper removeLoading];
        [self shownoNetWorkViewWithType:0];
        [self setRefreshBlock:^{
            [weakSelf loadData];
        }];
    }];
}
-(void)loadLineData{
    
    NSMutableDictionary *param = [NSMutableDictionary dictionary];
    [param setObject:@"5" forKey:@"pagesize"];
    [param setObject:_pageNum forKey:@"pageno"];
//    DLog(@"_pageNum:%@",_pageNum);
    [ProgressHUDHelper showLoading];
    __block typeof(self) weakSelf = self;
    __weak UITableView *tableView = self.tableView;
    [BGCommunityApi getHomepageLineData:param succ:^(NSDictionary *response) {
        DLog(@"\n>>>[getHomepageLineData sucess]:%@",response);
        if (weakSelf.pageNum.intValue == 1) {
            [weakSelf.lineDataArr removeAllObjects];
            [tableView.mj_footer resetNoMoreData];
        }
        NSMutableArray *tempArr = [BGAirProductModel mj_objectArrayWithKeyValuesArray:BGdictSetObjectIsNil(response[@"result"][@"rows"])];
        NSString *totalPageNumStr = [NSString stringWithFormat:@"%@",BGdictSetObjectIsNil(response[@"result"][@"pages"])];
        if (weakSelf.pageNum.integerValue<=totalPageNumStr.integerValue) {
            [weakSelf.lineDataArr addObjectsFromArray:tempArr];
           
        }
         [tableView reloadData];
       
        if (weakSelf.pageNum.integerValue>=totalPageNumStr.integerValue) {
            [tableView.mj_footer endRefreshingWithNoMoreData];
        }else{
          [tableView.mj_footer endRefreshing];
        }
    } failure:^(NSDictionary *response) {
        DLog(@"\n>>>[getHomepageLineData failure]:%@",response);
    }];
    
}
-(void)loadSubViews{
    
    self.navigationItem.title = @"傻孩子";
    self.view.backgroundColor = kAppBgColor;
    
    self.navigationItem.leftBarButtonItem = [UIBarButtonItem itemWithImage:@"hotline" highImage:@"hotline" target:self action:@selector(clickedHotlineAction)];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(messageTipsAction:) name:@"messageTipsAction" object:nil];
    self.messageBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [_messageBtn setImage:BGImage(@"home_message") forState:UIControlStateNormal];
    [_messageBtn setImage:BGImage(@"home_message") forState:UIControlStateHighlighted];
    _messageBtn.bounds = CGRectMake(0, 0, 70, 30);
    _messageBtn.imageEdgeInsets = UIEdgeInsetsMake(0, 0, 0, -30);
    _messageBtn.contentEdgeInsets = UIEdgeInsetsZero;
//    _messageBtn.contentHorizontalAlignment = UIControlContentHorizontalAlignmentRight;
    @weakify(self);
    [[_messageBtn rac_signalForControlEvents:(UIControlEventTouchUpInside)] subscribeNext:^(__kindof UIControl * _Nullable x) {
        @strongify(self);
        // 点击button的响应事件
        [self clickedMessageAction];
    }];
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:_messageBtn];
   
    UIView *headerView = UIView.new;
    CGFloat personItemWidth = (SCREEN_WIDTH-40)/(19/105.0+3);
    CGFloat foodItemWidth = (SCREEN_WIDTH-30)*0.5;
    CGFloat locationItemWidth = (SCREEN_WIDTH-20-12*2)/3.0;
    
    CGFloat personCollectionViewHeight = (personItemWidth*185/105.0)+23;
    CGFloat foodCollectionViewHeight = (foodItemWidth+61)*2+6+20+15;
    CGFloat locationCollectionViewHeight = (locationItemWidth+61)*2+6+20+15;
    // headerView
    headerView.frame = CGRectMake(0, 0, SCREEN_WIDTH, 3+SCREEN_WIDTH*9/16+161+10+SCREEN_WIDTH*139.0/750+11+51+25+SCREEN_WIDTH*216.0/375+18+98+54+51+15+personCollectionViewHeight+ 21+51+15+foodCollectionViewHeight+23+SCREEN_WIDTH*140.0/375+36+51+15+locationCollectionViewHeight+12+51);
    headerView.backgroundColor = kAppWhiteColor;
    
    // 1.topCycleScrollView 3+SCREEN_WIDTH*9/16
    UIView *topLineView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, 3)];
    topLineView.backgroundColor = kAppBgColor;
    [headerView addSubview:topLineView];
    
    self.topCycleScrollView = [SDCycleScrollView cycleScrollViewWithFrame:CGRectMake(0, 3, SCREEN_WIDTH, SCREEN_WIDTH*9/16) delegate:nil placeholderImage:BGImage(@"home_cycle_placeholder")];
    self.topCycleScrollView.pageControlAliment = SDCycleScrollViewPageContolAlimentCenter;
    self.topCycleScrollView.backgroundColor = kAppBgColor;
    self.topCycleScrollView.pageControlBottomOffset = 40;
    self.topCycleScrollView.currentPageDotImage = BGImage(@"home_cycle_selected");
    self.topCycleScrollView.pageDotImage = BGImage(@"home_cycle_unselected");
    [headerView addSubview:_topCycleScrollView];
    
    // 搜索框
    UIButton *searchBtn = [UIButton buttonWithType:(UIButtonTypeCustom)];
    searchBtn.frame = CGRectMake(10, 13, SCREEN_WIDTH-20, 30);
    searchBtn.backgroundColor = [UIColor colorWithWhite:1 alpha:0.4];
    searchBtn.clipsToBounds = YES;
    searchBtn.layer.cornerRadius = 15;
    
    [[searchBtn rac_signalForControlEvents:(UIControlEventTouchUpInside)] subscribeNext:^(__kindof UIControl * _Nullable x) {
        @strongify(self);
        // 点击button的响应事件
        // @@ 添加登录判断
        if (![Tool isLogin]) {
            [WHIndicatorView toast:@"请先登录!"];
            [BGAppDelegateHelper showLoginViewController];
            return;
        }
        
        [self clickedSearchAction];
        
    }];
    
    UIImageView *searchImgView = [[UIImageView alloc] initWithImage:BGImage(@"home_search_new")];
    searchImgView.frame = CGRectMake(28, 5, 20, 20);
    [searchBtn addSubview:searchImgView];
    
    UILabel *searchLabel = UILabel.new;
    searchLabel.frame = CGRectMake(searchImgView.x+searchImgView.width+5, 8, 61, 14);
    [searchLabel setTextColor:UIColorFromRGB(0x9D9D9D)];
    searchLabel.textAlignment = NSTextAlignmentLeft;
    searchLabel.text = @"搜索";
    [searchLabel setFont:kFont(14)];
    [searchBtn addSubview:searchLabel];
    
    [headerView addSubview:searchBtn];
    
    // 2.itemBtnsView 161
    self.itemBtnsView = UIView.new;
    _itemBtnsView.frame = CGRectMake(0, _topCycleScrollView.y+_topCycleScrollView.height-37-10, SCREEN_WIDTH, 208);
    UIImage *image = BGImage(@"home_icon_background");
    _itemBtnsView.layer.contents=(id)image.CGImage;
    _itemBtnsView.backgroundColor = kAppClearColor;
    [headerView addSubview:_itemBtnsView];
    
    NSArray *itemImg = @[@"home_icon_11",@"home_icon_12",@"home_icon_13",@"home_icon_14",@"home_icon_15",@"home_icon_21",@"home_icon_22",@"home_icon_23",@"home_icon_24",@"home_icon_25"];
    NSArray *itemName = @[@"签证",@"机票",@"酒店",@"火车票",@"捡漏",@"接机",@"私人订制",@"精品路线",@"按天包车",@"送机"];
    
    float w = (SCREEN_WIDTH-27*2-5*65)/5;
    float width = w;
    for (int i = 0; i < 5; i++) {
        BGTravelHomeBtn *itemBtn = [[BGTravelHomeBtn alloc] initWithFrame:CGRectMake(10+15+width, 10, 65, 80)];
        [itemBtn.btnImgView setImage:BGImage(itemImg[i])];
        itemBtn.btnTitleLabel.text = itemName[i];
        itemBtn.tag = 100+i;
        [itemBtn addTarget:self action:@selector(itemBtnClicked:) forControlEvents:UIControlEventTouchUpInside];
        [_itemBtnsView addSubview:itemBtn];
        width += 65 + w;
    }
    
    float z = (SCREEN_WIDTH-27*2-5*65)/5;
    float widthh = z;
    for (int i = 5; i < 10; i++) {
        BGTravelHomeBtn *itemBtn = [[BGTravelHomeBtn alloc] initWithFrame:CGRectMake(10+15+widthh, 95, 65, 80)];
        [itemBtn.btnImgView setImage:BGImage(itemImg[i])];
        itemBtn.btnTitleLabel.text = itemName[i];
        itemBtn.tag = 100+i;
        [itemBtn addTarget:self action:@selector(itemBtnClicked:) forControlEvents:UIControlEventTouchUpInside];
        [_itemBtnsView addSubview:itemBtn];
        widthh += 65 + z;
    }
    
    // 2.5 adImgView 10+SCREEN_WIDTH*139.0/750
    UIImageView *adImgView = [[UIImageView alloc] initWithFrame:CGRectMake(0, _itemBtnsView.y+_itemBtnsView.height+10, SCREEN_WIDTH, SCREEN_WIDTH*139/750)];
    [adImgView setImage:BGImage(@"home_tip_image")];
    [headerView addSubview:adImgView];
    
    
    // 3.hotView 11+51+25+SCREEN_WIDTH*216.0/375
    UIView *hotView = UIView.new;
    hotView.backgroundColor = kAppWhiteColor;
    hotView.frame = CGRectMake(0, adImgView.y+adImgView.height+11, SCREEN_WIDTH, 51);
    [headerView addSubview:hotView];
    
    UILabel *hotLabel = UILabel.new;
    hotLabel.frame = CGRectMake(17, 14, 100, 23);
    hotLabel.text = @"热门地区";
    hotLabel.textColor = kApp333Color;
    hotLabel.font = [UIFont fontWithName:@"PingFangSC-Semibold" size:24];
    [hotView addSubview:hotLabel];
    
    UIButton *moreHotBtn = [UIButton buttonWithType:(UIButtonTypeCustom)];
    [moreHotBtn setTitle:@"更多地区>" forState:(UIControlStateNormal)];
    [moreHotBtn.titleLabel setFont:kFont(14)];
    [moreHotBtn setTitleColor:UIColorFromRGB(0x9D9D9D) forState:(UIControlStateNormal)];
    moreHotBtn.frame = CGRectMake(SCREEN_WIDTH-85, 18.5, 70, 14);
    [hotView addSubview:moreHotBtn];
    
    [[moreHotBtn rac_signalForControlEvents:(UIControlEventTouchUpInside)] subscribeNext:^(__kindof UIControl * _Nullable x) {
        @strongify(self);
        // 点击button的响应事件
        // @@ 添加登录判断
        if (![Tool isLogin]) {
            [WHIndicatorView toast:@"请先登录!"];
            [BGAppDelegateHelper showLoginViewController];
            return;
        }
        BGAreaSelectViewController *cityVC = BGAreaSelectViewController.new;
        cityVC.category = 4; // 线路
        [self.navigationController pushViewController:cityVC animated:YES];
        
    }];
    
    self.hotCityView = [[BGHomeHotCityView alloc] initWithFrame:CGRectMake(0, hotView.y+hotView.height+25, SCREEN_WIDTH, SCREEN_WIDTH*216.0/375)];
    __weak typeof(self) weakSelf = self;
    _hotCityView.selectCityTapClick = ^(NSString * _Nonnull region_id) {
        if (![Tool isLogin]) {
            [WHIndicatorView toast:@"请先登录!"];
            [BGAppDelegateHelper showLoginViewController];
            return;
        }
        BGLineHotViewController *lineVC = BGLineHotViewController.new;
        lineVC.regionIdStr = region_id;
        [weakSelf.navigationController pushViewController:lineVC animated:YES];
    };
    [headerView addSubview:_hotCityView];
    
    // 4.bannerCycleScrollView 18+98
    self.bannerCycleScrollView = [SDCycleScrollView cycleScrollViewWithFrame:CGRectMake(10, _hotCityView.y+_hotCityView.height+18, SCREEN_WIDTH-20, 98) delegate:nil placeholderImage:nil];
    self.bannerCycleScrollView.pageControlAliment = SDCycleScrollViewPageContolAlimentCenter;
    self.bannerCycleScrollView.backgroundColor = kAppWhiteColor;
    self.bannerCycleScrollView.showPageControl = NO;
    [headerView addSubview:_bannerCycleScrollView];
    
    // 5.localPersonView 54+51
    UIView *localPersonView = UIView.new;
    localPersonView.backgroundColor = kAppWhiteColor;
    localPersonView.frame = CGRectMake(0, _bannerCycleScrollView.y+_bannerCycleScrollView.height+54, SCREEN_WIDTH, 51);
    [headerView addSubview:localPersonView];
    
    UILabel *localPersonLabel = UILabel.new;
    localPersonLabel.frame = CGRectMake(17, 14, 100, 23);
    localPersonLabel.text = @"当地达人";
    localPersonLabel.textColor = UIColorFromRGB(0x333333);
    localPersonLabel.font = [UIFont fontWithName:@"PingFangSC-Semibold" size:24];
    [localPersonView addSubview:localPersonLabel];
    
    UIButton *moreLocalPersonBtn = [UIButton buttonWithType:(UIButtonTypeCustom)];
    [moreLocalPersonBtn setTitle:@"更多达人>" forState:(UIControlStateNormal)];
    [moreLocalPersonBtn.titleLabel setFont:kFont(14)];
    [moreLocalPersonBtn setTitleColor:UIColorFromRGB(0x9D9D9D) forState:(UIControlStateNormal)];
    moreLocalPersonBtn.frame = CGRectMake(SCREEN_WIDTH-85, 18.5, 70, 14);
    [localPersonView addSubview:moreLocalPersonBtn];

    [[moreLocalPersonBtn rac_signalForControlEvents:(UIControlEventTouchUpInside)] subscribeNext:^(__kindof UIControl * _Nullable x) {
        @strongify(self);
        // 点击button的响应事件
        // @@ 添加登录判断
        if (![Tool isLogin]) {
            [WHIndicatorView toast:@"请先登录!"];
            [BGAppDelegateHelper showLoginViewController];
            return;
        }
        BGLocalPersonListViewController *personVC = BGLocalPersonListViewController.new;
        [self.navigationController pushViewController:personVC animated:YES];
        
    }];
    // 6.personCollectionView 15+personCollectionViewHeight
    UICollectionViewFlowLayout *personFlowLayout =[[UICollectionViewFlowLayout alloc]init];
    personFlowLayout.itemSize = CGSizeMake(personItemWidth, personItemWidth*185/105.0);
    personFlowLayout.sectionInset = UIEdgeInsetsMake(8, 10, 15, 10);
    personFlowLayout.minimumLineSpacing = 10;
    personFlowLayout.minimumInteritemSpacing  = 10;
    personFlowLayout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
    self.personCollectionView =[[UICollectionView alloc] initWithFrame:CGRectMake(0, localPersonView.y+localPersonView.height+15, SCREEN_WIDTH,personCollectionViewHeight) collectionViewLayout:personFlowLayout];
    _personCollectionView.backgroundColor = kAppWhiteColor;
    _personCollectionView.tag = BGCollectionViewLocalPerson;
    _personCollectionView.scrollsToTop = NO;
    _personCollectionView.showsHorizontalScrollIndicator = NO;
    [_personCollectionView registerNib:[UINib nibWithNibName:NSStringFromClass([BGHomeHotVideoCell class]) bundle:nil] forCellWithReuseIdentifier:@"BGHomeHotVideoCell"];
    _personCollectionView.delegate = self;
    _personCollectionView.dataSource = self;
    [headerView addSubview:_personCollectionView];
    
   // 7.foodView 21+51
    UIView *foodView = UIView.new;
    foodView.backgroundColor = kAppWhiteColor;
    foodView.frame = CGRectMake(0, _personCollectionView.y+_personCollectionView.height+21, SCREEN_WIDTH, 51);
    [headerView addSubview:foodView];
    
    UILabel *foodLabel = UILabel.new;
    foodLabel.frame = CGRectMake(17, 14, 100, 23);
    foodLabel.text = @"人气美食";
    foodLabel.textColor = kApp333Color;
    foodLabel.font = [UIFont fontWithName:@"PingFangSC-Semibold" size:24];
    [foodView addSubview:foodLabel];
    
    UIButton *moreFoodBtn = [UIButton buttonWithType:(UIButtonTypeCustom)];
    [moreFoodBtn setTitle:@"更多美食>" forState:(UIControlStateNormal)];
    [moreFoodBtn.titleLabel setFont:kFont(14)];
    [moreFoodBtn setTitleColor:UIColorFromRGB(0x9D9D9D) forState:(UIControlStateNormal)];
    moreFoodBtn.frame = CGRectMake(SCREEN_WIDTH-85, 18.5, 70, 14);
    [foodView addSubview:moreFoodBtn];
    
    [[moreFoodBtn rac_signalForControlEvents:(UIControlEventTouchUpInside)] subscribeNext:^(__kindof UIControl * _Nullable x) {
        @strongify(self);
        // 点击button的响应事件
        // @@ 添加登录判断
        if (![Tool isLogin]) {
            [WHIndicatorView toast:@"请先登录!"];
            [BGAppDelegateHelper showLoginViewController];
            return;
        }
        BGLoveFoodListViewController *foodVC = BGLoveFoodListViewController.new;
        [self.navigationController pushViewController:foodVC animated:YES];
        
    }];
    
    
    // 8.foodCollectionView 15+foodCollectionViewHeight
    UICollectionViewFlowLayout *foodFlowLayout =[[UICollectionViewFlowLayout alloc]init];
    foodFlowLayout.itemSize = CGSizeMake(foodItemWidth, foodItemWidth+61);
    foodFlowLayout.sectionInset = UIEdgeInsetsMake(6, 10, 15, 10);
    foodFlowLayout.minimumLineSpacing = 20;
    foodFlowLayout.minimumInteritemSpacing  = 10;
    self.foodCollectionView =[[UICollectionView alloc] initWithFrame:CGRectMake(0, foodView.height+foodView.y+15, SCREEN_WIDTH,foodCollectionViewHeight) collectionViewLayout:foodFlowLayout];
    _foodCollectionView.backgroundColor = kAppWhiteColor;
    _foodCollectionView.tag = BGCollectionViewLoveFood;
    _foodCollectionView.scrollsToTop = NO;
    _foodCollectionView.showsHorizontalScrollIndicator = NO;
    [_foodCollectionView registerNib:[UINib nibWithNibName:NSStringFromClass([BGHotVideoCell class]) bundle:nil] forCellWithReuseIdentifier:@"BGHotVideoCell"];
    _foodCollectionView.delegate = self;
    _foodCollectionView.dataSource = self;
    [headerView addSubview:_foodCollectionView];
    
    // 9.adCycleScrollView 23+SCREEN_WIDTH*140.0/375
    self.adCycleScrollView = [SDCycleScrollView cycleScrollViewWithFrame:CGRectMake(0, _foodCollectionView.y+_foodCollectionView.height+23, SCREEN_WIDTH, SCREEN_WIDTH*140.0/375) delegate:nil placeholderImage:nil];
    self.adCycleScrollView.pageControlAliment = SDCycleScrollViewPageContolAlimentCenter;
    self.adCycleScrollView.backgroundColor = kAppWhiteColor;
    [headerView addSubview:_adCycleScrollView];
    
    // 10.locationView 36+51
    UIView *locationView = UIView.new;
    locationView.backgroundColor = kAppWhiteColor;
    locationView.frame = CGRectMake(0, _adCycleScrollView.y+_adCycleScrollView.height+36, SCREEN_WIDTH, 51);
    [headerView addSubview:locationView];
    
    UILabel *locationLabel = UILabel.new;
    locationLabel.frame = CGRectMake(17, 14, 150, 23);
    locationLabel.text = @"网红时尚地标";
    locationLabel.textColor = kApp333Color;
    locationLabel.font = [UIFont fontWithName:@"PingFangSC-Semibold" size:24];
    [locationView addSubview:locationLabel];
    
    UIButton *moreLocationBtn = [UIButton buttonWithType:(UIButtonTypeCustom)];
    [moreLocationBtn setTitle:@"更多地标>" forState:(UIControlStateNormal)];
    [moreLocationBtn.titleLabel setFont:kFont(14)];
    [moreLocationBtn setTitleColor:UIColorFromRGB(0x9D9D9D) forState:(UIControlStateNormal)];
    moreLocationBtn.frame = CGRectMake(SCREEN_WIDTH-85, 18.5, 70, 14);
    [locationView addSubview:moreLocationBtn];
    
    [[moreLocationBtn rac_signalForControlEvents:(UIControlEventTouchUpInside)] subscribeNext:^(__kindof UIControl * _Nullable x) {
        @strongify(self);
        // 点击button的响应事件
        // @@ 添加登录判断
        if (![Tool isLogin]) {
            [WHIndicatorView toast:@"请先登录!"];
            [BGAppDelegateHelper showLoginViewController];
            return;
        }
        BGLoveLocationListViewController *locationVC = BGLoveLocationListViewController.new;
        [self.navigationController pushViewController:locationVC animated:YES];
        
    }];
    
    // 11.locationFlowLayout 15+locationCollectionViewHeight
    UICollectionViewFlowLayout *locationFlowLayout =[[UICollectionViewFlowLayout alloc]init];
    locationFlowLayout.itemSize = CGSizeMake(locationItemWidth, locationItemWidth+61);
    locationFlowLayout.sectionInset = UIEdgeInsetsMake(6, 10, 15, 10);
    locationFlowLayout.minimumLineSpacing = 20;
    locationFlowLayout.minimumInteritemSpacing  = 12;
    self.locationCollectionView =[[UICollectionView alloc] initWithFrame:CGRectMake(0, locationView.height+locationView.y+15, SCREEN_WIDTH,locationCollectionViewHeight) collectionViewLayout:locationFlowLayout];
    _locationCollectionView.backgroundColor = kAppWhiteColor;
    _locationCollectionView.tag = BGCollectionViewLoveLocation;
    _locationCollectionView.scrollsToTop = NO;
    _locationCollectionView.showsHorizontalScrollIndicator = NO;
    [_locationCollectionView registerNib:[UINib nibWithNibName:NSStringFromClass([BGHotVideoCell class]) bundle:nil] forCellWithReuseIdentifier:@"BGHotVideoCell"];
    _locationCollectionView.delegate = self;
    _locationCollectionView.dataSource = self;
    [headerView addSubview:_locationCollectionView];
    
    // 12.lineView 12+51
    UIView *lineView = UIView.new;
    lineView.backgroundColor = kAppWhiteColor;
    lineView.frame = CGRectMake(0, _locationCollectionView.y+_locationCollectionView.height+12, SCREEN_WIDTH, 51);
    [headerView addSubview:lineView];
    
    UILabel *lineLabel = UILabel.new;
    lineLabel.frame = CGRectMake(17, 14, 100, 23);
    lineLabel.text = @"精品路线";
    lineLabel.textColor = kApp333Color;
    lineLabel.font = [UIFont fontWithName:@"PingFangSC-Semibold" size:24];
    [lineView addSubview:lineLabel];
    
    UIButton *moreLineBtn = [UIButton buttonWithType:(UIButtonTypeCustom)];
    [moreLineBtn setTitle:@"更多线路>" forState:(UIControlStateNormal)];
    [moreLineBtn.titleLabel setFont:kFont(14)];
    [moreLineBtn setTitleColor:UIColorFromRGB(0x9D9D9D) forState:(UIControlStateNormal)];
    moreLineBtn.frame = CGRectMake(SCREEN_WIDTH-85, 18.5, 70, 14);
    [lineView addSubview:moreLineBtn];
    
    [[moreLineBtn rac_signalForControlEvents:(UIControlEventTouchUpInside)] subscribeNext:^(__kindof UIControl * _Nullable x) {
        @strongify(self);
        // 点击button的响应事件
        // @@ 添加登录判断
        if (![Tool isLogin]) {
            [WHIndicatorView toast:@"请先登录!"];
            [BGAppDelegateHelper showLoginViewController];
            return;
        }
        BGAreaSelectViewController *cityVC = BGAreaSelectViewController.new;
        cityVC.category = 4; // 线路
        [self.navigationController pushViewController:cityVC animated:YES];
        
        
    }];
    
    self.tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, SafeAreaTopHeight, SCREEN_WIDTH, SCREEN_HEIGHT-SafeAreaTopHeight-SafeAreaBottomHeight-kTabBarH) style:(UITableViewStyleGrouped)];
    _tableView.backgroundColor = kAppBgColor;
    _tableView.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
    _tableView.separatorColor = kAppBgColor;
    _tableView.tableHeaderView = headerView;
    _tableView.estimatedRowHeight = SCREEN_HEIGHT;
    _tableView.rowHeight = UITableViewAutomaticDimension;
    _tableView.dataSource = self;
    _tableView.delegate = self;
    [self.view addSubview:_tableView];
    
    // 注册cell
    [_tableView registerNib:[UINib nibWithNibName:@"BGHomeLineCell" bundle:nil] forCellReuseIdentifier:@"BGHomeLineCell"];
     _pageNum = @"1";
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(.3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self updateNoticeAction];
    });
}
- (void)itemBtnClicked:(UIButton *)sender {
    // @@ 添加登录判断
    if (![Tool isLogin]) {
        [WHIndicatorView toast:@"请先登录!"];
        [BGAppDelegateHelper showLoginViewController];
        return;
    }
    switch (sender.tag-100) {
        case 0:{
            // 签证
            BGVisaViewController *visaVC = BGVisaViewController.new;
            [self.navigationController pushViewController:visaVC animated:YES];
        }
            break;
        case 1:{
            BGAirTicketViewController *airVC = BGAirTicketViewController.new;
            [self.navigationController pushViewController:airVC animated:YES];
        }
            break;
        case 5:{
            BGAreaSelectViewController *cityVC = BGAreaSelectViewController.new;
            cityVC.category = 1;
            [self.navigationController pushViewController:cityVC animated:YES];
        }
            break;
        case 6:{  // 私人订制
            if (![Tool isLogin]) {
                [WHIndicatorView toast:@"请先登录!"];
                [BGAppDelegateHelper showLoginViewController];
                return;
            }
            BGPersonalTailorViewController *personalVC = BGPersonalTailorViewController.new;
            personalVC.preNav = self.navigationController;
            [self.navigationController pushViewController:personalVC animated:YES];
        }
            break;
        case 7:{  // 精品路线
            BGAreaSelectViewController *cityVC = BGAreaSelectViewController.new;
            cityVC.category = 4; // 线路
            [self.navigationController pushViewController:cityVC animated:YES];
        }
            break;
        case 8:{
            BGAreaSelectViewController *cityVC = BGAreaSelectViewController.new;
            cityVC.category = 3;  // 按天包车
            [self.navigationController pushViewController:cityVC animated:YES];
        }
            break;
        case 9:{
            BGAreaSelectViewController *cityVC = BGAreaSelectViewController.new;
            cityVC.category = 2;  // 送机
            [self.navigationController pushViewController:cityVC animated:YES];
        }
            break;
        default:{
            [WHIndicatorView toast:@"该业务即将上线，敬请期待..."];
        }
            break;
    }
}
#pragma mark UICollectionViewDataSource
- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView{
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    
    if (collectionView.tag == BGCollectionViewLocalPerson) {
        return self.personDataArr.count;
    }else if(collectionView.tag == BGCollectionViewLoveFood){
        return self.foodDataArr.count>4?4:self.foodDataArr.count;
    }else if(collectionView.tag == BGCollectionViewLoveLocation){
        return self.locationDataArr.count>6?6:self.locationDataArr.count;
    }else{
        return 0;
    }
    
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
     if (collectionView.tag == BGCollectionViewLocalPerson) {
         BGHomeHotVideoCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"BGHomeHotVideoCell" forIndexPath:indexPath];
         if ([Tool arrayIsNotEmpty:_personDataArr]) {
             BGHomeHotVideoModel *model = self.personDataArr[indexPath.item];
             [cell updataWithCellArray:model];
         }
         return cell;
     }else if(collectionView.tag == BGCollectionViewLoveFood){
         BGHotVideoCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"BGHotVideoCell" forIndexPath:indexPath];
         if ([Tool arrayIsNotEmpty:_foodDataArr]) {
             BGHomeHotVideoModel *model = self.foodDataArr[indexPath.item];
             [cell updataWithCellArray:model isFood:YES];
         }
         return cell;
     }else if(collectionView.tag == BGCollectionViewLoveLocation){
         BGHotVideoCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"BGHotVideoCell" forIndexPath:indexPath];
         if ([Tool arrayIsNotEmpty:_locationDataArr]) {
             BGHomeHotVideoModel *model = self.locationDataArr[indexPath.item];
             [cell updataWithCellArray:model isFood:NO];
         }
         return cell;
     }else{
         return UICollectionViewCell.new;
     }
}


-(void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{
    
//    DLog(@"\n>>>[collectionView didSelectItem]:%ld",(long)indexPath.item);
    // @@ 添加登录判断
    if (![Tool isLogin]) {
        [WHIndicatorView toast:@"请先登录!"];
        [BGAppDelegateHelper showLoginViewController];
        return;
    }
    if (collectionView.tag == BGCollectionViewLocalPerson) {
        BGHomeHotVideoModel *model = _personDataArr[indexPath.item];
        BGLocalPersonDetailViewController *detailVC = BGLocalPersonDetailViewController.new;
        detailVC.personID = model.ID;
        [self.navigationController pushViewController:detailVC animated:YES];
    }else if(collectionView.tag == BGCollectionViewLoveFood){
        BGHomeHotVideoModel *model = _foodDataArr[indexPath.item];
        BGFoodLocationDetailViewController *detailVC = BGFoodLocationDetailViewController.new;
        detailVC.landmark_id = model.ID;
        [self.navigationController pushViewController:detailVC animated:YES];
    }else if(collectionView.tag == BGCollectionViewLoveLocation){
        BGHomeHotVideoModel *model = _locationDataArr[indexPath.item];
        BGFoodLocationDetailViewController *detailVC = BGFoodLocationDetailViewController.new;
        detailVC.landmark_id = model.ID;
        [self.navigationController pushViewController:detailVC animated:YES];
    }
    
    
}
#pragma mark  -  TableViewDelegate  -
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return ceil(_lineDataArr.count*0.2);
    
}
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    NSMutableArray *tempArr = [[NSMutableArray alloc] init];
    for (int i = 0; i<5; i++) {
        NSInteger num = indexPath.section*5+i;
        if (num<_lineDataArr.count) {
             BGAirProductModel *model = _lineDataArr[num];
            [tempArr addObject:model];
        }
    }
    BGHomeLineCell *cell = [tableView dequeueReusableCellWithIdentifier:@"BGHomeLineCell" forIndexPath:indexPath];
    __weak typeof(self) weakSelf = self;
   
    if ([Tool arrayIsNotEmpty:tempArr]) {
        [cell updataWithCellArr:[NSArray arrayWithArray:tempArr]];
        cell.jumpToDetailBtnClick = ^(NSInteger btnTag) {
            // @@ 添加登录判断
            if (![Tool isLogin]) {
                [WHIndicatorView toast:@"请先登录!"];
                [BGAppDelegateHelper showLoginViewController];
                return;
            }
            BGLineDetailViewController *detailVC = BGLineDetailViewController.new;
            detailVC.product_id = [NSString stringWithFormat:@"%zd",btnTag];
            [weakSelf.navigationController pushViewController:detailVC animated:YES];
        };
    }
    return cell;
}
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    

}
-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    return section == 0? 0.01:6;
}

-(CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section{
   
    return 0.01;
}
- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    return nil;
}
- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section{

    return nil;
}

-(void)updateNoticeAction{
    
    [WHAPIClient GET:@"https://www.csnow.cn/updates.json" param:nil tokenType:3 succ:^(NSDictionary *response) {
        //        DLog(@"\n>>>[csnow success]:%@",response);
        int isForce = [BGdictSetObjectIsNil(response[@"updateC"]) intValue];
        
        if (isForce == 0) {
            return ;
        }
        NSString *versionStr = BGdictSetObjectIsNil(response[@"versionC"]);
        NSDictionary *infoDict = [[NSBundle mainBundle] infoDictionary];
        NSString *vison = infoDict[@"CFBundleShortVersionString"];
        if ([vison compare:versionStr options:NSNumericSearch] == NSOrderedAscending){
        } else {
            return ;
        }
        
        if (isForce == 1) {
            NSArray *noteArr = BGdictSetObjectIsNil(response[@"noteC"]);
            [SELUpdateAlert showUpdateAlertWithVersion:versionStr Descriptions:noteArr isForce:YES];
        }else if (isForce == 2){
            NSDate *now = [NSDate date];
            NSDate *agoDate = BGGetUserDefaultObjectForKey(@"UpdateOld_date");
            NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
            [dateFormatter setDateFormat:@"yyyy-MM-dd"];
            NSString *ageDateString = [dateFormatter stringFromDate:agoDate];
            NSString *nowDateString = [dateFormatter stringFromDate:now];
            if ([ageDateString isEqualToString:nowDateString]) {
                NSString *numStr = [NSString stringWithFormat:@"%d",[BGGetUserDefaultObjectForKey(@"update_times") intValue]+1];
                BGSetUserDefaultObjectForKey(numStr, @"update_times");
            }else{
                BGSetUserDefaultObjectForKey(now, @"UpdateOld_date");
                BGSetUserDefaultObjectForKey(@"0", @"update_times");
            }
            if ([BGGetUserDefaultObjectForKey(@"update_times") intValue] >2) {
            }else{
                NSArray *noteArr = BGdictSetObjectIsNil(response[@"noteC"]);
                [SELUpdateAlert showUpdateAlertWithVersion:versionStr Descriptions:noteArr isForce:NO];
            }
        }
        
    } failure:^(NSDictionary *response) {
        //        DLog(@"\n>>>[csnow failure]:%@",response);
    }];
}

-(void)clickedHotlineAction{
    if (![Tool isLogin]) {
        [WHIndicatorView toast:@"请先登录!"];
        [BGAppDelegateHelper showLoginViewController];
        return;
    }
    if ([RCIMClient sharedRCIMClient].getConnectionStatus != 0) {
        [WHIndicatorView toast:@"融云连接失败,请重新登录账号!"];
        [Tool logoutRongCloudAction];
        return;
    }
    
    RCDCustomerServiceViewController *chatService = [[RCDCustomerServiceViewController alloc] init];
    chatService.conversationType = ConversationType_CUSTOMERSERVICE;
    chatService.targetId = RongCloud_Service;//通过“客服管理后台 - 坐席管理 - 技能组”，对应为技能组列表中的技能组 ID。
    chatService.title = @"傻孩子客服";
    RCCustomerServiceInfo *csInfo = [[RCCustomerServiceInfo alloc] init];
    csInfo.userId = [RCIMClient sharedRCIMClient].currentUserInfo.userId;
    csInfo.nickName = BGGetUserDefaultObjectForKey(@"UserNickname");
    csInfo.portraitUrl = [RCIMClient sharedRCIMClient].currentUserInfo.portraitUri;
    csInfo.referrer = @"客户端";
    chatService.csInfo = csInfo; //用户的详细信息，此数据用于上传用户信息到客服后台，数据的 nickName 和 portraitUrl 必须填写。
    [[RCIMClient sharedRCIMClient] setConversationToTop:(ConversationType_CUSTOMERSERVICE) targetId:RongCloud_Service isTop:YES];
    [self.navigationController pushViewController :chatService animated:YES];
    
}
-(void)clickedMessageAction{
    // @@ 添加登录判断
    if (![Tool isLogin]) {
        [WHIndicatorView toast:@"请先登录!"];
        [BGAppDelegateHelper showLoginViewController];
        return;
    }
    BGConversationListViewController *messageVC = BGConversationListViewController.new;
    [self.navigationController pushViewController:messageVC animated:YES];
}
-(void)messageTipsAction:(NSNotification *)no{
    NSString *status = [no object];
    if (status.intValue>0) {
        self.badgeView.badgeText = status;
        [self.badgeView setNeedsLayout];
    }else{
        self.badgeView.badgeText = nil;
    }
}
/** 点击图片回调
- (void)cycleScrollView:(SDCycleScrollView *)cycleScrollView didSelectItemAtIndex:(NSInteger)index{
    // @@ 添加登录判断
    if (![Tool isLogin]) {
        [WHIndicatorView toast:@"请先登录!"];
        [BGAppDelegateHelper showLoginViewController];
        return;
    }
    BGHomeCycleModel *model = _cycleDataArray[index];
    if (![Tool isBlankString:model.linkUrl]) {
        BGWebViewController *webVC = BGWebViewController.new;
        webVC.url = model.linkUrl;
        [self.navigationController pushViewController:webVC animated:YES];
    }
}
 */
-(void)clickedSearchAction{
    // @@ 添加登录判断
    if (![Tool isLogin]) {
        [WHIndicatorView toast:@"请先登录!"];
        [BGAppDelegateHelper showLoginViewController];
        return;
    }
    BGHomePreSearchViewController *searchVC = BGHomePreSearchViewController.new;
    CATransition *transition = [CATransition animation];
    transition.type = kCATransitionFade;
    transition.subtype = kCATransitionFromBottom;
    [self.navigationController.view.layer addAnimation:transition forKey:kCATransition];
    [self.navigationController pushViewController:searchVC animated:NO];
}
/**
 显示
 */
-(void)showAirSelectedViewAction{
    [[[UIApplication sharedApplication] keyWindow] addSubview:self.backView];
    [[[UIApplication sharedApplication] keyWindow] addSubview:self.airSelectView];
    @weakify(self);
    [[self.airSelectView.pickupBtn rac_signalForControlEvents:(UIControlEventTouchUpInside)] subscribeNext:^(__kindof UIControl * _Nullable x) {
        @strongify(self);
        [self canaleCallBack];
        // 点击button的响应事件
        BGAreaSelectViewController *cityVC = BGAreaSelectViewController.new;
        cityVC.category = 1;
        [self.navigationController pushViewController:cityVC animated:YES];
    }];
    [[self.airSelectView.dropoffBtn rac_signalForControlEvents:(UIControlEventTouchUpInside)] subscribeNext:^(__kindof UIControl * _Nullable x) {
        @strongify(self);
        // 点击button的响应事件
        [self canaleCallBack];
        BGAreaSelectViewController *cityVC = BGAreaSelectViewController.new;
        cityVC.category = 2;
        [self.navigationController pushViewController:cityVC animated:YES];
    }];
    __block typeof(self) weakSelf = self;
    [UIView transitionWithView:self.backView duration:0.1 options:0 animations:^{
        weakSelf.backView.backgroundColor = [UIColor colorWithWhite:0 alpha:0.4];
        weakSelf.airSelectView.alpha = 1.0;
    } completion:nil];
}
/**
 隐藏
 */
- (void)canaleCallBack{
    __block typeof(self) weakSelf = self;
    [UIView transitionWithView:self.backView duration:0.1 options:0 animations:^{
        weakSelf.backView.backgroundColor = [UIColor clearColor];
        weakSelf.airSelectView.alpha = 0.0;
    } completion:^(BOOL finished) {
        [weakSelf.airSelectView removeFromSuperview];
        weakSelf.airSelectView = nil;
        [weakSelf.backView removeFromSuperview];
        weakSelf.backView = nil;
    }];
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
