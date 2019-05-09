//
//  BGMineViewController.m
//  shzTravelC
//
//  Created by 孙林茂 on 2018/5/4.
//  Copyright © 2018年 biao. All rights reserved.
//

#import "BGMineViewController.h"
#import "BGMineNewHeaderView.h"
#import "BGMineCustomOneCell.h"
#import "BGMineEditViewController.h"
#import "BGOrderViewController.h"
#import "BGMyWalletViewController.h"
#import "BGSettingViewController.h"
#import "BGShoppingCartViewController.h"
#import "BGCollectionViewController.h"
#import "BGReceiveAddressViewController.h"
#import "BGWebViewController.h"
#import "BGMyPublishViewController.h"
#import "BGMyAttentionViewController.h"
#import "BGMyFansViewController.h"
#import "BGSystemApi.h"
#import "BGMyActivityViewController.h"
#import "BGMyRecommendViewController.h"
#import "BGMineMsgViewController.h"
#import <JSBadgeView.h>

@interface BGMineViewController ()<UITableViewDelegate,UITableViewDataSource>

@property (nonatomic,strong)UITableView *tableView;
@property (nonatomic, strong) BGMineNewHeaderView *headerView;
@property(nonatomic,strong) UIView *footerView;
@property (nonatomic, strong) JSBadgeView *badgeView;

@end

@implementation BGMineViewController
-(JSBadgeView *)badgeView{
    if (!_badgeView) {
        self.badgeView = [[JSBadgeView alloc] initWithParentView:self.headerView.settingBtn alignment:(JSBadgeViewAlignmentTopRight)];
        _badgeView.badgeOverlayColor = [UIColor clearColor];
        _badgeView.badgeStrokeColor = [UIColor redColor];
        _badgeView.badgeShadowSize = CGSizeZero;
        _badgeView.badgePositionAdjustment = CGPointMake(-2, 2);
    }
    return _badgeView;
}
-(UIView *)footerView{
    if (!_footerView) {
        self.footerView = UIView.new;
        _footerView.backgroundColor = kAppClearColor;
        _footerView.frame = CGRectMake(0, 0, SCREEN_WIDTH, 90);
        UILabel *lab = [[UILabel alloc] initWithFrame:CGRectMake(10, 37, SCREEN_WIDTH-20, 14)];
        lab.text = @"技术支持@上海樱蓝网络科技有限公司";
        lab.font = kFont(13);
        lab.textColor = kApp333Color;
        lab.textAlignment = NSTextAlignmentCenter;
        [_footerView addSubview:lab];
        
    }
    return _footerView;
}
-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    self.navigationController.navigationBarHidden = YES;
    self.navigationController.navigationBar.translucent = YES;
    [self changeHeaderViewFrame];
    if ([self.tableView.delegate respondsToSelector:@selector(scrollViewDidScroll:)]){
        [self.tableView.delegate scrollViewDidScroll:self.tableView];
    }
}
 
-(void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
   self.navigationController.navigationBarHidden = YES;
    
    //拿到标题 标题文字的随着移动高度的变化而变化
    UILabel *titleL = (UILabel *)self.navigationItem.titleView;
    titleL.textColor = [UIColor colorWithWhite:0 alpha:0];
    [self.navigationController.navigationBar setBackgroundImage:BGImage(@"navigationbarBackgroundWhite") forBarMetrics:UIBarMetricsDefault];
}
- (void)viewDidLoad {
    [super viewDidLoad];
    [self loadSubViews];
    [self refreshView];
}
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
-(void)loadData {
    if (![Tool isLogin]) {
        return;
    }
    [ProgressHUDHelper showLoading];
    [BGSystemApi getUserInfo:nil succ:^(NSDictionary *response) {
        DLog(@"\n>>>[getUserInfo sucess]:%@",response);
    } failure:^(NSDictionary *response) {
        DLog(@"\n>>>[getUserInfo failure]:%@",response);
    }];
}
#pragma mark - 加载视图
- (void)loadSubViews {
//    self.navigationItem.title = @"我的";
//    [self.navigationController.navigationBar setBackgroundImage:[[UIImage alloc] init] forBarMetrics:UIBarMetricsDefault];
//    // 取消掉底部的那根线
//    [self.navigationController.navigationBar setShadowImage:[[UIImage alloc] init]];
    //设置标题
    UILabel *title = [[UILabel alloc] init];
    title.text = @"我的";
    [title sizeToFit];
    // 开始的时候看不见，所以alpha值为0
    title.textColor = [UIColor colorWithWhite:0 alpha:0];
    
    self.navigationItem.titleView = title;
    self.tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT-SafeAreaBottomHeight-kTabBarH) style:(UITableViewStyleGrouped)];
    _tableView.backgroundColor = kAppBgColor;
    _tableView.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
    _tableView.separatorColor = kAppBgColor;
    _tableView.dataSource = self;
    _tableView.delegate = self;
    [self.view addSubview:_tableView];
    
    // 注册cell
    [_tableView registerNib:[UINib nibWithNibName:@"BGMineCustomOneCell" bundle:nil] forCellReuseIdentifier:@"BGMineCustomOneCell"];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(changeNickNameAndId) name:@"ChangeNickNameAndId" object:nil];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(messageTipsActionThree:) name:@"messageTipsActionThree" object:nil];
   
    
    self.headerView = [[BGMineNewHeaderView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, 217+6)];
