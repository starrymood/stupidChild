//
//  BGShopListViewController.m
//  shzTravelC
//
//  Created by 孙林茂 on 2018/5/9.
//  Copyright © 2018年 biao. All rights reserved.
//

#import "BGShopListViewController.h"
#import "BGWaterFallLayout.h"
#import "BGShopCell.h"
#import "BGShopShowModel.h"
#import "BGShopDetailViewController.h"

#import "BGShopApi.h"
#import "BGSearchViewController.h"

#define kBtnViewHeight 41
@interface BGShopListViewController ()<UICollectionViewDataSource,UICollectionViewDelegate,BGWaterFallLayoutDelegate>
/** 所有的商品数据 */
@property (nonatomic, strong) NSMutableArray  *cellDataArr;

@property (nonatomic,strong) UICollectionView *collectionView;

// 页数
@property (nonatomic, copy) NSString *pageNum;
@property (nonatomic, copy) NSString *sortStr;
@property (nonatomic,assign) NSInteger lastSelectTag;
@property (nonatomic, strong) UIView *btnView;
@property (nonatomic, strong) UIView *noneView;

@end

@implementation BGShopListViewController
-(UIView *)noneView {
    if (!_noneView) {
        self.noneView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT-SafeAreaTopHeight)];
        _noneView.backgroundColor = kAppBgColor;
        [_noneView setHidden:YES];
        UIImageView *noneImgView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"noToken_bg"]];
        noneImgView.frame = CGRectMake(SCREEN_WIDTH*0.2, 60, SCREEN_WIDTH*0.6, SCREEN_WIDTH*0.6*1.02);
        [_noneView addSubview:noneImgView];
        
        UILabel *showMsgLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, noneImgView.frame.origin.y+noneImgView.frame.size.height+50, SCREEN_WIDTH-20, 20)];
        showMsgLabel.textAlignment = NSTextAlignmentCenter;
        [showMsgLabel setTextColor:kAppTipBGColor];
        showMsgLabel.font = kFont(14);
        showMsgLabel.text = @"没有搜索到您想要的内容~";
        [_noneView addSubview:showMsgLabel];
        
        __weak typeof(self)weakSelf = self;
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [weakSelf.noneView setHidden:NO];
        });
    }
    return _noneView;
}
-(NSMutableArray *)cellDataArr {
    if (!_cellDataArr) {
        self.cellDataArr = [NSMutableArray array];
    }
    return _cellDataArr;
}
-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    self.navigationController.navigationBarHidden = YES;
}
- (void)viewDidLoad {
    [super viewDidLoad];

    [self loadSubViews];
    [self setupLayoutAndCollectionView];
    [self refreshView];
}
-(void)loadSubViews {
    
    _pageNum = @"1";
    self.sortStr = @"all desc";
    self.lastSelectTag = 100;
    
    //得到当前视图控制器中的所有控制器
    NSMutableArray *array = [self.navigationController.viewControllers mutableCopy];
    
    for (int i = 0; i < array.count; i++) {
        if ([array[i] isKindOfClass:[BGSearchViewController class]]) {
            [array removeObjectAtIndex:i];
            //把删除后的控制器数组再次赋值
            [self.navigationController setViewControllers:[array copy] animated:YES];
        }
    }
    
    
    UIView *topView = UIView.new;
    topView.backgroundColor = kAppClearColor;
    topView.frame = CGRectMake(0, SafeAreaTopHeight-kNavigationBarH, SCREEN_WIDTH, kNavigationBarH);
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
    searchBtn.frame = CGRectMake(41, 7, SCREEN_WIDTH-41-24, 30);
    searchBtn.backgroundColor = kAppWhiteColor;
    searchBtn.layer.borderWidth = 1.0;
    searchBtn.layer.borderColor = kApp999Color.CGColor;
//    searchBtn.layer.shadowColor = kApp999Color.CGColor;
//    searchBtn.layer.shadowOffset = CGSizeMake(1, 1);
    searchBtn.clipsToBounds = YES;
    searchBtn.layer.cornerRadius = 15;
    
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
    
    UIImageView *searchImgView = [[UIImageView alloc] initWithImage:BGImage(@"home_search")];
    searchImgView.frame = CGRectMake(15, 8, 14, 14);
    [searchBtn addSubview:searchImgView];
    
    UILabel *searchLabel = UILabel.new;
    searchLabel.frame = CGRectMake(36, 9, SCREEN_WIDTH-100, 14);
    if ([Tool isBlankString:_keyword]) {
        [searchLabel setTextColor:kApp999Color];
        searchLabel.text = @"请输入您正在查找的商品";
    }else{
        [searchLabel setTextColor:kApp333Color];
        searchLabel.text = _keyword;
    }
   
    [searchLabel setFont:kFont(13)];
    [searchBtn addSubview:searchLabel];
    [topView addSubview:searchBtn];
    
    self.btnView = UIView.new;
    _btnView.backgroundColor = kAppWhiteColor;
    _btnView.frame = CGRectMake(0, topView.y+topView.height, SCREEN_WIDTH, kBtnViewHeight);
    [self.view addSubview:_btnView];
    
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
    
    NSArray *itemName = @[@"综合排序",@"销量优先",@"价格优先"];
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
}
- (void)itemBtnClicked:(UIButton *)sender {
    
    UIButton *lastSelectBtn = [self.btnView viewWithTag:self.lastSelectTag];
    [lastSelectBtn setTitleColor:kAppBlackColor forState:UIControlStateNormal];
    
    [sender setTitleColor:kAppMainColor forState:UIControlStateNormal];
    
    self.lastSelectTag = sender.tag;
    
    switch (sender.tag-100) {
        case 0:{
//            [WHIndicatorView toast:@"综合排序"];
            self.sortStr = @"all desc";
            self.pageNum = @"1";
            [self.collectionView.mj_header beginRefreshing];
        }
            break;
        case 1:{
//            [WHIndicatorView toast:@"销量优先"];
             self.sortStr = @"num desc";
            self.pageNum = @"1";
            [self.collectionView.mj_header beginRefreshing];
        }
            break;
        case 2:{
//            [WHIndicatorView toast:@"价格优先"];
             self.sortStr = @"price desc";
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
    UICollectionView * collectionView = [[UICollectionView alloc]initWithFrame:CGRectMake(0, SafeAreaTopHeight+kBtnViewHeight, SCREEN_WIDTH, SCREEN_HEIGHT-SafeAreaTopHeight-kBtnViewHeight) collectionViewLayout:waterFallLayout];
    collectionView.backgroundColor = kAppBgColor;
    
    collectionView.dataSource = self;
    collectionView.delegate = self;
    collectionView.contentInset = UIEdgeInsetsMake(0, 0, 0, 0);
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
        [weakSelf loadData];
        [weakSelf.collectionView.mj_header endRefreshing];
    }];
    
    // 上拉刷新
    self.collectionView.mj_footer = [MJRefreshAutoNormalFooter footerWithRefreshingBlock:^{
        //每次刷新,页码都加一页
        NSInteger nowPindex = [weakSelf.pageNum integerValue]+1;
        weakSelf.pageNum = [NSString stringWithFormat:@"%zd",nowPindex];
        [weakSelf loadData];
//        [weakSelf.collectionView.mj_footer endRefreshing];
    }];
     [self loadData];
}

