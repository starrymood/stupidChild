//
//  BGShopDetailViewController.m
//  shzTravelC
//
//  Created by 孙林茂 on 2018/5/9.
//  Copyright © 2018年 biao. All rights reserved.
//

#import "BGShopDetailViewController.h"
#import "BGShopHomeViewController.h"
#import "BGShopBarView.h"
#import "ChooseView.h"
#import "ChooseRank.h"
#import "BGFirmOrderViewController.h"
#import "BGShopApi.h"
#import <UMShare/UMShare.h>
#import <UShareUI/UShareUI.h>
#import "BGChatViewController.h"
#import <UIImageView+WebCache.h>
#import "BGShopCommentView.h"
#import "BGAirApi.h"
#import "BGShopCategoryModel.h"
#import "BGOrderShopApi.h"

#define PickViewHeight (SCREEN_HEIGHT-280-SafeAreaBottomHeight)
@interface BGShopDetailViewController ()<UIWebViewDelegate,ChooseRankDelegate>

@property (nonatomic, weak) UIWebView * webView;

@property (nonatomic, weak) UIActivityIndicatorView *activityView;

@property (nonatomic, strong) ChooseView *chooseView;
@property (nonatomic, strong) ChooseRank *chooseRank;
@property (nonatomic, strong) NSMutableArray *cellDataArr;
@property (nonatomic, strong) BGShopCategoryModel *selelctModel;
@property (nonatomic, strong) UIView *backView;

@property (nonatomic, copy) NSDictionary *dataDic;
@property (nonatomic, assign) BOOL isFavorited;
@property (nonatomic, strong) BGShopBarView *bottomView;
@property (nonatomic, assign) BOOL isBuy;

@property (nonatomic, copy) NSString *goodNumStr;
@property (nonatomic, strong) BGShopCommentView *commentView;
@property (nonatomic, assign) BOOL isComment;
@end

