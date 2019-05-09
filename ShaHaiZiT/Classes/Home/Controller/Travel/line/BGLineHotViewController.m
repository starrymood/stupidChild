//
//  BGLineHotViewController.m
//  shzTravelC
//
//  Created by biao on 2018/8/28.
//  Copyright © 2018年 biao. All rights reserved.
//

#import "BGLineHotViewController.h"
#import "BGAirApi.h"
#import "BGHotLineWaterFallCell.h"
#import "BGAirProductModel.h"
#import <SDCycleScrollView.h>
#import "BGWaterFallLayout.h"
#import "BGLineDetailViewController.h"
#import "BGHomeCycleModel.h"

#define kHeaderViewHeight (SCREEN_WIDTH*172/375+6)
@interface BGLineHotViewController ()<UICollectionViewDataSource,UICollectionViewDelegate,BGWaterFallLayoutDelegate,SDCycleScrollViewDelegate>

@property (nonatomic, strong) SDCycleScrollView *cycleScrollView;
/** 轮播图数据 */
@property (nonatomic,strong) NSMutableArray *cycleDataArray;

@property (nonatomic,strong) UICollectionView *collectionView;

@property (nonatomic, strong) UIView *headerView;

@property (nonatomic, strong) NSMutableArray *cellDataArr;

// 页数
@property (nonatomic, copy) NSString *pageNum;

@property (nonatomic, strong) UIView *noneView;

@property (nonatomic, strong) UILabel *cityLabel;

@end

@implementation BGLineHotViewController
-(NSMutableArray *)cellDataArr {
    if (!_cellDataArr) {
        self.cellDataArr = [NSMutableArray array];
    }
    return _cellDataArr;
}
- (NSMutableArray *)cycleDataArray {
    if (!_cycleDataArray) {
        self.cycleDataArray = [NSMutableArray array];
    }
    return _cycleDataArray;
}
-(UIView *)noneView {
    if (!_noneView) {
        if (!_noneView) {
            self.noneView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT-SafeAreaTopHeight)];
            _noneView.backgroundColor = kAppBgColor;
            [_noneView setHidden:YES];
            UIImageView *noneImgView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"noToken_bg"]];
            noneImgView.frame = CGRectMake(SCREEN_WIDTH*0.2, 30, SCREEN_WIDTH*0.6, SCREEN_WIDTH*0.6*1.02);
            [_noneView addSubview:noneImgView];
            
            UILabel *showMsgLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, noneImgView.frame.origin.y+noneImgView.frame.size.height+50, SCREEN_WIDTH-20, 20)];
            showMsgLabel.textAlignment = NSTextAlignmentCenter;
            [showMsgLabel setTextColor:kAppTipBGColor];
            showMsgLabel.font = kFont(14);
            showMsgLabel.text = @"暂无线路~";
            [_noneView addSubview:showMsgLabel];
            
            __weak typeof(self)weakSelf = self;
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                [weakSelf.noneView setHidden:NO];
            });
        }
        return _noneView;
    }
    return _noneView;
}


-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    self.navigationController.navigationBarHidden = NO;
}
- (void)viewDidLoad {
    [super viewDidLoad];
    [self creatHeaderView];
    [self setupLayoutAndCollectionView];
    [self loadCycleData];
}
-(void)creatHeaderView {
    self.navigationItem.title = @"精选线路";
    self.view.backgroundColor = kAppBgColor;
    self.headerView = UIView.new;
    _headerView.backgroundColor = kAppBgColor;
    _headerView.frame = CGRectMake(0, -kHeaderViewHeight, SCREEN_WIDTH, kHeaderViewHeight);
    // 背景图 搜索框
    
    self.cycleScrollView = [SDCycleScrollView cycleScrollViewWithFrame:CGRectMake(0, 6, SCREEN_WIDTH, SCREEN_WIDTH*172/375) delegate:self placeholderImage:BGImage(@"home_cycle_placeholder")];
    self.cycleScrollView.pageControlAliment = SDCycleScrollViewPageContolAlimentCenter;
//    self.cycleScrollView.bannerImageViewContentMode = UIViewContentModeScaleAspectFit;
    self.cycleScrollView.backgroundColor = kAppBgColor;
    [_headerView addSubview:_cycleScrollView];
    
}
/**
 * 创建布局和collectionView
 */
