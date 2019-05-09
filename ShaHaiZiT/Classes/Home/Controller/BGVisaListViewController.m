//
//  BGVisaListViewController.m
//  ShaHaiZiT
//
//  Created by biao on 2019/1/19.
//  Copyright © 2019 biao. All rights reserved.
//

#import "BGVisaListViewController.h"
#import "BGVisaListModel.h"
#import "BGVisaListCell.h"
#import "BGAirApi.h"
#import <JCAlertController.h>
#import "BGVisaDetailViewController.h"

@interface BGVisaListViewController ()<UITableViewDelegate,UITableViewDataSource>

@property (nonatomic, strong) NSMutableArray *cellDataArr;

@property (nonatomic, strong) UITableView *tableView;

@property (nonatomic, strong) UIView *noneView;
// 页数
@property (nonatomic, copy) NSString *pageNum;

@end

@implementation BGVisaListViewController

-(UIView *)noneView {
    if (!_noneView) {
        self.noneView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT-SafeAreaTopHeight)];
        _noneView.backgroundColor = kAppBgColor;
        [_noneView setHidden:YES];
        UIImageView *noneImgView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"noToken_bg"]];
        noneImgView.frame = CGRectMake(SCREEN_WIDTH*0.2, 60, SCREEN_WIDTH*0.6, SCREEN_WIDTH*0.6*1.02);
        [_noneView addSubview:noneImgView];
        
        UILabel *showMsgLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, noneImgView.frame.origin.y+noneImgView.frame.size.height+50, SCREEN_WIDTH-20, 20)];
        showMsgLabel.textAlignment = NSTextAlignmentCenter;
        [showMsgLabel setTextColor:kAppTipBGColor];
        showMsgLabel.font = kFont(14);
        showMsgLabel.text = @"暂无签证信息";
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
-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    self.navigationController.navigationBarHidden = NO;
}
- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self loadSubViews];
    [self refreshView];
}

- (void)loadSubViews {
    
    self.view.backgroundColor = kAppBgColor;
    self.navigationItem.title = self.titleStr;
    UIButton *noteBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [noteBtn setTitle:@"领区说明" forState:(UIControlStateNormal)];
    [noteBtn setTitle:@"领区说明" forState:(UIControlStateHighlighted)];
    [noteBtn setTitleColor:kAppMainColor forState:(UIControlStateNormal)];
    [noteBtn setTitleColor:kAppMainColor forState:(UIControlStateHighlighted)];
    [noteBtn.titleLabel setFont:kFont(14)];
    noteBtn.bounds = CGRectMake(0, 0, 70, 30);
    noteBtn.contentEdgeInsets = UIEdgeInsetsZero;
    noteBtn.contentHorizontalAlignment = UIControlContentHorizontalAlignmentRight;
    UIBarButtonItem *noteItem = [[UIBarButtonItem alloc] initWithCustomView:noteBtn];
    self.navigationItem.rightBarButtonItem = noteItem;
    @weakify(self);
    [[noteBtn rac_signalForControlEvents:(UIControlEventTouchUpInside)] subscribeNext:^(__kindof UIControl * _Nullable x) {
        @strongify(self);
        // 点击button的响应事件
        NSMutableDictionary *param = [[NSMutableDictionary alloc] init];
        [param setObject:self.country_id forKey:@"country_id"];
        [ProgressHUDHelper showLoading];
        __weak typeof(self) weakSelf = self;
        [BGAirApi getConsulateInfo:param succ:^(NSDictionary *response) {
            DLog(@"\n>>>[getConsulateInfo sucess]:%@",response);
            NSString *consulate_name = [NSString stringWithFormat:@"%@",BGdictSetObjectIsNil(response[@"result"][@"consulate_name"])];
            NSString *consulate_description = [NSString stringWithFormat:@"%@",BGdictSetObjectIsNil(response[@"result"][@"consulate_description"])];
            JCAlertStyle *style = [JCAlertStyle shareStyle];
            style.background.canDismiss = YES;
            style.title.backgroundColor = kAppMainColor;
            style.title.font = kFont(15);
            style.title.textColor = kAppWhiteColor;
            style.alertView.width = SCREEN_WIDTH*0.9;
            CGFloat width = [JCAlertStyle shareStyle].alertView.width;
            UIWebView *webView = [[UIWebView alloc] initWithFrame:CGRectMake(0, 0, width, SCREEN_HEIGHT*0.6)];
            webView.backgroundColor = kAppWhiteColor;
            [webView loadHTMLString:[Tool attributeByWeb:consulate_description width:width scale:width*0.96] baseURL:nil];
            JCAlertController *alert = [JCAlertController alertWithTitle:consulate_name contentView:webView];
           
            [alert addButtonWithTitle:@"确定" type:JCButtonTypeNormal clicked:^{
                
            }];
            [weakSelf presentViewController:alert animated:YES completion:nil];
        } failure:^(NSDictionary *response) {
            DLog(@"\n>>>[getConsulateInfo failure]:%@",response);
          
        }];
    }];
    
    self.tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, SafeAreaTopHeight, SCREEN_WIDTH, SCREEN_HEIGHT-SafeAreaTopHeight) style:(UITableViewStyleGrouped)];
    _tableView.backgroundColor = kAppBgColor;
    _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    _tableView.separatorColor = kAppBgColor;
    _tableView.estimatedRowHeight = SCREEN_HEIGHT;
    _tableView.dataSource = self;
    _tableView.delegate = self;
    [self.view addSubview:_tableView];
    
    // 注册cell
    [_tableView registerNib:[UINib nibWithNibName:@"BGVisaListCell" bundle:nil] forCellReuseIdentifier:@"BGVisaListCell"];
    _pageNum = @"1";
}

