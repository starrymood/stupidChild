//
//  BGPendingPaymentViewController.m
//  shzTravelC
//
//  Created by 孙林茂 on 2018/5/9.
//  Copyright © 2018年 biao. All rights reserved.
//

#import "BGPendingPaymentViewController.h"
#import "BGOrderDetailCell.h"
#import "BGOrderDetailViewController.h"
#import "BGOrderShopApi.h"
#import "BGOrderModel.h"
#import "JCAlertController.h"
#import "BGPayDefaultView.h"
#import <AlipaySDK/AlipaySDK.h>
#import "WXApi.h"
#import "BGWalletOrderPayResultViewController.h"
#import "BGOrderListModel.h"

#define BtnHeight (6+45+6+40)
#define payViewHeight 404
@interface BGPendingPaymentViewController ()<UITableViewDataSource,UITableViewDelegate>

@property (nonatomic, strong) UITableView *tableView;

@property (nonatomic,strong) NSMutableArray *cellDataArr;

@property (nonatomic, copy) NSString *pageNum;

@property (nonatomic, strong) UIView *noneView;

@property (nonatomic, strong) JCAlertController *alert;

@property (nonatomic, strong) UIView *backView;
@property(nonatomic,strong) BGPayDefaultView *payView;
@property(nonatomic,copy) NSString *payMoneyStr;
@property(nonatomic,copy) NSString *order_number;


@end