//    UIImageView *topBackgroundImgView = [[UIImageView alloc] initWithFrame:CGRectMake(0, -275, SCREEN_WIDTH, 275)];
//    [topBackgroundImgView setImage:BGImage(@"wallet_background")];
//    [_headerView addSubview:topBackgroundImgView];
    _tableView.tableHeaderView = _headerView;
    
    // 头像
    NSString *fullPath = [[NSHomeDirectory() stringByAppendingPathComponent:@"Documents"] stringByAppendingPathComponent:@"currentImage.png"];
    UIImage *savedImage = [[UIImage alloc] initWithContentsOfFile:fullPath];
    if (savedImage == nil) {
        [_headerView.headImgView setImage:BGImage(@"headImg_placeholder")];
    }else{
        [_headerView.headImgView setImage:savedImage];
    }
    // 昵称
    _headerView.mineNameLabel.text = [self valueForKeyJude:@"UserNickname"] ? : @"暂未设置昵称";
    // 傻孩子账号
    _headerView.shzIdLabel.text = [self valueForKeyJude:@"UserSHZ"] ? : @"";
    // 会员等级
    NSString *levelImgNameStr = [NSString stringWithFormat:@"mine_level_%@",[self valueForKeyJude:@"UserLevel"] ? : @"1"];
    [_headerView.levelImgView setImage:BGImage(levelImgNameStr)];
    // 个性签名
