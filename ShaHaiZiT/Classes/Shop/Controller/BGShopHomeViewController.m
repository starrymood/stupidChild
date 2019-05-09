//
//  BGShopHomeViewController.m
//  shzTravelC
//
//  Created by 孙林茂 on 2018/5/9.
//  Copyright © 2018年 biao. All rights reserved.
//

#import "BGShopHomeViewController.h"
#import "BGWaterFallLayout.h"
#import "BGShopCell.h"
#import "BGShopShowModel.h"
#import "BGShopDetailViewController.h"

#import "BGShopApi.h"
#import "BGHomeCycleModel.h"
#import <SDCycleScrollView.h>
#import "BGAirApi.h"

#define kBtnViewHeight 82
@interface BGShopHomeViewController ()<UICollectionViewDataSource,UICollectionViewDelegate,BGWaterFallLayoutDelegate>

@property (nonatomic, strong) SDCycleScrollView *cycleScrollView;

/** 所有的商品数据 */
@property (nonatomic, strong) NSMutableArray  *cellDataArr;

@property (nonatomic,strong) UICollectionView *collectionView;

@property (nonatomic, copy) NSString *pageNum;

@property (nonatomic, copy) NSString *allPageNum;

@property (nonatomic, assign) NSInteger lastSelectTag;

@property (nonatomic, copy) NSString *sortStr;

@property (nonatomic, copy) NSString *orderStr;

@property (nonatomic, strong) UIView *btnView;

@property (nonatomic, assign) BOOL isHome;

@property (nonatomic, strong) UIButton *collectedBtn;

@property (nonatomic, assign) BOOL isCollected;

@end

@implementation BGShopHomeViewController

