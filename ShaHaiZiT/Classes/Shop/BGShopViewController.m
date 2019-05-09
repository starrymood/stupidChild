//
//  BGShopViewController.m
//  shzTravelC
//
//  Created by biao on 2018/7/18.
//  Copyright © 2018年 biao. All rights reserved.
//

#import "BGShopViewController.h"
#import "BGWaterFallLayout.h"

#import "BGHomeCycleModel.h"
#import "BGShopCategoryModel.h"
#import "BGShopShowModel.h"

#import "BGShopListViewController.h"
#import "BGShopDetailViewController.h"
#import "BGShopMoreViewController.h"
#import <SDCycleScrollView.h>
#import "BGWebViewController.h"

#import "BGShopApi.h"
#import <UIImageView+WebCache.h>
#import "BGSearchViewController.h"
#import "BGShopMoreSimpleViewController.h"
#import "BGShopBargainViewController.h"
#import "BGShopCatView.h"
#import "BGShopGoodCell.h"

@interface BGShopViewController ()<UICollectionViewDataSource,UICollectionViewDelegate,BGWaterFallLayoutDelegate>

@property (nonatomic, strong) SDCycleScrollView *cycleScrollView;
/** 轮播图数据 */
@property (nonatomic,strong) NSMutableArray *cycleDataArray;
/** 分类图标数据 */
@property (nonatomic, strong) NSMutableArray *iconDataArr;
/** 所有的商品数据 */
@property (nonatomic, strong) NSMutableArray *cellDataArr;

@property (nonatomic,strong) UICollectionView *collectionView;

@property (nonatomic, strong) UIView *headerView;

@property (nonatomic, strong) UIView *itemBtnsView;

@property (nonatomic, copy) NSString *pageNum;

@property(nonatomic,assign) NSInteger headerViewHeight;

@property(nonatomic,strong) BGShopCatView *catView;

@property (nonatomic,strong) UICollectionView *foodCollectionView;

@property (nonatomic, strong) NSMutableArray *foodDataArr;

@property(nonatomic,strong) UIView *foodView;

@property(nonatomic,strong) UIView *locationView;

@end

@implementation BGShopViewController

-(NSMutableArray *)foodDataArr {
    if (!_foodDataArr) {
        self.foodDataArr = [NSMutableArray array];
    }
    return _foodDataArr;
}
- (NSMutableArray *)cycleDataArray {
    if (!_cycleDataArray) {
        self.cycleDataArray = [NSMutableArray array];
    }
    return _cycleDataArray;
}

- (NSMutableArray *)iconDataArr {
    if (!_iconDataArr) {
        self.iconDataArr = [NSMutableArray array];
    }
    return _iconDataArr;
}
 
-(NSMutableArray *)cellDataArr {
    if (!_cellDataArr) {
        self.cellDataArr = [NSMutableArray array];
    }
    return _cellDataArr;
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    self.navigationController.navigationBar.translucent = YES;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self loadSubViews];
    [self refreshView];
}