#pragma mark - 加载数据  -
- (void)loadData {
    NSMutableDictionary *param = [NSMutableDictionary dictionary];
    [param setObject:_pageNum forKey:@"pageno"];
    [param setObject:@"10" forKey:@"pagesize"];
    if (![Tool isBlankString:_cat_id]) {
        [param setObject:_cat_id forKey:@"cat_id"];
    }
    if (![Tool isBlankString:_keyword]) {
        [param setObject:_keyword forKey:@"keyword"];
    }
     [param setObject:_sortStr forKey:@"sort"];
    [ProgressHUDHelper showLoading];
    __block typeof(self) weakSelf = self;
    [BGShopApi getGoodsList:param succ:^(NSDictionary *response) {
//        DLog(@"\n>>>[getGoodsList sucess]:%@",response);
        [self hideNodateView];

        if (weakSelf.pageNum.intValue == 1) {
            [weakSelf.cellDataArr removeAllObjects];
            [weakSelf.collectionView.mj_footer resetNoMoreData];
        }
        NSMutableArray *tempArr = [BGShopShowModel mj_objectArrayWithKeyValuesArray:BGdictSetObjectIsNil(response[@"result"][@"rows"])];
       
        NSString *totalPageNumStr = [NSString stringWithFormat:@"%@",BGdictSetObjectIsNil(response[@"result"][@"pages"])];
        if (weakSelf.pageNum.integerValue<=totalPageNumStr.integerValue) {
            [weakSelf.cellDataArr addObjectsFromArray:tempArr];
        }
        if (![Tool arrayIsNotEmpty:weakSelf.cellDataArr]) {
            [weakSelf.collectionView addSubview:weakSelf.noneView];
        }
        [weakSelf.collectionView reloadData];
        if (weakSelf.pageNum.integerValue>=totalPageNumStr.integerValue) {
            [weakSelf.collectionView.mj_footer endRefreshingWithNoMoreData];
        }else{
            [weakSelf.collectionView.mj_footer endRefreshing];
        }
    } failure:^(NSDictionary *response) {
        DLog(@"\n>>>[getGoodsList failure]:%@",response);
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
