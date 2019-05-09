//
//  BGOrderFourDetailViewController.m
//  ShaHaiZiT
//
//  Created by biao on 2018/11/29.
//  Copyright © 2018 biao. All rights reserved.
//

#import "BGOrderFourDetailViewController.h"
#import "BGOrderTravelApi.h"
#import "BGPayDefaultView.h"
#import <AlipaySDK/AlipaySDK.h>
#import "WXApi.h"
#import "BGWalletOrderPayResultViewController.h"
#import "BGChatViewController.h"
#import <JCAlertController.h>
#import "BGTPostCommentViewController.h"
#import "BGOrderDetailModel.h"
#import "BGCommunityApi.h"

#define payViewHeight 404
@interface BGOrderFourDetailViewController ()
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *contentCenterY;
@property (weak, nonatomic) IBOutlet UILabel *orderNumLabel;
@property (weak, nonatomic) IBOutlet UILabel *titleeLabel;
@property (weak, nonatomic) IBOutlet UILabel *dateLabel;
@property (weak, nonatomic) IBOutlet UILabel *personNumLabel;
@property (weak, nonatomic) IBOutlet UILabel *packageNumLabel;
@property (weak, nonatomic) IBOutlet UITextView *noteTextView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *noteViewHeight;
@property (weak, nonatomic) IBOutlet UILabel *orderPriceLabel;
@property (weak, nonatomic) IBOutlet UILabel *orderCouponLabel;
@property (weak, nonatomic) IBOutlet UILabel *orderRealPayLabel;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *priceViewTopHeight;
@property (weak, nonatomic) IBOutlet UIView *guideView;
@property (weak, nonatomic) IBOutlet UILabel *guideNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *guideCarNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *guideNumLabel;
@property (weak, nonatomic) IBOutlet UIButton *guideConcernBtn;

@property (weak, nonatomic) IBOutlet UIButton *zeroBtn;
@property (weak, nonatomic) IBOutlet UIButton *oneBtn;
@property (weak, nonatomic) IBOutlet UIButton *twoBtn;
@property(nonatomic,strong) BGChatViewController *conversationVC;

@property (nonatomic, strong) UIView *backView;
@property(nonatomic,strong) BGPayDefaultView *payView;
@property(nonatomic,copy) NSString *payMoneyStr;
@end

@implementation BGOrderFourDetailViewController

-(BGChatViewController *)conversationVC{
    if (!_conversationVC) {
        self.conversationVC = [[BGChatViewController alloc] init];
    }
    return _conversationVC;
}
-(UIView *)backView{
    if (!_backView) {
        self.backView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT)];
        _backView.backgroundColor = [UIColor clearColor];
    }
    return _backView;
}
-(void)showPayViewActionWithData:(BGOrderDetailModel *)model{
    
    BGPayDefaultView *payView = [[BGPayDefaultView alloc] initWithFrame:CGRectMake(0, SCREEN_HEIGHT, SCREEN_WIDTH, payViewHeight) dataSModel:model];
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
- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self loadSubViews];
    [self loadData];
}
-(void)loadSubViews{
    self.navigationItem.title = @"精品线路";
    self.view.backgroundColor = kAppBgColor;
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(alipaySuccessAction:) name:@"AlipaySuccessNotification" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(weChatSuccessAction:) name:@"WeChatSuccessNotification" object:nil];
    [self changeViewFrame];
}

-(void)loadData{
    [ProgressHUDHelper showLoading];
    NSMutableDictionary *param = [[NSMutableDictionary alloc] init];
    [param setObject:_order_number forKey:@"order_number"];
    __weak __typeof(self) weakSelf = self;
    [BGOrderTravelApi getOrderDetail:param succ:^(NSDictionary *response) {
        DLog(@"\n>>>[getOrderDetail sucess]:%@",response);
        [weakSelf hideNodateView];
        BGOrderDetailModel *model = [BGOrderDetailModel mj_objectWithKeyValues:BGdictSetObjectIsNil(response[@"result"])];
        [weakSelf updateSubViewsWithModel:model];
    } failure:^(NSDictionary *response) {
        DLog(@"\n>>>[getOrderDetail failure]:%@",response);
        [ProgressHUDHelper removeLoading];
        [self shownoNetWorkViewWithType:0];
        [self setRefreshBlock:^{
            [weakSelf loadData];
        }];
    }];
}