-(void)loadSubViews {
    
     self.navigationItem.title = @"商城";
    self.view.backgroundColor = kAppBgColor;
    _pageNum = @"1";
    
     CGFloat foodItemWidth = (SCREEN_WIDTH-30)*0.5;
     CGFloat foodCollectionViewHeight = (foodItemWidth*208.0/173+91)*2+6+15+15;
    self.headerView = UIView.new;
    _headerView.backgroundColor = kAppWhiteColor;
    self.headerViewHeight = (3+SCREEN_WIDTH*9/16+16+SCREEN_WIDTH*90.0/375*2+13+15*2+11+51+15+foodCollectionViewHeight+11+51);
    _headerView.frame = CGRectMake(0, -_headerViewHeight, SCREEN_WIDTH, _headerViewHeight);
    
    // 1.topCycleScrollView 3+SCREEN_WIDTH*9/16
    UIView *topLineView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, 3)];
    topLineView.backgroundColor = kAppBgColor;
    [_headerView addSubview:topLineView];
    
    self.cycleScrollView = [SDCycleScrollView cycleScrollViewWithFrame:CGRectMake(0, 3, SCREEN_WIDTH, SCREEN_WIDTH*9/16) delegate:nil placeholderImage:BGImage(@"img_cycle_placeholder")];
    self.cycleScrollView.pageControlAliment = SDCycleScrollViewPageContolAlimentCenter;
    self.cycleScrollView.backgroundColor = kAppBgColor;
    self.cycleScrollView.pageControlBottomOffset = 50;
    self.cycleScrollView.currentPageDotImage = BGImage(@"pageControlCurrentDot");
    self.cycleScrollView.pageDotImage = BGImage(@"pageControlDot");
    [_headerView addSubview:_cycleScrollView];
    
    
    // 搜索框
    UIButton *searchBtn = [UIButton buttonWithType:(UIButtonTypeCustom)];
    searchBtn.frame = CGRectMake(10, _cycleScrollView.y+_cycleScrollView.height-18-40, SCREEN_WIDTH-20, 40);
    searchBtn.backgroundColor = [UIColor colorWithWhite:1 alpha:0.4];
    searchBtn.clipsToBounds = YES;
    searchBtn.layer.cornerRadius = 20;
    @weakify(self);
    [[searchBtn rac_signalForControlEvents:(UIControlEventTouchUpInside)] subscribeNext:^(__kindof UIControl * _Nullable x) {
        @strongify(self);
        // 点击button的响应事件
        BGSearchViewController *searchVC = BGSearchViewController.new;
        CATransition *transition = [CATransition animation];
        transition.type = kCATransitionFade;
        transition.subtype = kCATransitionFromBottom;
        [self.navigationController.view.layer addAnimation:transition forKey:kCATransition];
        [self.navigationController pushViewController:searchVC animated:NO];
        
    }];
    
    UIImageView *searchImgView = [[UIImageView alloc] initWithImage:BGImage(@"home_search_new")];
    searchImgView.frame = CGRectMake(15, 10, 20, 20);
    [searchBtn addSubview:searchImgView];
    
    UILabel *searchLabel = UILabel.new;
    searchLabel.frame = CGRectMake(searchImgView.x+searchImgView.width+7, 13, 100, 14);
    [searchLabel setTextColor:UIColorFromRGB(0x9D9D9D)];
    searchLabel.textAlignment = NSTextAlignmentLeft;
    searchLabel.text = @"搜索所需商品...";
    [searchLabel setFont:kFont(14)];
    [searchBtn addSubview:searchLabel];
    [_headerView addSubview:searchBtn];
    
  
    // 2.类别View
    self.catView = [[BGShopCatView alloc] initWithFrame:CGRectMake(0, _cycleScrollView.y+_cycleScrollView.height+16, SCREEN_WIDTH, SCREEN_WIDTH*90.0/375*2+13+15*2)];
    __weak typeof(self) weakSelf = self;
    _catView.selectCatTapClick = ^(NSString * _Nonnull cat_id) {
        if (![Tool isLogin]) {
            [WHIndicatorView toast:@"请先登录!"];
            [BGAppDelegateHelper showLoginViewController];
            return;
        }
        if ([cat_id isEqualToString:@"0"]) {
            BGShopMoreSimpleViewController *moreVC = BGShopMoreSimpleViewController.new;
            [weakSelf.navigationController pushViewController:moreVC animated:YES];
        }else if ([cat_id isEqualToString:@"-1"]){
            BGShopBargainViewController *bargainVC = BGShopBargainViewController.new;
            [weakSelf.navigationController pushViewController:bargainVC animated:YES];
        }else{
            BGShopListViewController *shopListVC = BGShopListViewController.new;
            shopListVC.cat_id = cat_id;
            [weakSelf.navigationController pushViewController:shopListVC animated:YES];
        }
       
    };
  
    [_headerView addSubview:_catView];
    
    // 3.foodView 11+51
    self.foodView = UIView.new;
    _foodView.backgroundColor = kAppWhiteColor;
    _foodView.frame = CGRectMake(0, _catView.y+_catView.height+11, SCREEN_WIDTH, 51);
    [_headerView addSubview:_foodView];
    
    UILabel *foodLabel = UILabel.new;
    foodLabel.frame = CGRectMake(17, 14, 100, 23);
    foodLabel.text = @"新品上新";
    foodLabel.textColor = kApp333Color;
    foodLabel.font = [UIFont fontWithName:@"PingFangSC-Semibold" size:24];
    [_foodView addSubview:foodLabel];
    
    UIButton *moreFoodBtn = [UIButton buttonWithType:(UIButtonTypeCustom)];
    [moreFoodBtn setTitle:@"更多新品>" forState:(UIControlStateNormal)];
    [moreFoodBtn.titleLabel setFont:kFont(14)];
    [moreFoodBtn setTitleColor:UIColorFromRGB(0x9D9D9D) forState:(UIControlStateNormal)];
    moreFoodBtn.frame = CGRectMake(SCREEN_WIDTH-85, 18.5, 70, 14);
    [_foodView addSubview:moreFoodBtn];
    
    [[moreFoodBtn rac_signalForControlEvents:(UIControlEventTouchUpInside)] subscribeNext:^(__kindof UIControl * _Nullable x) {
        @strongify(self);
        // 点击button的响应事件
        // @@ 添加登录判断
        if (![Tool isLogin]) {
            [WHIndicatorView toast:@"请先登录!"];
            [BGAppDelegateHelper showLoginViewController];
            return;
        }
        BGShopListViewController *shopListVC = BGShopListViewController.new;
        shopListVC.cat_id = @"-3";
        [self.navigationController pushViewController:shopListVC animated:YES];
        
    }];
    
    
    // 4.foodCollectionView 15+foodCollectionViewHeight
    UICollectionViewFlowLayout *foodFlowLayout =[[UICollectionViewFlowLayout alloc]init];
    foodFlowLayout.itemSize = CGSizeMake(foodItemWidth, foodItemWidth*208.0/173+91);
    foodFlowLayout.sectionInset = UIEdgeInsetsMake(6, 10, 15, 10);
    foodFlowLayout.minimumLineSpacing = 15;
    foodFlowLayout.minimumInteritemSpacing  = 10;
    self.foodCollectionView =[[UICollectionView alloc] initWithFrame:CGRectMake(0, _foodView.height+_foodView.y+15, SCREEN_WIDTH,foodCollectionViewHeight) collectionViewLayout:foodFlowLayout];
    _foodCollectionView.backgroundColor = kAppWhiteColor;
    _foodCollectionView.tag = 5001;
    _foodCollectionView.scrollsToTop = NO;
    _foodCollectionView.showsHorizontalScrollIndicator = NO;
    [_foodCollectionView registerNib:[UINib nibWithNibName:NSStringFromClass([BGShopGoodCell class]) bundle:nil] forCellWithReuseIdentifier:@"BGShopGoodCell"];
    _foodCollectionView.delegate = self;
    _foodCollectionView.dataSource = self;
    [_headerView addSubview:_foodCollectionView];
    
    // 5.locationView 11+51
    self.locationView = UIView.new;
    _locationView.backgroundColor = kAppWhiteColor;
    _locationView.frame = CGRectMake(0, _foodCollectionView.y+_foodCollectionView.height+11, SCREEN_WIDTH, 51);
    [_headerView addSubview:_locationView];
    
    UILabel *locationLabel = UILabel.new;
    locationLabel.frame = CGRectMake(17, 14, 150, 23);
    locationLabel.text = @"推荐商品";
    locationLabel.textColor = kApp333Color;
    locationLabel.font = [UIFont fontWithName:@"PingFangSC-Semibold" size:24];
    [_locationView addSubview:locationLabel];
    
    UIButton *moreLocationBtn = [UIButton buttonWithType:(UIButtonTypeCustom)];
    [moreLocationBtn setTitle:@"更多推荐>" forState:(UIControlStateNormal)];
    [moreLocationBtn.titleLabel setFont:kFont(14)];
    [moreLocationBtn setTitleColor:UIColorFromRGB(0x9D9D9D) forState:(UIControlStateNormal)];
    moreLocationBtn.frame = CGRectMake(SCREEN_WIDTH-85, 18.5, 70, 14);
    [_locationView addSubview:moreLocationBtn];
    
    [[moreLocationBtn rac_signalForControlEvents:(UIControlEventTouchUpInside)] subscribeNext:^(__kindof UIControl * _Nullable x) {
        @strongify(self);
        // 点击button的响应事件
        // @@ 添加登录判断
        if (![Tool isLogin]) {
            [WHIndicatorView toast:@"请先登录!"];
            [BGAppDelegateHelper showLoginViewController];
            return;
        }
        BGShopListViewController *shopListVC = BGShopListViewController.new;
        shopListVC.cat_id = @"-4";
        [self.navigationController pushViewController:shopListVC animated:YES];
        
    }];
    
    // 6.创建布局
    BGWaterFallLayout * waterFallLayout = [[BGWaterFallLayout alloc]init];
    waterFallLayout.delegate = self;
    
    // 创建collectionView
    self.collectionView = [[UICollectionView alloc]initWithFrame:CGRectMake(0, SafeAreaTopHeight, SCREEN_WIDTH, SCREEN_HEIGHT*2-SafeAreaBottomHeight-kTabBarH-SafeAreaTopHeight) collectionViewLayout:waterFallLayout];
    _collectionView.backgroundColor = kAppWhiteColor;
    _collectionView.tag = 5002;
    _collectionView.dataSource = self;
    _collectionView.delegate = self;
    _collectionView.showsHorizontalScrollIndicator = NO;
    _collectionView.contentInset = UIEdgeInsetsMake(_headerViewHeight, 0, 0, 0);
    [_collectionView addSubview:self.headerView];
    [self.view addSubview:_collectionView];
    // 注册
    [_collectionView registerNib:[UINib nibWithNibName:NSStringFromClass([BGShopGoodCell class]) bundle:nil] forCellWithReuseIdentifier:@"BGShopGoodCell"];
    
    
}

