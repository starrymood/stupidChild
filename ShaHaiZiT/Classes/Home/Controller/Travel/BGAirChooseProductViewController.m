//
//  BGAirChooseProductViewController.m
//  shzTravelC
//
//  Created by biao on 2018/8/20.
//  Copyright © 2018年 biao. All rights reserved.
//

#import "BGAirChooseProductViewController.h"
#import "BGAirProductModel.h"
#import "BGAirProductCell.h"
#import "BGAirApi.h"
#import "BGAirPriceInfoViewController.h"
#import "BGDayCarPriceInfoViewController.h"

@interface BGAirChooseProductViewController ()<UICollectionViewDelegate,UICollectionViewDataSource>

@property (nonatomic, strong) UICollectionView *collectionView;

@property (nonatomic,strong)NSMutableArray *cellDataArr;

@property (nonatomic, strong) UIView *noneView;

// 页数
@property (nonatomic, copy) NSString *pageNum;

@end

@implementation BGAirChooseProductViewController
-(UIView *)noneView {
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
        showMsgLabel.text = @"暂无产品~";
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
    self.navigationController.navigationBarHidden = NO;
}
- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self loadSubViews];
    [self refreshView];
}
-(void)loadSubViews {
    
    switch (_category) {
        case 1:{
            self.navigationItem.title = @"接机产品";
        }
            break;
        case 2:{
            self.navigationItem.title = @"送机产品";
        }
            break;
        case 3:{
            self.navigationItem.title = @"按天包车产品";
        }
            break;
            
        default:
            break;
    }
    self.view.backgroundColor = kAppBgColor;
    
    UIView *titleeView = UIView.new;
    titleeView.backgroundColor = kAppWhiteColor;
    titleeView.frame = CGRectMake(0, SafeAreaTopHeight+6, SCREEN_WIDTH, 45);
    [self.view addSubview:titleeView];
    
    UILabel *lab = UILabel.new;
    lab.frame = CGRectMake(13, 15, SCREEN_WIDTH-26, 15);
    lab.textColor = kApp333Color;
    lab.font = [UIFont boldSystemFontOfSize:14];
    lab.textAlignment = NSTextAlignmentCenter;
    lab.text = _titleStr;
    [titleeView addSubview:lab];
    
    CGFloat itemWidth = (SCREEN_WIDTH-13*3)*0.5;
    UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
    layout.itemSize = CGSizeMake(itemWidth, itemWidth/21.0*16+73);
    layout.minimumInteritemSpacing = 13;
    layout.minimumLineSpacing = 6;
    layout.sectionInset = UIEdgeInsetsMake(6, 13, 15, 13);
    
    
    _collectionView = [[UICollectionView alloc] initWithFrame:CGRectMake(0, titleeView.height+titleeView.y, SCREEN_WIDTH, SCREEN_HEIGHT-titleeView.height-titleeView.y) collectionViewLayout:layout];
    _collectionView.showsVerticalScrollIndicator = NO;
    _collectionView.backgroundColor = kAppBgColor;
    _collectionView.delegate = self;
    _collectionView.dataSource = self;
    [_collectionView registerNib:[UINib nibWithNibName:NSStringFromClass([BGAirProductCell class]) bundle:nil] forCellWithReuseIdentifier:@"BGAirProductCell"];
    [self.view addSubview:_collectionView];
    
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
//        [weakSelf.collectionView.mj_footer endRefreshing];
    }];
    [self loadData];
}
-(void)loadData{
    NSMutableDictionary *param = [[NSMutableDictionary alloc] init];
    if ([Tool isBlankString:_airport_id]) {
        [WHIndicatorView toast:@"未能获取到信息"];
        [self.navigationController popViewControllerAnimated:YES];
        return;
    }else{
        if (_category == 3) {
            [param setObject:_airport_id forKey:@"region_id"];
        }else{
            [param setObject:_airport_id forKey:@"airport_id"];
        }
    }
    [param setObject:@(_category) forKey:@"product_set_cd"];
    [param setObject:_pageNum forKey:@"pageno"];
    [param setObject:@"10" forKey:@"pagesize"];
    [ProgressHUDHelper showLoading];
    __weak __typeof(self) weakSelf = self;
    [BGAirApi getProductInfoByAirId:param isCar:(_category==3)?YES:NO succ:^(NSDictionary *response) {
        DLog(@"\n>>>[getProductInfoByAirId sucess]:%@",response);
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
        DLog(@"\n>>>[getProductInfoByAirId failure]:%@",response);
        [self shownoNetWorkViewWithType:0];
        [self setRefreshBlock:^{
            [weakSelf loadData];
        }];
    }];
}
#pragma - mark UICollectionView
-(NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView{
    return 1;
}
-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
     self.collectionView.mj_footer.hidden = self.cellDataArr.count == 0;
    return _cellDataArr.count;
    
}
-(UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    BGAirProductCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"BGAirProductCell" forIndexPath:indexPath];
    cell.layer.cornerRadius = 5;
    if (_cellDataArr.count>0) {
        [cell updataWithCellArray:_cellDataArr[indexPath.item]];
    }
    
    return cell;
}
-(void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{

    switch (_category) {
        case 1:{
            BGAirProductModel *model =_cellDataArr[indexPath.item];
            BGAirPriceInfoViewController *infoVC = BGAirPriceInfoViewController.new;
            infoVC.product_id = model.ID;
            infoVC.category = _category;
            [self.navigationController pushViewController:infoVC animated:YES];
        }
            break;
        case 2:{
            BGAirProductModel *model =_cellDataArr[indexPath.item];
            BGAirPriceInfoViewController *infoVC = BGAirPriceInfoViewController.new;
            infoVC.product_id = model.ID;
            infoVC.category = _category;
            [self.navigationController pushViewController:infoVC animated:YES];
        }
            break;
        case 3:{
            BGAirProductModel *model =_cellDataArr[indexPath.item];
            BGDayCarPriceInfoViewController *dayCarVC = BGDayCarPriceInfoViewController.new;
            dayCarVC.product_id = model.ID;
            [self.navigationController pushViewController:dayCarVC animated:YES];
        }
            break;
            
        default:
            break;
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
