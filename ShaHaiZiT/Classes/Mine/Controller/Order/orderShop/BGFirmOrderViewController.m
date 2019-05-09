//
//  BGFirmOrderViewController.m
//  shzTravelC
//
//  Created by 孙林茂 on 2018/5/12.
//  Copyright © 2018年 biao. All rights reserved.
//

#import "BGFirmOrderViewController.h"
#import "BGOrderAddressCell.h"
#import "BGOrderShopInfoCell.h"
#import "BGOrderInfoCell.h"
#import "BGOrderPayViewController.h"
#import "BGFirmOrderViewController.h"
#import "BGOrderShopApi.h"
#import "BGReceiveAddressViewController.h"
#import "BGShopApi.h"
#import "BGSystemApi.h"
#import <JCAlertController.h>
#import "BGVerifyNameViewController.h"
#import "BGPayDefaultView.h"
#import <AlipaySDK/AlipaySDK.h>
#import "WXApi.h"
#import "BGWalletOrderPayResultViewController.h"

#define payViewHeight 404
@interface BGFirmOrderViewController ()<UITableViewDelegate, UITableViewDataSource>
@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, copy) NSDictionary *addressDic;
@property (nonatomic, copy) NSDictionary *orderInfoDic;
@property (nonatomic, copy) NSArray *goodsArr;
@property (nonatomic, copy) NSString *addressIdStr;

@property (nonatomic, copy) NSString *goodsPriceStr;
@property (nonatomic, copy) NSString *couponMoneyStr;
@property (nonatomic, copy) NSString *bonus_idStr;

@property (nonatomic, strong) UILabel *totalMoneyLabel;
@property(nonatomic,copy) NSString *nameStr;
@property(nonatomic,copy) NSString *id_cardStr;
@property (nonatomic, strong) UIView *backView;
@property(nonatomic,strong) BGPayDefaultView *payView;
@property(nonatomic,copy) NSString *payMoneyStr;
@property(nonatomic,copy) NSString *order_number;

@end

@implementation BGFirmOrderViewController
-(UIView *)backView{
    if (!_backView) {
        self.backView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT)];
        _backView.backgroundColor = [UIColor clearColor];
    }
    return _backView;
}
-(void)showPayViewActionWithData:(NSDictionary *)dataDic{
    
    BGPayDefaultView *payView = [[BGPayDefaultView alloc] initWithFrame:CGRectMake(0, SCREEN_HEIGHT, SCREEN_WIDTH, payViewHeight) dataDic:dataDic];
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
        [self cancelPayViewActionWithPop:YES];
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
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"AddAddressRefreshNotification" object:nil];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self loadSubViews];
    [self loadVerifyData];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(AddAddressRefreshAction) name:@"AddAddressRefreshNotification" object:nil];
    self.payMoneyStr = @"";
    self.order_number = @"";
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(alipaySuccessAction:) name:@"AlipaySuccessNotification" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(weChatSuccessAction:) name:@"WeChatSuccessNotification" object:nil];
}