@implementation BGShopDetailViewController
-(NSMutableArray *)cellDataArr {
    if (!_cellDataArr) {
        self.cellDataArr = [NSMutableArray array];
    }
    return _cellDataArr;
}
-(BGShopCommentView *)commentView{
    if (!_commentView) {
        self.commentView = [[BGShopCommentView alloc] initWithFrame:self.webView.frame GoodsId:self.goodsid];
    }
    return _commentView;
}
-(UIView *)backView{
    if (!_backView) {
        self.backView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT)];
        _backView.backgroundColor = [UIColor clearColor];
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(dismissChooseView)];
        [_backView addGestureRecognizer:tap];
    }
    return _backView;
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    self.navigationController.navigationBarHidden = NO;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor = kAppWhiteColor;
    
    if (@available(iOS 11.0,*)) {
        UIScrollView.appearance.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
    }else{
        self.automaticallyAdjustsScrollViewInsets = NO;
    }
    
    [self initNaviBar];
    
    [self initWebView];
    
    [self initBottomView];
    
    [self getStoreIdAndFavoritedAction];

}
-(void)getStoreIdAndFavoritedAction {
    [ProgressHUDHelper showLoading];
     [self.bottomView setHidden:YES];
    NSMutableDictionary *param = [[NSMutableDictionary alloc] init];
    [param setObject:_goodsid forKey:@"goods_id"];
    __weak __typeof(self) weakSelf = self;
    [BGShopApi getGoodsDetails:param succ:^(NSDictionary *response) {
         DLog(@"\n>>>[getGoodsDetails sucess]:%@",response);
        [weakSelf.bottomView setHidden:NO];
        NSDictionary *dic = BGdictSetObjectIsNil(response[@"result"]);
        weakSelf.dataDic = [NSDictionary dictionaryWithDictionary:dic];
         weakSelf.cellDataArr = [BGShopCategoryModel mj_objectArrayWithKeyValuesArray:BGdictSetObjectIsNil(response[@"result"][@"price_list"])];
        weakSelf.isFavorited = [NSString stringWithFormat:@"%@",BGdictSetObjectIsNil(dic[@"is_collect"])].boolValue;
        if (weakSelf.isFavorited) {
            [weakSelf.bottomView.bt_collection setBackgroundImage:BGImage(@"home_shopBar_collectioned") forState:0];
        }else{
            [weakSelf.bottomView.bt_collection setBackgroundImage:BGImage(@"home_shopBar_collection") forState:0];
        }
    } failure:^(NSDictionary *response) {
         DLog(@"\n>>>[getGoodsDetails failure]:%@",response);
    }];
}
- (void)initWebView{
    
    UIWebView *webView = [[UIWebView alloc]initWithFrame:CGRectMake(0, SafeAreaTopHeight, self.view.frame.size.width, self.view.frame.size.height-SafeAreaTopHeight-SafeAreaBottomHeight-kTabBarH-10)];
    webView.delegate = self;
    webView.dataDetectorTypes = UIDataDetectorTypeNone;
    [self.view addSubview:webView];
    self.webView = webView;
    
    
    //activityView
    UIActivityIndicatorView *activityView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    activityView.center = self.view.center;
    [activityView startAnimating];
    [self performSelector:@selector(stopActivit) withObject:self afterDelay:5.0];
    self.activityView = activityView;
    [self.view addSubview:activityView];
    
    //清除UIWebView的缓存
    [[NSURLCache sharedURLCache] removeAllCachedResponses];
    
    [self.webView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:self.url] cachePolicy:NSURLRequestReloadIgnoringCacheData timeoutInterval:10.0]];
    
}
-(void)initBottomView {
    
   self.bottomView = [[BGShopBarView alloc] initWithFrame:CGRectMake(0, SCREEN_HEIGHT-kTabBarH-10-SafeAreaBottomHeight+1, SCREEN_WIDTH, kTabBarH-2)];
    [_bottomView setHidden:YES];
    [self.view addSubview:_bottomView];
    [_bottomView.bt_service addTarget:self action:@selector(seleteShop) forControlEvents:UIControlEventTouchUpInside];
    [_bottomView.bt_shop addTarget:self action:@selector(seleteService) forControlEvents:UIControlEventTouchUpInside];
    [_bottomView.bt_collection addTarget:self action:@selector(seleteCollection:) forControlEvents:UIControlEventTouchUpInside];
    [_bottomView.bt_addBasket addTarget:self action:@selector(addGoodsToCart) forControlEvents:UIControlEventTouchUpInside];
    [_bottomView.bt_buyNow addTarget:self action:@selector(seleteBuy) forControlEvents:UIControlEventTouchUpInside];
}
-(void)stopActivit{
    [self.activityView stopAnimating];
    self.activityView.hidden = YES;
}
- (void)initNaviBar{
    // 左上角返回按钮
    self.navigationItem.leftBarButtonItem = [UIBarButtonItem itemWithImage:@"btn_back_black" highImage:@"btn_back_green" target:self action:@selector(clickedBackItem:)];
    self.navigationItem.rightBarButtonItem = [UIBarButtonItem itemWithImage:@"product_details_share_icon" highImage:@"product_details_share_icon" target:self action:@selector(clickedShareItem:)];
    
}

#pragma mark - clickedBackItem

- (void)clickedBackItem:(UIBarButtonItem *)btn{
    if (self.webView.canGoBack) {
//        [self.webView goBack];
         [self clickedCloseItem:nil];
    }else{
        if (_isComment) {
            CATransition *transition = [CATransition animation];
            transition.duration = 0.3f;
            transition.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
            transition.type = kCATransitionPush;
            transition.subtype = kCATransitionFromLeft;
            //    transition.delegate = self;
            [self.commentView.superview.layer addAnimation:transition forKey:nil];
            _isComment = NO;
             self.title = [self.webView stringByEvaluatingJavaScriptFromString:@"document.title"];
            [self.commentView removeFromSuperview];
        }else{
            [self clickedCloseItem:nil];
        }
    }
}

#pragma mark - clickedCloseItem

- (void)clickedCloseItem:(UIButton *)btn{
    [self.navigationController popViewControllerAnimated:YES];
}
#pragma mark - clickedShareItem

