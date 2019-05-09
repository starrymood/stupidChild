//
//  BGVisaDetailViewController.m
//  ShaHaiZiT
//
//  Created by biao on 2019/1/19.
//  Copyright © 2019 biao. All rights reserved.
//

#import "BGVisaDetailViewController.h"
#import "BGAirApi.h"
#import "BGAirPriceCommentModel.h"
#import <JCAlertController.h>
#import "UITextField+BGLimit.h"
#import <UMShare/UMShare.h>
#import <UShareUI/UShareUI.h>
#import <SDCycleScrollView.h>
#import "BGChatViewController.h"
#import "BGHotLineModel.h"
#import "BGOrderTravelApi.h"
#import "BGPayDefaultView.h"
#import <AlipaySDK/AlipaySDK.h>
#import "WXApi.h"
#import "BGWalletOrderPayResultViewController.h"

#define payViewHeight 404
@interface BGVisaDetailViewController ()<UITextViewDelegate,UIWebViewDelegate>
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *contentCenterY;
@property (weak, nonatomic) IBOutlet SDCycleScrollView *cycleScrollView;
@property (weak, nonatomic) IBOutlet UILabel *titleeLabel;
@property (weak, nonatomic) IBOutlet UITextView *subtitleTextView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *titleeViewHeight;
@property (weak, nonatomic) IBOutlet UIWebView *detailWebView;
@property (weak, nonatomic) IBOutlet UILabel *unsubscribeLabel;
@property (weak, nonatomic) IBOutlet UITextField *personNameTextField;
@property (weak, nonatomic) IBOutlet UITextField *personPhoneTextField;
@property (weak, nonatomic) IBOutlet UITextView *noteTextView;
@property (weak, nonatomic) IBOutlet UIButton *payBtn;
@property (weak, nonatomic) IBOutlet UIButton *unsubscribeBtn;
@property (weak, nonatomic) IBOutlet UILabel *peopleNumLabel;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *lineViewHeight;
@property (weak, nonatomic) IBOutlet UIButton *connectServiceBtn;
@property (weak, nonatomic) IBOutlet UILabel *perPriceLabel;
@property (weak, nonatomic) IBOutlet UILabel *orderTotalPriceLabel;
@property (weak, nonatomic) IBOutlet UIButton *peopleMinusBtn;
@property (weak, nonatomic) IBOutlet UIButton *peopleAddBtn;

@property (nonatomic, strong) UILabel *placeholderLabel;
@property (nonatomic, strong) BGHotLineModel *fModel;
@property (nonatomic, strong) UIView *backView;
@property(nonatomic,strong) BGPayDefaultView *payView;
@property(nonatomic,copy) NSString *payMoneyStr;
@property(nonatomic,copy) NSString *orderNumberStr;

@end

@implementation BGVisaDetailViewController
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
    self.navigationItem.title = @"签证详情";
    self.view.backgroundColor = kAppBgColor;
    self.personNameTextField.maxLenght = 30;
    self.personPhoneTextField.maxLenght = 20;
    self.personPhoneTextField.digitsChars = @[@"0",@"1",@"2",@"3",@"4",@"5",@"6",@"7",@"8",@"9"];
    self.placeholderLabel = [[UILabel alloc] initWithFrame:CGRectMake(3, 3, SCREEN_WIDTH-20-6, 25)];
    _placeholderLabel.enabled = NO;
    _placeholderLabel.text = @"有特别要求您可以在此填写备注";
    _placeholderLabel.numberOfLines = 0;
    _placeholderLabel.font = kFont(14);
    _placeholderLabel.textColor = kApp999Color;
    [_noteTextView addSubview:_placeholderLabel];
    self.peopleNumLabel.text = @"1";
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(alipaySuccessAction:) name:@"AlipaySuccessNotification" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(weChatSuccessAction:) name:@"WeChatSuccessNotification" object:nil];
    
    [self changeViewFrame];
}
-(void)loadData{
    [ProgressHUDHelper showLoading];
    NSMutableDictionary *param = [[NSMutableDictionary alloc] init];
    [param setObject:_product_id forKey:@"product_id"];
    __weak __typeof(self) weakSelf = self;
    [BGAirApi getCarInfoById:param succ:^(NSDictionary *response) {
        DLog(@"\n>>>[getCarInfoById sucess]:%@",response);
        [weakSelf hideNodateView];
        BGHotLineModel *model = [BGHotLineModel mj_objectWithKeyValues:BGdictSetObjectIsNil(response[@"result"])];
         weakSelf.fModel = model;
        [weakSelf updateSubViewsWithModel:model];
    } failure:^(NSDictionary *response) {
        DLog(@"\n>>>[getCarInfoById failure]:%@",response);
        [ProgressHUDHelper removeLoading];
        [self shownoNetWorkViewWithType:0];
        [self setRefreshBlock:^{
            [weakSelf loadData];
        }];
    }];
    
}