-(NSMutableArray *)cellDataArr {
    if (!_cellDataArr) {
        self.cellDataArr = [NSMutableArray array];
    }
    return _cellDataArr;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self loadSubViews];
    [self setupLayoutAndCollectionView];
    [self refreshView];
    
}
-(void)loadSubViews {
    
    _pageNum = @"1";
    _allPageNum = @"1";
    self.sortStr = @"all";
    self.orderStr = @"desc";
    self.lastSelectTag = 100;
    self.isHome = YES;
    self.view.backgroundColor = kAppBgColor;
    self.navigationItem.title = [Tool isEmpty:_store_name] ?  @"店铺": _store_name;
    
    self.collectedBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [_collectedBtn setImage:BGImage(@"store_uncollected") forState:UIControlStateNormal];
    [_collectedBtn setImage:BGImage(@"store_uncollected") forState:UIControlStateHighlighted];

    _collectedBtn.bounds = CGRectMake(0, 0, 70, 30);
    _collectedBtn.contentEdgeInsets = UIEdgeInsetsZero;
    _collectedBtn.contentHorizontalAlignment = UIControlContentHorizontalAlignmentRight;
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:_collectedBtn];
    @weakify(self);
    [[_collectedBtn rac_signalForControlEvents:(UIControlEventTouchUpInside)] subscribeNext:^(__kindof UIControl * _Nullable x) {
        @strongify(self);
        // 点击button的响应事件
        [self clickedCollectAction];
    }];
    
    UIView *selectedView = UIView.new;
    selectedView.backgroundColor = kAppWhiteColor;
    selectedView.frame = CGRectMake(0, SafeAreaTopHeight+3, SCREEN_WIDTH, kBtnViewHeight*0.5);
    [self.view addSubview:selectedView];
    
    float shopBtnWidth = (SCREEN_WIDTH-1)*0.5;
    UIButton *shopHomeBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    shopHomeBtn.frame = CGRectMake(0, 1, shopBtnWidth, 40);
    shopHomeBtn.titleLabel.font = kFont(14);
    [shopHomeBtn setTitleColor:kAppMainColor forState:UIControlStateNormal];
    [shopHomeBtn setTitle:@"店铺首页" forState:UIControlStateNormal];
    [selectedView addSubview:shopHomeBtn];
    
    UIButton *shopAllBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    shopAllBtn.frame = CGRectMake(shopBtnWidth+1, 1, shopBtnWidth, 40);
    shopAllBtn.titleLabel.font = kFont(14);
    [shopAllBtn setTitleColor:kAppBlackColor forState:UIControlStateNormal];
    [shopAllBtn setTitle:@"全部商品" forState:UIControlStateNormal];
    [selectedView addSubview:shopAllBtn];
    
    UIView *shopLineView = UIView.new;
    shopLineView.backgroundColor = kAppLineBGColor;
    shopLineView.frame = CGRectMake(shopBtnWidth+1, 1, 1, 40);
    [selectedView addSubview:shopLineView];
    
    self.btnView = UIView.new;
    _btnView.backgroundColor = kAppWhiteColor;
    _btnView.hidden = YES;
    [self.view addSubview:_btnView];
    _btnView.frame = CGRectMake(0, selectedView.y+selectedView.height, SCREEN_WIDTH, kBtnViewHeight*0.5);

    
    UIView *lineView = UIView.new;
    lineView.backgroundColor = kAppLineBGColor;
    lineView.frame = CGRectMake(0, 0, SCREEN_WIDTH, 1);
    [_btnView addSubview:lineView];
    
    float btnWidth = (SCREEN_WIDTH-2)/3.0;
    
    UIView *lineView1 = UIView.new;
    lineView1.backgroundColor = kAppLineBGColor;
    lineView1.frame = CGRectMake(btnWidth, 1, 1, 40);
    [_btnView addSubview:lineView1];
    
    UIView *lineView2 = UIView.new;
    lineView2.backgroundColor = kAppLineBGColor;
    lineView2.frame = CGRectMake(btnWidth*2+1, 1, 1, 40);
    [_btnView addSubview:lineView2];
    
    NSArray *itemName = @[@"综合",@"销量",@"价格"];
    for (int i = 0; i<3; i++) {
        UIButton *itemBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        itemBtn.frame = CGRectMake((btnWidth+1)*i, 0, btnWidth, 40);
        itemBtn.titleLabel.font = kFont(12);
        if (i == 0) {
            [itemBtn setTitleColor:kAppMainColor forState:UIControlStateNormal];
        }else{
            [itemBtn setTitleColor:kAppBlackColor forState:UIControlStateNormal];
        }
        [itemBtn setTitle:itemName[i] forState:UIControlStateNormal];
        itemBtn.tag = 100+i;
        [itemBtn addTarget:self action:@selector(itemBtnClicked:) forControlEvents:UIControlEventTouchUpInside];
        [_btnView addSubview:itemBtn];
    }
    
    self.cycleScrollView = [SDCycleScrollView cycleScrollViewWithFrame:CGRectMake(0, -160, SCREEN_WIDTH, 160) delegate:nil placeholderImage:BGImage(@"img_cycle_placeholder")];
    self.cycleScrollView.pageControlAliment = SDCycleScrollViewPageContolAlimentCenter;
    self.cycleScrollView.currentPageDotImage = BGImage(@"pageControlCurrentDot");
    self.cycleScrollView.pageDotImage = BGImage(@"pageControlDot");
    _cycleScrollView.hidden = NO;
    
    [[shopHomeBtn rac_signalForControlEvents:(UIControlEventTouchUpInside)] subscribeNext:^(__kindof UIControl * _Nullable x) {
        @strongify(self);
        self.isHome = YES;
        // 点击button的响应事件
        [shopHomeBtn setTitleColor:kAppMainColor forState:(UIControlStateNormal)];
        [shopAllBtn setTitleColor:kAppBlackColor forState:(UIControlStateNormal)];
        self.btnView.hidden = YES;
        self.cycleScrollView.hidden = NO;
        self.collectionView.frame = CGRectMake(0, SafeAreaTopHeight+3+kBtnViewHeight-41, SCREEN_WIDTH, SCREEN_HEIGHT-SafeAreaTopHeight-3-kBtnViewHeight+41);

        self.pageNum = @"1";
        self.allPageNum = @"1";
        self.collectionView.mj_header.ignoredScrollViewContentInsetTop = 160;
         self.collectionView.contentInset = UIEdgeInsetsMake(160, 0, 0, 0);
        [self loadData];
    }];
    [[shopAllBtn rac_signalForControlEvents:(UIControlEventTouchUpInside)] subscribeNext:^(__kindof UIControl * _Nullable x) {
        @strongify(self);
        self.isHome = NO;
        // 点击button的响应事件
        [shopAllBtn setTitleColor:kAppMainColor forState:(UIControlStateNormal)];
        [shopHomeBtn setTitleColor:kAppBlackColor forState:(UIControlStateNormal)];
        self.btnView.hidden = NO;
        self.cycleScrollView.hidden = YES;
        self.collectionView.frame = CGRectMake(0, SafeAreaTopHeight+3+kBtnViewHeight, SCREEN_WIDTH, SCREEN_HEIGHT-SafeAreaTopHeight-3-kBtnViewHeight);

        self.pageNum = @"1";
        self.allPageNum = @"1";
        self.collectionView.mj_header.ignoredScrollViewContentInsetTop = 0;
        self.collectionView.contentInset = UIEdgeInsetsMake(0, 0, 0, 0);
        [self loadData];
    }];
}
- (void)itemBtnClicked:(UIButton *)sender {

    UIButton *lastSelectBtn = [self.btnView viewWithTag:self.lastSelectTag];
    [lastSelectBtn setTitleColor:kAppBlackColor forState:UIControlStateNormal];
    
    [sender setTitleColor:kAppMainColor forState:UIControlStateNormal];
    
    self.lastSelectTag = sender.tag;

    switch (sender.tag-100) {
        case 0:{
//            DLog(@"综合");
            self.sortStr = @"all";
            self.orderStr = @"desc";
            self.pageNum = @"1";
            [self.collectionView.mj_header beginRefreshing];
        }
            break;
        case 1:{
//            DLog(@"销量");
            self.sortStr = @"num";
            self.orderStr = @"desc";
            self.pageNum = @"1";
            [self.collectionView.mj_header beginRefreshing];
        }
            break;
        case 2:{
//            DLog(@"价格");
            self.sortStr = @"price";
            self.orderStr = @"desc";
            self.pageNum = @"1";
            [self.collectionView.mj_header beginRefreshing];
        }
            break;
        default:
            break;
    }
}
/**
 * 创建布局和collectionView
 */