#pragma mark UITableView + 下拉刷新 隐藏时间
- (void)refreshView
{
    // 设置回调（一旦进入刷新状态，就调用target的action，也就是调用self的loadNewData方法）
    __weak __typeof(self) weakSelf = self;
    
    // 设置回调（一旦进入刷新状态就会调用这个refreshingBlock）
    self.collectionView.mj_header = [MJRefreshNormalHeader headerWithRefreshingBlock:^{
        // 设置自动切换透明度(在导航栏下面自动隐藏)
        weakSelf.collectionView.mj_header.automaticallyChangeAlpha = YES;
        weakSelf.pageNum = @"1";
        [weakSelf loadData];
        [weakSelf.collectionView.mj_header endRefreshing];
    }];
    // 上拉刷新
    self.collectionView.mj_footer = [MJRefreshAutoNormalFooter footerWithRefreshingBlock:^{
        //每次刷新,页码都加一页
        NSInteger nowPindex = [weakSelf.pageNum integerValue]+1;
        weakSelf.pageNum = [NSString stringWithFormat:@"%zd",nowPindex];
        [weakSelf loadLineData];
//        [weakSelf.collectionView.mj_footer endRefreshing];
    }];
    self.collectionView.mj_header.ignoredScrollViewContentInsetTop = _headerViewHeight;
    [self loadData];
}

