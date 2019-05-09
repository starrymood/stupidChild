//
//  BGWebViewController.m
//  shahaizic
//
//  Created by 孙林茂 on 2018/4/10.
//  Copyright © 2018年 樱兰网络. All rights reserved.
//

#import "BGWebViewController.h"
#import <UMShare/UMShare.h>
#import <UShareUI/UShareUI.h>
#import <JCAlertController.h>
#import "RCDCustomerServiceViewController.h"

@interface BGWebViewController ()<UIWebViewDelegate>

@property (nonatomic, weak) UIWebView * webView;

@property (nonatomic, weak) UIActivityIndicatorView * activityView;


@end

@implementation BGWebViewController

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:NO animated:YES];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    
    if (@available(iOS 11.0,*)) {
        UIScrollView.appearance.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
    }else{
        self.automaticallyAdjustsScrollViewInsets = NO;
    }

    [self initNaviBar];
    
    [self initWebView];
    
}

- (void)initWebView{
    
    UIWebView *webView = [[UIWebView alloc]initWithFrame:CGRectMake(0, SafeAreaTopHeight, self.view.frame.size.width, self.view.frame.size.height-SafeAreaTopHeight+SafeAreaBottomHeight)];
    webView.delegate = self;
    [self.view addSubview:webView];
    self.webView = webView;
    
    
    //activityView
    UIActivityIndicatorView *activityView = [[UIActivityIndicatorView alloc]initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    activityView.center = self.view.center;
    [activityView startAnimating];
    [self performSelector:@selector(stopActivit) withObject:self afterDelay:8.0];
    self.activityView = activityView;
    [self.view addSubview:activityView];
    
    //清除UIWebView的缓存
    [[NSURLCache sharedURLCache] removeAllCachedResponses];
    
    [self.webView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:self.url] cachePolicy:NSURLRequestReloadIgnoringCacheData timeoutInterval:10.0]];
}
-(void)stopActivit{
    [self.activityView stopAnimating];
    self.activityView.hidden = YES;
}
- (void)initNaviBar{
    // 左上角返回按钮
    self.navigationItem.leftBarButtonItem = [UIBarButtonItem itemWithImage:@"btn_back_black" highImage:@"btn_back_green" target:self action:@selector(clickedBackItem:)];
    if (_isShowActivityShare) {
        UIButton *shareBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [shareBtn setImage:BGImage(@"product_details_share_icon") forState:UIControlStateNormal];
        [shareBtn setImage:BGImage(@"product_details_share_icon") forState:UIControlStateHighlighted];
        shareBtn.bounds = CGRectMake(0, 0, 30, 30);
        shareBtn.contentEdgeInsets = UIEdgeInsetsZero;
        shareBtn.contentHorizontalAlignment = UIControlContentHorizontalAlignmentRight;
        UIBarButtonItem *shareItem = [[UIBarButtonItem alloc] initWithCustomView:shareBtn];
        
        UIButton *collectBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [collectBtn setImage:BGImage(@"hotline") forState:UIControlStateNormal];
        [collectBtn setImage:BGImage(@"hotline") forState:UIControlStateHighlighted];
        collectBtn.bounds = CGRectMake(0, 0, 70, 30);
        collectBtn.contentEdgeInsets = UIEdgeInsetsZero;
        collectBtn.contentHorizontalAlignment = UIControlContentHorizontalAlignmentRight;
        UIBarButtonItem *collectItem = [[UIBarButtonItem alloc] initWithCustomView:collectBtn];
        
        
        self.navigationItem.rightBarButtonItems = @[shareItem,collectItem];
        @weakify(self);
        [[shareBtn rac_signalForControlEvents:(UIControlEventTouchUpInside)] subscribeNext:^(__kindof UIControl * _Nullable x) {
            @strongify(self);
            // 点击button的响应事件
            [self clickedShareItem:x];
        }];
        
        [[collectBtn rac_signalForControlEvents:(UIControlEventTouchUpInside)] subscribeNext:^(__kindof UIControl * _Nullable x) {
            @strongify(self);
            // 点击button的响应事件
            if (![Tool isLogin]) {
                [WHIndicatorView toast:@"请先登录!"];
                [BGAppDelegateHelper showLoginViewController];
                return;
            }
            if ([RCIMClient sharedRCIMClient].getConnectionStatus != 0) {
                [WHIndicatorView toast:@"融云连接失败,请重新登录账号!"];
                [Tool logoutRongCloudAction];
                return;
            }
            RCDCustomerServiceViewController *chatService = [[RCDCustomerServiceViewController alloc] init];
            chatService.conversationType = ConversationType_CUSTOMERSERVICE;
            if ([Tool isBlankString:self.service_id]) {
                chatService.targetId = RongCloud_Service;
                chatService.title = @"傻孩子客服";
            }else{
                chatService.targetId = self.service_id;
                chatService.title = self.service_name;;
            }
            RCCustomerServiceInfo *csInfo = [[RCCustomerServiceInfo alloc] init];
            csInfo.userId = [RCIMClient sharedRCIMClient].currentUserInfo.userId;
            csInfo.nickName = BGGetUserDefaultObjectForKey(@"UserNickname");
            csInfo.portraitUrl = [RCIMClient sharedRCIMClient].currentUserInfo.portraitUri;
            csInfo.referrer = @"客户端";
            chatService.csInfo = csInfo; //用户的详细信息，此数据用于上传用户信息到客服后台，数据的 nickName 和 portraitUrl 必须填写。
            [[RCIMClient sharedRCIMClient] setConversationToTop:(ConversationType_CUSTOMERSERVICE) targetId:RongCloud_Service isTop:YES];
            [self.navigationController pushViewController :chatService animated:YES];
        }];
}
}

