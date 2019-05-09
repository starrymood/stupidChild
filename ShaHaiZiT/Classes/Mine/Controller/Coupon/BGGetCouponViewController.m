//
//  BGGetCouponViewController.m
//  shzTravelC
//
//  Created by biao on 2018/11/1.
//  Copyright © 2018年 biao. All rights reserved.
//

#import "BGGetCouponViewController.h"
#import <UIImageView+WebCache.h>
#import "BGGetCouponCell.h"
#import "BGMemberApi.h"
#import "BGCouponModel.h"
#import <UMShare/UMShare.h>
#import <UShareUI/UShareUI.h>
#import "BGAirApi.h"
#import <SDCycleScrollView.h>
#import "BGHomeCycleModel.h"

@interface BGGetCouponViewController ()<UITableViewDelegate, UITableViewDataSource>
@property (nonatomic, strong) UITableView *tableView;
// cell的数据数组
@property (nonatomic,strong) NSMutableArray *cellDataArr;

@property (nonatomic, strong) UIView *noneView;

@property (nonatomic, strong) SDCycleScrollView *cycleScrollView;
/** 轮播图数据 */
@property (nonatomic,strong) NSMutableArray *cycleDataArray;

@end

@implementation BGGetCouponViewController
- (NSMutableArray *)cycleDataArray {
    if (!_cycleDataArray) {
        self.cycleDataArray = [NSMutableArray array];
    }
    return _cycleDataArray;
}
-(UIView *)noneView {
    if (!_noneView) {
        self.noneView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT-SafeAreaTopHeight-SCREEN_WIDTH*200/375-6)];
        _noneView.backgroundColor = kAppBgColor;
        [_noneView setHidden:YES];
        UIImageView *noneImgView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"noToken_bg"]];
        noneImgView.frame = CGRectMake(SCREEN_WIDTH*0.2, 60, SCREEN_WIDTH*0.6, SCREEN_WIDTH*0.6*1.02);
        [_noneView addSubview:noneImgView];
        
        UILabel *showMsgLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, noneImgView.frame.origin.y+noneImgView.frame.size.height+50, SCREEN_WIDTH-20, 20)];
        showMsgLabel.textAlignment = NSTextAlignmentCenter;
        [showMsgLabel setTextColor:kAppTipBGColor];
        showMsgLabel.font = kFont(14);
        showMsgLabel.text = @"暂无可领优惠券~";
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
    [self loadCycleData];
}