-(void)loadData {
    
        [ProgressHUDHelper showLoading];
    __weak typeof(self) weakSelf = self;
    NSMutableDictionary *param = [NSMutableDictionary dictionary];
    [BGShopApi getHomePageInfo:param succ:^(NSDictionary *response) {
                DLog(@"\n>>>[getHomePageInfo sucess]:%@",response);
        [weakSelf hideNodateView];
        [weakSelf loadLineData];
        // 轮播图
        weakSelf.cycleDataArray  = [BGHomeCycleModel mj_objectArrayWithKeyValuesArray:response[@"result"][@"adv"]];
        NSMutableArray *imgArray = [NSMutableArray array];
        
        for (BGHomeCycleModel *model in weakSelf.cycleDataArray) {
            
            [imgArray addObject:model.url];
        }
        weakSelf.cycleScrollView.imageURLStringsGroup = imgArray;
        
       
        
        weakSelf.foodDataArr = [BGShopShowModel mj_objectArrayWithKeyValuesArray:BGdictSetObjectIsNil(response[@"result"][@"new_goods"])];
        [weakSelf.foodCollectionView reloadData];
        if (![Tool arrayIsNotEmpty:weakSelf.foodDataArr]) {
            [weakSelf hideBlankView];
        }
        // 图标icon
        weakSelf.iconDataArr = [BGShopCategoryModel mj_objectArrayWithKeyValuesArray:response[@"result"][@"cat"]];
        [weakSelf.catView updataWithCellArray:weakSelf.iconDataArr];
        
    } failure:^(NSDictionary *response) {
        DLog(@"\n>>>[getHomePageInfo failure]:%@",response);
        [ProgressHUDHelper removeLoading];
        [self shownoNetWorkViewWithType:0];
        [self setRefreshBlock:^{
            [weakSelf loadData];
        }];
    }];
}
-(void)hideBlankView{
    
    self.foodView.hidden = YES;
    self.foodCollectionView.hidden = YES;
    
    self.headerViewHeight = (3+SCREEN_WIDTH*9/16+16+SCREEN_WIDTH*90.0/375*2+13+15*2+11+51);
    self.headerView.frame = CGRectMake(0, -self.headerViewHeight, SCREEN_WIDTH, self.headerViewHeight);
    [self.catView removeFromSuperview];
    self.catView = [[BGShopCatView alloc] initWithFrame:CGRectMake(0, _cycleScrollView.y+_cycleScrollView.height+16, SCREEN_WIDTH, SCREEN_WIDTH*90.0/375*2+13+15*2)];
    __weak typeof(self) weakSelf = self;
    _catView.selectCatTapClick = ^(NSString * _Nonnull cat_id) {
        if (![Tool isLogin]) {
            [WHIndicatorView toast:@"请先登录!"];
            [BGAppDelegateHelper showLoginViewController];
            return;
        }
        if ([cat_id isEqualToString:@"0"]) {
            BGShopMoreSimpleViewController *moreVC = BGShopMoreSimpleViewController.new;
            [weakSelf.navigationController pushViewController:moreVC animated:YES];
        }else if ([cat_id isEqualToString:@"-1"]){
            BGShopBargainViewController *bargainVC = BGShopBargainViewController.new;
            [weakSelf.navigationController pushViewController:bargainVC animated:YES];
        }else{
            BGShopListViewController *shopListVC = BGShopListViewController.new;
            shopListVC.cat_id = cat_id;
            [weakSelf.navigationController pushViewController:shopListVC animated:YES];
        }
        
    };
    
    [_headerView addSubview:_catView];
    
    self.locationView.frame = CGRectMake(0, self.catView.y+self.catView.height+11, SCREEN_WIDTH, 51);
    
    
    self.collectionView.contentInset = UIEdgeInsetsMake(self.headerViewHeight, 0, 0, 0);
    
    self.collectionView.mj_header.ignoredScrollViewContentInsetTop = self.headerViewHeight;
}
-(void)loadLineData{
    NSMutableDictionary *param = [NSMutableDictionary dictionary];
    [param setObject:@"8" forKey:@"pagesize"];
    [param setObject:_pageNum forKey:@"pageno"];
    
    [ProgressHUDHelper showLoading];
    __block typeof(self) weakSelf = self;
    [BGShopApi getHomeGoodsList:param succ:^(NSDictionary *response) {
        DLog(@"\n>>>[getHomepageLineData sucess]:%@",response);
        if (weakSelf.pageNum.intValue == 1) {
            [weakSelf.cellDataArr removeAllObjects];
            [weakSelf.collectionView.mj_footer resetNoMoreData];
        }
        NSMutableArray *tempArr = [BGShopShowModel mj_objectArrayWithKeyValuesArray:BGdictSetObjectIsNil(response[@"result"][@"rows"])];
        NSString *totalPageNumStr = [NSString stringWithFormat:@"%@",BGdictSetObjectIsNil(response[@"result"][@"pages"])];
        if (weakSelf.pageNum.integerValue<=totalPageNumStr.integerValue) {
            [weakSelf.cellDataArr addObjectsFromArray:tempArr];
        }
        [weakSelf.collectionView reloadData];
        
        if (weakSelf.pageNum.integerValue>=totalPageNumStr.integerValue) {
            [weakSelf.collectionView.mj_footer endRefreshingWithNoMoreData];
        }else{
            [weakSelf.collectionView.mj_footer endRefreshing];
        }
    } failure:^(NSDictionary *response) {
        DLog(@"\n>>>[getHomepageLineData failure]:%@",response);
    }];
}
#pragma mark UICollectionViewDataSource
- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView{
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    if (collectionView.tag == 5001) {
        return self.foodDataArr.count>4?4:self.foodDataArr.count;
    }else{
        self.collectionView.mj_footer.hidden = self.cellDataArr.count == 0;
        
        return self.cellDataArr.count;
    }
    
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
   
    BGShopGoodCell * cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"BGShopGoodCell" forIndexPath:indexPath];
    if (collectionView.tag == 5001) {
        if ([Tool arrayIsNotEmpty:self.foodDataArr]) {
            BGShopShowModel *model = self.foodDataArr[indexPath.item];
            [cell updataWithCellArray:model];
        }
    }else{
        if ([Tool arrayIsNotEmpty:self.cellDataArr]) {
            BGShopShowModel *model = self.cellDataArr[indexPath.item];
            [cell updataWithCellArray:model];
        }
    }
   
    
    return cell;
    
}



