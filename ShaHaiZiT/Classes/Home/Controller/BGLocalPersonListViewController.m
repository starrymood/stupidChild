//
//  BGLocalPersonListViewController.m
//  ShaHaiZiT
//
//  Created by biao on 2019/3/25.
//  Copyright © 2019 biao. All rights reserved.
//

#import "BGLocalPersonListViewController.h"
#import "BGAirApi.h"
#import "BGHomeHotVideoModel.h"
#import "BGHomeHotVideoCell.h"
#import "BGLocalPersonDetailViewController.h"

@interface BGLocalPersonListViewController ()<UICollectionViewDataSource,UICollectionViewDelegate>

@property (nonatomic, strong) NSMutableArray *cellDataArr;

@property (nonatomic,strong) UICollectionView *collectionView;
// 页数
@property (nonatomic, copy) NSString *pageNum;

@end

@implementation BGLocalPersonListViewController

-(NSMutableArray *)cellDataArr {
    if (!_cellDataArr) {
        self.cellDataArr = [NSMutableArray array];
    }
    return _cellDataArr;
}
-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    self.navigationController.navigationBarHidden = NO;
}
- (void)viewDidLoad {
    [super viewDidLoad];
    [self loadSubViews];
    [self setupLayoutAndCollectionView];
    [self refreshView];
}

-(void)loadSubViews{
    self.view.backgroundColor = kAppBgColor;
    self.navigationItem.title = @"当地达人";
}
/**
 * 创建布局和collectionView
 */
- (void)setupLayoutAndCollectionView{
    
    // 创建布局
    CGFloat itemVideoWidth = (SCREEN_WIDTH-40-30*2)/3.0-0.1;
    UICollectionViewFlowLayout *flowLayout1 =[[UICollectionViewFlowLayout alloc]init];
    flowLayout1.itemSize = CGSizeMake(itemVideoWidth, itemVideoWidth*185/105.0);
    flowLayout1.sectionInset = UIEdgeInsetsMake(15, 20, 20, 20);
    flowLayout1.minimumLineSpacing = 20;
    flowLayout1.minimumInteritemSpacing  = 30;
    flowLayout1.scrollDirection = UICollectionViewScrollDirectionVertical;
    
    // 创建collectionView
    UICollectionView * collectionView = [[UICollectionView alloc]initWithFrame:CGRectMake(0, SafeAreaTopHeight, SCREEN_WIDTH, SCREEN_HEIGHT-SafeAreaTopHeight) collectionViewLayout:flowLayout1];
    collectionView.backgroundColor = kAppBgColor;
    
    collectionView.dataSource = self;
    collectionView.delegate = self;
    [self.view addSubview:collectionView];
    // 注册
    [collectionView registerNib:[UINib nibWithNibName:NSStringFromClass([BGHomeHotVideoCell class]) bundle:nil] forCellWithReuseIdentifier:@"BGHomeHotVideoCell"];
    
    self.collectionView = collectionView;
    
    _pageNum = @"1";
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
    self.collectionView.mj_footer = [MJRefreshAutoFooter footerWithRefreshingBlock:^{
        //每次刷新,页码都加一页
        NSInteger nowPindex = [weakSelf.pageNum integerValue]+1;
        weakSelf.pageNum = [NSString stringWithFormat:@"%zd",nowPindex];
        [weakSelf loadData];
    }];
    [self loadData];
}
-(void)loadData {
    NSMutableDictionary *param = [[NSMutableDictionary alloc] init];
    [param setObject:_pageNum forKey:@"pageno"];
    [param setObject:@"15" forKey:@"pagesize"];
    [ProgressHUDHelper showLoading];
    __block typeof(self) weakSelf = self;
    [BGAirApi getLocalPersonList:param succ:^(NSDictionary *response) {
        DLog(@"\n>>>[getLocalPersonList sucess]:%@",response);
        [weakSelf hideNodateView];
        if (weakSelf.pageNum.intValue == 1) {
            [weakSelf.cellDataArr removeAllObjects];
            [weakSelf.collectionView.mj_footer resetNoMoreData];
        }
        NSMutableArray *tempArr = [BGHomeHotVideoModel mj_objectArrayWithKeyValuesArray:response[@"result"][@"rows"]];
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
        DLog(@"\n>>>[getLocalPersonList failure]:%@",response);
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
    
    BGHomeHotVideoCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"BGHomeHotVideoCell" forIndexPath:indexPath];
    if ([Tool arrayIsNotEmpty:_cellDataArr]) {
        BGHomeHotVideoModel *model = self.cellDataArr[indexPath.item];
        [cell updataWithCellArray:model];
    }
    
    return cell;
    
}


-(void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{
    
    if (![Tool isLogin]) {
        [WHIndicatorView toast:@"请先登录!"];
        [BGAppDelegateHelper showLoginViewController];
        return;
    }
    BGHomeHotVideoModel *model = _cellDataArr[indexPath.item];
    BGLocalPersonDetailViewController *detailVC = BGLocalPersonDetailViewController.new;
    detailVC.personID = model.ID;
    [self.navigationController pushViewController:detailVC animated:YES];
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