//    _headerView.mineAutographLabel.text = [self valueForKeyJude:@"UserSignature"] ?: @"暂未设置个性签名";
    _headerView.inviteCountLabel.text = [self valueForKeyJude:@"UserInviteCount"] ? : @"0";
    _headerView.integralLabel.text = [NSString stringWithFormat:@"%@积分",[self valueForKeyJude:@"UserIntegral"] ? : @"0"];
    __block typeof(self) weakSelf = self;
    _headerView.headImgBtnClick = ^{
        BGMineEditViewController *editVC = BGMineEditViewController.new;
        [weakSelf.navigationController pushViewController:editVC animated:YES];
    };
    _headerView.attentionBtnClick = ^{
        BGMyAttentionViewController *attentionVC = BGMyAttentionViewController.new;
        [weakSelf.navigationController pushViewController:attentionVC animated:YES];
    };
    _headerView.fansBtnClick = ^{
        BGMyFansViewController *fansVC = BGMyFansViewController.new;
        [weakSelf.navigationController pushViewController:fansVC animated:YES];
    };
    _headerView.recommendBtnClick = ^{
        BGMyRecommendViewController *recommendVC = BGMyRecommendViewController.new;
        [weakSelf.navigationController pushViewController:recommendVC animated:YES];
    };
    _headerView.editBtnClick = ^{
        BGMineEditViewController *editVC = BGMineEditViewController.new;
        [weakSelf.navigationController pushViewController:editVC animated:YES];
    };
    _headerView.settingBtnClick = ^{
        BGMineMsgViewController *settingVC = BGMineMsgViewController.new;
        [weakSelf.navigationController pushViewController:settingVC animated:YES];
    };
   
    
}
-(void)changeHeaderViewFrame{
    if ([Tool isLogin]) {
        [_headerView.clearView setHidden:NO];
        [_headerView.loginBtn setHidden:YES];
        [_headerView.loginLabel setHidden:YES];
        [_headerView.editBtn setHidden:NO];
        [_headerView.settingBtn setHidden:NO];
        [_headerView.headImgView setHidden:NO];
    }else{
        [_headerView.clearView setHidden:YES];
        [_headerView.loginBtn setHidden:NO];
        [_headerView.loginLabel setHidden:NO];
        [_headerView.editBtn setHidden:YES];
        [_headerView.settingBtn setHidden:YES];
        [_headerView.headImgView setHidden:YES];
        
    }
}
#pragma mark  -  TableViewDelegate  -
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 4;
}
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    switch (section) {
        case 0:
            return 1;
        case 1:
            return 2;
        case 2:
            return 5;
        case 3:
            return 2;
        default:
            return 1;
    }
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSArray *iconArr =  @[@"mine_wallet",@"mine_cart",@"mine_order",@"mine_publish",@"store_collected",@"mine_collection",@"mine_share",@"mine_address",@"mine_setting",@"mine_hotline"];
    NSArray *titleArr = @[@"我的钱包",@"购物车",@"我的订单",@"我的发布",@"我的收藏",@"我的活动",@"分享有礼",@"收货地址",@"设置",@"VIP救援"];
    BGMineCustomOneCell *cell = [tableView dequeueReusableCellWithIdentifier:@"BGMineCustomOneCell" forIndexPath:indexPath];
    
    switch (indexPath.section) {
        case 0:{
            cell.oneImgView.image =  BGImage(iconArr[indexPath.row]);
            cell.oneNameLabel.text = titleArr[indexPath.row];
        }
            break;
        case 1:{
            cell.oneImgView.image =  BGImage(iconArr[indexPath.row+1]);
            cell.oneNameLabel.text = titleArr[indexPath.row+1];
        }
            break;
        case 2:{
            cell.oneImgView.image =  BGImage(iconArr[indexPath.row+3]);
            cell.oneNameLabel.text = titleArr[indexPath.row+3];
        }
            break;
        case 3:{
            cell.oneImgView.image =  BGImage(iconArr[indexPath.row+8]);
            cell.oneNameLabel.text = titleArr[indexPath.row+8];
        }
            break;
        default:
            break;
    }
    return cell;
}
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
    switch (indexPath.section) {
        case 0:{
            if (![Tool isLogin]) {
                [WHIndicatorView toast:@"请先登录!"];
                [BGAppDelegateHelper showLoginViewController];
                return;
            }
            BGMyWalletViewController *walletVC = BGMyWalletViewController.new;
            [self.navigationController pushViewController:walletVC animated:YES];
        }
            break;
        case 1:{
            if (![Tool isLogin]) {
                [WHIndicatorView toast:@"请先登录!"];
                [BGAppDelegateHelper showLoginViewController];
                return;
            }
            if (indexPath.row == 0) { // 购物车
                BGShoppingCartViewController *cartVC = BGShoppingCartViewController.new;
                [self.navigationController pushViewController:cartVC animated:YES];
                
            }else{
                BGOrderViewController *orderVC = BGOrderViewController.new;
                [self.navigationController pushViewController:orderVC animated:YES];
            }
            
        }
            break;
        case 2:{
                if (![Tool isLogin]) {
                    [WHIndicatorView toast:@"请先登录!"];
                    [BGAppDelegateHelper showLoginViewController];
                    return;
                }
                switch (indexPath.row) {
                    case 0:{
                        BGMyPublishViewController *publishVC = BGMyPublishViewController.new;
                        [self.navigationController pushViewController:publishVC animated:YES];
                    }
                        break;
                    case 1:{
                        BGCollectionViewController *collectionVC = BGCollectionViewController.new;
                        [self.navigationController pushViewController:collectionVC animated:YES];
                    }
                        break;
                    case 2:{
                        BGMyActivityViewController *activityVC = BGMyActivityViewController.new;
                        [self.navigationController pushViewController:activityVC animated:YES];
                    }
                        break;
                    case 3:{
                        BGWebViewController *webVC = [[BGWebViewController alloc] init];
                        webVC.url = [NSString stringWithFormat:@"%@share.html?icode=%@",BGWebMainHtml,BGGetUserDefaultObjectForKey(@"inviteCode")];
                        [self.navigationController pushViewController:webVC animated:YES];
                    }
                        break;
                    case 4:{
                        BGReceiveAddressViewController *addressVC = BGReceiveAddressViewController.new;
                        addressVC.isCanSelect = NO;
                        [self.navigationController pushViewController:addressVC animated:YES];
                    }
                        break;
                        
                    default:
                        break;
                }
            
        }
            break;
        case 3:{
            if (indexPath.row == 0) {
                BGSettingViewController *settingVC = BGSettingViewController.new;
                [self.navigationController pushViewController:settingVC animated:YES];
            }else{
                // @@ 添加登录判断
                if (![Tool isLogin]) {
                    [WHIndicatorView toast:@"请先登录!"];
                    [BGAppDelegateHelper showLoginViewController];
                    return;
                }
                BGWebViewController *webVC = [[BGWebViewController alloc] init];
                webVC.url = BGWebPages(@"rescue_phone.html");
                [self.navigationController pushViewController:webVC animated:YES];
            }
        }
            break;
        default:
            break;
    }
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 45;
}
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return section == 0 ? 15:6;
}
-(CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section{
    return section == 3 ?  90:0.01;
}
- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    return nil;
}
- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section{
    if (section == 3) {
        return self.footerView;
    }else{
        return nil;
    }
}
//-(void)scrollViewDidScroll:(UIScrollView *)scrollView{
//    if (![Tool isLogin]) {
//        if (_tableView.contentOffset.y <= 0) {
//            [_tableView setContentOffset:CGPointMake(_tableView.contentOffset.x, 0)];
//        }
//    }
//}
-(NSString *)valueForKeyJude:(NSString *)key{
    NSString *valueStr = [NSString stringWithFormat:@"%@", BGGetUserDefaultObjectForKey(key)];
    if ([Tool isBlankString:valueStr]) {
        return nil;
    }else{
        return valueStr;
    }
}

