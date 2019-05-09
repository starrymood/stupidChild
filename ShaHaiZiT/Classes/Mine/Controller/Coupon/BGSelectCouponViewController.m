//
//  BGSelectCouponViewController.m
//  ShaHaiZiT
//
//  Created by biao on 2018/11/28.
//  Copyright © 2018 biao. All rights reserved.
//

#import "BGSelectCouponViewController.h"
#import "BGCouponManagerListCell.h"
#import "BGMemberApi.h"
#import "BGCouponModel.h"
#import "BGGetCouponViewController.h"

@interface BGSelectCouponViewController ()<UITableViewDelegate, UITableViewDataSource>
@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) UIView *noneView;
// cell的数据数组
@property (nonatomic,strong) NSMutableArray *cellDataArr;

@property(nonatomic,strong) UIView *headerView;

@end

@implementation BGSelectCouponViewController
-(UIView *)headerView{
    if (!_headerView) {
        self.headerView = UIView.new;
        _headerView.frame = CGRectMake(0, 0, SCREEN_WIDTH, 55);
        _headerView.backgroundColor = kAppBgColor;
        
        UIButton *btn = [UIButton buttonWithType:(UIButtonTypeCustom)];
        [btn setTitle:@"不使用优惠券" forState:(UIControlStateNormal)];
        [btn.titleLabel setFont:kFont(14)];
        [btn setTitleColor:kAppMainColor forState:(UIControlStateNormal)];
        btn.frame = CGRectMake(SCREEN_WIDTH*0.3, 8, SCREEN_WIDTH*0.4, 34);
        btn.backgroundColor = kAppWhiteColor;
        btn.layer.cornerRadius = 8.0;
        btn.clipsToBounds = YES;
        btn.layer.borderColor = kAppMainColor.CGColor;
        btn.layer.borderWidth = 0.5;
        [_headerView addSubview:btn];
        @weakify(self);
        [[btn rac_signalForControlEvents:(UIControlEventTouchUpInside)] subscribeNext:^(__kindof UIControl * _Nullable x) {
            @strongify(self);
            // 点击button的响应事件
            if (self.callBackCouponBlock) {
                self.callBackCouponBlock(@"", @"");
                [self.navigationController popViewControllerAnimated:YES];
            }
        }];
    }
    return _headerView;
}
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
        showMsgLabel.text = @"亲，暂无可用的优惠券哟~";
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
    [self loadData];
}
- (void)viewDidLoad {
    [super viewDidLoad];
    [self loadSubViews];
    [self refreshView];
}

-(void)loadSubViews {
    
    self.navigationItem.title = @"选择优惠券";
    self.view.backgroundColor = kAppBgColor;
    self.tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, SafeAreaTopHeight, SCREEN_WIDTH, SCREEN_HEIGHT-SafeAreaTopHeight) style:(UITableViewStyleGrouped)];
    
    _tableView.backgroundColor = kAppBgColor;
    _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    _tableView.estimatedRowHeight = 0;
    _tableView.estimatedSectionHeaderHeight = 0;
    _tableView.estimatedSectionFooterHeight = 0;
    _tableView.dataSource = self;
    _tableView.delegate = self;
    [self.view addSubview:_tableView];
    
    [self.tableView registerNib:[UINib nibWithNibName:@"BGCouponManagerListCell" bundle:nil] forCellReuseIdentifier:@"BGCouponManagerListCell"];
    
    UIButton *couponBtn = [UIButton buttonWithType:(UIButtonTypeCustom)];
    couponBtn.frame = CGRectMake((SCREEN_WIDTH-250)*0.5, SCREEN_HEIGHT-SafeAreaTopHeight-SafeAreaBottomHeight-10-41, 250, 41);
    
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
        [weakSelf loadData];
        [weakSelf.tableView.mj_header endRefreshing];
    }];
    
    
}

-(void)loadData {
    
    NSMutableDictionary *param = [NSMutableDictionary dictionary];
    [param setObject:@"10" forKey:@"business_id"];
    
    [ProgressHUDHelper showLoading];
    __block typeof(self) weakSelf = self;
    [BGMemberApi getUseCouponList:param succ:^(NSDictionary *response) {
        DLog(@"\n>>>[getUseCouponList sucess]:%@",response);
        [self hideNodateView];
        self.cellDataArr = [BGCouponModel mj_objectArrayWithKeyValuesArray:response[@"result"]];
        
        if (weakSelf.cellDataArr.count>0) {
            [weakSelf.noneView removeFromSuperview];
        }
        [weakSelf.tableView reloadData];
    } failure:^(NSDictionary *response) {
        DLog(@"\n>>>[getUseCouponList failure]:%@",response);
        [self shownoNetWorkViewWithType:0];
        [self setRefreshBlock:^{
            [weakSelf loadData];
        }];
    }];
    
}
#pragma mark  -  TableViewDelegate  -
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return _cellDataArr.count==0 ? 1: _cellDataArr.count;
}
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return _cellDataArr.count==0 ? 0:1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    BGCouponManagerListCell *cell = [tableView dequeueReusableCellWithIdentifier:@"BGCouponManagerListCell" forIndexPath:indexPath];
    
    if ([Tool arrayIsNotEmpty:_cellDataArr]) {
        BGCouponModel *model = _cellDataArr[indexPath.section];
        [cell updataSelectCouponWithArray:model];
    }
    
    return cell;
}
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
     BGCouponModel *model = _cellDataArr[indexPath.section];
    if (_goodsPriceStr.doubleValue < model.limit_amount.doubleValue) {
        [WHIndicatorView toast:@"该优惠券不符合使用规则"];
    }else{
    if (self.callBackCouponBlock) {
        self.callBackCouponBlock(model.denomination, model.coupon_id);
        [self.navigationController popViewControllerAnimated:YES];
    }
    }
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return (SCREEN_WIDTH-41)*0.35+24;
}
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    if (_cellDataArr.count == 0) {
        return 0.01;
    }else{
        return section == 0? 55:0.01;
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
    if (_cellDataArr.count != 0 &&section == 0) {
        return self.headerView;
    }else{
        return nil;
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