-(void)loadVerifyData{
    [ProgressHUDHelper showLoading];
    NSMutableDictionary *param = [[NSMutableDictionary alloc] init];
    __weak __typeof(self) weakSelf = self;
    [BGSystemApi getVerifyInfo:param succ:^(NSDictionary *response) {
        DLog(@"\n>>>[getVerifyInfo sucess]:%@",response);
        [weakSelf hideNodateView];
        [weakSelf loadData];
    } failure:^(NSDictionary *response) {
        DLog(@"\n>>>[getVerifyInfo failure]:%@",response);
        [ProgressHUDHelper removeLoading];
        if ([[NSString stringWithFormat:@"%@",BGdictSetObjectIsNil(response[@"code"])] intValue] != 300) {
            [self shownoNetWorkViewWithType:0];
            [self setRefreshBlock:^{
                [weakSelf loadData];
            }];
        }else{
            JCAlertController *alert = [JCAlertController alertWithTitle:@"实名认证" message:@"根据海关要求，购买跨境商品需要提供订购人身份信息 （请与支付账号实名信息相同）本信息仅用于海关清关， 傻孩子保证信息安全。"];
            __weak __typeof(self) weakSelf = self;
            [alert addButtonWithTitle:@"取消" type:JCButtonTypeCancel clicked:^{
                [weakSelf.navigationController popViewControllerAnimated:YES];
            }];
            [alert addButtonWithTitle:@"去认证" type:JCButtonTypeNormal clicked:^{
               [weakSelf.navigationController popViewControllerAnimated:NO];
                BGVerifyNameViewController *verifyVC = BGVerifyNameViewController.new;
                [weakSelf.preNav pushViewController:verifyVC animated:YES];
            }];
            
            [weakSelf presentViewController:alert animated:YES completion:nil];
        }
    }];
    
}
-(void)loadData {
    [ProgressHUDHelper showLoading];
    NSMutableDictionary *param = [[NSMutableDictionary alloc] init];
    [param setObject:_cartIds forKey:@"cart_ids"];
    __weak __typeof(self) weakSelf = self;
    [BGOrderShopApi firmOrder:param FirmType:YES succ:^(NSDictionary *response) {
        DLog(@"\n>>>[firmOrder success]:%@",response);
        weakSelf.addressDic = [NSDictionary dictionaryWithDictionary:response[@"result"][@"address"]];
        weakSelf.orderInfoDic = [NSDictionary dictionaryWithDictionary:response[@"result"]];
        weakSelf.goodsArr = [NSArray arrayWithArray:response[@"result"][@"goods_list"]];
        weakSelf.addressIdStr = [NSString stringWithFormat:@"%@",BGdictSetObjectIsNil(response[@"result"][@"address"][@"id"])];
        weakSelf.nameStr = [NSString stringWithFormat:@"%@",BGdictSetObjectIsNil(response[@"result"][@"name"])];
        weakSelf.id_cardStr = [NSString stringWithFormat:@"%@",BGdictSetObjectIsNil(response[@"result"][@"id_card"])];
        NSString *totalPriceStr = BGdictSetObjectIsNil(response[@"result"][@"total_account"]);
        NSString *activityStr = BGdictSetObjectIsNil(response[@"result"][@"activity_account"]);
        weakSelf.goodsPriceStr = [NSString stringWithFormat:@"%.2f",(totalPriceStr.doubleValue - activityStr.doubleValue)];
        [weakSelf.tableView reloadData];
    } failure:^(NSDictionary *response) {
        DLog(@"\n>>>[firmOrder failure]:%@",response);
        [weakSelf.navigationController popViewControllerAnimated:YES];
    }];
    
    
}
-(void)loadSubViews {
    
    self.navigationItem.title = @"确认订单";
    self.tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, SafeAreaTopHeight, SCREEN_WIDTH, SCREEN_HEIGHT-SafeAreaBottomHeight-SafeAreaTopHeight-49) style:(UITableViewStyleGrouped)];
    _tableView.backgroundColor = kAppBgColor;
    _tableView.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
    _tableView.separatorColor = kAppLineBGColor;
    _tableView.estimatedRowHeight = 137;
    _tableView.rowHeight = UITableViewAutomaticDimension;
    _tableView.dataSource = self;
    _tableView.delegate = self;
    [self.view addSubview:_tableView];
    
    [self.tableView registerNib:[UINib nibWithNibName:@"BGOrderAddressCell" bundle:nil] forCellReuseIdentifier:@"BGOrderAddressCell"];
    [self.tableView registerNib:[UINib nibWithNibName:@"BGOrderShopInfoCell" bundle:nil] forCellReuseIdentifier:@"BGOrderShopInfoCell"];
    [self.tableView registerNib:[UINib nibWithNibName:@"BGOrderInfoCell" bundle:nil] forCellReuseIdentifier:@"BGOrderInfoCell"];
    
    UIView *bottomView = UIView.new;
    bottomView.backgroundColor = kAppWhiteColor;
    bottomView.frame = CGRectMake(0, SCREEN_HEIGHT-SafeAreaBottomHeight-49, SCREEN_WIDTH, 49);
    [self.view addSubview:bottomView];
    
    UILabel *totalStaticLabel = UILabel.new;
    totalStaticLabel.frame = CGRectMake(16, 18, 45, 14);
    totalStaticLabel.font = kFont(14);
    totalStaticLabel.text = @"合计：";
    totalStaticLabel.textColor = kApp333Color;
    [bottomView addSubview:totalStaticLabel];
    
    self.totalMoneyLabel = UILabel.new;
    _totalMoneyLabel.frame = CGRectMake(16+45, 18, SCREEN_WIDTH-16-100-10-30-45, 14);
    _totalMoneyLabel.font = kFont(15);
    _totalMoneyLabel.text = @"¥ 0.00";
    _totalMoneyLabel.textColor = kAppRedColor;
    [bottomView addSubview:_totalMoneyLabel];
    
    UIButton *uploadOrderBtn = [UIButton buttonWithType:(UIButtonTypeCustom)];
    uploadOrderBtn.frame = CGRectMake(SCREEN_WIDTH-100-15, 6, 100, 37);
    uploadOrderBtn.clipsToBounds = YES;
    uploadOrderBtn.layer.borderWidth = 1;
    uploadOrderBtn.layer.borderColor = kAppMainColor.CGColor;
    uploadOrderBtn.layer.cornerRadius = 5;
    
    [uploadOrderBtn.titleLabel setFont:kFont(16)];
    [uploadOrderBtn setTitle:@"提交订单" forState:(UIControlStateNormal)];
    [uploadOrderBtn setTitleColor:kAppMainColor forState:(UIControlStateNormal)];
    [bottomView addSubview:uploadOrderBtn];
    
    @weakify(self);
    [[uploadOrderBtn rac_signalForControlEvents:(UIControlEventTouchUpInside)] subscribeNext:^(__kindof UIControl * _Nullable x) {
        @strongify(self);

        [self createOrderAction];
    }];
    
}
-(void)createOrderAction {
    
    if ([Tool isBlankString:_addressIdStr]) {
        [WHIndicatorView toast:@"请先选择收货地址"];
        return;
    }
    
    [ProgressHUDHelper showLoading];
    NSMutableDictionary *param = [[NSMutableDictionary alloc] init];
    
    [param setObject:_addressIdStr forKey:@"addressId"];
    [param setObject:@"0" forKey:@"paymentId"];
    [param setObject:_nameStr forKey:@"username"];
    [param setObject:_id_cardStr forKey:@"id_card"];
    __weak __typeof(self) weakSelf = self;
    [BGOrderShopApi createPayOrder:param succ:^(NSDictionary *response) {
        DLog(@"\n>>>[createPayOrder success]:%@",response);
        [[NSNotificationCenter defaultCenter] postNotificationName:@"MyCartRefreshNotification" object:nil];
        [weakSelf showPayViewActionWithData:BGdictSetObjectIsNil(response[@"result"])];
        self.payMoneyStr = [NSString stringWithFormat:@"%@",BGdictSetObjectIsNil(response[@"result"][@"need_pay_money"])];
        self.order_number = [NSString stringWithFormat:@"%@",BGdictSetObjectIsNil(response[@"result"][@"order_number"])];
    } failure:^(NSDictionary *response) {
        DLog(@"\n>>>[createPayOrder failure]:%@",response);
    }];
    
}
#pragma mark - TableView
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 3;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    
    return  1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    switch (indexPath.section) {
        case 0:{
            BGOrderAddressCell *cell = [tableView dequeueReusableCellWithIdentifier:@"BGOrderAddressCell" forIndexPath:indexPath];
            
            [cell updataWithCellArray:self.addressDic isHiddenColorLine:NO];
            return cell;
        }
            break;
        case 1:{
            BGOrderShopInfoCell *cell = [tableView dequeueReusableCellWithIdentifier:@"BGOrderShopInfoCell" forIndexPath:indexPath];
            if (_goodsArr != nil) {
                [cell updataWithCellArray:self.goodsArr orderStatus:1];
            }
            return cell;
        }
            break;
        case 2:{
            BGOrderInfoCell *cell = [tableView dequeueReusableCellWithIdentifier:@"BGOrderInfoCell" forIndexPath:indexPath];
            if (_orderInfoDic != nil) {
                 [cell updataWithCellArray:self.orderInfoDic isPay:YES];
            }
            if (![Tool isBlankString:_couponMoneyStr]) {
                cell.goodsCouponLabel.text = [NSString stringWithFormat:@" ¥ -%.2f",[_couponMoneyStr doubleValue]];
                NSString *freightStr = BGdictSetObjectIsNil(self.orderInfoDic[@"ship_account"]);
                if (self.goodsPriceStr.doubleValue > 0) {
                    CGFloat totalPrice = self.goodsPriceStr.doubleValue + freightStr.doubleValue - _couponMoneyStr.doubleValue;
                    _totalMoneyLabel.text = [NSString stringWithFormat:@"¥ %.2f",totalPrice];
                }
                
            }else{
                if (self.goodsPriceStr.doubleValue > 0) {
                    NSString *freightStr = BGdictSetObjectIsNil(self.orderInfoDic[@"ship_account"]);
                    CGFloat totalPrice = self.goodsPriceStr.doubleValue + freightStr.doubleValue;
                    _totalMoneyLabel.text = [NSString stringWithFormat:@"¥ %.2f",totalPrice];
                }
                
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
   
    __weak __typeof(self) weakSelf = self;
    
    switch (indexPath.section) {
        case 0:{ // 选择地址
            [tableView deselectRowAtIndexPath:indexPath animated:NO];
            BGReceiveAddressViewController *addressVC = BGReceiveAddressViewController.new;
            addressVC.isCanSelect = YES;
            addressVC.refreshEditBlock = ^{
                [weakSelf loadAddressAction];
            };
            [weakSelf.navigationController pushViewController:addressVC animated:YES];
        }
            break;
        case 1:{
            UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
        }
            break;
        case 2:{
            UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
        }
    }
}
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return section== 0 ? 1:10;
}
-(CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section{
    return 0.01;
}
- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    
    return nil;
}
- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section{
    return nil;
}

-(void)loadAddressAction {
    [ProgressHUDHelper showLoading];
    __block typeof(self) weakSelf = self;
    NSMutableDictionary *param = [NSMutableDictionary dictionary];
    [BGShopApi getDefaultAddress:param succ:^(NSDictionary *response) {
        DLog(@"\n>>>[getDefaultAddress success]:%@",response);
        weakSelf.addressDic = response[@"result"];
        weakSelf.addressIdStr = [NSString stringWithFormat:@"%@",BGdictSetObjectIsNil(response[@"result"][@"id"])];
        NSIndexSet *indexSet=[[NSIndexSet alloc]initWithIndex:0];
        [weakSelf.tableView reloadSections:indexSet withRowAnimation:UITableViewRowAnimationAutomatic];
        
    } failure:^(NSDictionary *response) {
        DLog(@"\n>>>[getDefaultAddress failure]:%@",response);
        weakSelf.addressDic = nil;
        weakSelf.addressIdStr = nil;
        NSIndexSet *indexSet = [[NSIndexSet alloc]initWithIndex:0];
        [weakSelf.tableView reloadSections:indexSet withRowAnimation:UITableViewRowAnimationAutomatic];
    }];
    
}
-(void)AddAddressRefreshAction{
    [self loadAddressAction];
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
    payResultVC.addressDic = _addressDic;
    payResultVC.isNew = YES;
    payResultVC.order_num = _order_number;
    payResultVC.payBalanceStr = [NSString stringWithFormat:@"¥ %.2f",_payMoneyStr.doubleValue];
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
