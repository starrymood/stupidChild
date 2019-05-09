//
//  BGPromotionNewViewController.m
//  shzTravelC
//
//  Created by biao on 2018/9/13.
//  Copyright © 2018年 biao. All rights reserved.
//

#import "BGPromotionNewViewController.h"
#import "BGPromotionNewCell.h"
#import "BGPromotionNewModel.h"
#import <SDCycleScrollView.h>
#import "BGWebViewController.h"
#import "BGAirApi.h"
#import "BGStrategyModel.h"
#import "BGPromotionPastListViewController.h"
#import "BGPromotionMsgViewController.h"
#import "BGSystemApi.h"
#import <JSBadgeView.h>

@interface BGPromotionNewViewController ()<SDCycleScrollViewDelegate,UITableViewDelegate,UITableViewDataSource>

@property (nonatomic, strong) NSMutableArray *cellDataArr;

@property (nonatomic, strong) NSMutableArray *cycleDataArr;

@property (nonatomic, strong) SDCycleScrollView *cycleScrollView;

@property (nonatomic, strong) UITableView *tableView;

@property (nonatomic, strong) UIButton *messageBtn;

@property (nonatomic, strong) JSBadgeView *badgeView;

@end

@implementation BGPromotionNewViewController
-(JSBadgeView *)badgeView{
    if (!_badgeView) {
        self.badgeView = [[JSBadgeView alloc] initWithParentView:_messageBtn alignment:(JSBadgeViewAlignmentTopRight)];
        _badgeView.badgeOverlayColor = [UIColor clearColor];
        _badgeView.badgeStrokeColor = [UIColor redColor];
        _badgeView.badgeShadowSize = CGSizeZero;
        _badgeView.badgePositionAdjustment = CGPointMake(-10, 5);
    }
    return _badgeView;
}
-(NSMutableArray *)cycleDataArr{
    if (!_cycleDataArr) {
        self.cycleDataArr = [NSMutableArray array];
    }
    return _cycleDataArr;
}
-(NSMutableArray *)cellDataArr {
    if (!_cellDataArr) {
        self.cellDataArr = [NSMutableArray array];
    }
    return _cellDataArr;
}
-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    self.navigationController.navigationBarHidden = NO;
    self.navigationController.navigationBar.translucent = YES;
}
- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self loadSubViews];
    [self loadData];
}

- (void)loadSubViews {
    
    self.navigationItem.title = @"活动";
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(messageTipsActionTwo:) name:@"messageTipsActionTwo" object:nil];
    self.messageBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [_messageBtn setImage:BGImage(@"home_message") forState:UIControlStateNormal];
    [_messageBtn setImage:BGImage(@"home_message") forState:UIControlStateHighlighted];
    _messageBtn.bounds = CGRectMake(0, 0, 70, 30);
    _messageBtn.imageEdgeInsets = UIEdgeInsetsMake(0, 0, 0, -30);
    _messageBtn.contentEdgeInsets = UIEdgeInsetsZero;
    @weakify(self);
    [[_messageBtn rac_signalForControlEvents:(UIControlEventTouchUpInside)] subscribeNext:^(__kindof UIControl * _Nullable x) {
        @strongify(self);
        // 点击button的响应事件
        if (![Tool isLogin]) {
            [WHIndicatorView toast:@"请先登录!"];
            [BGAppDelegateHelper showLoginViewController];
            return;
        }
        BGPromotionMsgViewController *messageVC = BGPromotionMsgViewController.new;
        [self.navigationController pushViewController:messageVC animated:YES];
    }];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:_messageBtn];
    self.view.backgroundColor = kAppBgColor;
    UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_WIDTH*9/16+24+38+6)];
    headerView.backgroundColor = kAppBgColor;
    
    // 轮播图 
    self.cycleScrollView = [SDCycleScrollView cycleScrollViewWithFrame:CGRectMake(0, 6, SCREEN_WIDTH, SCREEN_WIDTH*9/16) delegate:self placeholderImage:BGImage(@"home_cycle_placeholder")];
    self.cycleScrollView.pageControlAliment = SDCycleScrollViewPageContolAlimentCenter;
    self.cycleScrollView.pageControlBottomOffset = -27;
