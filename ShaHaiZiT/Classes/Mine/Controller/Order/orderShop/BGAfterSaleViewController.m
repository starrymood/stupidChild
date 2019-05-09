//
//  BGAfterSaleViewController.m
//  shzTravelC
//
//  Created by 孙林茂 on 2018/5/9.
//  Copyright © 2018年 biao. All rights reserved.
//

#import "BGAfterSaleViewController.h"
#import "BGOrderDetailCell.h"
#import "BGOrderDetailViewController.h"
#import "BGOrderShopApi.h"
#import "BGOrderModel.h"
#import "JCAlertController.h"
#import "BGAfterSaleDetailViewController.h"
#import "BGApplyAfterSaleViewController.h"

#define BtnHeight (6+45+6+40)
@interface BGAfterSaleViewController ()<UITableViewDataSource,UITableViewDelegate>

@property (nonatomic, strong) UITableView *tableView;

@property (nonatomic,strong) NSMutableArray *cellDataArr;

@property (nonatomic, copy) NSString *pageNum;

@property (nonatomic, strong) UIView *noneView;

@property (nonatomic, strong) JCAlertController *alert;

@end

@implementation BGAfterSaleViewController
-(UIView *)noneView {
    if (!_noneView) {
        self.noneView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT-SafeAreaTopHeight)];
        _noneView.backgroundColor = kAppBgColor;
        [_noneView setHidden:YES];
        UIImageView *noneImgView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"no_order"]];
        noneImgView.frame = CGRectMake(SCREEN_WIDTH*0.4, 60, SCREEN_WIDTH*0.2, SCREEN_WIDTH*0.2*1.059);
        [_noneView addSubview:noneImgView];
        
        UILabel *showMsgLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, noneImgView.frame.origin.y+noneImgView.frame.size.height+50, SCREEN_WIDTH-20, 20)];
        showMsgLabel.textAlignment = NSTextAlignmentCenter;
        [showMsgLabel setTextColor:kAppTipBGColor];
        showMsgLabel.font = kFont(14);
        showMsgLabel.text = noOrderMessage;
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
    _pageNum = @"1";
    [self refreshView];
}
#pragma mark - 加载数据  -
- (void)loadData {
    
    NSMutableDictionary *param = [NSMutableDictionary dictionary];
    [param setObject:@"7" forKey:@"status"];
    [param setObject:_pageNum forKey:@"pageno"];
    [param setObject:@"10" forKey:@"pagesize"];
    
    [ProgressHUDHelper showLoading];
    
    __block typeof(self) weakSelf = self;
    [BGOrderShopApi getOrderList:param succ:^(NSDictionary *response) {
                DLog(@"\n>>>[getOrderList sucess]:%@",response);
        [weakSelf hideNodateView];
        if (weakSelf.pageNum.intValue == 1) {
            [weakSelf.cellDataArr removeAllObjects];
            [weakSelf.tableView.mj_footer resetNoMoreData];
        }
        NSMutableArray *tempArr = [BGOrderModel mj_objectArrayWithKeyValuesArray:response[@"result"][@"rows"]];
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
        DLog(@"\n>>>[getOrderList failure]:%@",response);
        [self shownoNetWorkViewWithType:0];
        [self setRefreshBlock:^{
            [weakSelf loadData];
        }];
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
    
    [self loadData];
}
-(void)loadSubViews {
    
    self.view.backgroundColor = kAppBgColor;
    self.tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT-SafeAreaTopHeight-BtnHeight) style:(UITableViewStyleGrouped)];
    _tableView.backgroundColor = kAppBgColor;
    _tableView.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
    _tableView.separatorColor = kAppLineBGColor;
    _tableView.estimatedRowHeight = SCREEN_HEIGHT;
    _tableView.rowHeight = UITableViewAutomaticDimension;
    _tableView.dataSource = self;
    _tableView.delegate = self;
    [self.view addSubview:_tableView];
    
    [self.tableView registerNib:[UINib nibWithNibName:@"BGOrderDetailCell" bundle:nil] forCellReuseIdentifier:@"BGOrderDetailCell"];
    
    
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
    BGOrderDetailCell *cell = [tableView dequeueReusableCellWithIdentifier:@"BGOrderDetailCell" forIndexPath:indexPath];
    if (![Tool arrayIsNotEmpty:_cellDataArr]) {
        return UITableViewCell.new;
    }
    BGOrderModel *model = _cellDataArr[indexPath.section];
    [cell updataWithCellArray:model];
    __weak __typeof(self) weakSelf = self;
    cell.didSelectRowClicked = ^{
        BGOrderDetailViewController *detailVC = BGOrderDetailViewController.new;
        detailVC.order_number = model.order_number;
        [weakSelf.navigationController pushViewController:detailVC animated:YES];
    };
    cell.afterSaleBtnClick = ^(NSString *itemId, NSString *num) { // 售后详情
        NSArray *strArr = [num componentsSeparatedByString:@":"];
        NSString *numStr = @"1";
        NSString *titleStr = @"申请售后";
        if (strArr.count>1) {
            numStr = strArr[0];
            titleStr = strArr[1];
        }
        if ([titleStr isEqualToString:@"申请售后"]) {
            BGApplyAfterSaleViewController *applyVC = BGApplyAfterSaleViewController.new;
            applyVC.itemId = itemId;
            applyVC.order_number = model.order_number;
            applyVC.creatTime = model.create_time;
            applyVC.maxNum = numStr.integerValue;
            [weakSelf.navigationController pushViewController:applyVC animated:YES];
        }else{
            BGAfterSaleDetailViewController *detailVC = BGAfterSaleDetailViewController.new;
            detailVC.itemId = itemId;
            [weakSelf.navigationController pushViewController:detailVC animated:YES];
        }
        
    };
    return cell;
}
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    BGOrderModel *model = _cellDataArr[indexPath.section];
    BGOrderDetailViewController *detailVC = BGOrderDetailViewController.new;
    detailVC.order_number = model.order_number;
    [self.navigationController pushViewController:detailVC animated:YES];
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    if (_cellDataArr.count == 0) {
        return 0.01;
    }else{
        return 10;
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
