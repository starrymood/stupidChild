//
//  BGOrderDetailViewController.m
//  shzTravelC
//
//  Created by 孙林茂 on 2018/5/11.
//  Copyright © 2018年 biao. All rights reserved.
//

#import "BGOrderDetailViewController.h"
#import "BGOrderWaitTipCell.h"
#import "BGOrderExpressCell.h"
#import "BGOrderAddressCell.h"
#import "BGOrderShopInfoCell.h"
#import "BGOrderInfoCell.h"
#import "BGOrderPayInfoCell.h"
#import "JCAlertController.h"
#import "BGOrderShopApi.h"
#import "BGWebViewController.h"
#import "BGPostCommentListViewController.h"
#import "BGApplyAfterSaleViewController.h"
#import "BGAfterSaleDetailViewController.h"
#import "BGPayDefaultView.h"
#import <AlipaySDK/AlipaySDK.h>
#import "WXApi.h"
#import "BGWalletOrderPayResultViewController.h"
#import "BGOrderListModel.h"

#define payViewHeight 404
@interface BGOrderDetailViewController ()<UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) JCAlertController *alert;
@property (nonatomic,strong) NSMutableDictionary *cellDataDic;
@property (nonatomic, strong) UIButton *firstBtn;
@property (nonatomic, strong) UIButton *sureBtn;
@property (nonatomic) int isPayType;   // 1：待付款；2：待发货；3：待收货；5：已完成；6：已关闭；7：售后
@property (nonatomic, strong) UIView *bottomView;
@property (nonatomic, copy) NSString *payBalanceStr;
@property (nonatomic, strong) UIView *backView;
@property(nonatomic,strong) BGPayDefaultView *payView;
@property(nonatomic,copy) NSString *payMoneyStr;

@end