//    self.cycleScrollView.bannerImageViewContentMode = UIViewContentModeScaleAspectFit;
    self.cycleScrollView.backgroundColor = kAppBgColor;
    self.cycleScrollView.currentPageDotImage = BGImage(@"pageControlCurrentCircle");
    self.cycleScrollView.pageDotImage = BGImage(@"pageControlCircle");
    self.cycleScrollView.hidesForSinglePage = NO;
    [headerView addSubview:_cycleScrollView];
    
    UIView *whiteView = [[UIView alloc] initWithFrame:CGRectMake(0, _cycleScrollView.y+_cycleScrollView.height+24, SCREEN_WIDTH, 38)];
    whiteView.backgroundColor = kAppWhiteColor;
    [headerView addSubview:whiteView];
    
    UIImageView *hotImgView = [[UIImageView alloc] initWithImage:BGImage(@"promotion_new_hot")];
    hotImgView.frame = CGRectMake(0, 11, 95, 27);
    [whiteView addSubview:hotImgView];
    UILabel *hotLabel = UILabel.new;
    hotLabel.frame = CGRectMake(9, 5.5, 70, 16);
    hotLabel.textColor = kAppWhiteColor;
    hotLabel.font = kFont(14);
    hotLabel.text = @"热门活动";
    hotLabel.textAlignment = NSTextAlignmentCenter;
    [hotImgView addSubview:hotLabel];
    
    UIButton *seeMoreBtn = [UIButton buttonWithType:(UIButtonTypeCustom)];
    [seeMoreBtn setTitle:@"往期精彩 >" forState:(UIControlStateNormal)];
    [seeMoreBtn.titleLabel setFont:kFont(14)];
    [seeMoreBtn setTitleColor:kApp999Color forState:(UIControlStateNormal)];
    seeMoreBtn.frame = CGRectMake(SCREEN_WIDTH-85,17, 72, 15);
    [whiteView addSubview:seeMoreBtn];
    
    [[seeMoreBtn rac_signalForControlEvents:(UIControlEventTouchUpInside)] subscribeNext:^(__kindof UIControl * _Nullable x) {
        @strongify(self);
        // 点击button的响应事件
        BGPromotionPastListViewController *listVC = BGPromotionPastListViewController.new;
        listVC.navigationItem.title = @"往期活动";
        listVC.type = 1;
        [self.navigationController pushViewController:listVC animated:YES];
    }];
    
    self.tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, SafeAreaTopHeight, SCREEN_WIDTH, SCREEN_HEIGHT-SafeAreaTopHeight-SafeAreaBottomHeight-kTabBarH) style:(UITableViewStyleGrouped)];
    _tableView.backgroundColor = kAppBgColor;
    _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    _tableView.separatorColor = kAppBgColor;
    _tableView.tableHeaderView = headerView;
    _tableView.dataSource = self;
    _tableView.delegate = self;
    [self.view addSubview:_tableView];
    
    // 注册cell
    [_tableView registerNib:[UINib nibWithNibName:@"BGPromotionNewCell" bundle:nil] forCellReuseIdentifier:@"BGPromotionNewCell"];
    
}


