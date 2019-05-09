//
//  BGDayCarOrderPayViewController.m
//  shzTravelC
//
//  Created by biao on 2018/8/23.
//  Copyright © 2018年 biao. All rights reserved.
//

#import "BGDayCarOrderPayViewController.h"
#import <UIImageView+WebCache.h>
#import "BGOrderTravelApi.h"
#import "BGAirPayInfoModel.h"
#import "BGSelectCouponViewController.h"
#import <JCAlertController.h>
#import "BGPayDefaultView.h"
#import <AlipaySDK/AlipaySDK.h>
#import "WXApi.h"
#import "BGWalletOrderPayResultViewController.h"
#import "BGSelectCouponViewController.h"

#define payViewHeight 404
@interface BGDayCarOrderPayViewController ()
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *contentCenterY;
@property (weak, nonatomic) IBOutlet UIImageView *carImgView;
@property (weak, nonatomic) IBOutlet UILabel *carNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *peopleNumLabel;
@property (weak, nonatomic) IBOutlet UILabel *carPriceLabel;
@property (weak, nonatomic) IBOutlet UIView *serviceView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *serviceViewHeight;
@property (weak, nonatomic) IBOutlet UIButton *unsubscribeBtn;
@property (weak, nonatomic) IBOutlet UILabel *unsubscribeLabel;
@property (weak, nonatomic) IBOutlet UILabel *travelDateLabel;
@property (weak, nonatomic) IBOutlet UITextField *startPlaceTextField;
@property (weak, nonatomic) IBOutlet UITextField *endPlaceTextField;
@property (weak, nonatomic) IBOutlet UITextField *adultNumTextField;
@property (weak, nonatomic) IBOutlet UITextField *childNumTextField;
@property (weak, nonatomic) IBOutlet UITextField *packageNumTextField;
@property (weak, nonatomic) IBOutlet UITextField *personNameTextField;
@property (weak, nonatomic) IBOutlet UITextField *personPhoneTextField;
@property (weak, nonatomic) IBOutlet UITextView *noteTextView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *noteViewHeight;
@property (weak, nonatomic) IBOutlet UILabel *orderPriceLabel;
@property (weak, nonatomic) IBOutlet UILabel *orderNumLabel;
@property (weak, nonatomic) IBOutlet UILabel *orderTotalPriceLabel;
@property (weak, nonatomic) IBOutlet UIView *orderCouponView;
@property (weak, nonatomic) IBOutlet UILabel *orderCouponLabel;
@property (weak, nonatomic) IBOutlet UIButton *selectCouponBtn;
@property (nonatomic, copy) NSString *bonus_idStr;
@property (nonatomic, strong) UIView *bottomView;
@property (nonatomic, strong) UILabel *payPriceLabel;
@property (nonatomic, strong) UIButton *payBtn;
@property (nonatomic, strong) UIView *backView;
@property(nonatomic,strong) BGPayDefaultView *payView;
@property(nonatomic,copy) NSString *payMoneyStr;

@end

