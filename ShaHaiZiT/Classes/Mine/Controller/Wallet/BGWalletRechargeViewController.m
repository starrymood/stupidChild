//
//  BGWalletRechargeViewController.m
//  ShaHaiZiT
//
//  Created by biao on 2018/11/27.
//  Copyright © 2018 biao. All rights reserved.
//

#import "BGWalletRechargeViewController.h"
#import "BGPayNewView.h"
#import "BGPayWayView.h"
#import <AlipaySDK/AlipaySDK.h>
#import "WXApi.h"
#import "BGWalletPayResultViewController.h"
#import "BGPurseApi.h"

#define payViewHeight 404
#define myDotNumbers     @"0123456789.\n"
#define myNumbers          @"0123456789\n"
@interface BGWalletRechargeViewController ()<UITextFieldDelegate>
@property (weak, nonatomic) IBOutlet UITextField *moneyTextField;
@property (nonatomic, strong) BGPayNewView *payView;
@property (nonatomic, strong) UIView *backView;
@property(nonatomic,strong) BGPayWayView *payWayView;
@property(nonatomic,copy) NSString *payWayStr;

@end
@implementation BGWalletRechargeViewController
-(UIView *)backView{
    if (!_backView) {
        self.backView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT)];
        _backView.backgroundColor = [UIColor clearColor];
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTapGesture)];
        [_backView addGestureRecognizer:tap];
    }
    return _backView;
}
-(BGPayNewView *)payView{
    if (!_payView) {
        self.payView = [[BGPayNewView alloc] initWithFrame:CGRectMake(0, SCREEN_HEIGHT, SCREEN_WIDTH, payViewHeight)];
    }
    return _payView;
}
-(BGPayWayView *)payWayView{
    if (!_payWayView) {
        self.payWayView = [[BGPayWayView alloc] initWithFrame:CGRectMake(0, SCREEN_HEIGHT, SCREEN_WIDTH, payViewHeight)];
    }
    return _payWayView;
}
-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [self.moneyTextField becomeFirstResponder];
}
-(void)dealloc{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"WeChatSuccessNotification" object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"AlipaySuccessNotification" object:nil];
}
- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationItem.title = @"账户充值";
    self.view.backgroundColor = kAppBgColor;
    self.payWayStr = @"alipay";
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(alipaySuccessAction:) name:@"AlipaySuccessNotification" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(weChatSuccessAction:) name:@"WeChatSuccessNotification" object:nil];
}
- (IBAction)btnNextStepClicked:(UIButton *)sender {
    [self keyboarkHidden];
    if (_moneyTextField.text.doubleValue < 0.01) {
        [WHIndicatorView toast:@"请输入充值金额"];
        return;
    }
    [self showPayViewAction];
}
/**
 显示支付View
 */
-(void)showPayViewAction{
    [[[UIApplication sharedApplication] keyWindow] addSubview:self.backView];
    [[[UIApplication sharedApplication] keyWindow] addSubview:self.payView];
        if ([self.payWayStr isEqualToString:@"alipay"]) {
            self.payView.payTypeLabel.text = @"支付宝";
        }else{
            self.payView.payTypeLabel.text = @"微信";
        }
        __weak __typeof(self) weakSelf = self;
    @weakify(self);
    [[self.payView.payCancelBtn rac_signalForControlEvents:(UIControlEventTouchUpInside)] subscribeNext:^(__kindof UIControl * _Nullable x) {
        @strongify(self);
        // 点击button的响应事件
        [self handleTapGesture];
    }];
    [[self.payView.paySelectBtn rac_signalForControlEvents:(UIControlEventTouchUpInside)] subscribeNext:^(__kindof UIControl * _Nullable x) {
        @strongify(self);
        // 点击button的响应事件
        [self showPayWayAction];
    }];
    [[self.payView.payPayBtn rac_signalForControlEvents:(UIControlEventTouchUpInside)] subscribeNext:^(__kindof UIControl * _Nullable x) {
        @strongify(self);
        // 点击button的响应事件
        [self judgePayAction];
    }];
            
    
        [UIView transitionWithView:self.payView duration:0.2 options:0 animations:^{
            weakSelf.backView.backgroundColor = [UIColor colorWithWhite:0 alpha:0.4];
            self.payView.y = SCREEN_HEIGHT-SafeAreaBottomHeight-payViewHeight;
            
        } completion:^(BOOL finished) {
            
        }];
    
}
-(void)judgePayAction{
    if ([self.payWayStr isEqualToString:@"weixin"]) {
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
    [param setObject:[NSString stringWithFormat:@"%.2f",self.moneyTextField.text.doubleValue] forKey:@"money"];
    [param setObject:_payWayStr forKey:@"pay_type"];
    DLog(@"param:%@",param);
    [BGPurseApi rechargePay:param succ:^(NSDictionary *response) {
        DLog(@"\n>>>[rechargePay sucess]:%@",response);
        self.payView.userInteractionEnabled = YES;
        [self handleTapGesture];
        if ([self.payWayStr isEqualToString:@"alipay"]) {
            [self alipayActionWithData:response[@"result"]];
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
    
    BGWalletPayResultViewController *payResultVC = BGWalletPayResultViewController.new;
    payResultVC.isPaySuccess = isSuccess;
    [self.navigationController pushViewController:payResultVC animated:YES];
}
/**
 显示支付方式View
 */
-(void)showPayWayAction{
    [[[UIApplication sharedApplication] keyWindow] addSubview:self.payWayView];
    if ([self.payWayStr isEqualToString:@"alipay"]) {
        [self.payWayView.alipayImg setImage:BGImage(@"address_address_selection")];
        [self.payWayView.weChatImg setImage:BGImage(@"address_address_default")];
    }else{
        [self.payWayView.alipayImg setImage:BGImage(@"address_address_default")];
        [self.payWayView.weChatImg setImage:BGImage(@"address_address_selection")];
    }
    @weakify(self);
    [[self.payWayView.payTypeCancelBtn rac_signalForControlEvents:(UIControlEventTouchUpInside)] subscribeNext:^(__kindof UIControl * _Nullable x) {
        @strongify(self);
        // 点击button的响应事件
        [self removePayWayAction];
    }];
    [[self.payWayView.alipayBtn rac_signalForControlEvents:(UIControlEventTouchUpInside)] subscribeNext:^(__kindof UIControl * _Nullable x) {
        @strongify(self);
        self.payWayView.userInteractionEnabled = NO;
        if ([self.payWayStr isEqualToString:@"weixin"]) {
            [self.payWayView.alipayImg setImage:BGImage(@"address_address_selection")];
            [self.payWayView.weChatImg setImage:BGImage(@"address_address_default")];
            self.payView.payTypeLabel.text = @"支付宝";
            self.payWayStr = @"alipay";
        }
       
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.4 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [self removePayWayAction];
            
        });
    }];
    
    [[self.payWayView.weChatBtn rac_signalForControlEvents:(UIControlEventTouchUpInside)] subscribeNext:^(__kindof UIControl * _Nullable x) {
        @strongify(self);
        // 点击button的响应事件
        self.payWayView.userInteractionEnabled = NO;
        if ([self.payWayStr isEqualToString:@"alipay"]) {
            [self.payWayView.alipayImg setImage:BGImage(@"address_address_default")];
            [self.payWayView.weChatImg setImage:BGImage(@"address_address_selection")];
            self.payView.payTypeLabel.text = @"微信";
            self.payWayStr = @"weixin";
        }
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.4 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [self removePayWayAction];
            
        });
    }];
    
    
    __weak __typeof(self) weakSelf = self;
    [UIView transitionWithView:self.payView duration:0.2 options:0 animations:^{
        weakSelf.payWayView.y = SCREEN_HEIGHT-SafeAreaBottomHeight-payViewHeight;
        
    } completion:^(BOOL finished) {
        
    }];
    
}
-(void)removePayWayAction{
    __weak __typeof(self) weakSelf = self;
    [UIView transitionWithView:self.payWayView duration:0.2 options:0 animations:^{
        weakSelf.payWayView.y = SCREEN_HEIGHT;
    } completion:^(BOOL finished) {
        [weakSelf.payWayView removeFromSuperview];
        weakSelf.payWayView = nil;
        
    }];
}
/**
 点击灰色背景 取消View
 */