- (void)setupLayoutAndCollectionView{
    
    // 创建布局
    BGWaterFallLayout * waterFallLayout = [[BGWaterFallLayout alloc]init];
    waterFallLayout.delegate = self;
    
    // 创建collectionView
    UICollectionView * collectionView = [[UICollectionView alloc]initWithFrame:CGRectMake(0, SafeAreaTopHeight+3+kBtnViewHeight-41, SCREEN_WIDTH, SCREEN_HEIGHT-SafeAreaTopHeight-kBtnViewHeight-3+41) collectionViewLayout:waterFallLayout];
    collectionView.backgroundColor = kAppBgColor;
    
    collectionView.dataSource = self;
    collectionView.delegate = self;
    collectionView.contentInset = UIEdgeInsetsMake(160, 0, 0, 0);
    [collectionView addSubview:self.cycleScrollView];
    [self.view addSubview:collectionView];
    
    // 注册
    [collectionView registerNib:[UINib nibWithNibName:NSStringFromClass([BGShopCell class]) bundle:nil] forCellWithReuseIdentifier:@"BGShopCell"];
    
    self.collectionView = collectionView;
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
        weakSelf.allPageNum = @"1";
        [weakSelf loadData];
        [weakSelf.collectionView.mj_header endRefreshing];
    }];
    
    // 上拉刷新
    self.collectionView.mj_footer = [MJRefreshAutoNormalFooter footerWithRefreshingBlock:^{
        if (self.isHome) {
            NSInteger nowPindex = [weakSelf.allPageNum integerValue]+1;
            weakSelf.allPageNum = [NSString stringWithFormat:@"%zd",nowPindex];
            [weakSelf loadLineData];
        }else{
            NSInteger nowPindex = [weakSelf.pageNum integerValue]+1;
            weakSelf.pageNum = [NSString stringWithFormat:@"%zd",nowPindex];
            [weakSelf loadAllData];
            //        [weakSelf.collectionView.mj_footer endRefreshing];
        }
    }];
    
    self.collectionView.mj_header.ignoredScrollViewContentInsetTop = 160;
    [self loadData];
}