@implementation BGOrderDetailViewController
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
-(NSMutableDictionary *)cellDataDic{
    if (!_cellDataDic) {
        self.cellDataDic = [[NSMutableDictionary alloc] init];
    }
    return _cellDataDic;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self loadSubViews];
    [self refreshView];
}
#pragma mark - 加载数据  -
- (void)loadData {
    
    NSMutableDictionary *param = [NSMutableDictionary dictionary];
    [param setObject:_order_number forKey:@"order_number"];
    
    [ProgressHUDHelper showLoading];
    __block typeof(self) weakSelf = self;
    [BGOrderShopApi getOrderDetail:param succ:^(NSDictionary *response) {
                DLog(@"\n>>>[getOrderDetail sucess]:%@",response);
        [self hideNodateView];
        [weakSelf.cellDataDic removeAllObjects];
        weakSelf.cellDataDic = [NSMutableDictionary dictionaryWithDictionary:BGdictSetObjectIsNil(response[@"result"])];
        if (weakSelf.cellDataDic != nil) {
            NSString *statusStr = [NSString stringWithFormat:@"%@",BGdictSetObjectIsNil(weakSelf.cellDataDic[@"status"])];
            weakSelf.isPayType = statusStr.intValue;
            [weakSelf.bottomView setHidden:NO];
            [weakSelf bottomBtnSetTitle];
        }
        [weakSelf.tableView reloadData];
    } failure:^(NSDictionary *response) {
        DLog(@"\n>>>[getOrderDetail failure]:%@",response);
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
        [weakSelf loadData];
        [weakSelf.tableView.mj_header endRefreshing];
    }];
    
    [self loadData];
}
-(void)loadSubViews {
    
    self.navigationItem.title = @"订单详情";
    self.view.backgroundColor = kAppBgColor;
    _isPayType = 2;
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(alipaySuccessAction:) name:@"AlipaySuccessNotification" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(weChatSuccessAction:) name:@"WeChatSuccessNotification" object:nil];
    [self setTableViewLayout];
    [self setbottomViewLayout];
}
-(void)setTableViewLayout{
    
    self.tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, SafeAreaTopHeight, SCREEN_WIDTH, SCREEN_HEIGHT-SafeAreaTopHeight) style:(UITableViewStyleGrouped)];
    _tableView.backgroundColor = kAppBgColor;
    _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    _tableView.estimatedRowHeight = 137;
    _tableView.rowHeight = UITableViewAutomaticDimension;
    
    _tableView.dataSource = self;
    _tableView.delegate = self;
    [self.view addSubview:_tableView];
    
    [self.tableView registerNib:[UINib nibWithNibName:@"BGOrderWaitTipCell" bundle:nil] forCellReuseIdentifier:@"BGOrderWaitTipCell"];
    [self.tableView registerNib:[UINib nibWithNibName:@"BGOrderExpressCell" bundle:nil] forCellReuseIdentifier:@"BGOrderExpressCell"];
    [self.tableView registerNib:[UINib nibWithNibName:@"BGOrderAddressCell" bundle:nil] forCellReuseIdentifier:@"BGOrderAddressCell"];
    [self.tableView registerNib:[UINib nibWithNibName:@"BGOrderShopInfoCell" bundle:nil] forCellReuseIdentifier:@"BGOrderShopInfoCell"];
    [self.tableView registerNib:[UINib nibWithNibName:@"BGOrderInfoCell" bundle:nil] forCellReuseIdentifier:@"BGOrderInfoCell"];
    [self.tableView registerNib:[UINib nibWithNibName:@"BGOrderPayInfoCell" bundle:nil] forCellReuseIdentifier:@"BGOrderPayInfoCell"];
}
-(void)setbottomViewLayout{
    
    self.bottomView = UIView.new;
    _bottomView.backgroundColor = kAppWhiteColor;
    _bottomView.frame = CGRectMake(0, SCREEN_HEIGHT-SafeAreaBottomHeight-49, SCREEN_WIDTH, 49+SafeAreaBottomHeight);
    [_bottomView setHidden:YES];
    [self.view addSubview:_bottomView];
    
    UIView *lineView = UIView.new;
    lineView.backgroundColor = kAppLineBGColor;
    lineView.frame = CGRectMake(0, 0, SCREEN_WIDTH, 1);
    [_bottomView addSubview:lineView];
    
    self.firstBtn = [UIButton buttonWithType:(UIButtonTypeCustom)];
    _firstBtn.frame = CGRectMake(SCREEN_WIDTH -90*2-15-10, 7, 90, 35);
    _firstBtn.clipsToBounds = YES;
    _firstBtn.layer.cornerRadius = 5;
    _firstBtn.layer.borderColor = kAppMainColor.CGColor;
    _firstBtn.layer.borderWidth = 1;
    [_firstBtn.titleLabel setFont:kFont(15)];
    [_firstBtn setTitleColor:kAppMainColor forState:0];
    [_bottomView addSubview:_firstBtn];
    
    self.sureBtn = [UIButton buttonWithType:(UIButtonTypeCustom)];
    _sureBtn.frame = CGRectMake(SCREEN_WIDTH -90-15, 7, 90, 35);
    _sureBtn.clipsToBounds = YES;
    _sureBtn.layer.cornerRadius = 5;
    _sureBtn.layer.borderColor = kAppMainColor.CGColor;
    _sureBtn.layer.borderWidth = 1;
    [_sureBtn.titleLabel setFont:kFont(15)];
    [_sureBtn setTitleColor:kAppMainColor forState:0];
    [_bottomView addSubview:_sureBtn];
    
    @weakify(self);
    [[_firstBtn rac_signalForControlEvents:(UIControlEventTouchUpInside)] subscribeNext:^(__kindof UIControl * _Nullable x) {
        @strongify(self);
        // 点击button的响应事件
        [self btnFirstBtnClickedAction];
    }];
    [[_sureBtn rac_signalForControlEvents:(UIControlEventTouchUpInside)] subscribeNext:^(__kindof UIControl * _Nullable x) {
        @strongify(self);
        // 点击button的响应事件
        [self btnSureBtnClickedAction];
    }];
}
#pragma mark - TableView
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 5;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    
    return  1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    switch (indexPath.section) {
        case 0:{
            if (_isPayType == 1 || _isPayType == 6) {
                BGOrderWaitTipCell *cell = [tableView dequeueReusableCellWithIdentifier:@"BGOrderWaitTipCell" forIndexPath:indexPath];
                __weak __typeof(self) weakSelf = self;
                cell.timeOverClicked = ^{
                    [weakSelf.firstBtn removeFromSuperview];
                    [weakSelf.sureBtn removeFromSuperview];
                    [weakSelf.bottomView removeFromSuperview];
                };
                if (_cellDataDic != nil) {
                    if (_isPayType == 1) {
                        NSString *now_timeStr = BGdictSetObjectIsNil(_cellDataDic[@"now_time"]);
                        NSString *last_timeStr = BGdictSetObjectIsNil(_cellDataDic[@"end_time"]);
                        NSInteger timeDifference = last_timeStr.integerValue - now_timeStr.integerValue;
                        [cell updataWithCellArray:timeDifference];
                        if (timeDifference<1) {
                            [self.bottomView setHidden:YES];
                        }
                    }else{
                        [cell updataWithCellArray:999999];
                    }
                    
                }
                
                return cell;
            }else{
                BGOrderExpressCell *cell = [tableView dequeueReusableCellWithIdentifier:@"BGOrderExpressCell" forIndexPath:indexPath];
                if (_cellDataDic != nil) {
                    [cell updataWithCellArray:BGdictSetObjectIsNil(_cellDataDic[@"shipInfo"]) PayType:_isPayType];
                }
                return cell;
                
            }
            
        }
            break;
        case 1:{
            BGOrderAddressCell *cell = [tableView dequeueReusableCellWithIdentifier:@"BGOrderAddressCell" forIndexPath:indexPath];
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            cell.userInteractionEnabled = NO;
            [cell updataWithCellArray:_cellDataDic isHiddenColorLine:YES];
            return cell;
        }
            break;
        case 2:{
            BGOrderShopInfoCell *cell = [tableView dequeueReusableCellWithIdentifier:@"BGOrderShopInfoCell" forIndexPath:indexPath];
            if (_cellDataDic != nil) {
                [cell updataWithCellArray:BGdictSetObjectIsNil(_cellDataDic[@"goods_list"]) orderStatus:_isPayType];
                __weak __typeof(self) weakSelf = self;
                cell.afterSaleBtnClick = ^(NSString *itemId, NSString *num) { // 申请售后
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
                        applyVC.order_number = BGdictSetObjectIsNil(weakSelf.cellDataDic[@"order_number"]);
                        applyVC.creatTime = BGdictSetObjectIsNil(weakSelf.cellDataDic[@"create_time"]);
                        applyVC.maxNum = numStr.integerValue;
                        applyVC.isDetail = YES;
                        [weakSelf.navigationController pushViewController:applyVC animated:YES];
                    }else{
                        BGAfterSaleDetailViewController *detailVC = BGAfterSaleDetailViewController.new;
                        detailVC.itemId = itemId;
                        [weakSelf.navigationController pushViewController:detailVC animated:YES];
                    }
                    
                };
            }
            return cell;
        }
            break;
        case 3:{
            BGOrderInfoCell *cell = [tableView dequeueReusableCellWithIdentifier:@"BGOrderInfoCell" forIndexPath:indexPath];
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            cell.userInteractionEnabled = NO;
            if (_cellDataDic != nil) {
                if (_isPayType == 1) {
                    _payBalanceStr = [NSString stringWithFormat:@"¥ %.2f",[BGdictSetObjectIsNil(_cellDataDic[@"need_pay_money"]) doubleValue]];
                }
                [cell updataWithCellArray:_cellDataDic isPay:NO];
            }
            return cell;
        }
            break;
        case 4:{
            BGOrderPayInfoCell *cell = [tableView dequeueReusableCellWithIdentifier:@"BGOrderPayInfoCell" forIndexPath:indexPath];
            if (_cellDataDic != nil) {
                [cell updataWithCellArray:_cellDataDic PayType:_isPayType];
            }
            return cell;
        }
            break;
            
        default:{
            return UITableViewCell.new;
        }
            
            break;
    }
    
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 0.01;
}
-(CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section{
    return section == 4? 70+SafeAreaBottomHeight:10;
}
- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    return nil;
}
- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section{
    return nil;
}
-(void)bottomBtnSetTitle{
    
    switch (_isPayType) {
        case 1:{
            [_firstBtn setTitle:@"取消订单" forState:(UIControlStateNormal)];
            [_sureBtn setTitle:@"确认付款" forState:(UIControlStateNormal)];
        }
            break;
        case 2:{
            [_firstBtn removeFromSuperview];
            [_sureBtn setTitle:@"提醒发货" forState:(UIControlStateNormal)];
        }
            break;
        case 3:{
            [_firstBtn removeFromSuperview];
            [_sureBtn setTitle:@"确认收货" forState:(UIControlStateNormal)];
        }
            break;
        case 5:{
            [_firstBtn removeFromSuperview];
            if (_cellDataDic != nil) {
                int commentedNum = [BGdictSetObjectIsNil(_cellDataDic[@"commented"]) intValue];
                if (commentedNum == 0) {
                    [_sureBtn setTitle:@"评价订单" forState:(UIControlStateNormal)];
                }else{
                    [_sureBtn removeFromSuperview];
                    [_bottomView removeFromSuperview];
                }
            }
            
        }
            break;
        case 6:{
            [_firstBtn removeFromSuperview];
            [_sureBtn removeFromSuperview];
            [_bottomView removeFromSuperview];
        }
            break;
        case 7:{
            [_firstBtn removeFromSuperview];
            [_sureBtn removeFromSuperview];
            [_bottomView removeFromSuperview];
        }
            break;
        case 8:{
            [_firstBtn removeFromSuperview];
            [_sureBtn removeFromSuperview];
            [_bottomView removeFromSuperview];
        }
            break;
            
        default:{
            [_firstBtn removeFromSuperview];
            [_sureBtn removeFromSuperview];
            [_bottomView removeFromSuperview];
        }
            break;
    }
}
-(void)btnFirstBtnClickedAction{
    switch (_isPayType) {
        case 1:{
            self.alert = [JCAlertController alertWithTitle:@"提示" message:@"确定要取消订单吗?"];
            [self.alert addButtonWithTitle:@"取消" type:JCButtonTypeCancel clicked:^{
            }];
            __weak __typeof(self) weakSelf = self;
            [self.alert addButtonWithTitle:@"确定" type:JCButtonTypeNormal clicked:^{
                weakSelf.firstBtn.enabled = NO;
                [ProgressHUDHelper showLoading];
                NSMutableDictionary *param = [NSMutableDictionary dictionary];
                [param setObject:weakSelf.order_number forKey:@"order_number"];
                [param setObject:@"" forKey:@"reason"];
                [BGOrderShopApi cancelOrder:param succ:^(NSDictionary *response) {
                    DLog(@"\n>>>[cancelOrder sucess]:%@",response);
                    weakSelf.firstBtn.enabled = YES;
                    [weakSelf loadData];
                } failure:^(NSDictionary *response) {
                    DLog(@"\n>>>[cancelOrder failure]:%@",response);
                    weakSelf.firstBtn.enabled = YES;
                }];
            }];
            [self presentViewController:_alert animated:YES completion:nil];
        }
            break;
        case 3:{  // 查看物流
            BGWebViewController *webVC = BGWebViewController.new;
            webVC.url = [NSString stringWithFormat:@"%@%@%@",BGWebMainHtml,@"order_logistics.html?orderid=",BGdictSetObjectIsNil(_cellDataDic[@"order_number"])];
            [self.navigationController pushViewController:webVC animated:YES];
        }
            break;
        default:
            break;
    }
}
-(void)btnSureBtnClickedAction{
    switch (_isPayType) {
        case 1:{
            if (_cellDataDic != nil) {
                [ProgressHUDHelper showLoading];
                NSMutableDictionary *param = [[NSMutableDictionary alloc] init];
                [param setObject:_order_number forKey:@"order_number"];
                __weak __typeof(self) weakSelf = self;
                [BGOrderShopApi getOrderPayDetail:param succ:^(NSDictionary *response) {
                    DLog(@"\n>>>[getOrderPayDetail success]:%@",response);
                    BGOrderListModel *cModel = [[BGOrderListModel alloc] init];
                    cModel.payment_deadline = BGdictSetObjectIsNil(response[@"result"][@"end_time"]);
                    cModel.paymemnt_start_time = BGdictSetObjectIsNil(response[@"result"][@"now_time"]);
                    cModel.order_number = weakSelf.order_number;
                    cModel.pay_amount = BGdictSetObjectIsNil(response[@"result"][@"pay_money"]);
                    [weakSelf showPayViewActionWithData:cModel];
                    weakSelf.payMoneyStr = cModel.pay_amount;
                } failure:^(NSDictionary *response) {
                    DLog(@"\n>>>[getOrderPayDetail failure]:%@",response);
                }];

            }
        }
            break;
        case 2:{    // 提醒发货
            self.alert = [JCAlertController alertWithTitle:@"提示" message:@"确定提醒发货"];
            
            [self.alert addButtonWithTitle:@"取消" type:JCButtonTypeCancel clicked:^{
                
            }];
            __weak __typeof(self) weakSelf = self;
            [self.alert addButtonWithTitle:@"确定" type:JCButtonTypeNormal clicked:^{
                [ProgressHUDHelper showLoading];
                NSMutableDictionary *param = [NSMutableDictionary dictionary];
                [param setObject:weakSelf.order_number forKey:@"order_number"];
                [BGOrderShopApi remindDelivery:param succ:^(NSDictionary *response) {
                    DLog(@"\n>>>[remindDelivery sucess]:%@",response);
                    [WHIndicatorView toast:response[@"msg"]];
                    [weakSelf loadData];
                } failure:^(NSDictionary *response) {
                    DLog(@"\n>>>[remindDelivery failure]:%@",response);
                }];
            }];
            [self presentViewController:_alert animated:YES completion:nil];
            
        }
            break;
        case 3:{   // 确认收货
            self.alert = [JCAlertController alertWithTitle:@"提示" message:@"确定已收到货物"];
            
            [self.alert addButtonWithTitle:@"取消" type:JCButtonTypeCancel clicked:^{
                
            }];
            __weak __typeof(self) weakSelf = self;
            [self.alert addButtonWithTitle:@"确定" type:JCButtonTypeNormal clicked:^{
                [ProgressHUDHelper showLoading];
                NSMutableDictionary *param = [NSMutableDictionary dictionary];
                [param setObject:weakSelf.order_number forKey:@"order_number"];
                [BGOrderShopApi confirmReceived:param succ:^(NSDictionary *response) {
                    DLog(@"\n>>>[confirmReceived sucess]:%@",response);
                    [WHIndicatorView toast:response[@"msg"]];
                    [weakSelf loadData];
                } failure:^(NSDictionary *response) {
                    DLog(@"\n>>>[confirmReceived failure]:%@",response);
                }];
            }];
            [self presentViewController:_alert animated:YES completion:nil];
            
        }
            break;
        case 5:{   // 评价订单
            BGPostCommentListViewController *postVC = BGPostCommentListViewController.new;
            postVC.order_number = _order_number;
            postVC.orderItems = [NSArray arrayWithArray:BGdictSetObjectIsNil(_cellDataDic[@"goods_list"])];
            __weak __typeof(self) weakSelf = self;
            postVC.postBtnClicked = ^{
                [weakSelf loadData];
            };
            [self.navigationController pushViewController:postVC animated:YES];
        }
            break;
            
        default:
            break;
    }
    
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

    NSMutableDictionary *addressDic = [[NSMutableDictionary alloc] init];
    [addressDic setObject:BGdictSetObjectIsNil(_cellDataDic[@"ship_name"]) forKey:@"ship_name"];
    [addressDic setObject:BGdictSetObjectIsNil(_cellDataDic[@"ship_nship_mobileame"]) forKey:@"ship_mobile"];
    [addressDic setObject:BGdictSetObjectIsNil(_cellDataDic[@"shipping_area"]) forKey:@"shipping_area"];
    [addressDic setObject:BGdictSetObjectIsNil(_cellDataDic[@"ship_addr"]) forKey:@"ship_addr"];
    
    payResultVC.addressDic = addressDic;
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