#pragma mark UITableView + 下拉刷新 隐藏时间
- (void)refreshView
{
    // 设置回调（一旦进入刷新状态，就调用target的action，也就是调用self的loadNewData方法）
    __weak __typeof(self) weakSelf = self;
    
    // 设置回调（一旦进入刷新状态就会调用这个refreshingBlock）
    self.tableView.mj_header = [MJRefreshNormalHeader headerWithRefreshingBlock:^{
        // 设置自动切换透明度(在导航栏下面自动隐藏)
        weakSelf.tableView.mj_header.automaticallyChangeAlpha = YES;
        weakSelf.pageNum = @"1";
        [weakSelf loadData];
        [weakSelf.tableView.mj_header endRefreshing];
    }];
    
    // 上拉刷新
    self.tableView.mj_footer = [MJRefreshAutoFooter footerWithRefreshingBlock:^{
        //每次刷新,页码都加一页
        NSInteger nowPindex = [weakSelf.pageNum integerValue]+1;
        weakSelf.pageNum = [NSString stringWithFormat:@"%zd",nowPindex];
        [weakSelf loadData];
        //        [weakSelf.tableView.mj_footer endRefreshing];
    }];
    [self loadData];
}
-(void)loadData {
    NSMutableDictionary *param = [[NSMutableDictionary alloc] init];
    [param setObject:_pageNum forKey:@"pageno"];
    [param setObject:@"10" forKey:@"pagesize"];
    [param setObject:@"6" forKey:@"product_set_cd"];
    [param setObject:_country_id forKey:@"country_id"];
    [ProgressHUDHelper showLoading];
    __weak typeof(self) weakSelf = self;
    [BGAirApi getVisaList:param succ:^(NSDictionary *response) {
        DLog(@"\n>>>[getVisaList sucess]:%@",response);
        [weakSelf hideNodateView];
        if (weakSelf.pageNum.intValue == 1) {
            [weakSelf.cellDataArr removeAllObjects];
            [weakSelf.tableView.mj_footer resetNoMoreData];
        }
        NSMutableArray *tempArr = [BGVisaListModel mj_objectArrayWithKeyValuesArray:BGdictSetObjectIsNil(response[@"result"][@"rows"])];
        NSString *totalPageNumStr = [NSString stringWithFormat:@"%@",BGdictSetObjectIsNil(response[@"result"][@"pages"])];
        if (weakSelf.pageNum.integerValue<=totalPageNumStr.integerValue) {
            [weakSelf.cellDataArr addObjectsFromArray:tempArr];
        }
        [weakSelf.tableView reloadData];
        if (weakSelf.pageNum.integerValue>=totalPageNumStr.integerValue) {
            [weakSelf.tableView.mj_footer endRefreshingWithNoMoreData];
        }else{
            [weakSelf.tableView.mj_footer endRefreshing];
        }
    } failure:^(NSDictionary *response) {
        DLog(@"\n>>>[getVisaList failure]:%@",response);
        [self shownoNetWorkViewWithType:0];
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

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    BGVisaListModel *model = _cellDataArr[indexPath.section];
    BGVisaListCell *cell = [tableView dequeueReusableCellWithIdentifier:@"BGVisaListCell" forIndexPath:indexPath];
    if ([Tool arrayIsNotEmpty:_cellDataArr]) {
        [cell updataWithCellArray:model];
    }
    return cell;
}
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
    BGVisaListModel *model = _cellDataArr[indexPath.section];
    BGVisaDetailViewController *detailVC = BGVisaDetailViewController.new;
    detailVC.product_id = model.ID;
    [self.navigationController pushViewController:detailVC animated:YES];
}
-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    if (_cellDataArr.count == 0) {
        return 0.01;
    }else{
        return section == 0? 6:3;
    }
}
- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    return nil;
}

-(CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section{
    if (_cellDataArr.count == 0) {
        return _tableView.frame.size.height;
    }else{
        return 0.01;
    }
}
- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section{
    if (_cellDataArr.count == 0) {
        return self.noneView;
    }
    return nil;
}
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 138;
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