-(void)updateSubViewsWithModel:(BGHotLineModel *)model{
    @weakify(self);
    
    self.connectServiceBtn.userInteractionEnabled = YES;
    self.unsubscribeBtn.userInteractionEnabled = YES;
    self.payBtn.userInteractionEnabled = YES;
    
    [[self.connectServiceBtn rac_signalForControlEvents:(UIControlEventTouchUpInside)] subscribeNext:^(__kindof UIControl * _Nullable x) {
        @strongify(self);
        // 点击button的响应事件
        if (![Tool isLogin]) {
            [WHIndicatorView toast:@"请先登录!"];
            [BGAppDelegateHelper showLoginViewController];
            return;
        }
        BGChatViewController *conversationVC = [[BGChatViewController alloc]init];
        conversationVC.conversationType = ConversationType_PRIVATE;
        
        conversationVC.targetId = [NSString stringWithFormat:@"%@",model.service_id];
        conversationVC.title = [NSString stringWithFormat:@"%@",model.service_name];
        [self.navigationController pushViewController:conversationVC animated:YES];
    }];
    UIButton *shareBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [shareBtn setImage:BGImage(@"travel_share_green") forState:UIControlStateNormal];
    [shareBtn setImage:BGImage(@"travel_share_green") forState:UIControlStateHighlighted];
    shareBtn.bounds = CGRectMake(0, 0, 70, 30);
    shareBtn.contentEdgeInsets = UIEdgeInsetsZero;
    shareBtn.contentHorizontalAlignment = UIControlContentHorizontalAlignmentRight;
    UIBarButtonItem *shareItem = [[UIBarButtonItem alloc] initWithCustomView:shareBtn];
    self.navigationItem.rightBarButtonItem = shareItem;
    [[shareBtn rac_signalForControlEvents:(UIControlEventTouchUpInside)] subscribeNext:^(__kindof UIControl * _Nullable x) {
        @strongify(self);
        // 点击button的响应事件
        [self showShareAction];
    }];
    self.titleeLabel.text = model.product_name;
    self.cycleScrollView.pageControlAliment = SDCycleScrollViewPageContolAlimentCenter;
    self.cycleScrollView.backgroundColor = kAppBgColor;
    self.cycleScrollView.imageURLStringsGroup = model.car_pictures;
    [_detailWebView loadHTMLString:[Tool attributeByWeb:model.product_content width:SCREEN_WIDTH-20 scale:SCREEN_WIDTH*0.96] baseURL:nil];
    _detailWebView.delegate = self;
    self.subtitleTextView.text = model.product_introduction;
    self.titleeViewHeight.constant = [self heightForString:self.subtitleTextView andWidth:SCREEN_WIDTH-24]+95;
    self.unsubscribeLabel.text = model.unsubscribe_title;
    self.perPriceLabel.text = [NSString stringWithFormat:@"¥%@/人",model.product_price];
    self.orderTotalPriceLabel.text = [NSString stringWithFormat:@"¥%@",model.product_price];
    [self changeViewFrame];
    [[self.payBtn rac_signalForControlEvents:(UIControlEventTouchUpInside)] subscribeNext:^(__kindof UIControl * _Nullable x) {
        @strongify(self);
        // 点击button的响应事件
        [self uploadInfoAction:x];
    }];
    
    [[self.peopleMinusBtn rac_signalForControlEvents:(UIControlEventTouchUpInside)] subscribeNext:^(__kindof UIControl * _Nullable x) {
        @strongify(self);
        // 点击button的响应事件
        if (self.peopleNumLabel.text.integerValue<2) {
            
        }else{
            self.peopleNumLabel.text = [NSString stringWithFormat:@"%zd",self.peopleNumLabel.text.integerValue-1];
            self.orderTotalPriceLabel.text = [NSString stringWithFormat:@"¥%.2f",self.peopleNumLabel.text.integerValue*model.product_price.doubleValue];
        }
        
    }];
    [[self.peopleAddBtn rac_signalForControlEvents:(UIControlEventTouchUpInside)] subscribeNext:^(__kindof UIControl * _Nullable x) {
        @strongify(self);
        // 点击button的响应事件
        self.peopleNumLabel.text = [NSString stringWithFormat:@"%zd",self.peopleNumLabel.text.integerValue+1];
        self.orderTotalPriceLabel.text = [NSString stringWithFormat:@"¥%.2f",self.peopleNumLabel.text.integerValue*model.product_price.doubleValue];
    }];
    
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
}
-(void)uploadInfoAction:(UIButton *)sender{
    [self keyboarkHidden];
    
    if (![Tool isLogin]) {
        [WHIndicatorView toast:@"请先登录!"];
        [BGAppDelegateHelper showLoginViewController];
        return;
    }
    if (_personNameTextField.text.length<1) {
        [WHIndicatorView toast:@"请填写联系人姓名"];
        return;
    }
    if (_personPhoneTextField.text.length<1) {
        [WHIndicatorView toast:@"请填写联系人电话"];
        return;
    }
   
    if (_noteTextView.text.length<1) {
        _noteTextView.text = @"";
    }
    
    NSMutableDictionary *param = [[NSMutableDictionary alloc] init];
    [param setObject:_product_id forKey:@"product_id"];
    [param setObject:_personNameTextField.text forKey:@"contact"];
    [param setObject:_personPhoneTextField.text forKey:@"contact_number"];
    [param setObject:_noteTextView.text forKey:@"remark"];
    [param setObject:_peopleNumLabel.text forKey:@"audit_number"];
    
    
    sender.userInteractionEnabled = NO;
    __weak __typeof(self) weakSelf = self;
    [ProgressHUDHelper showLoading];
    [BGOrderTravelApi uploadPreInfo:param succ:^(NSDictionary *response) {
        DLog(@"\n>>>[uploadPreInfo sucess]:%@",response);
        weakSelf.orderNumberStr = [NSString stringWithFormat:@"%@",BGdictSetObjectIsNil(response[@"result"][@"order_number"])];
        [weakSelf createPayOrder];
        sender.userInteractionEnabled = YES;
    } failure:^(NSDictionary *response) {
        DLog(@"\n>>>[uploadPreInfo failure]:%@",response);
        sender.userInteractionEnabled = YES;
    }];
    
}
-(void)createPayOrder{
    [ProgressHUDHelper showLoading];
    NSMutableDictionary *param = [[NSMutableDictionary alloc] init];
    [param setObject:_orderNumberStr forKey:@"order_number"];
    __weak __typeof(self) weakSelf = self;
    [BGOrderTravelApi createOrderByProductId:param succ:^(NSDictionary *response) {
        DLog(@"\n>>>[createOrderByProductId success]:%@",response);
        [weakSelf showPayViewActionWithData:BGdictSetObjectIsNil(response[@"result"])];
        self.payMoneyStr = [NSString stringWithFormat:@"%@",BGdictSetObjectIsNil(response[@"result"][@"pay_amount"])];
    } failure:^(NSDictionary *response) {
        DLog(@"\n>>>[createOrderByProductId failure]:%@",response);
    }];
    
}
- (float)heightForString:(UITextView *)textView andWidth:(float)width{
    CGSize sizeToFit = [textView sizeThatFits:CGSizeMake(width, MAXFLOAT)];
    return sizeToFit.height;
}
#pragma mark - UITextView -
-(void)textViewDidChange:(UITextView *)textView
{
    if ([textView.text length] == 0) {
        [_placeholderLabel setHidden:NO];
    }else{
        [_placeholderLabel setHidden:YES];
    }
    if (textView.text.length > 500) {
        [WHIndicatorView toast:@"请输入小于500个文字"];
        NSString *s = [textView.text substringToIndex:500];
        textView.text = s;
    }
}
-(void)changeViewFrame{
    self.contentCenterY.constant = (_payBtn.y+_payBtn.height+self.titleeViewHeight.constant+self.lineViewHeight.constant-SCREEN_HEIGHT+SafeAreaTopHeight+SafeAreaBottomHeight-120)*0.5;
    [UIView animateWithDuration:.2 animations:^{
        [self.view layoutIfNeeded];
    }];
}
#pragma mark - clickedShareItem