-(void)handleTapGesture{
    __weak __typeof(self) weakSelf = self;
    [UIView transitionWithView:self.backView duration:0.2 options:0 animations:^{
        weakSelf.backView.backgroundColor = [UIColor clearColor];
        self.payView.y = SCREEN_HEIGHT;
        self.payWayView.y = SCREEN_HEIGHT;
        
    } completion:^(BOOL finished) {
        [weakSelf.payView removeFromSuperview];
        weakSelf.payView = nil;
        [weakSelf.backView removeFromSuperview];
        weakSelf.backView = nil;
        [weakSelf.payWayView removeFromSuperview];
        weakSelf.payWayView = nil;
    }];
    
}
#pragma mark  --  TextFieldDelegate  --
- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    
    // 判断是否输入内容，或者用户点击的是键盘的删除按钮
    if (![string isEqualToString:@""]) {
        NSCharacterSet *cs;
        // 小数点在字符串中的位置 第一个数字从0位置开始
        
        NSInteger dotLocation = [textField.text rangeOfString:@"."].location;
        
        // 判断字符串中是否有小数点，并且小数点不在第一位
        
        // NSNotFound 表示请求操作的某个内容或者item没有发现，或者不存在
        
        // range.location 表示的是当前输入的内容在整个字符串中的位置，位置编号从0开始
        
        if (dotLocation == NSNotFound && range.location != 0) {
            
            // 取只包含“myDotNumbers”中包含的内容，其余内容都被去掉
            
            /* [NSCharacterSet characterSetWithCharactersInString:myDotNumbers]的作用是去掉"myDotNumbers"中包含的所有内容，只要字符串中有内容与"myDotNumbers"中的部分内容相同都会被舍去在上述方法的末尾加上invertedSet就会使作用颠倒，只取与“myDotNumbers”中内容相同的字符
             */
            cs = [[NSCharacterSet characterSetWithCharactersInString:myDotNumbers] invertedSet];
            if (range.location >= 7) {
                [WHIndicatorView toast:@"单笔金额已超过最大限制"];
                if ([string isEqualToString:@"."] && range.location == 7) {
                    return YES;
                }
                return NO;
            }
        }else {
            
            cs = [[NSCharacterSet characterSetWithCharactersInString:myNumbers] invertedSet];
            
        }
        // 按cs分离出数组,数组按@""分离出字符串
        
        NSString *filtered = [[string componentsSeparatedByCharactersInSet:cs] componentsJoinedByString:@""];
        
        BOOL basicTest = [string isEqualToString:filtered];
        
        if (!basicTest) {
            
            [WHIndicatorView toast:@"只能输入数字和小数点"];
            
            return NO;
            
        }
        
        if (dotLocation != NSNotFound && range.location > dotLocation + 2) {
            
            [WHIndicatorView toast:@"小数点后最多两位"];
            
            return NO;
        }
        if (textField.text.length > 9) {
            [WHIndicatorView toast:@"单笔金额已超过最大限制"];
            return NO;
            
        }
    }
    return YES;
    
}
- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    
    [textField resignFirstResponder];
    
    return YES;
}

@end