- (void)clickedShareItem:(UIButton *)btn{
     [self showShareAction];
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
        NSArray *strArr = [method componentsSeparatedByString:@"/"];
        
        if (strArr.count<2) {
        }else{
            method = strArr[0];
            _goodsid = strArr[1];
        }
        SEL selector = NSSelectorFromString(method);
        if ([self respondsToSelector:selector]) {
            [self performSelector:selector withObject:nil afterDelay:0];
        }
        
    }
    return YES;
}
-(void)gooddetail{
    [self.webView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:BGWebGoodDetail(_goodsid)] cachePolicy:NSURLRequestReloadIgnoringCacheData timeoutInterval:10.0]];
    [self getStoreIdAndFavoritedAction];
    
}
-(void)comment {
    
    CATransition *transition = [CATransition animation];
    transition.duration = 0.3f;
    transition.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
    transition.type = kCATransitionPush;
    transition.subtype = kCATransitionFromRight;
    [self.view.layer addAnimation:transition forKey:nil];
    _isComment = YES;
    self.title = @"评论";
    [self.view addSubview:self.commentView];
    
}
- (void)webViewDidFinishLoad:(UIWebView *)webView {
    self.activityView.hidden = YES;
    self.title = [webView stringByEvaluatingJavaScriptFromString:@"document.title"];
    if ([Tool isBlankString:self.title]) {
        [self delayShowTitleAction];
    }
}
-(void)delayShowTitleAction{
 dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.6 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        self.title = [self.webView stringByEvaluatingJavaScriptFromString:@"document.title"];
     if ([Tool isBlankString:self.title]) {
          [self delayShowTitleAction];
     }
    });
}
- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error{
    self.activityView.hidden = YES;
}
#pragma mark-bottom action
-(void)seleteService
{
    if (![Tool isLogin]) {
        [WHIndicatorView toast:@"请先登录!"];
        [BGAppDelegateHelper showLoginViewController];
        return;
    }
    BGChatViewController *conversationVC = [[BGChatViewController alloc]init];
    conversationVC.conversationType = ConversationType_PRIVATE;
   
    conversationVC.targetId = BGdictSetObjectIsNil(self.dataDic[@"rong_id"]);
    conversationVC.title = BGdictSetObjectIsNil(self.dataDic[@"store_name"]);
    [self.navigationController pushViewController:conversationVC animated:YES];
}
-(void)seleteShop
{
    BGShopHomeViewController *shopHomeVC = BGShopHomeViewController.new;
    shopHomeVC.storeid = BGdictSetObjectIsNil(self.dataDic[@"store_id"]);
    shopHomeVC.store_name = BGdictSetObjectIsNil(self.dataDic[@"store_name"]);
    [self.navigationController pushViewController:shopHomeVC animated:YES];
    
}
-(void)seleteCollection:(UIButton *)btn
{
    if (![Tool isLogin]) {
        [WHIndicatorView toast:@"请先登录!"];
        [BGAppDelegateHelper showLoginViewController];
        return;
    }
    [ProgressHUDHelper showLoading];
    NSMutableDictionary *param = [[NSMutableDictionary alloc] init];
    [param setObject:_goodsid forKey:@"collect_id"];
    [param setObject:@"1" forKey:@"category"];
    // 点击button的响应事件
     __weak __typeof(self) weakSelf = self;
    [BGAirApi addAndCancelFavoriteAction:param succ:^(NSDictionary *response) {
        DLog(@"\n>>>[cancelFavoriteAction success]:%@",response);
        if (weakSelf.isFavorited == YES) {
            [WHIndicatorView toast:@"取消收藏"];
            weakSelf.isFavorited = NO;
        }else{
            [WHIndicatorView toast:@"已收藏"];
             weakSelf.isFavorited = YES;
        }
        NSString *collectionStr =  weakSelf.isFavorited ? @"home_shopBar_collectioned":@"home_shopBar_collection";
        [btn setBackgroundImage:BGImage(collectionStr) forState:0];
    } failure:^(NSDictionary *response) {
        DLog(@"\n>>>[cancelFavoriteAction failure]:%@",response);
    }];
}

-(void)addGoodsToCart {
    
    if (![Tool isLogin]) {
        [WHIndicatorView toast:@"请先登录!"];
        [BGAppDelegateHelper showLoginViewController];
        return;
    }
    self.isBuy = NO;
    [self preLoadSpecAction];
   
}