-(void)loadSubViews {
    self.navigationItem.title = @"领券中心";
    self.view.backgroundColor = kAppBgColor;
    
    self.navigationItem.rightBarButtonItem = [UIBarButtonItem itemWithImage:@"travel_share_green" highImage:@"travel_share_green" target:self action:@selector(clickedShareItem:)];
    
    UIView *headView = UIView.new;
    headView.backgroundColor = kAppBgColor;
    headView.frame = CGRectMake(0, 6, SCREEN_WIDTH, SCREEN_WIDTH*200/375+12);
    
    self.cycleScrollView = [SDCycleScrollView cycleScrollViewWithFrame:CGRectMake(0, 6, SCREEN_WIDTH, SCREEN_WIDTH*200/375) delegate:nil placeholderImage:BGImage(@"home_cycle_placeholder")];
    self.cycleScrollView.pageControlAliment = SDCycleScrollViewPageContolAlimentCenter;
//    self.cycleScrollView.bannerImageViewContentMode = UIViewContentModeScaleAspectFit;
    self.cycleScrollView.backgroundColor = kAppBgColor;
    [headView addSubview:_cycleScrollView];
    
    self.tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, SafeAreaTopHeight, SCREEN_WIDTH, SCREEN_HEIGHT-SafeAreaTopHeight-SafeAreaBottomHeight) style:(UITableViewStyleGrouped)];
    _tableView.backgroundColor = kAppBgColor;
    _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    _tableView.estimatedRowHeight = 0;
    _tableView.estimatedSectionHeaderHeight = 0;
    _tableView.estimatedSectionFooterHeight = 0;
    _tableView.dataSource = self;
    _tableView.delegate = self;
    _tableView.tableHeaderView = headView;
    [self.view addSubview:_tableView];
    
    [self.tableView registerNib:[UINib nibWithNibName:@"BGGetCouponCell" bundle:nil] forCellReuseIdentifier:@"BGGetCouponCell"];
    
}
-(void)loadCycleData{
    __block typeof(self) weakSelf = self;
    [BGAirApi getCouponCycleInfo:nil succ:^(NSDictionary *response) {
        DLog(@"\n>>>[getCouponCycleInfo sucess]:%@",response);
        [weakSelf loadData];
        // 轮播图
        weakSelf.cycleDataArray  = [BGHomeCycleModel mj_objectArrayWithKeyValuesArray:BGdictSetObjectIsNil(response[@"result"])];
        NSMutableArray *imgArray = [NSMutableArray array];
        
        for (BGHomeCycleModel *model in weakSelf.cycleDataArray) {
            
            [imgArray addObject:model.bannerImages];
        }
        weakSelf.cycleScrollView.imageURLStringsGroup = imgArray;
    } failure:^(NSDictionary *response) {
        DLog(@"\n>>>[getCouponCycleInfo failure]:%@",response);
         [weakSelf loadData];
    }];
}
-(void)loadData {
    
    __block typeof(self) weakSelf = self;
    NSMutableDictionary *param = [NSMutableDictionary dictionary];
    [param setObject:@"50" forKey:@"pagesize"];
    [param setObject:@"1" forKey:@"pageno"];
    [BGMemberApi getCenterCouponList:param succ:^(NSDictionary *response) {
        DLog(@"\n>>>[getCenterCouponList sucess]:%@",response);
        [weakSelf hideNodateView];
        [weakSelf.cellDataArr removeAllObjects];
        weakSelf.cellDataArr = [BGCouponModel mj_objectArrayWithKeyValuesArray:response[@"result"][@"rows"]];
        if (weakSelf.cellDataArr.count>0) {
            [weakSelf.noneView removeFromSuperview];
        }
        [weakSelf.tableView reloadData];
    } failure:^(NSDictionary *response) {
        DLog(@"\n>>>[getCenterCouponList failure]:%@",response);
        [weakSelf shownoNetWorkViewWithType:0];
        [self setRefreshBlock:^{
            [weakSelf loadData];
        }];
    }];
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
    BGGetCouponCell *cell = [tableView dequeueReusableCellWithIdentifier:@"BGGetCouponCell" forIndexPath:indexPath];
    
    if ([Tool arrayIsNotEmpty:_cellDataArr]) {
        BGCouponModel *model = _cellDataArr[indexPath.section];
        [cell updataWithCellArray:model];
        @weakify(self);
        [[[cell.getCouponBtn rac_signalForControlEvents:(UIControlEventTouchUpInside)] takeUntil:cell.rac_prepareForReuseSignal] subscribeNext:^(__kindof UIControl * _Nullable x) {
            @strongify(self);
            // 点击button的响应事件
            if (![Tool isLogin]) {
                [WHIndicatorView toast:@"请先登录!"];
                [BGAppDelegateHelper showLoginViewController];
                return;
            }
            NSMutableDictionary *param = [[NSMutableDictionary alloc] init];
            [param setObject:model.ID forKey:@"coupon_id"];
            [ProgressHUDHelper showLoading];
            __block typeof(self) weakSelf = self;
            [BGMemberApi getCouponAction:param succ:^(NSDictionary *response) {
                DLog(@"\n>>>[getCouponAction sucess]:%@",response);
                [WHIndicatorView toast:BGdictSetObjectIsNil(response[@"msg"])];
                [weakSelf loadData];
            } failure:^(NSDictionary *response) {
                DLog(@"\n>>>[getCouponAction failure]:%@",response);
            }];
            
        }];
    }
    
    return cell;
}
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
   
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 95;
}
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    if (_cellDataArr.count == 0) {
        return 0.01;
    }else{
        return 13;
    }
}
-(CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section{
    if (_cellDataArr.count == 0) {
        return _tableView.frame.size.height-SCREEN_WIDTH*200/375-6;
    }else{
        return 0.01;
    }
}
- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    return UIView.new;
}
- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section{
    if (_cellDataArr.count == 0) {
        return self.noneView;
    }
    return nil;
}

#pragma mark - clickedShareItem

- (void)clickedShareItem:(UIButton *)btn{
    [self showShareAction];
}
-(void)showShareAction {
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
                //                UMSocialShareResponse *resp = data;
                //                DLog(@"\n>>>[UMSocialManager message]:%@ originalResponse:%@",resp.message,resp.originalResponse);
                [WHIndicatorView toast:@"分享成功"];
            }else{
                //                DLog(@"/n[share]");
                [WHIndicatorView toast:@"分享成功"];
            }
        }
    }];
    
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