#pragma mark - clickedBackItem

- (void)clickedBackItem:(UIBarButtonItem *)btn{
    if (self.webView.canGoBack) {
        [self.webView goBack];
    }else{
        [self clickedCloseItem:nil];
    }
}

#pragma mark - clickedCloseItem

- (void)clickedCloseItem:(UIButton *)btn{
    [self.navigationController popViewControllerAnimated:YES];
}


#pragma mark - UIWebViewDelegate
- (void)webViewDidStartLoad:(UIWebView *)webView{
    self.activityView.hidden = YES;
}


- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType{
    if ([@"intent" isEqualToString:request.URL.scheme]) {
        NSString *url = request.URL.absoluteString;
        NSRange range = [url rangeOfString:@":"];
        NSString *method = [request.URL.absoluteString substringFromIndex:range.location+3];
        SEL selector = NSSelectorFromString(method);
        if ([self respondsToSelector:selector]) {
            [self performSelector:selector withObject:nil afterDelay:0];
        }
    }
    return YES;
}
-(void)activityDetail{

    JCAlertController *alert = [JCAlertController alertWithTitle:@"提示" message:@"报名成功"];
__weak __typeof(self) weakSelf = self;
    [alert addButtonWithTitle:@"确定" type:JCButtonTypeNormal clicked:^{
        if (![Tool isLogin]) {
            [WHIndicatorView toast:@"请先登录!"];
            [BGAppDelegateHelper showLoginViewController];
            return;
        }
        [weakSelf.navigationController popToRootViewControllerAnimated:NO];
        NSMutableDictionary *dic = [[NSMutableDictionary alloc] init];
        [dic setObject:[NSString stringWithFormat:@"%@",weakSelf.service_name] forKey:@"serviceName"];
        [dic setObject:[NSString stringWithFormat:@"%@",weakSelf.service_id] forKey:@"serviceID"];
        [[NSNotificationCenter defaultCenter] postNotificationName:@"SELECTINDEXMESSAGE" object:dic];
    }];

    [self presentViewController:alert animated:YES completion:nil];
}

-(void)callError{
    self.activityView.hidden = YES;
}
- (void)webViewDidFinishLoad:(UIWebView *)webView {
    self.activityView.hidden = YES;
    if ([Tool isBlankString:_activityTitleStr]) {
         self.title = [webView stringByEvaluatingJavaScriptFromString:@"document.title"];
    }else{
        self.title = _activityTitleStr;
    }
}

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error{
    self.activityView.hidden = YES;
}
#pragma mark - clickedShareItem

- (void)clickedShareItem:(UIButton *)btn{
    [[[UIApplication sharedApplication] keyWindow] endEditing:YES];
    [self showShareAction];
}
-(void)showShareAction {
    
    [UMSocialUIManager setPreDefinePlatforms:@[@(UMSocialPlatformType_WechatSession),@(UMSocialPlatformType_WechatTimeLine),@(UMSocialPlatformType_QQ),@(UMSocialPlatformType_Qzone),@(UMSocialPlatformType_Sina)]];
     __weak __typeof(self) weakSelf = self;
    [UMSocialUIManager showShareMenuViewInWindowWithPlatformSelectionBlock:^(UMSocialPlatformType platformType, NSDictionary *userInfo) {
        // 根据获取的platformType确定所选平台进行下一步操作
        [self doShareTitle:weakSelf.activityTitleStr description:weakSelf.subTitleStr image:[UIImage imageNamed:@"applogo"] url:weakSelf.url shareType:(platformType)];
    }];
}
-(void)share {
    [UMSocialUIManager setPreDefinePlatforms:@[@(UMSocialPlatformType_WechatSession),@(UMSocialPlatformType_WechatTimeLine),@(UMSocialPlatformType_QQ),@(UMSocialPlatformType_Qzone),@(UMSocialPlatformType_Sina)]];
    [UMSocialUIManager showShareMenuViewInWindowWithPlatformSelectionBlock:^(UMSocialPlatformType platformType, NSDictionary *userInfo) {
        // 根据获取的platformType确定所选平台进行下一步操作
        [self doShareTitle:@"出境游 & 正品海淘！就找傻孩子" description:@"您的朋友邀请您使用傻孩子并给您发了一个大红包" image:[UIImage imageNamed:@"applogo"] url:[NSString stringWithFormat:@"%@login.html?icode=%@",BGWebMainHtml,BGGetUserDefaultObjectForKey(@"inviteCode")] shareType:(platformType)];
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
                DLog(@"/n[share]");
                [WHIndicatorView toast:@"分享成功"];
            }
        }
    }];
    
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