#pragma mark - 加载数据  -
- (void)loadData {
    if (_isHome) {
        [self loadHomeData];
    }else{
        [self loadAllData];
    }
}
-(void)loadHomeData {
    
    [ProgressHUDHelper showLoading];
    NSMutableDictionary *param = [NSMutableDictionary dictionary];
    [param setObject:_storeid forKey:@"store_id"];
    __block typeof(self) weakSelf = self;
    [BGShopApi getShopHomeCycle:param succ:^(NSDictionary *response) {
        DLog(@"\n>>>[getShopHomeCycle sucess]:%@",response);
        [weakSelf loadLineData];
        int isCollect = [[NSString stringWithFormat:@"%@",response[@"result"][@"is_collect"]] intValue];
        if (isCollect == 1) {
            [weakSelf.collectedBtn setImage:BGImage(@"store_collected") forState:UIControlStateNormal];
            [weakSelf.collectedBtn setImage:BGImage(@"store_collected") forState:UIControlStateHighlighted];
            weakSelf.isCollected = YES;
        }else if (isCollect == 0){
            [weakSelf.collectedBtn setImage:BGImage(@"store_uncollected") forState:UIControlStateNormal];
            [weakSelf.collectedBtn setImage:BGImage(@"store_uncollected") forState:UIControlStateHighlighted];
            weakSelf.isCollected = NO;
        }
        
        // 轮播图
        NSArray *imgArray = BGdictSetObjectIsNil(response[@"result"][@"store_banner"]);
        if ([Tool arrayIsNotEmpty:imgArray]) {
            weakSelf.cycleScrollView.imageURLStringsGroup = imgArray;
        }
        
        
    } failure:^(NSDictionary *response) {
        DLog(@"\n>>>[getShopHomeCycle failure]:%@",response);
        
    }];
    
}
-(void)loadLineData{
    NSMutableDictionary *param = [NSMutableDictionary dictionary];
    [param setObject:@"10" forKey:@"pagesize"];
    [param setObject:_allPageNum forKey:@"pageno"];
    [param setObject:_storeid forKey:@"store_id"];
    
    [ProgressHUDHelper showLoading];
    __block typeof(self) weakSelf = self;
    [BGShopApi getShopHomeGoods:param succ:^(NSDictionary *response) {
        DLog(@"\n>>>[getHomepageLineData sucess]:%@",response);
        if (self.allPageNum.intValue == 1) {
            [self.cellDataArr removeAllObjects];
             [weakSelf.collectionView.mj_footer resetNoMoreData];
        }
        NSMutableArray *tempArr = [BGShopShowModel mj_objectArrayWithKeyValuesArray:BGdictSetObjectIsNil(response[@"result"][@"rows"])];
        
        NSString *totalPageNumStr = [NSString stringWithFormat:@"%@",BGdictSetObjectIsNil(response[@"result"][@"pages"])];
        if (weakSelf.allPageNum.integerValue<=totalPageNumStr.integerValue) {
            [weakSelf.cellDataArr addObjectsFromArray:tempArr];
        }
        [weakSelf.collectionView reloadData];
        
        if (weakSelf.allPageNum.integerValue>=totalPageNumStr.integerValue) {
            [weakSelf.collectionView.mj_footer endRefreshingWithNoMoreData];
        }else{
            [weakSelf.collectionView.mj_footer endRefreshing];
        }
    } failure:^(NSDictionary *response) {
        DLog(@"\n>>>[getHomepageLineData failure]:%@",response);
    }];
}
-(void)loadAllData {
    
    NSMutableDictionary *param = [NSMutableDictionary dictionary];
    [param setObject:@"10" forKey:@"pagesize"];
    [param setObject:_pageNum forKey:@"pageno"];
    [param setObject:_storeid forKey:@"store_id"];
    [param setObject:[NSString stringWithFormat:@"%@ %@",_sortStr,_orderStr] forKey:@"sort"];
    [ProgressHUDHelper showLoading];
    __block typeof(self) weakSelf = self;
    [BGShopApi getShopHomeGoods:param succ:^(NSDictionary *response) {
        DLog(@"\n>>>[getShopAllGoods sucess]:%@",response);
        [self hideNodateView];
        if (self.pageNum.intValue == 1) {
            [self.cellDataArr removeAllObjects];
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
        DLog(@"\n>>>[getShopAllGoods failure]:%@",response);
        [self shownoNetWorkViewWithType:0];
        [self setRefreshBlock:^{
            [weakSelf loadData];
        }];
    }];
}
#pragma mark UICollectionViewDataSource
- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView{
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    
    self.collectionView.mj_footer.hidden = self.cellDataArr.count == 0;
    
    return self.cellDataArr.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    
    BGShopCell * cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"BGShopCell" forIndexPath:indexPath];
    cell.layer.cornerRadius = 5;
    
    BGShopShowModel *model = self.cellDataArr[indexPath.item];
    [cell updataWithCellArray:model];
    
    return cell;
}