@implementation BGPendingPaymentViewController
-(UIView *)backView{
    if (!_backView) {
        self.backView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT)];
        _backView.backgroundColor = [UIColor clearColor];
    }
    return _backView;
}
-(void)showPayViewActionWithData:(BGOrderListModel *)model{
    
    BGPayDefaultView *payView = [[BGPayDefaultView alloc] initWithFrame:CGRectMake(0, SCREEN_HEIGHT, SCREEN_WIDTH, payViewHeight) dataModel:model];
    self.payView = payView;
    [[[UIApplication sharedApplication] keyWindow] addSubview:self.backView];
    [[[UIApplication sharedApplication] keyWindow] addSubview:payView];
    __weak __typeof(self) weakSelf = self;
    [UIView transitionWithView:payView duration:0.2 options:0 animations:^{
        weakSelf.backView.backgroundColor = [UIColor colorWithWhite:0 alpha:0.4];
        payView.y = SCREEN_HEIGHT-SafeAreaBottomHeight-payViewHeight;
        
    } completion:^(BOOL finished) {
        
    }];
    
    @weakify(self);
    [[payView.payCancelBtn rac_signalForControlEvents:(UIControlEventTouchUpInside)] subscribeNext:^(__kindof UIControl * _Nullable x) {
        @strongify(self);
        // 点击button的响应事件
        [self cancelPayViewActionWithPop:NO];
    }];
    
    
    payView.sureBtnClick = ^(NSString * _Nonnull payType) {
        [self judgePayActionWithWay:payType];
    };
}
-(void)cancelPayViewActionWithPop:(BOOL)isPop{
    __weak __typeof(self) weakSelf = self;
    [UIView transitionWithView:self.backView duration:0.2 options:0 animations:^{
        weakSelf.backView.backgroundColor = [UIColor clearColor];
        weakSelf.payView.y = SCREEN_HEIGHT;
        
    } completion:^(BOOL finished) {
        [weakSelf.payView removeFromSuperview];
        weakSelf.payView = nil;
        [weakSelf.backView removeFromSuperview];
        weakSelf.backView = nil;
        if (isPop) {
            [weakSelf.navigationController popViewControllerAnimated:YES];
        }
    }];
}
-(void)dealloc{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"WeChatSuccessNotification" object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"AlipaySuccessNotification" object:nil];
}

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
    [param setObject:@"1" forKey:@"status"];
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
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(alipaySuccessAction:) name:@"AlipaySuccessNotification" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(weChatSuccessAction:) name:@"WeChatSuccessNotification" object:nil];
    self.order_number = @"";
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
    cell.firstBtnClicked = ^{ // 取消订单
        self.alert = [JCAlertController alertWithTitle:@"提示" message:@"确定要取消订单吗?"];
        
        [weakSelf.alert addButtonWithTitle:@"取消" type:JCButtonTypeCancel clicked:^{
            
        }];
        [weakSelf.alert addButtonWithTitle:@"确定" type:JCButtonTypeNormal clicked:^{
            [ProgressHUDHelper showLoading];
            NSMutableDictionary *param = [NSMutableDictionary dictionary];
            [param setObject:model.order_number forKey:@"order_number"];
            [param setObject:@"" forKey:@"reason"];
            [BGOrderShopApi cancelOrder:param succ:^(NSDictionary *response) {
                DLog(@"\n>>>[cancelOrder sucess]:%@",response);
                [weakSelf loadData];
            } failure:^(NSDictionary *response) {
                DLog(@"\n>>>[cancelOrder failure]:%@",response);
            }];
        }];
        [self presentViewController:weakSelf.alert animated:YES completion:nil];
        
    };
    cell.sureBtnClicked = ^{  // 确认付款
        [ProgressHUDHelper showLoading];
        NSMutableDictionary *param = [[NSMutableDictionary alloc] init];
        [param setObject:model.order_number forKey:@"order_number"];
        __weak __typeof(self) weakSelf = self;
        [BGOrderShopApi getOrderPayDetail:param succ:^(NSDictionary *response) {
            DLog(@"\n>>>[getOrderPayDetail success]:%@",response);
            BGOrderListModel *cModel = [[BGOrderListModel alloc] init];
            cModel.payment_deadline = BGdictSetObjectIsNil(response[@"result"][@"end_time"]);
            cModel.paymemnt_start_time = BGdictSetObjectIsNil(response[@"result"][@"now_time"]);
            cModel.order_number = model.order_number;
            cModel.pay_amount = BGdictSetObjectIsNil(response[@"result"][@"pay_money"]);
            [weakSelf showPayViewActionWithData:cModel];
            weakSelf.payMoneyStr = cModel.pay_amount;
            weakSelf.order_number = model.order_number;
        } failure:^(NSDictionary *response) {
            DLog(@"\n>>>[getOrderPayDetail failure]:%@",response);
        }];
        
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
-(void)judgePayActionWithWay:(NSString *)payWayStr{
    if ([payWayStr isEqualToString:@"weixin"]) {
        if (![WXApi isWXAppInstalled]) {
            [WHIndicatorView toast:@"您还没有安装微信"];
            return;
        }else if (![WXApi isWXAppSupportApi]){
            [WHIndicatorView toast:@"不支持微信支付"];
            return;
        }
    }
    self.payView.userInteractionEnabled = NO;
    [ProgressHUDHelper showLoading];
    NSMutableDictionary *param = [[NSMutableDictionary alloc] init];
    [param setObject:_order_number forKey:@"order_number"];
    
    [param setObject:payWayStr forKey:@"pay_type"];
    
    [BGOrderShopApi payShopOrder:param succ:^(NSDictionary *response) {
        DLog(@"\n>>>[payShopOrder sucess]:%@",response);
        self.payView.userInteractionEnabled = YES;
        [self cancelPayViewActionWithPop:NO];
        if ([payWayStr isEqualToString:@"alipay"]) {
            [self alipayActionWithData:response[@"result"]];
        }else if ([payWayStr isEqualToString:@"qianbao"]){
            //  余额支付成功
            [self jumpToPayResultWithStatus:YES];
        }else{
            [self weChatPayActionWithData:response[@"result"]];
        }
    } failure:^(NSDictionary *response) {
        DLog(@"\n>>>[payShopOrder failure]:%@",response);
        self.payView.userInteractionEnabled = YES;
        
    }];
}
/**
 支付宝充值
 */
-(void)alipayActionWithData:(NSDictionary *)dataDic {
    
    NSString *signStr = dataDic[@"order_form"];
    [[AlipaySDK defaultService] payOrder:signStr fromScheme:ALIPAY_URLSCHEME callback:^(NSDictionary *resultDic){
        
        NSString *codeStr = [resultDic objectForKey:@"resultStatus"];
        if (codeStr.intValue == 9000) {
            
            [WHIndicatorView toast:@"支付成功"];
            [self jumpToPayResultWithStatus:YES];
            
        }else if (codeStr.integerValue == 6002){
            [WHIndicatorView toast:@"网络繁忙,请稍后再试!"];
            
        }else{
            [WHIndicatorView toast:@"支付失败,请稍后再试!"];
        }
    }];
    
    
}
/**
 微信充值
 */
-(void)weChatPayActionWithData:(NSDictionary *)dataDic {
    
    PayReq *request = [[PayReq alloc] init];
    request.partnerId = dataDic[@"partnerid"];
    request.prepayId = dataDic[@"prepayid"];
    request.package = dataDic[@"package"];
    request.nonceStr = dataDic[@"noncestr"];
    request.timeStamp = [NSString stringWithFormat:@"%@",dataDic[@"timestamp"]].intValue;
    request.sign = dataDic[@"sign"];
    [WXApi sendReq: request];
    
}
#pragma mark - Notification

-(void)alipaySuccessAction:(NSNotification *)no{
    NSString *status = [no object];
    if ([status isEqualToString:@"paySucess"]) {
        [self jumpToPayResultWithStatus:YES];
    }else if ([status isEqualToString:@"payFail"]){
        [self jumpToPayResultWithStatus:NO];
    }
    
}

-(void)weChatSuccessAction:(NSNotification *)no{
    NSString *status = [no object];
    if ([status isEqualToString:@"paySucess"]) {
        [self jumpToPayResultWithStatus:YES];
    }else if ([status isEqualToString:@"payFail"]){
        [self jumpToPayResultWithStatus:NO];
    }
    
}
-(void)jumpToPayResultWithStatus:(BOOL)isSuccess{
    
    BGWalletOrderPayResultViewController *payResultVC = BGWalletOrderPayResultViewController.new;
    payResultVC.isPaySuccess = isSuccess;
    payResultVC.isShop = 333;
//    payResultVC.addressDic = _addressDic;
    payResultVC.isNew = YES;
    payResultVC.order_num = _order_number;
    payResultVC.payBalanceStr = [NSString stringWithFormat:@"¥%.2f",_payMoneyStr.doubleValue];
    [self.navigationController pushViewController:payResultVC animated:YES];
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
