//
//  BGCouponNotUsedViewController.m
//  shzTravelC
//
//  Created by 孙林茂 on 2018/5/10.
//  Copyright © 2018年 biao. All rights reserved.
//

#import "BGCouponNotUsedViewController.h"
#import "BGCouponManagerListCell.h"
#import "BGMemberApi.h"
#import "BGCouponModel.h"
#import "BGGetCouponViewController.h"

#define BtnHeight 40
@interface BGCouponNotUsedViewController ()<UITableViewDelegate, UITableViewDataSource>
@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) UIView *noneView;
// cell的数据数组
@property (nonatomic,strong) NSMutableArray *cellDataArr;

// 页数
@property (nonatomic, copy) NSString *pageNum;

@end

@implementation BGCouponNotUsedViewController
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
        showMsgLabel.text = @"亲，您还没有未使用的优惠券哟~";
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
    _pageNum = @"1";
    [self loadData];
}
- (void)viewDidLoad {
    [super viewDidLoad];
    [self loadSubViews];
    [self refreshView];
}

-(void)loadSubViews {
    
        self.tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT-SafeAreaTopHeight-BtnHeight) style:(UITableViewStyleGrouped)];
    
    _tableView.backgroundColor = kAppBgColor;
    _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    _tableView.estimatedRowHeight = 0;
    _tableView.estimatedSectionHeaderHeight = 0;
    _tableView.estimatedSectionFooterHeight = 0;
    _tableView.dataSource = self;
    _tableView.delegate = self;
    [self.view addSubview:_tableView];
    
    [self.tableView registerNib:[UINib nibWithNibName:@"BGCouponManagerListCell" bundle:nil] forCellReuseIdentifier:@"BGCouponManagerListCell"];
    
      _pageNum = @"1";
    
    UIButton *couponBtn = [UIButton buttonWithType:(UIButtonTypeCustom)];
    couponBtn.frame = CGRectMake((SCREEN_WIDTH-250)*0.5, SCREEN_HEIGHT-SafeAreaTopHeight-SafeAreaBottomHeight-kTabBarH-10-41, 250, 41);
    
    [couponBtn setBackgroundImage:BGImage(@"btn_bgColor") forState:(UIControlStateNormal)];
    [couponBtn setTitle:@"前往领券中心" forState:(UIControlStateNormal)];
    [couponBtn.titleLabel setFont:kFont(15)];
    couponBtn.layer.masksToBounds = YES;
    couponBtn.layer.cornerRadius = couponBtn.height*0.5;
    [self.view addSubview:couponBtn];
    @weakify(self);
    [[couponBtn rac_signalForControlEvents:(UIControlEventTouchUpInside)] subscribeNext:^(__kindof UIControl * _Nullable x) {
        @strongify(self);
        // 点击button的响应事件
        BGGetCouponViewController *couponVC = BGGetCouponViewController.new;
        [self.navigationController pushViewController:couponVC animated:YES];
    }];
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
    
   
}

-(void)loadData {

        NSMutableDictionary *param = [NSMutableDictionary dictionary];
        [param setObject:@"10" forKey:@"pagesize"];
        [param setObject:_pageNum forKey:@"pageno"];
        [param setObject:@"1" forKey:@"status"];
        
            [ProgressHUDHelper showLoading];
        __block typeof(self) weakSelf = self;
        [BGMemberApi getCouponList:param succ:^(NSDictionary *response) {
            DLog(@"\n>>>[getCouponList sucess]:%@",response);
            [weakSelf hideNodateView];
            if (weakSelf.pageNum.intValue == 1) {
                [weakSelf.cellDataArr removeAllObjects];
                [weakSelf.tableView.mj_footer resetNoMoreData];
            }
            NSMutableArray *tempArr = [BGCouponModel mj_objectArrayWithKeyValuesArray:response[@"result"][@"rows"]];
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
            DLog(@"\n>>>[getCouponList failure]:%@",response);
            [self shownoNetWorkViewWithType:0];
            [self setRefreshBlock:^{
                [weakSelf loadData];
            }];
        }];
    
}
#pragma mark  -  TableViewDelegate  -
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    self.tableView.mj_footer.hidden = self.cellDataArr.count == 0;
    return _cellDataArr.count==0 ? 1: _cellDataArr.count;
}
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return _cellDataArr.count==0 ? 0:1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    BGCouponManagerListCell *cell = [tableView dequeueReusableCellWithIdentifier:@"BGCouponManagerListCell" forIndexPath:indexPath];

    if ([Tool arrayIsNotEmpty:_cellDataArr]) {
        BGCouponModel *model = _cellDataArr[indexPath.section];
        [cell updataWithCellArray:model codeType:1];
        @weakify(self);
        [[cell.couponUseBtn rac_signalForControlEvents:(UIControlEventTouchUpInside)] subscribeNext:^(__kindof UIControl * _Nullable x) {
            @strongify(self);
            // 点击button的响应事件
            [self.navigationController popToRootViewControllerAnimated:NO];
            [[NSNotificationCenter defaultCenter] postNotificationName:@"SELECTINDEXHOME" object:nil];
        }];
    }
    
    return cell;
}
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
   
  
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return (SCREEN_WIDTH-41)*0.35+24;
}
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    if (_cellDataArr.count == 0) {
        return 0.01;
    }else{
        return section == 0? 6:0.01;
    }
}
-(CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section{
    if (_cellDataArr.count == 0) {
        return _tableView.frame.size.height;
    }else{
        return 0.01;
    }
}
- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    return nil;
}
- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section{
    if (_cellDataArr.count == 0) {
        return self.noneView;
    }
    return nil;
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