-(void)updateSubViewsWithModel:(BGOrderDetailModel *)model{
    
    self.navigationItem.title = model.product_name;
    self.titleeLabel.text = model.product_name;
    
    self.orderNumLabel.text = [NSString stringWithFormat:@"订单号：%@",model.order_number];
    NSString *aStr = [Tool dateFormatter:model.start_time.doubleValue dateFormatter:@"yyyy年MM月dd日"];
    NSString *bStr = [Tool dateFormatter:model.end_time.doubleValue dateFormatter:@"MM月dd日"];
    self.dateLabel.text = [NSString stringWithFormat:@"%@-%@",aStr,bStr];
    if (model.children_number.intValue == 0) {
        self.personNumLabel.text = [NSString stringWithFormat:@"%@成人",model.audit_number];
    }else{
        self.personNumLabel.text = [NSString stringWithFormat:@"%@成人  %@儿童",model.audit_number,model.children_number];
    }
    self.packageNumLabel.text = [NSString stringWithFormat:@"%@件行李",model.baggage_number];
    if ([Tool isBlankString:model.remark]) {
        model.remark = @"无特殊说明";
    }
    self.noteTextView.text = model.remark;
    self.orderPriceLabel.text = [NSString stringWithFormat:@"¥ %@",model.order_amount];
    self.orderCouponLabel.text = [NSString stringWithFormat:@"¥ %@",model.dis_amount];
    self.noteViewHeight.constant = [self heightForString:self.noteTextView andWidth:SCREEN_WIDTH-17*2]+45;
    self.orderRealPayLabel.text = [NSString stringWithFormat:@"¥ %@", model.pay_amount];
    
    if ([Tool isBlankString:model.nickname]) {
        self.guideView.hidden = YES;
        self.priceViewTopHeight.constant = 6;
    }else{
        self.guideView.hidden = NO;
        self.priceViewTopHeight.constant = 198;
        self.guideConcernBtn.userInteractionEnabled = YES;
        self.guideNameLabel.text = model.nickname;
        self.guideCarNameLabel.text = model.model_name;
        self.guideNumLabel.text = model.number_plate;
        [self changeConcernBtnStatusAction:model.is_concern.boolValue];
        @weakify(self);
        [[self.guideConcernBtn rac_signalForControlEvents:(UIControlEventTouchUpInside)] subscribeNext:^(__kindof UIControl * _Nullable x) {
            @strongify(self);
            // 点击button的响应事件
            [ProgressHUDHelper showLoading];
            NSMutableDictionary *param = [[NSMutableDictionary alloc] init];
            [param setObject:model.guide_member_id forKey:@"member_id"];
            [param setObject:@"2" forKey:@"type"];
            [ProgressHUDHelper showLoading];
            [BGCommunityApi modifyConcernStatus:param succ:^(NSDictionary *response) {
                DLog(@"\n>>>[modifyConcernStatus sucess]:%@",response);
                if (model.is_concern.boolValue) {
                    [WHIndicatorView toast:@"取消关注成功"];
                    model.is_concern = @"0";
                }else{
                    [WHIndicatorView toast:@"关注成功"];
                    model.is_concern = @"1";
                }
                [self changeConcernBtnStatusAction:model.is_concern.boolValue];
            } failure:^(NSDictionary *response) {
                DLog(@"\n>>>[modifyConcernStatus failure]:%@",response);
            }];
        }];
    }
    switch (model.order_status.intValue) {
        case 0:{
            _zeroBtn.hidden = NO;
            _oneBtn.hidden = !_zeroBtn.hidden;
            _twoBtn.hidden = !_zeroBtn.hidden;
            @weakify(self);
            [_zeroBtn setTitle:@"支付订单" forState:(UIControlStateNormal)];
            [[_zeroBtn rac_signalForControlEvents:(UIControlEventTouchUpInside)] subscribeNext:^(__kindof UIControl * _Nullable x) {
                @strongify(self);
                // 点击button的响应事件
                [self showPayViewActionWithData:model];
                self.payMoneyStr = model.pay_amount;
            }];
        }
            break;
        case 1:{
            if (![Tool isBlankString:model.nickname]) {
                _zeroBtn.hidden = YES;
                _oneBtn.hidden = !_zeroBtn.hidden;
                _twoBtn.hidden = !_zeroBtn.hidden;
                [_oneBtn setTitle:@"打电话" forState:(UIControlStateNormal)];
                [_twoBtn setTitle:@"发私聊" forState:(UIControlStateNormal)];
                @weakify(self);
                [[_twoBtn rac_signalForControlEvents:(UIControlEventTouchUpInside)] subscribeNext:^(__kindof UIControl * _Nullable x) {
                    @strongify(self);
                    // 点击button的响应事件
                    self.conversationVC.conversationType = ConversationType_PRIVATE;
                    self.conversationVC.targetId = model.rong_id;
                    self.conversationVC.title = model.nickname;
                    [self.navigationController pushViewController:self.conversationVC animated:YES];
                }];
                
                [[_oneBtn rac_signalForControlEvents:(UIControlEventTouchUpInside)] subscribeNext:^(__kindof UIControl * _Nullable x) {
                    // 点击button的响应事件
                    JCAlertController *alert = [JCAlertController alertWithTitle:@"联系司导" message:@"小主，您确定要联系司导吗?"];
                    [alert addButtonWithTitle:@"取消" type:JCButtonTypeCancel clicked:^{
                    }];
                    [alert addButtonWithTitle:@"确认拨打" type:JCButtonTypeNormal clicked:^{
                        NSMutableString *str = [[NSMutableString alloc] initWithFormat:@"tel:%@", model.phone];
                        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:str]];
                    }];
                    [self presentViewController:alert animated:YES completion:nil];
                }];
            }else{
                _zeroBtn.hidden = YES;
                _oneBtn.hidden = _zeroBtn.hidden;
                _twoBtn.hidden = _zeroBtn.hidden;
            }
            
        }
            break;
        case 2:{
            _zeroBtn.hidden = NO;
            _oneBtn.hidden = !_zeroBtn.hidden;
            _twoBtn.hidden = !_zeroBtn.hidden;
            @weakify(self);
            [_zeroBtn setTitle:@"评价订单" forState:(UIControlStateNormal)];
            [[_zeroBtn rac_signalForControlEvents:(UIControlEventTouchUpInside)] subscribeNext:^(__kindof UIControl * _Nullable x) {
                @strongify(self);
                // 点击button的响应事件
                BGTPostCommentViewController *postVC = BGTPostCommentViewController.new;
                postVC.order_number = model.order_number;
                postVC.main_picture = self.main_picture;
                postVC.titleeStr = self.product_name;
                [self.navigationController pushViewController:postVC animated:YES];
            }];
        }
            break;
            
        default:{
            _zeroBtn.hidden = YES;
            _oneBtn.hidden = _zeroBtn.hidden;
            _twoBtn.hidden = _zeroBtn.hidden;
        }
            break;
    }
    [self changeViewFrame];
}