-(void)changeNickNameAndId {
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        
        // 头像
        NSString *fullPath = [[NSHomeDirectory() stringByAppendingPathComponent:@"Documents"] stringByAppendingPathComponent:@"currentImage.png"];
        UIImage *savedImage = [[UIImage alloc] initWithContentsOfFile:fullPath];
        if (savedImage == nil) {
            [self.headerView.headImgView setImage:BGImage(@"headImg_placeholder")];
        }else{
            [self.headerView.headImgView setImage:savedImage];
        }
        
        // 昵称
        self.headerView.mineNameLabel.text = [self valueForKeyJude:@"UserNickname"] ? : @"暂未设置昵称";
        // 傻孩子账号
        self.headerView.shzIdLabel.text = [self valueForKeyJude:@"UserSHZ"] ? : @"";
        // 会员等级
        NSString *levelImgNameStr = [NSString stringWithFormat:@"mine_level_%@",[self valueForKeyJude:@"UserLevel"] ? : @"1"];
        [self.headerView.levelImgView setImage:BGImage(levelImgNameStr)];
        // 个性签名
//        self.headerView.mineAutographLabel.text = [self valueForKeyJude:@"UserSignature"] ?: @"暂未设置个性签名";
        self.headerView.inviteCountLabel.text = [self valueForKeyJude:@"UserInviteCount"] ? : @"0";
        self.headerView.integralLabel.text = [NSString stringWithFormat:@"%@积分",[self valueForKeyJude:@"UserIntegral"] ? : @"0"];
        
        self.headerView.concernLabel.text = [self valueForKeyJude:@"UserConcern"] ? : @"0";
        self.headerView.fansLabel.text = [self valueForKeyJude:@"UserFans"] ? : @"0";
        self.headerView.collectedLabel.text = [self valueForKeyJude:@"UserCollected"] ? : @"0";
        self.headerView.likeLabel.text = [self valueForKeyJude:@"UserLike"] ? : @"0";
        
    });
   
}
- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
//    NSLog(@"%f", scrollView.contentOffset.y);
    CGFloat offset = scrollView.contentOffset.y;
    if (offset<44) {
        self.navigationController.navigationBarHidden = YES;
    }else{
        self.navigationController.navigationBarHidden = NO;
    }
//    CGFloat imgH = 100 - offset;
//    if (imgH < 64) {
//        imgH = 64;
//    }
//    self.imageHeight.constant = imgH;
    
    //根据透明度来生成图片
    //找最大值/
    CGFloat alpha = offset * 1 / 136.0;   // (200 - 64) / 136.0f
    if (alpha >= 1) {
        alpha = 0.99;
    }
    
    //拿到标题 标题文字的随着移动高度的变化而变化
    UILabel *titleL = (UILabel *)self.navigationItem.titleView;
    titleL.textColor = [UIColor colorWithWhite:0 alpha:alpha];
    
    //把颜色生成图片
    UIColor *alphaColor = [UIColor colorWithWhite:1 alpha:alpha];
    //把颜色生成图片
    UIImage *alphaImage = [self imageWithColor:alphaColor];
    //修改导航条背景图片
    [self.navigationController.navigationBar setBackgroundImage:alphaImage forBarMetrics:UIBarMetricsDefault];
    
}
- (UIImage *)imageWithColor:(UIColor *)color {
    
    CGRect rect = CGRectMake(0, 0, 1.0f, 1.0f);
    // 开启位图上下文
    UIGraphicsBeginImageContext(rect.size);
    // 开启上下文
    CGContextRef ref = UIGraphicsGetCurrentContext();
    // 使用color演示填充上下文
    CGContextSetFillColorWithColor(ref, color.CGColor);
    // 渲染上下文
    CGContextFillRect(ref, rect);
    // 从上下文中获取图片
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    // 结束上下文
    UIGraphicsEndImageContext();
    return image;
}
-(void)messageTipsActionThree:(NSNotification *)no{
    NSString *status = [no object];
    if (status.intValue>0) {
        self.badgeView.badgeText = status;
        [self.badgeView setNeedsLayout];
    }else{
        self.badgeView.badgeText = nil;
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