- (void)setupLayoutAndCollectionView{
    
    // 创建布局
    BGWaterFallLayout * waterFallLayout = [[BGWaterFallLayout alloc]init];
    waterFallLayout.delegate = self;
    
    // 创建collectionView
    UICollectionView *collectionView = [[UICollectionView alloc] initWithFrame:CGRectMake(0, SafeAreaTopHeight, SCREEN_WIDTH, SCREEN_HEIGHT-SafeAreaBottomHeight-SafeAreaTopHeight) collectionViewLayout:waterFallLayout];
    collectionView.backgroundColor = kAppBgColor;
    
    collectionView.dataSource = self;
    collectionView.delegate = self;
    collectionView.contentInset = UIEdgeInsetsMake(kHeaderViewHeight, 0, 0, 0);
    [collectionView addSubview:self.headerView];
    [self.view addSubview:collectionView];
    // 注册
    [collectionView registerNib:[UINib nibWithNibName:NSStringFromClass([BGHotLineWaterFallCell class]) bundle:nil] forCellWithReuseIdentifier:@"BGHotLineWaterFallCell"];
    
    self.collectionView = collectionView;
    
    _pageNum = @"1";
}
-(void)loadCycleData{
    __block typeof(self) weakSelf = self;
    [BGAirApi getRouteCycleInfo:nil succ:^(NSDictionary *response) {
        DLog(@"\n>>>[getRouteCycleInfo sucess]:%@",response);
        [weakSelf refreshView];
        // 轮播图
        weakSelf.cycleDataArray  = [BGHomeCycleModel mj_objectArrayWithKeyValuesArray:BGdictSetObjectIsNil(response[@"result"])];
        NSMutableArray *imgArray = [NSMutableArray array];
        
        for (BGHomeCycleModel *model in weakSelf.cycleDataArray) {
            
            [imgArray addObject:model.bannerImages];
        }
        weakSelf.cycleScrollView.imageURLStringsGroup = imgArray;
    } failure:^(NSDictionary *response) {
        DLog(@"\n>>>[getRouteCycleInfo failure]:%@",response);
        [weakSelf refreshView];
    }];
}
#pragma mark UITableView + 下拉刷新 隐藏时间
- (void)refreshView{
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
    self.collectionView.mj_footer = [MJRefreshAutoFooter footerWithRefreshingBlock:^{
        //每次刷新,页码都加一页
        NSInteger nowPindex = [weakSelf.pageNum integerValue]+1;
        weakSelf.pageNum = [NSString stringWithFormat:@"%zd",nowPindex];
        [weakSelf loadData];
//        [weakSelf.collectionView.mj_footer endRefreshing];
    }];
    [self loadData];
}
-(void)loadData {
    
    NSMutableDictionary *param = [[NSMutableDictionary alloc] init];
    if (![Tool isBlankString:_regionIdStr]) {
        [param setObject:_regionIdStr forKey:@"region_id"];
    }
    [param setObject:_pageNum forKey:@"pageno"];
    [param setObject:@"4" forKey:@"product_set_cd"];
    [param setObject:@"10" forKey:@"pagesize"];
    [ProgressHUDHelper showLoading];
    __block typeof(self) weakSelf = self;
    [BGAirApi getLineGoodsList:param succ:^(NSDictionary *response) {
        DLog(@"\n>>>[getLineGoodsList sucess]:%@",response);
        [weakSelf hideNodateView];
        if (weakSelf.pageNum.intValue == 1) {
            [weakSelf.cellDataArr removeAllObjects];
            [weakSelf.collectionView.mj_footer resetNoMoreData];
        }
        NSMutableArray *tempArr = [BGAirProductModel mj_objectArrayWithKeyValuesArray:response[@"result"][@"rows"]];
        NSString *totalPageNumStr = [NSString stringWithFormat:@"%@",BGdictSetObjectIsNil(response[@"result"][@"pages"])];
        if (weakSelf.pageNum.integerValue<=totalPageNumStr.integerValue) {
            [weakSelf.cellDataArr addObjectsFromArray:tempArr];
        }
        if (weakSelf.cellDataArr.count>0) {
            [weakSelf.noneView removeFromSuperview];
        }else{
            [weakSelf.collectionView addSubview:weakSelf.noneView];
        }
        [weakSelf.collectionView reloadData];
        
        if (weakSelf.pageNum.integerValue>=totalPageNumStr.integerValue) {
            [weakSelf.collectionView.mj_footer endRefreshingWithNoMoreData];
        }else{
            [weakSelf.collectionView.mj_footer endRefreshing];
        }
    } failure:^(NSDictionary *response) {
        DLog(@"\n>>>[getLineGoodsList failure]:%@",response);
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
    
    BGHotLineWaterFallCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"BGHotLineWaterFallCell" forIndexPath:indexPath];
    cell.layer.cornerRadius = 5;
    
    BGAirProductModel *model = self.cellDataArr[indexPath.item];
    [cell updataWithCellArray:model];
    
    return cell;
}



#pragma mark  - <LMHWaterFallLayoutDeleaget>
/**
 * 每个item的高度
 */
- (CGFloat)waterFallLayout:(BGWaterFallLayout *)waterFallLayout heightForItemAtIndexPath:(NSUInteger)indexPath itemWidth:(CGFloat)itemWidth{
    
    BGAirProductModel *model = self.cellDataArr[indexPath];
    
    CGFloat imgHeight = 1/([NSString stringWithFormat:@"%@",model.aspect_ratio].floatValue ?:1.25);
    NSInteger lineNum = [Tool needLinesWithWidth:(itemWidth-16) text:model.product_introduction];
    CGFloat staticHeight = 85;
    switch (lineNum) {
        case 1:
            staticHeight = 85;
            break;
        case 2:
            staticHeight = 96;
            break;
            
        default:
            staticHeight = 109;
            break;
    }
    
    
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
    
    return 10;
    
}

/**
 * 有多少列
 */
- (NSUInteger)columnCountInWaterFallLayout:(BGWaterFallLayout *)waterFallLayout{
    
    return 2;
    
}

-(void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{
    //    DLog(@"\n>>>[collectionView didSelectItem]:%ld",(long)indexPath.item);
    // @@ 添加登录判断
    if (![Tool isLogin]) {
        [WHIndicatorView toast:@"请先登录!"];
        [BGAppDelegateHelper showLoginViewController];
        return;
    }
    BGAirProductModel *model = _cellDataArr[indexPath.item];
    BGLineDetailViewController *detailVC = BGLineDetailViewController.new;
    detailVC.product_id = model.ID;
    [self.navigationController pushViewController:detailVC animated:YES];
    
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