-(void)changeViewFrame{
    self.contentCenterY.constant = (_zeroBtn.y+_zeroBtn.height-SCREEN_HEIGHT+SafeAreaTopHeight+SafeAreaBottomHeight+55+6+self.noteViewHeight.constant+self.priceViewTopHeight.constant-198-6-100)*0.5;
    
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

-(void)changeConcernBtnStatusAction:(BOOL)isConcern{
    if (isConcern) {
        self.guideConcernBtn.layer.cornerRadius = 15;
        self.guideConcernBtn.layer.borderColor = kAppMainColor.CGColor;
        self.guideConcernBtn.layer.borderWidth = 0;
        [self.guideConcernBtn setTitle:@"已关注" forState:(UIControlStateNormal)];
        [self.guideConcernBtn setTitleColor:kAppWhiteColor forState:(UIControlStateNormal)];
        [self.guideConcernBtn setBackgroundColor:kAppMainColor];
    }else{
        self.guideConcernBtn.layer.cornerRadius = 15;
        self.guideConcernBtn.layer.borderColor = kAppMainColor.CGColor;
        self.guideConcernBtn.layer.borderWidth = 1;
        [self.guideConcernBtn setTitle:@"关注" forState:(UIControlStateNormal)];
        [self.guideConcernBtn setTitleColor:kAppMainColor forState:(UIControlStateNormal)];
        [self.guideConcernBtn setBackgroundColor:kAppWhiteColor];
    }
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