#pragma mark  - <LMHWaterFallLayoutDeleaget>
/**
 * 每个item的高度
 */
- (CGFloat)waterFallLayout:(BGWaterFallLayout *)waterFallLayout heightForItemAtIndexPath:(NSUInteger)indexPath itemWidth:(CGFloat)itemWidth{
    
    BGShopShowModel * shop = self.cellDataArr[indexPath];
    
  CGFloat imgHeight = 1/([NSString stringWithFormat:@"%@",shop.aspect_ratio].floatValue ?:1.25);
  CGFloat staticHeight = 91;
    return itemWidth * imgHeight+staticHeight;
}
/**
 * 每列之间的间距
 */
- (CGFloat)columnMarginInWaterFallLayout:(BGWaterFallLayout *)waterFallLayout{
    return 10;
}
/**
 * 每行之间的间距
 */
- (CGFloat)rowMarginInWaterFallLayout:(BGWaterFallLayout *)waterFallLayout{
    
    return 15;
    
}
/**
 * 每个item的内边距
 */
//- (UIEdgeInsets)edgeInsetdInWaterFallLayout:(BGWaterFallLayout *)waterFallLayout;


/**
 * 有多少列
 */
- (NSUInteger)columnCountInWaterFallLayout:(BGWaterFallLayout *)waterFallLayout{
    
    return 2;
    
}