-(void)seleteBuy
{
    if (![Tool isLogin]) {
        [WHIndicatorView toast:@"请先登录!"];
        [BGAppDelegateHelper showLoginViewController];
        return;
    }
    self.isBuy = YES;
    [self preLoadSpecAction];
    
}
-(void)selectedSpecSureAction{
    if (_isBuy) {
        [ProgressHUDHelper showLoading];
        NSMutableDictionary *param = [[NSMutableDictionary alloc] init];
        [param setObject:_selelctModel.goods_id forKey:@"goods_id"];
        [param setObject:_selelctModel.ID forKey:@"item_id"];
        [param setObject:_goodNumStr forKey:@"num"];
        __weak __typeof(self) weakSelf = self;
        [BGOrderShopApi firmOrder:param FirmType:NO succ:^(NSDictionary *response) {
            DLog(@"\n>>>[firmOrder success]:%@",response);
            BGFirmOrderViewController *firmOrderVC = BGFirmOrderViewController.new;
            firmOrderVC.preNav = weakSelf.navigationController;
            firmOrderVC.cartIds = [NSString stringWithFormat:@"%@",BGdictSetObjectIsNil(response[@"result"])];
            [weakSelf.navigationController pushViewController:firmOrderVC animated:YES];

        } failure:^(NSDictionary *response) {
            DLog(@"\n>>>[firmOrder failure]:%@",response);
            [WHIndicatorView toast:@"服务器错误,请重试"];
            [weakSelf getStoreIdAndFavoritedAction];
        }];
        
    }else{
        [ProgressHUDHelper showLoading];
        NSMutableDictionary *param = [[NSMutableDictionary alloc] init];
        [param setObject:_selelctModel.goods_id forKey:@"goods_id"];
        [param setObject:_selelctModel.ID forKey:@"item_id"];
        [param setObject:_goodNumStr forKey:@"num"];
        [BGShopApi addGoodsToCart:param succ:^(NSDictionary *response) {
            DLog(@"\n>>>[addGoodsToCart success]:%@",response);
            [WHIndicatorView toast:@"加入购物车成功"];
        } failure:^(NSDictionary *response) {
            DLog(@"\n>>>[addGoodsToCart failure]:%@",response);
            [WHIndicatorView toast:@"加入购物车失败,请重试"];
        }];
    }
}

#pragma mark - 加载数据

#pragma mark - 加载chooseView

// 选择规格后确定事件
-(void)chooseViewClick {
    if ([Tool isBlankString:_selelctModel.ID]) {
        [WHIndicatorView toast:@"请选择规格"];
        return;
    }
    [self dismissChooseView];
    [self selectedSpecSureAction];
    
}
-(void)showChooseView {
    [[[UIApplication sharedApplication] keyWindow] addSubview:self.backView];
    [[[UIApplication sharedApplication] keyWindow] addSubview:self.chooseView];
    __block typeof(self) weakSelf = self;
    [UIView transitionWithView:self.backView duration:0.3 options:0 animations:^{
        weakSelf.backView.backgroundColor = [UIColor colorWithWhite:0 alpha:0.4];
        weakSelf.chooseView.y = SCREEN_HEIGHT-PickViewHeight-SafeAreaBottomHeight;
    } completion:nil];
}
// #dismiss#
-(void)dismissChooseView {
    __block typeof(self) weakSelf = self;
    [UIView transitionWithView:self.backView duration:0.3 options:0 animations:^{
        weakSelf.backView.backgroundColor = [UIColor clearColor];
        weakSelf.chooseView.y = SCREEN_HEIGHT;
    } completion:^(BOOL finished) {
        [weakSelf.chooseView removeFromSuperview];
        weakSelf.chooseView = nil;
        [weakSelf.backView removeFromSuperview];
        weakSelf.backView = nil;
        weakSelf.goodNumStr = @"1";
        weakSelf.selelctModel = nil;
    }];
    
}


