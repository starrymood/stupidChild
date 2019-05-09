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
        showMsgLabel.text = @"暂无优惠券";
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
    [self refreshView];
}

-(void)loadSubViews {
    
    if (_isCanSelect) {
        self.tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, SafeAreaTopHeight, SCREEN_WIDTH, SCREEN_HEIGHT-SafeAreaTopHeight) style:(UITableViewStyleGrouped)];
    }else{
        self.tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT-SafeAreaTopHeight-BtnHeight) style:(UITableViewStyleGrouped)];
    }
    
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
        [weakSelf.tableView.mj_footer endRefreshing];
    }];
    
    [self loadData];
}
-(void)loadData {
    
    NSMutableDictionary *param = [NSMutableDictionary dictionary];
    [param setObject:@"1" forKey:@"type"];
    [param setObject:_pageNum forKey:@"page"];
    
    //    [ProgressHUDHelper showLoading];
    __block typeof(self) weakSelf = self;
    [BGMemberApi getCouponList:param succ:^(NSDictionary *response) {
        DLog(@"\n>>>[getCouponList sucess]:%@",response);
        [self hideNodateView];
        if (self.pageNum.intValue == 1) {
            [self.cellDataArr removeAllObjects];
        }
        NSMutableArray *tempArr = [BGCouponModel mj_objectArrayWithKeyValuesArray:response[@"data"]];
        [self.cellDataArr addObjectsFromArray:tempArr];
        
        if (tempArr.count<10) {
            [self.tableView.mj_footer endRefreshingWithNoMoreData];
        }else{
            [self.tableView.mj_footer resetNoMoreData];
        }
        if (weakSelf.cellDataArr.count>0) {
            [weakSelf.noneView removeFromSuperview];
        }
        [weakSelf.tableView reloadData];
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
    return _cellDataArr.count==0 ? 1: _cellDataArr.count;
}
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return _cellDataArr.count==0 ? 0:1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    BGCouponManagerListCell *cell = [tableView dequeueReusableCellWithIdentifier:@"BGCouponManagerListCell" forIndexPath:indexPath];
    if (_isCanSelect) {
        cell.userInteractionEnabled = YES;
    }else{
        cell.userInteractionEnabled = NO;
    }
    if ([Tool arrayIsNotEmpty:_cellDataArr]) {
        BGCouponModel *model = _cellDataArr[indexPath.section];
        [cell updataWithCellArray:model codeType:1 goodsPrice:_goodsPriceStr];
    }
    
    return cell;
}
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    if (_isCanSelect) {
         [tableView deselectRowAtIndexPath:indexPath animated:NO];
        
        BGCouponModel *model = _cellDataArr[indexPath.section];
        if (_goodsPriceStr.doubleValue < model.min_goods_amount.doubleValue) {
            [WHIndicatorView toast:@"不满足商品最小使用金额"];
        }else{
            self.callBackCouponBlock(model.type_money, model.type_id);
            [self.navigationController popViewControllerAnimated:YES];
        }
        
    }
  
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 100;
}
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    if (_cellDataArr.count == 0) {
        return 0.01;
    }else{
        return 15;
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