-(void)showShareAction {
    
    [UMSocialUIManager setPreDefinePlatforms:@[@(UMSocialPlatformType_WechatSession),@(UMSocialPlatformType_WechatTimeLine),@(UMSocialPlatformType_QQ),@(UMSocialPlatformType_Qzone),@(UMSocialPlatformType_Sina)]];
    
    [UMSocialUIManager showShareMenuViewInWindowWithPlatformSelectionBlock:^(UMSocialPlatformType platformType, NSDictionary *userInfo) {
        // 根据获取的platformType确定所选平台进行下一步操作
        [self doShareTitle:self.fModel.product_name description:self.fModel.product_introduction image:[UIImage imageNamed:@"applogo"] url:[NSString stringWithFormat:@"%@login.html?icode=%@",BGWebMainHtml,BGGetUserDefaultObjectForKey(@"inviteCode")] shareType:(platformType)];
    }];
}
#pragma mark- 分享公共方法
- (void)doShareTitle:(NSString *)tieleStr
         description:(NSString *)descriptionStr
               image:(UIImage *)image
                 url:(NSString *)url
           shareType:(UMSocialPlatformType)type
{
    [ProgressHUDHelper showLoading];
    
    //创建分享消息对象
    UMSocialMessageObject *messageObject = [UMSocialMessageObject messageObject];
    
    //创建网页内容对象
    UMShareWebpageObject *shareObject = [UMShareWebpageObject shareObjectWithTitle:tieleStr descr:descriptionStr thumImage:image];
    //设置网页地址
    shareObject.webpageUrl = url;
    
    //分享消息对象设置分享内容对象
    messageObject.shareObject = shareObject;
    [ProgressHUDHelper removeLoading];
    //调用分享接口
    [[UMSocialManager defaultManager] shareToPlatform:type messageObject:messageObject currentViewController:self completion:^(id data, NSError *error) {
        if (error) {
            [WHIndicatorView toast:@"分享失败"];
        }else{
            if ([data isKindOfClass:[UMSocialShareResponse class]]) {
                [WHIndicatorView toast:@"分享成功"];
            }else{
                //                DLog(@"/n[share]");
                [WHIndicatorView toast:@"分享成功"];
            }
        }
    }];
    
}
-(void)webViewDidFinishLoad:(UIWebView *)webView{
    //HTML5的高度
    NSString *htmlHeight = [webView stringByEvaluatingJavaScriptFromString:@"document.body.scrollHeight"];
    if ([htmlHeight isEqualToString:@"300"]) {
        self.lineViewHeight.constant = 47;
    }else{
        self.lineViewHeight.constant = [htmlHeight floatValue];
    }
    self.contentCenterY.constant = (_payBtn.y+_payBtn.height+self.lineViewHeight.constant-SCREEN_HEIGHT+SafeAreaTopHeight+SafeAreaBottomHeight-300)*0.5;
    [UIView animateWithDuration:.2 animations:^{
        [self.view layoutIfNeeded];
        
    } completion:^(BOOL finished) {
        
    }];
    
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
    [param setObject:_orderNumberStr forKey:@"order_number"];
    
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
    payResultVC.order_num = _orderNumberStr;
    payResultVC.payBalanceStr = [NSString stringWithFormat:@"¥ %@",_payMoneyStr];
    [self.navigationController pushViewController:payResultVC animated:YES];
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