-(void)showShareAction {
    [UMSocialUIManager setPreDefinePlatforms:@[@(UMSocialPlatformType_WechatSession),@(UMSocialPlatformType_WechatTimeLine),@(UMSocialPlatformType_QQ),@(UMSocialPlatformType_Qzone),@(UMSocialPlatformType_Sina)]];
    [UMSocialUIManager showShareMenuViewInWindowWithPlatformSelectionBlock:^(UMSocialPlatformType platformType, NSDictionary *userInfo) {
        // 根据获取的platformType确定所选平台进行下一步操作
        NSData *imgData = [NSData dataWithContentsOfURL:[NSURL URLWithString:BGdictSetObjectIsNil(self.dataDic[@"small"])]];
        UIImage *shareImg = [UIImage imageWithData:imgData];
        [self doShareTitle:BGdictSetObjectIsNil(self.dataDic[@"name"]) description:BGdictSetObjectIsNil(self.dataDic[@"goods_description"]) image:shareImg url:[NSString stringWithFormat:@"%@login.html?icode=%@",BGWebMainHtml,BGGetUserDefaultObjectForKey(@"inviteCode")] shareType:(platformType)];
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
-(ChooseView *)chooseView{
    if (!_chooseView) {
        self.chooseView = [[ChooseView alloc] initWithFrame:CGRectMake(0, SCREEN_HEIGHT, SCREEN_WIDTH, PickViewHeight)];
        BGShopCategoryModel *model = self.cellDataArr[0];
        [self.chooseView.headImage sd_setImageWithURL:[NSURL URLWithString:BGdictSetObjectIsNil(_dataDic[@"small"])] placeholderImage:BGImage(@"img_placeholder")];
        self.chooseView.LB_price.text = [NSString stringWithFormat:@"￥%.2f",[model.goods_price doubleValue]];
        NSString *storeStr = [NSString stringWithFormat:@"%@",BGdictSetObjectIsNil(_dataDic[@"enable_stock"])];
        if (storeStr.intValue<1) {
            [self.chooseView.stockBtn setHidden:NO];
        }else{
            self.chooseView.LB_stock.text = [NSString stringWithFormat:@"库存%@件",storeStr];
        }
        self.chooseView.LB_detail.text = @"请选择商品规格";
        __weak typeof (self)weakself = self;
       
        self.chooseRank = [[ChooseRank alloc] initWithTitleArr:self.cellDataArr andFrame:CGRectMake(0, 0, SCREEN_WIDTH, 40)];
        self.chooseRank.tag = 8000;
        self.chooseRank.delegate = self;
        
        [self.chooseView.mainscrollview addSubview:self.chooseRank];
        ChooseRank *numView = [[ChooseRank alloc] initWithTitleArr:nil andFrame:CGRectMake(0, CGRectGetMaxY(self.chooseRank.frame), SCREEN_WIDTH, 40)];
        numView.tag = 8001;
        numView.numBtn.callBack = ^(NSString *currentNum){
            weakself.goodNumStr = currentNum;
        };
        [self.chooseView.mainscrollview addSubview:self.chooseRank];
        [self.chooseView.mainscrollview addSubview:numView];

        self.chooseView.mainscrollview.contentSize = CGSizeMake(0, self.chooseRank.height+40);
        
        //确定按钮
        [self.chooseView.buyBtn addTarget:self action:@selector(chooseViewClick) forControlEvents:UIControlEventTouchUpInside];
        //取消按钮
        [self.chooseView.cancelBtn addTarget:self action:@selector(dismissChooseView) forControlEvents:UIControlEventTouchUpInside];
        
    }
    return _chooseView;
}
-(void)preLoadSpecAction{

    self.goodNumStr = @"1";
    
    [self showChooseView];
}
// 点击返回数据rankArray代理
-(void)selectBtn:(UIButton *)btn{
    
    self.selelctModel = nil;
    
    ChooseRank *view = [[[UIApplication sharedApplication] keyWindow] viewWithTag:8000];
    
    for (UIButton *obj in  view.btnView.subviews)
    {
        if(obj.selected){
            self.selelctModel = self.cellDataArr[btn.tag-10000];
            [self.chooseView.headImage sd_setImageWithURL:[NSURL URLWithString:_selelctModel.goods_picture] placeholderImage:BGImage(@"img_placeholder")];
            self.chooseView.LB_price.text = [NSString stringWithFormat:@"￥%.2f",[_selelctModel.goods_price doubleValue]];
            self.chooseView.LB_detail.text = _selelctModel.name;
        }
    }
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
