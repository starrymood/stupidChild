//
//  BGOrderCommentViewController.m
//  ShaHaiZiT
//
//  Created by biao on 2018/11/20.
//  Copyright © 2018 biao. All rights reserved.
//

#import "BGOrderCommentViewController.h"
#import "BGOrderTravelApi.h"
#import "BGOrderListModel.h"
#import "BGOrderListCell.h"
#import "BGOrderOneDetailViewController.h"
#import "BGOrderTwoDetailViewController.h"
#import "BGOrderThreeDetailViewController.h"
#import "BGOrderFourDetailViewController.h"
#import "BGOrderFiveDetailViewController.h"
#import "BGOrderSixDetailViewController.h"
#import "BGTPostCommentViewController.h"
#import "BGVisaPostCommentViewController.h"

#define BtnHeight (6+45+6+40)
@interface BGOrderCommentViewController ()<UITableViewDataSource,UITableViewDelegate>

@property (nonatomic, strong) UITableView *tableView;

@property (nonatomic,strong) NSMutableArray *cellDataArr;

@property (nonatomic, copy) NSString *pageNum;

@property (nonatomic, strong) UIView *noneView;

@end

@implementation BGOrderCommentViewController

-(UIView *)noneView {
    if (!_noneView) {
        self.noneView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT-SafeAreaTopHeight)];
        _noneView.backgroundColor = kAppBgColor;
        [_noneView setHidden:YES];
        
        UIView *topView = [[UIView alloc] initWithFrame:CGRectMake(0, 6, SCREEN_WIDTH, 122)];
        topView.backgroundColor = kAppWhiteColor;
        UILabel *tipLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 52, SCREEN_WIDTH, 18)];
        tipLabel.text = @"下单后在这里管理您的行程哟~";
        tipLabel.textAlignment = NSTextAlignmentCenter;
        tipLabel.font = kFont(17);
        tipLabel.textColor = kApp333Color;
        [topView addSubview:tipLabel];
        [_noneView addSubview:topView];
        
        UIImageView *noneImgView = [[UIImageView alloc] initWithImage:BGImage(@"order_placeholder_img")];
        noneImgView.frame = CGRectMake(SCREEN_WIDTH*0.043, topView.y+topView.height+31, SCREEN_WIDTH*0.917, SCREEN_WIDTH*0.504);
        [_noneView addSubview:noneImgView];
        
        UILabel *showMsgLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, noneImgView.frame.origin.y+noneImgView.frame.size.height+37, SCREEN_WIDTH, 17)];
        showMsgLabel.textAlignment = NSTextAlignmentCenter;
        [showMsgLabel setTextColor:kApp333Color];
        showMsgLabel.font = kFont(17);
        showMsgLabel.text = @"赶紧去订制您的第一个行程吧~";
        [_noneView addSubview:showMsgLabel];
        
        UIButton *sureBtn = [UIButton buttonWithType:(UIButtonTypeCustom)];
        sureBtn.frame = CGRectMake(SCREEN_WIDTH*0.256, showMsgLabel.y+showMsgLabel.height+31, SCREEN_WIDTH*0.488, 40);
        sureBtn.clipsToBounds = YES;
        [sureBtn setBackgroundImage:BGImage(@"btn_bgColor") forState:(UIControlStateNormal)];
        sureBtn.layer.cornerRadius = 20;
        [sureBtn.titleLabel setFont:kFont(17)];
        [sureBtn setTitle:@"开启行程" forState:(UIControlStateNormal)];
        [sureBtn setTitleColor:kAppWhiteColor forState:(UIControlStateNormal)];
        [_noneView addSubview:sureBtn];
        @weakify(self);
        [[sureBtn rac_signalForControlEvents:(UIControlEventTouchUpInside)] subscribeNext:^(__kindof UIControl * _Nullable x) {
            @strongify(self);
            // 点击button的响应事件
            [self.navigationController popToRootViewControllerAnimated:NO];
            [[NSNotificationCenter defaultCenter] postNotificationName:@"SELECTINDEXHOME" object:nil];
        }];
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
    [param setObject:@"2" forKey:@"order_status"];
    [param setObject:_pageNum forKey:@"pageno"];
    [param setObject:@"10" forKey:@"pagesize"];
    
    [ProgressHUDHelper showLoading];
    
    __block typeof(self) weakSelf = self;
    [BGOrderTravelApi getOrderList:param succ:^(NSDictionary *response) {
        DLog(@"\n>>>[getOrderList sucess]:%@",response);
        [weakSelf hideNodateView];
        if (weakSelf.pageNum.intValue == 1) {
            [weakSelf.cellDataArr removeAllObjects];
            [weakSelf.tableView.mj_footer resetNoMoreData];
        }
        NSMutableArray *tempArr = [BGOrderListModel mj_objectArrayWithKeyValuesArray:response[@"result"][@"rows"]];
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
    _tableView.estimatedRowHeight = 0;
    _tableView.estimatedSectionHeaderHeight = 0;
    _tableView.estimatedSectionFooterHeight = 0;
    _tableView.dataSource = self;
    _tableView.delegate = self;
    [self.view addSubview:_tableView];
    
    [self.tableView registerNib:[UINib nibWithNibName:@"BGOrderListCell" bundle:nil] forCellReuseIdentifier:@"BGOrderListCell"];
    
    
}

#pragma mark  -  TableViewDelegate  -
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    self.tableView.mj_footer.hidden = self.cellDataArr.count == 0;
    return _cellDataArr.count==0 ? 1: _cellDataArr.count;
}
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return _cellDataArr.count==0 ? 0:1;
}
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 251;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    BGOrderListCell *cell = [tableView dequeueReusableCellWithIdentifier:@"BGOrderListCell" forIndexPath:indexPath];
    if (![Tool arrayIsNotEmpty:_cellDataArr]) {
        return UITableViewCell.new;
    }
    BGOrderListModel *model = _cellDataArr[indexPath.section];
    [cell updataWithCellArray:model];
    
    __weak __typeof(self) weakSelf = self;
    
    cell.firstBtnClicked = ^{  // 评价订单
        if (model.product_set_cd.intValue == 6) {
            BGVisaPostCommentViewController *postVC = BGVisaPostCommentViewController.new;
            postVC.order_number = model.order_number;
            [weakSelf.navigationController pushViewController:postVC animated:YES];
        }else{
            BGTPostCommentViewController *postVC = BGTPostCommentViewController.new;
            postVC.order_number = model.order_number;
            postVC.main_picture = model.main_picture;
            postVC.titleeStr = model.product_name;
            [weakSelf.navigationController pushViewController:postVC animated:YES];
        }
    };
    
    return cell;
}
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
    BGOrderListModel *model = _cellDataArr[indexPath.section];
    
    switch (model.product_set_cd.intValue) {
        case 1:{
            BGOrderOneDetailViewController *detailVC = BGOrderOneDetailViewController.new;
            detailVC.order_number = model.order_number;
            detailVC.main_picture = model.main_picture;
            detailVC.product_name = model.product_name;
            [self.navigationController pushViewController:detailVC animated:YES];
        }
            break;
        case 2:{
            BGOrderTwoDetailViewController *detailVC = BGOrderTwoDetailViewController.new;
            detailVC.order_number = model.order_number;
            detailVC.main_picture = model.main_picture;
            detailVC.product_name = model.product_name;
            [self.navigationController pushViewController:detailVC animated:YES];
        }
            break;
        case 3:{
            BGOrderThreeDetailViewController *detailVC = BGOrderThreeDetailViewController.new;
            detailVC.order_number = model.order_number;
            detailVC.main_picture = model.main_picture;
            detailVC.product_name = model.product_name;
            [self.navigationController pushViewController:detailVC animated:YES];
        }
            break;
        case 4:{
            BGOrderFourDetailViewController *detailVC = BGOrderFourDetailViewController.new;
            detailVC.order_number = model.order_number;
            detailVC.main_picture = model.main_picture;
            detailVC.product_name = model.product_name;
            [self.navigationController pushViewController:detailVC animated:YES];
        }
            break;
        case 5:{
            BGOrderFiveDetailViewController *detailVC = BGOrderFiveDetailViewController.new;
            detailVC.order_number = model.order_number;
            detailVC.main_picture = model.main_picture;
            detailVC.product_name = model.product_name;
            [self.navigationController pushViewController:detailVC animated:YES];
        }
            break;
        case 6:{
            BGOrderSixDetailViewController *detailVC = BGOrderSixDetailViewController.new;
            detailVC.order_number = model.order_number;
            [self.navigationController pushViewController:detailVC animated:YES];
        }
            break;
        default:
            break;
    }
    
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    if (_cellDataArr.count == 0) {
        return 0.01;
    }else{
        return 6;
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

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
