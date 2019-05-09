//
//  BGCollectionLineViewController.m
//  ShaHaiZiT
//
//  Created by biao on 2018/11/24.
//  Copyright © 2018 biao. All rights reserved.
//

#import "BGCollectionLineViewController.h"
#import "BGHotLineWaterFallCell.h"
#import "BGWaterFallLayout.h"
#import "BGAirApi.h"
#import "BGAirProductModel.h"
#import "BGLineDetailViewController.h"

#define BtnHeight 48
@interface BGCollectionLineViewController ()<UICollectionViewDataSource,UICollectionViewDelegate,BGWaterFallLayoutDelegate>

@property (nonatomic, strong) NSMutableArray *cellDataArr;

@property (nonatomic,strong) UICollectionView *collectionView;
// 页数
@property (nonatomic, copy) NSString *pageNum;

@property (nonatomic, strong) UIView *noneView;

@end

@implementation BGCollectionLineViewController

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
        showMsgLabel.text = @"您还没有收藏线路哦~";
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
- (void)viewDidLoad {
    [super viewDidLoad];
    [self loadSubViews];
    [self setupLayoutAndCollectionView];
    [self refreshView];
}

-(void)loadSubViews{
    self.view.backgroundColor = kAppBgColor;
}
/**
 * 创建布局和collectionView
 */
- (void)setupLayoutAndCollectionView{
    
    // 创建布局
    BGWaterFallLayout * waterFallLayout = [[BGWaterFallLayout alloc]init];
    waterFallLayout.delegate = self;
    
    // 创建collectionView
    UICollectionView * collectionView = [[UICollectionView alloc]initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT-SafeAreaTopHeight-BtnHeight) collectionViewLayout:waterFallLayout];
    collectionView.backgroundColor = kAppBgColor;
    
    collectionView.dataSource = self;
    collectionView.delegate = self;
    [self.view addSubview:collectionView];
    // 注册
    [collectionView registerNib:[UINib nibWithNibName:NSStringFromClass([BGHotLineWaterFallCell class]) bundle:nil] forCellWithReuseIdentifier:@"BGHotLineWaterFallCell"];
    
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
//        [weakSelf.collectionView.mj_footer endRefreshing];
    }];
    [self loadData];
}
-(void)loadData {
    NSMutableDictionary *param = [[NSMutableDictionary alloc] init];
    [param setObject:_pageNum forKey:@"pageno"];
    [param setObject:@"10" forKey:@"pagesize"];
    [param setObject:@"5" forKey:@"category"];
    [ProgressHUDHelper showLoading];
    __block typeof(self) weakSelf = self;
    [BGAirApi getUserCollectionList:param succ:^(NSDictionary *response) {
        DLog(@"\n>>>[getUserCollectionList sucess]:%@",response);
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
        DLog(@"\n>>>[getUserCollectionList failure]:%@",response);
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
    
    BGAirProductModel *model = _cellDataArr[indexPath.item];
    BGLineDetailViewController *detailVC = BGLineDetailViewController.new;
    detailVC.product_id = model.product_id;
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
