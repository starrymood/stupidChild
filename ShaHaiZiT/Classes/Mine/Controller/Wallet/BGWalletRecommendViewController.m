//
//  BGWalletRecommendViewController.m
//  ShaHaiZiT
//
//  Created by biao on 2019/1/11.
//  Copyright © 2019 biao. All rights reserved.
//

#import "BGWalletRecommendViewController.h"
#import "BGWalletRecommendCell.h"
#import "BGWalletDetailModel.h"
#import "BGPurseApi.h"

@interface BGWalletRecommendViewController ()<UITableViewDelegate,UITableViewDataSource>

@property (weak, nonatomic) IBOutlet UITableView *tableView;
// cell的数据数组
@property (nonatomic,strong) NSMutableArray *cellDataArr;
// 页数
@property (nonatomic, copy) NSString *pageNum;
@property (nonatomic, strong) UIView *noneView;
@property (weak, nonatomic) IBOutlet UILabel *recommendMoneyLabel;

@end

@implementation BGWalletRecommendViewController
-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    self.navigationController.navigationBarHidden = YES;
}
-(void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    self.navigationController.navigationBarHidden = NO;
}

-(UIView *)noneView {
    if (!_noneView) {
        self.noneView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT-SCREEN_WIDTH*194/375)];
        _noneView.backgroundColor = kAppBgColor;
        [_noneView setHidden:YES];
        UIImageView *noneImgView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"noToken_bg"]];
        noneImgView.frame = CGRectMake(SCREEN_WIDTH*0.2, 60, SCREEN_WIDTH*0.6, SCREEN_WIDTH*0.6*1.02);
        [_noneView addSubview:noneImgView];
        
        UILabel *showMsgLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, noneImgView.frame.origin.y+noneImgView.frame.size.height+50, SCREEN_WIDTH-20, 20)];
        showMsgLabel.textAlignment = NSTextAlignmentCenter;
        [showMsgLabel setTextColor:kAppTipBGColor];
        showMsgLabel.font = kFont(14);
        showMsgLabel.text = @"亲,您还没有佣金收入哟~";
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
    
    self.view.backgroundColor = kAppBgColor;
    
    if ([self.recommendMoneyStr isEqualToString:@"0.0"]) {
        [self loadMoneyAction];
    }else{
        self.recommendMoneyLabel.text = self.recommendMoneyStr;
    }
    _tableView.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
    _tableView.separatorColor = kAppLineBGColor;
    _tableView.tableFooterView = [UIView new];
    _tableView.estimatedRowHeight = 0;
    _tableView.estimatedSectionHeaderHeight = 0;
    _tableView.estimatedSectionFooterHeight = 0;
    _tableView.delegate = self;
    _tableView.dataSource = self;
    self.tableView.backgroundColor = kAppBgColor;
    
    [self.view addSubview:_tableView];
    
    
    [self.tableView registerNib:[UINib nibWithNibName:@"BGWalletRecommendCell" bundle:nil] forCellReuseIdentifier:@"BGWalletRecommendCell"];
    _pageNum = @"1";
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
    self.tableView.mj_footer = [MJRefreshAutoFooter footerWithRefreshingBlock:^{
        //每次刷新,页码都加一页
        NSInteger nowPindex = [weakSelf.pageNum integerValue]+1;
        weakSelf.pageNum = [NSString stringWithFormat:@"%zd",nowPindex];
        [weakSelf loadData];
        //        [weakSelf.tableView.mj_footer endRefreshing];
    }];
    
    [self loadData];
}

#pragma mark - loadData  -
- (void)loadData {
    
    NSMutableDictionary *param = [NSMutableDictionary dictionary];
    [param setObject:_pageNum forKey:@"pageNo"];
    [param setObject:@"15" forKey:@"pagesize"];
    [ProgressHUDHelper showLoading];
    __block typeof(self) weakSelf = self;
    [BGPurseApi getPurseCommissionDetail:param succ:^(NSDictionary *response) {
        DLog(@"\n>>>[getPurseCommissionDetail sucess]:%@",response);
        [weakSelf hideNodateView];
        if (weakSelf.pageNum.intValue == 1) {
            [weakSelf.cellDataArr removeAllObjects];
            [weakSelf.tableView.mj_footer resetNoMoreData];
        }
        
        NSMutableArray *tempArr = [BGWalletDetailModel mj_objectArrayWithKeyValuesArray:BGdictSetObjectIsNil(response[@"result"][@"rows"])];
        NSString *totalPageNumStr = [NSString stringWithFormat:@"%@",BGdictSetObjectIsNil(response[@"result"][@"pages"])];
        if (weakSelf.pageNum.integerValue<=totalPageNumStr.integerValue) {
            [weakSelf.cellDataArr addObjectsFromArray:tempArr];
        }
        if (weakSelf.cellDataArr.count>0) {
            [weakSelf.noneView removeFromSuperview];
        }
        [weakSelf.tableView reloadData];
        
        if (weakSelf.pageNum.integerValue>=totalPageNumStr.integerValue) {
            [weakSelf.tableView.mj_footer endRefreshingWithNoMoreData];
        }else{
            [weakSelf.tableView.mj_footer endRefreshing];
        }
    } failure:^(NSDictionary *response) {
        DLog(@"\n>>>[getPurseCommissionDetail failure]:%@",response);
        [self shownoNetWorkViewWithType:0];
        [self setRefreshBlock:^{
            [weakSelf loadData];
        }];
    }];
}
-(void)loadMoneyAction {
    
    __block typeof(self)weakSelf = self;
    [BGPurseApi getPurseBalance:nil succ:^(NSDictionary *response) {
        DLog(@"\n>>>[getPurseBalance success]:%@",response);
        
        weakSelf.recommendMoneyLabel.text = [NSString stringWithFormat:@"%@",BGdictSetObjectIsNil(response[@"result"][@"commission_count"])];
    } failure:^(NSDictionary *response) {
        DLog(@"\n>>>[getPurseBalance failure]:%@",response);
    }];
}
- (IBAction)btnBackClicked:(UIButton *)sender {
    [self.navigationController popViewControllerAnimated:YES];
}
#pragma mark --  TableViewDelegate  --
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    self.tableView.mj_footer.hidden = self.cellDataArr.count == 0;
    return self.cellDataArr.count;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    BGWalletRecommendCell *cell = [tableView dequeueReusableCellWithIdentifier:@"BGWalletRecommendCell" forIndexPath:indexPath];
    if ([Tool arrayIsNotEmpty:_cellDataArr]) {
        BGWalletDetailModel *model = self.cellDataArr[indexPath.row];
        [cell updataWithAwardArray:model];
    }
    
    
    return cell;
    
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 60;
}

-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    if (_cellDataArr.count == 0) {
        return 0.01;
    }else{
        return 6;
    }
}
-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    return UIView.new;
}
-(CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section{
    if (_cellDataArr.count == 0) {
        return _tableView.frame.size.height;
    }else{
        return 0.01;
    }
}
- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section{
    if (_cellDataArr.count == 0) {
        return self.noneView;
    }
    return nil;
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