#pragma mark  - <LMHWaterFallLayoutDeleaget>
/**
 * 每个item的高度
 */
- (CGFloat)waterFallLayout:(BGWaterFallLayout *)waterFallLayout heightForItemAtIndexPath:(NSUInteger)indexPath itemWidth:(CGFloat)itemWidth{
    
    BGShopShowModel * shop = self.cellDataArr[indexPath];
    
    CGFloat imgHeight = 1/([NSString stringWithFormat:@"%@",shop.aspect_ratio].floatValue ?:1.25);

    CGFloat staticHeight = 112;
    if ([Tool isBlankString:shop.goods_description]){
        staticHeight = staticHeight - 25;
    }
     staticHeight = staticHeight - 17;
    return itemWidth * imgHeight+staticHeight;
}
/**
 * 每列之间的间距
 */
- (CGFloat)columnMarginInWaterFallLayout:(BGWaterFallLayout *)waterFallLayout{
    return 5;
}
/**
 * 每行之间的间距
 */
- (CGFloat)rowMarginInWaterFallLayout:(BGWaterFallLayout *)waterFallLayout{
    
    return 20;
    
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
    BGShopShowModel *model = _cellDataArr[indexPath.row];
    BGShopDetailViewController *detailVC = BGShopDetailViewController.new;
    detailVC.url = BGWebGoodDetail(model.ID);
    detailVC.goodsid = model.ID;
    [self.navigationController pushViewController:detailVC animated:YES];
//    CATransition*transition=[CATransition animation];
//    transition.duration=1.0f;
//    transition.type=@"rippleEffect";
//    transition.subtype=@"fromTop";
//    [self.navigationController.view.layer addAnimation:transition forKey:kCATransition];
//    [self.navigationController pushViewController:detailVC animated:NO];
}
-(void)clickedCollectAction{
    if (![Tool isLogin]) {
        [WHIndicatorView toast:@"请先登录!"];
        [BGAppDelegateHelper showLoginViewController];
        return;
    }
    
    __weak __typeof(self) weakSelf = self;
    [ProgressHUDHelper showLoading];
    NSMutableDictionary *param = [[NSMutableDictionary alloc] init];
    [param setObject:_storeid forKey:@"collect_id"];
    [param setObject:@"2" forKey:@"category"];
    // 点击button的响应事件
    [BGAirApi addAndCancelFavoriteAction:param succ:^(NSDictionary *response) {
        DLog(@"\n>>>[cancelFavoriteAction success]:%@",response);
        if (weakSelf.isCollected) {
            [WHIndicatorView toast:@"取消收藏"];
            weakSelf.isCollected = NO;
        }else{
            [WHIndicatorView toast:@"已收藏"];
            weakSelf.isCollected = YES;
        }
        NSString *collectionStr = weakSelf.isCollected ? @"store_collected":@"store_uncollected";
        [weakSelf.collectedBtn setImage:BGImage(collectionStr) forState:(UIControlStateNormal)];
        [weakSelf.collectedBtn setImage:BGImage(collectionStr) forState:(UIControlStateHighlighted)];
    } failure:^(NSDictionary *response) {
        DLog(@"\n>>>[cancelFavoriteAction failure]:%@",response);
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
