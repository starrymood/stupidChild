//
//  BGLocalSpecialDetailViewController.m
//  ShaHaiZiT
//
//  Created by biao on 2019/3/27.
//  Copyright © 2019 biao. All rights reserved.
//

#import "BGLocalSpecialDetailViewController.h"
#import "BGLocalSpecialModel.h"
#import "BGLocalRecommendCell.h"
#import "BGAirApi.h"
#import <SDCycleScrollView.h>

@interface BGLocalSpecialDetailViewController ()<UICollectionViewDataSource,UICollectionViewDelegate>

@property (nonatomic, strong) SDCycleScrollView *cycleScrollView;
/** 轮播图数据 */
@property (nonatomic,strong) NSMutableArray *cycleDataArray;

@property (nonatomic,strong) UICollectionView *collectionView;

@property (nonatomic, strong) UIView *headerView;

@property (nonatomic, strong) NSMutableArray *cellDataArr;

// 页数
@property (nonatomic, copy) NSString *pageNum;

@property (nonatomic, strong) UIView *noneView;

@property(nonatomic,strong) UITextView *textView;

@property(nonatomic,assign) CGFloat headerViewHeight;

@property(nonatomic,strong) UILabel *hotLabel;

@property(nonatomic,strong) UIView *otherView;

@end