-(void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{
    //    DLog(@"\n>>>[collectionView didSelectItem]:%ld",(long)indexPath.item);
    if (collectionView.tag == 5001) {
        BGShopShowModel *model = _foodDataArr[indexPath.item];
        BGShopDetailViewController *detailVC = BGShopDetailViewController.new;
        detailVC.url = BGWebGoodDetail(model.ID);
        detailVC.goodsid = model.ID;
        [self.navigationController pushViewController:detailVC animated:YES];
    }else{
        BGShopShowModel *model = _cellDataArr[indexPath.item];
        BGShopDetailViewController *detailVC = BGShopDetailViewController.new;
        detailVC.url = BGWebGoodDetail(model.ID);
        detailVC.goodsid = model.ID;
        [self.navigationController pushViewController:detailVC animated:YES];
    }
    
//    CATransition*transition=[CATransition animation];
//    transition.duration=1.0f;
//    transition.type=@"rippleEffect";
//    transition.subtype=@"fromTop";
//    [self.navigationController.view.layer addAnimation:transition forKey:kCATransition];
//    [self.navigationController pushViewController:detailVC animated:NO];
}
/** 点击图片回调
- (void)cycleScrollView:(SDCycleScrollView *)cycleScrollView didSelectItemAtIndex:(NSInteger)index{
    BGHomeCycleModel *model = _cycleDataArray[index];
    if (![Tool isBlankString:model.linkUrl]) {
        BGWebViewController *webVC = BGWebViewController.new;
        webVC.url = model.linkUrl;
        [self.navigationController pushViewController:webVC animated:YES];
    }
}
 */
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