-(void)loadData {

    [ProgressHUDHelper showLoading];
    __weak typeof(self) weakSelf = self;
    [BGAirApi getNewActivityInfo:nil succ:^(NSDictionary *response) {
         DLog(@"\n>>>[getNewActivityInfo sucess]:%@",response);
        [weakSelf hideNodateView];
        weakSelf.cycleDataArr = [BGStrategyModel mj_objectArrayWithKeyValuesArray:response[@"result"][@"banner_list"]];
        NSMutableArray *imgArray = [NSMutableArray array];
        
        for (BGStrategyModel *model in weakSelf.cycleDataArr) {
            [imgArray addObject:model.bannerImages];
        }
        weakSelf.cycleScrollView.imageURLStringsGroup = imgArray;
        weakSelf.cellDataArr = [BGPromotionNewModel mj_objectArrayWithKeyValuesArray:response[@"result"][@"activity_list"]];
        if ([Tool isLogin]) {
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                [BGSystemApi getMsgUnreadNum:nil succ:^(NSDictionary *response) {
                    DLog(@"\n>>>[getMsgUnreadNum sucess]:%@",response);
                } failure:^(NSDictionary *response) {
                    DLog(@"\n>>>[getMsgUnreadNum failure]:%@",response);
                }];
            });
        }
       
        [weakSelf.tableView reloadData];
    } failure:^(NSDictionary *response) {
        DLog(@"\n>>>[getNewActivityInfo failure]:%@",response);
        [ProgressHUDHelper removeLoading];
        [self shownoNetWorkViewWithType:0];
        [self setRefreshBlock:^{
            [weakSelf loadData];
        }];
    }];
}

#pragma mark  -  TableViewDelegate  -
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    self.tableView.mj_footer.hidden = self.cellDataArr.count == 0;
    return _cellDataArr.count;
}
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    BGPromotionNewModel *model = _cellDataArr[indexPath.section];
    BGPromotionNewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"BGPromotionNewCell" forIndexPath:indexPath];
    if ([Tool arrayIsNotEmpty:_cellDataArr]) {
        [cell updataWithCellArray:model];
    }
    return cell;
}
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
    if (![Tool isLogin]) {
        [WHIndicatorView toast:@"请先登录!"];
        [BGAppDelegateHelper showLoginViewController];
        return;
    }
    BGPromotionNewModel *model = _cellDataArr[indexPath.section];
    BGWebViewController *webVC = BGWebViewController.new;
    webVC.url = BGWebActivityHtml(model.ID);
    webVC.activityTitleStr = model.activityTitle;

    webVC.isShowActivityShare = YES;
    webVC.subTitleStr = model.activitySubtitle;
    webVC.service_id = model.serviceId;
    webVC.service_name = model.serviceName;
    [self.navigationController pushViewController:webVC animated:YES];
}
-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    return section == 0? 0.01:6;
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
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    BGPromotionNewModel *model = _cellDataArr[indexPath.section];
    NSInteger lineNum = [self needLinesWithWidth:(SCREEN_WIDTH-25-20) text:model.activitySubtitle];
   return 17+(SCREEN_WIDTH-24)*9/16+13+15+12+14.5*lineNum+8+12+10;
}

/** 点击图片回调 */
- (void)cycleScrollView:(SDCycleScrollView *)cycleScrollView didSelectItemAtIndex:(NSInteger)index{
    
    BGStrategyModel *model = _cycleDataArr[index];
    if (![Tool isBlankString:model.linkUrl]) {
        BGWebViewController *webVC = BGWebViewController.new;
        webVC.url = model.linkUrl;
        [self.navigationController pushViewController:webVC animated:YES];
    }
}
/**
 显示当前文字需要几行
 
 @param width 给定一个宽度
 @return 返回行数
 */
- (NSInteger)needLinesWithWidth:(CGFloat)width text:(NSString *)text{
    //创建一个labe
    UILabel * label = [[UILabel alloc]init];
    //font和当前label保持一致
    label.font = kFont(12);
    NSInteger sum = 0;
    //总行数受换行符影响，所以这里计算总行数，需要用换行符分隔这段文字，然后计算每段文字的行数，相加即是总行数。
    NSArray * splitText = [text componentsSeparatedByString:@"\n"];
    for (NSString * sText in splitText) {
        label.text = sText;
        //获取这段文字一行需要的size
        CGSize textSize = [label systemLayoutSizeFittingSize:CGSizeZero];
        //size.width/所需要的width 向上取整就是这段文字占的行数
        NSInteger lines = ceilf(textSize.width/width);
        //当是0的时候，说明这是换行，需要按一行算。
        lines = lines == 0?1:lines;
        sum += lines;
    }
    if ([Tool isBlankString:text]) {
        return 0;
    }
    return sum;
}
-(void)messageTipsActionTwo:(NSNotification *)no{
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