@implementation BGLocalSpecialDetailViewController
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
        self.noneView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT-SafeAreaTopHeight-SCREEN_WIDTH*200/375-6)];
        _noneView.backgroundColor = kAppBgColor;
        [_noneView setHidden:YES];
        UIImageView *noneImgView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"noToken_bg"]];
        noneImgView.frame = CGRectMake(SCREEN_WIDTH*0.2, 30, SCREEN_WIDTH*0.6, SCREEN_WIDTH*0.6*1.02);
        [_noneView addSubview:noneImgView];
        
        UILabel *showMsgLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, noneImgView.frame.origin.y+noneImgView.frame.size.height+50, SCREEN_WIDTH-20, 20)];
        showMsgLabel.textAlignment = NSTextAlignmentCenter;
        [showMsgLabel setTextColor:kAppTipBGColor];
        showMsgLabel.font = kFont(14);
        showMsgLabel.text = @"暂无推荐~";
        [_noneView addSubview:showMsgLabel];
        
        __weak typeof(self)weakSelf = self;
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [weakSelf.noneView setHidden:NO];
        });
    }
    return _noneView;
}
- (void)viewDidLoad {
    [super viewDidLoad];
    [self loadSubViews];
    [self refreshView];
    
}
-(void)loadSubViews{
    self.navigationItem.title = _specialModel.title;
    self.view.backgroundColor = kAppBgColor;
    self.headerView = UIView.new;
    
    self.textView = [[UITextView alloc] init];
    _textView.backgroundColor = kAppWhiteColor;
    _textView.font = kFont(13);
    _textView.textColor = kAppDefaultLabelColor;
    _textView.textAlignment = NSTextAlignmentCenter;
    _textView.text = _specialModel.recommended_reason;
    _textView.textContainerInset = UIEdgeInsetsMake(12, 15, 20, 15);
    CGFloat textViewHeight = [self heightForString:_textView andWidth:SCREEN_WIDTH];
    
    self.headerViewHeight = (SCREEN_WIDTH*3/5 + textViewHeight + 37);
    _headerView.backgroundColor = kAppBgColor;
    _headerView.frame = CGRectMake(0, -_headerViewHeight, SCREEN_WIDTH, _headerViewHeight);
    // 轮播图
    self.cycleScrollView = [SDCycleScrollView cycleScrollViewWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_WIDTH*3/5) delegate:nil placeholderImage:BGImage(@"home_cycle_placeholder")];
    self.cycleScrollView.pageControlAliment = SDCycleScrollViewPageContolAlimentCenter;
    self.cycleScrollView.backgroundColor = kAppBgColor;
    self.cycleScrollView.imageURLStringsGroup = _specialModel.picture;
    self.cycleScrollView.currentPageDotColor = kAppMainColor;
    self.cycleScrollView.pageDotColor = kAppWhiteColor;
    [_headerView addSubview:_cycleScrollView];
    
     _textView.frame = CGRectMake(0, _cycleScrollView.height+_cycleScrollView.y, SCREEN_WIDTH, textViewHeight);
    [_headerView addSubview:_textView];
    
    self.otherView = [[UIView alloc] initWithFrame:CGRectMake(0, _textView.y+_textView.height+10, SCREEN_WIDTH, 40)];
    _otherView.backgroundColor = kAppWhiteColor;
    [_headerView addSubview:_otherView];
    
    self.hotLabel = UILabel.new;
    _hotLabel.frame = CGRectMake(20, 10, SCREEN_WIDTH-40, 17);
    if (_typeID.integerValue == 1) {
        _hotLabel.text = @"其他美食推荐";
    }else if(_typeID.integerValue == 2){
        _hotLabel.text = @"其他景点推荐";
    }else{
        _hotLabel.text = @"其他推荐";
    }
    _hotLabel.textColor = UIColorFromRGB(0x333333);
    _hotLabel.font = kFont(18);
    [_otherView addSubview:_hotLabel];
    
    // 创建布局
    CGFloat itemVideoWidth = (SCREEN_WIDTH-10-20*2)*0.5;
    UICollectionViewFlowLayout *flowLayout1 =[[UICollectionViewFlowLayout alloc]init];
    flowLayout1.itemSize = CGSizeMake(itemVideoWidth, itemVideoWidth*228/163.0+44);
    flowLayout1.sectionInset = UIEdgeInsetsMake(10, 20, 20, 20);
    flowLayout1.minimumLineSpacing = 20;
    flowLayout1.minimumInteritemSpacing  = 10;
    flowLayout1.scrollDirection = UICollectionViewScrollDirectionVertical;
    
    // 创建collectionView
    UICollectionView * collectionView = [[UICollectionView alloc]initWithFrame:CGRectMake(0, SafeAreaTopHeight, SCREEN_WIDTH, SCREEN_HEIGHT-SafeAreaTopHeight) collectionViewLayout:flowLayout1];
    collectionView.backgroundColor = kAppWhiteColor;
    collectionView.contentInset = UIEdgeInsetsMake(_headerViewHeight, 0, 0, 0);
    collectionView.dataSource = self;
    collectionView.delegate = self;
    [collectionView addSubview:self.headerView];
    [self.view addSubview:collectionView];
    // 注册
    [collectionView registerNib:[UINib nibWithNibName:NSStringFromClass([BGLocalRecommendCell class]) bundle:nil] forCellWithReuseIdentifier:@"BGLocalRecommendCell"];
    self.collectionView = collectionView;
    
    _pageNum = @"1";
    
}
-(void)updateWithNewData {
     self.navigationItem.title = _specialModel.title;
    _textView.text = _specialModel.recommended_reason;
    CGFloat textViewHeight = [self heightForString:_textView andWidth:SCREEN_WIDTH];
    self.headerViewHeight = (SCREEN_WIDTH*3/5 + textViewHeight + 37);
    _headerView.frame = CGRectMake(0, -_headerViewHeight, SCREEN_WIDTH, _headerViewHeight);
     self.cycleScrollView.imageURLStringsGroup = _specialModel.picture;
     _textView.frame = CGRectMake(0, _cycleScrollView.height+_cycleScrollView.y, SCREEN_WIDTH, textViewHeight);
     self.otherView = [[UIView alloc] initWithFrame:CGRectMake(0, _textView.y+_textView.height+10, SCREEN_WIDTH, 40)];
     _collectionView.contentInset = UIEdgeInsetsMake(_headerViewHeight, 0, 0, 0);
    _pageNum = @"1";
    
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
-(void)loadDetailsWithTalentID:(NSString *)talentID recommendID:(NSString *)recommendID{
    [ProgressHUDHelper showLoading];
    NSMutableDictionary *param = [[NSMutableDictionary alloc] init];
    [param setObject:talentID forKey:@"talent_id"];
    [param setObject:_typeID forKey:@"recommend_type"];
    [param setObject:recommendID forKey:@"recommend_id"];
    __weak __typeof(self) weakSelf = self;
    [BGAirApi getLocalPersonRecommendNew:param succ:^(NSDictionary *response) {
        DLog(@"\n>>>[getLocalPersonRecommendNew sucess]:%@",response);
       
        BGLocalSpecialModel *specialModel = [BGLocalSpecialModel mj_objectWithKeyValues:BGdictSetObjectIsNil(response[@"result"])];
        weakSelf.specialModel = specialModel;
        [weakSelf updateWithNewData];
        [weakSelf loadData];

    } failure:^(NSDictionary *response) {
        DLog(@"\n>>>[getLocalPersonRecommendNew failure]:%@",response);
    }];
}
-(void)loadData {
    
    NSMutableDictionary *param = [[NSMutableDictionary alloc] init];
    [param setObject:_pageNum forKey:@"pageno"];
    [param setObject:_specialModel.talent_id forKey:@"talent_id"];
    [param setObject:_typeID forKey:@"recommend_type"];
    [param setObject:@"10" forKey:@"pagesize"];
    [ProgressHUDHelper showLoading];
    __block typeof(self) weakSelf = self;
    [BGAirApi getLocalPersonRecommendList:param succ:^(NSDictionary *response) {
        DLog(@"\n>>>[getLocalPersonRecommendList sucess]:%@",response);
        [weakSelf hideNodateView];
        if (weakSelf.pageNum.intValue == 1) {
            [weakSelf.cellDataArr removeAllObjects];
            [weakSelf.collectionView.mj_footer resetNoMoreData];
        }
        NSMutableArray *tempArr = [BGLocalSpecialModel mj_objectArrayWithKeyValuesArray:response[@"result"][@"rows"]];
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
        DLog(@"\n>>>[getLocalPersonRecommendList failure]:%@",response);
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
    
    BGLocalRecommendCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"BGLocalRecommendCell" forIndexPath:indexPath];
    if ([Tool arrayIsNotEmpty:_cellDataArr]) {
        BGLocalSpecialModel *model = self.cellDataArr[indexPath.item];
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
     BGLocalSpecialModel *model =_cellDataArr[indexPath.item];
    [self loadDetailsWithTalentID:model.talent_id recommendID:model.ID];
}
- (float)heightForString:(UITextView *)textView andWidth:(float)width{
    CGSize sizeToFit = [textView sizeThatFits:CGSizeMake(width, MAXFLOAT)];
    return sizeToFit.height;
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