@implementation BGDayCarOrderPayViewController
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
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self loadSubViews];
    [self loadData];
}
-(void)loadSubViews{
    self.navigationItem.title = @"支付订单";
    self.view.backgroundColor = kAppBgColor;
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(alipaySuccessAction:) name:@"AlipaySuccessNotification" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(weChatSuccessAction:) name:@"WeChatSuccessNotification" object:nil];
    [self setbottomViewLayout];
    [self changeViewFrame];
}
-(void)setbottomViewLayout{
    
    self.bottomView = UIView.new;
    _bottomView.backgroundColor = kAppWhiteColor;
    _bottomView.frame = CGRectMake(0, SCREEN_HEIGHT-SafeAreaBottomHeight-52, SCREEN_WIDTH, 52+SafeAreaBottomHeight);
    [_bottomView setHidden:YES];
    [self.view addSubview:_bottomView];
    
    UILabel *sLab = UILabel.new;
    sLab.frame = CGRectMake(23, 20, 70, 13);
    sLab.font = kFont(13);
    sLab.textColor = kApp333Color;
    sLab.text = @"实际支付：";
    [_bottomView addSubview:sLab];
    
    self.payPriceLabel = UILabel.new;
    _payPriceLabel.frame = CGRectMake(17+70, 19, SCREEN_WIDTH-17-70-179, 15);
    _payPriceLabel.textAlignment = NSTextAlignmentLeft;
    _payPriceLabel.font = [UIFont boldSystemFontOfSize:18];
    _payPriceLabel.textColor = UIColorFromRGB(0xFF5656);
    _payPriceLabel.text = @"¥0.00";
    [_bottomView addSubview:_payPriceLabel];
    
    self.payBtn = [UIButton buttonWithType:(UIButtonTypeCustom)];
    _payBtn.frame = CGRectMake(SCREEN_WIDTH-179, 0, 179, 52);
    [_payBtn.titleLabel setFont:[UIFont boldSystemFontOfSize:16]];
    [_payBtn setTitle:@"确认支付" forState:(UIControlStateNormal)];
    [_payBtn setTitleColor:kAppWhiteColor forState:(UIControlStateNormal)];
    [_payBtn setBackgroundColor:UIColorFromRGB(0xFF5656)];
    [_bottomView addSubview:_payBtn];
}
-(void)loadData{
    [ProgressHUDHelper showLoading];
    NSMutableDictionary *param = [[NSMutableDictionary alloc] init];
    [param setObject:_order_number forKey:@"order_number"];
    __weak __typeof(self) weakSelf = self;
    [BGOrderTravelApi getRequirementInfoById:param succ:^(NSDictionary *response) {
        DLog(@"\n>>>[getRequirementInfoById sucess]:%@",response);
        [weakSelf hideNodateView];
        BGAirPayInfoModel *model = [BGAirPayInfoModel mj_objectWithKeyValues:BGdictSetObjectIsNil(response[@"result"])];
        [weakSelf updateSubViewsWithModel:model];
    } failure:^(NSDictionary *response) {
        DLog(@"\n>>>[getRequirementInfoById failure]:%@",response);
        [ProgressHUDHelper removeLoading];
        [self shownoNetWorkViewWithType:0];
        [self setRefreshBlock:^{
            [weakSelf loadData];
        }];
    }];
    
}
-(void)updateSubViewsWithModel:(BGAirPayInfoModel *)model{
    _adultNumTextField.text = model.audit_number;
    _childNumTextField.text = model.children_number;
    _packageNumTextField.text = model.baggage_number;
    _startPlaceTextField.text = model.departure;
    _endPlaceTextField.text = model.destination;
    if ([Tool arrayIsNotEmpty:model.car_pictures]) {
        [self.carImgView sd_setImageWithURL:[NSURL URLWithString:model.car_pictures[0]]];
//        self.carImgView.contentMode = UIViewContentModeScaleAspectFit;
    }
    self.carNameLabel.text = model.model_name;
    self.peopleNumLabel.text = [NSString stringWithFormat:@"%@人%@行李",model.passenger_number,model.baggage_number];
    self.carPriceLabel.text = [NSString stringWithFormat:@"¥%.2f", model.model_price.doubleValue];
    self.unsubscribeLabel.text = model.unsubscribe_title;
    self.orderCouponLabel.text = [NSString stringWithFormat:@"%@ 张优惠券",model.coupon_number];
    self.serviceViewHeight.constant =39+model.service_configuration.count/3*(39+24);
    
    for (int i = 0; i<model.service_configuration.count; i++) {
        UILabel *lab = UILabel.new;
        CGFloat spaceWidth = SCREEN_WIDTH*0.072;
        CGFloat btnWidth = (SCREEN_WIDTH-spaceWidth*4)/3.0;
        lab.frame = CGRectMake(spaceWidth+i%3*(90+spaceWidth), i/3*(39+24), btnWidth, 39);
        lab.textColor = kApp999Color;
        lab.backgroundColor = UIColorFromRGB(0xEEEEEE);
        lab.clipsToBounds = YES;
        lab.layer.cornerRadius = lab.height*0.5;
        lab.font = kFont(14);
        lab.textAlignment = NSTextAlignmentCenter;
        NSString *nameStr = [NSString stringWithFormat:@"%@",[model.service_configuration[i] objectForKey:@"name"]];
        lab.text = nameStr;
        NSString *isShowStr = [NSString stringWithFormat:@"%@",[model.service_configuration[i] objectForKey:@"is_show"]];
        if(isShowStr.intValue == 1){
            lab.textColor = kAppMainColor;
            lab.font = [UIFont boldSystemFontOfSize:14];
            lab.backgroundColor = kAppWhiteColor;
        }
        [self.serviceView addSubview:lab];
    }
    
    
    _travelDateLabel.text = _duringDateStr;
    _personNameTextField.text = model.contact;
    _personPhoneTextField.text = model.contact_number;
    self.orderPriceLabel.text = [NSString stringWithFormat:@"¥%.2f", model.model_price.doubleValue];
    self.orderTotalPriceLabel.text = [NSString stringWithFormat:@"¥%.2f", model.product_price.doubleValue];
    self.payPriceLabel.text = [NSString stringWithFormat:@"¥%.2f", model.product_price.doubleValue];
    self.orderNumLabel.text = [NSString stringWithFormat:@"x%@", model.member_play_days];
    
    if ([Tool isBlankString:model.remark]) {
        model.remark = @"无特殊说明";
    }
    self.noteTextView.text = model.remark;
    
    self.noteViewHeight.constant = [self heightForString:self.noteTextView andWidth:SCREEN_WIDTH-17*2]+12;
    
    [self changeViewFrame];
    
    [self.bottomView setHidden:NO];
    
    @weakify(self);
    [[self.unsubscribeBtn rac_signalForControlEvents:(UIControlEventTouchUpInside)] subscribeNext:^(__kindof UIControl * _Nullable x) {
        @strongify(self);
        // 点击button的响应事件
        CGFloat width = [JCAlertStyle shareStyle].alertView.width;
        UIWebView *webView = [[UIWebView alloc] initWithFrame:CGRectMake(0, 0, width, SCREEN_HEIGHT*0.6)];
        webView.backgroundColor = kAppWhiteColor;
        [webView loadHTMLString:[Tool attributeByWeb:model.unsubscribe_content width:width scale:width*0.96] baseURL:nil];
        JCAlertController *alert = [JCAlertController alertWithTitle:@"退订政策" contentView:webView];
        JCAlertStyle *style = [JCAlertStyle shareStyle];
        style.background.canDismiss = YES;
        [alert addButtonWithTitle:@"确定" type:JCButtonTypeNormal clicked:^{
            
        }];
        [self presentViewController:alert animated:YES completion:nil];
    }];
    [[self.selectCouponBtn rac_signalForControlEvents:(UIControlEventTouchUpInside)] subscribeNext:^(__kindof UIControl * _Nullable x) {
        @strongify(self);
        // 点击button的响应事件
        BGSelectCouponViewController *couponVC = BGSelectCouponViewController.new;
        couponVC.couponType = 3;
        couponVC.goodsPriceStr = model.product_price;
        [self.navigationController pushViewController:couponVC animated:YES];
        __weak __typeof(self) weakSelf = self;
        couponVC.callBackCouponBlock = ^(NSString *amountStr, NSString *couponIdStr) {
            weakSelf.bonus_idStr = couponIdStr;
            weakSelf.orderCouponLabel.text = [NSString stringWithFormat:@" ¥-%.2f",[amountStr doubleValue]];
            CGFloat totalPrice = model.product_price.doubleValue - amountStr.doubleValue;
            weakSelf.payPriceLabel.text = [NSString stringWithFormat:@"¥%.2f", totalPrice];
        };
    }];
    [[self.payBtn rac_signalForControlEvents:(UIControlEventTouchUpInside)] subscribeNext:^(__kindof UIControl * _Nullable x) {
        @strongify(self);
        // 点击button的响应事件
        [self payActionWithModel:model btn:x];
    }];
    
}
-(void)payActionWithModel:(BGAirPayInfoModel *)model btn:(UIButton *)sender{
    [ProgressHUDHelper showLoading];
    
    NSMutableDictionary *param = [[NSMutableDictionary alloc] init];
    [param setObject:_order_number forKey:@"order_number"];
    if (![Tool isBlankString:_bonus_idStr]) {
        [param setObject:_bonus_idStr forKey:@"coupon_id"];
        //        [param setObject:@"0" forKey:@"integral"];
    }
    sender.userInteractionEnabled = NO;
    __weak __typeof(self) weakSelf = self;
    [BGOrderTravelApi createOrderByProductId:param succ:^(NSDictionary *response) {
        DLog(@"\n>>>[createOrderByProductId success]:%@",response);
        [weakSelf showPayViewActionWithData:BGdictSetObjectIsNil(response[@"result"])];
        self.payMoneyStr = [NSString stringWithFormat:@"%@",BGdictSetObjectIsNil(response[@"result"][@"pay_amount"])];
    } failure:^(NSDictionary *response) {
        DLog(@"\n>>>[createOrderByProductId failure]:%@",response);
        sender.userInteractionEnabled = YES;
    }];
}
-(void)changeViewFrame{
    self.contentCenterY.constant = (_orderCouponView.y+_orderCouponView.height-SCREEN_HEIGHT+SafeAreaTopHeight+SafeAreaBottomHeight+self.serviceViewHeight.constant+self.noteViewHeight.constant+55+6-100-100)*0.5;
    [UIView animateWithDuration:.2 animations:^{
        [self.view layoutIfNeeded];
    }];
}
- (float)heightForString:(UITextView *)textView andWidth:(float)width{
    CGSize sizeToFit = [textView sizeThatFits:CGSizeMake(width, MAXFLOAT)];
    return sizeToFit.height;
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
    
    [BGOrderTravelApi payTravelOrder:param succ:^(NSDictionary *response) {
        DLog(@"\n>>>[payTravelOrder sucess]:%@",response);
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
        DLog(@"\n>>>[rechargePay failure]:%@",response);
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
    payResultVC.isNew = YES;
    payResultVC.order_num = _order_number;
    payResultVC.payBalanceStr = [NSString stringWithFormat:@"¥ %@",_payMoneyStr];
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
