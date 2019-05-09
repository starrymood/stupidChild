//
//  BGCommunityMsgViewController.m
//  ShaHaiZiT
//
//  Created by biao on 2019/1/20.
//  Copyright © 2019 biao. All rights reserved.
//

#import "BGCommunityMsgViewController.h"
#import "BGMessageTypeCell.h"
#import "BGMemberApi.h"
#import "BGSysMsgModel.h"
#import "BGUserHomepageViewController.h"
#import "BGEssayDetailViewController.h"
#import "BGDouYinViewController.h"
#import "BGEssayCommentDetailViewController.h"
#import "BGSystemApi.h"

@interface BGCommunityMsgViewController ()<UITableViewDataSource,UITableViewDelegate>

@property (nonatomic,strong)UITableView *tableView;
// cell的数据数组
@property (nonatomic,strong) NSMutableArray *cellDataArr;

// 页数
@property (nonatomic, copy) NSString *pageNum;

@property (nonatomic, strong) UIView *noneView;

@end

@implementation BGCommunityMsgViewController

-(UIView *)noneView {
    if (!_noneView) {
        self.noneView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT-SafeAreaTopHeight)];
        _noneView.backgroundColor = kAppBgColor;
        [_noneView setHidden:YES];
        UIImageView *noneImgView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"no_chat_message"]];
        noneImgView.frame = CGRectMake(SCREEN_WIDTH*0.4, SafeAreaTopHeight+60, SCREEN_WIDTH*0.2, SCREEN_WIDTH*0.2*0.88);
        [_noneView addSubview:noneImgView];
        UILabel *showMsgLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, noneImgView.frame.origin.y+noneImgView.frame.size.height+50, SCREEN_WIDTH-20, 20)];
        showMsgLabel.textAlignment = NSTextAlignmentCenter;
        [showMsgLabel setTextColor:kAppTipBGColor];
        showMsgLabel.font = kFont(14);
        showMsgLabel.text = @"亲，您还没有社区消息哟~";
        [_noneView addSubview:showMsgLabel];
        
        __weak typeof(self)weakSelf = self;
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [weakSelf.noneView setHidden:NO];
        });
    }
    return _noneView;
}
-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    self.navigationController.navigationBarHidden = NO;
    self.pageNum = @"1";
    [self loadData];
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
    [self refreshView];
}

#pragma mark - 加载视图
- (void)loadSubViews {
    
    self.navigationItem.title = @"我的社区消息";
    self.view.backgroundColor = kAppBgColor;
    self.tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, SafeAreaTopHeight, SCREEN_WIDTH, SCREEN_HEIGHT-SafeAreaTopHeight) style:(UITableViewStyleGrouped)];
    _tableView.backgroundColor = kAppBgColor;
    _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    _tableView.separatorColor = kAppBgColor;
    _tableView.estimatedRowHeight = 0;
    _tableView.estimatedSectionHeaderHeight = 0;
    _tableView.estimatedSectionFooterHeight = 0;
    _tableView.dataSource = self;
    _tableView.delegate = self;
    [self.view addSubview:_tableView];
    
    [self.tableView registerNib:[UINib nibWithNibName:@"BGMessageTypeCell" bundle:nil] forCellReuseIdentifier:@"BGMessageTypeCell"];
    _pageNum = @"1";
    
}

#pragma mark - 加载数据  -

- (void)loadData {
    
    NSMutableDictionary *param = [[NSMutableDictionary alloc] init];
    [param setObject:@"1" forKey:@"pageno"];
    [param setObject:@"10" forKey:@"pagesize"];
    
    __weak __typeof(self) weakSelf = self;
    [BGMemberApi getCommunityMessage:param succ:^(NSDictionary *response) {
        DLog(@"\n>>>[getCommunityMessage sucess]:%@",response);
        [weakSelf hideNodateView];
        if (weakSelf.pageNum.intValue == 1) {
            [weakSelf.cellDataArr removeAllObjects];
            [weakSelf.tableView.mj_footer resetNoMoreData];
        }
        NSMutableArray *tempArr = [BGSysMsgModel mj_objectArrayWithKeyValuesArray:response[@"result"][@"rows"]];
        NSString *totalPageNumStr = [NSString stringWithFormat:@"%@",BGdictSetObjectIsNil(response[@"result"][@"pages"])];
        if (weakSelf.pageNum.integerValue<=totalPageNumStr.integerValue) {
            [weakSelf.cellDataArr addObjectsFromArray:tempArr];
        }
        if (weakSelf.cellDataArr.count>0) {
            [weakSelf.noneView removeFromSuperview];
        }
        [BGSystemApi getMsgUnreadNum:nil succ:^(NSDictionary *response) {
            DLog(@"\n>>>[getMsgUnreadNum sucess]:%@",response);
        } failure:^(NSDictionary *response) {
            DLog(@"\n>>>[getMsgUnreadNum failure]:%@",response);
        }];
        [weakSelf.tableView reloadData];
        
        if (weakSelf.pageNum.integerValue>=totalPageNumStr.integerValue) {
            [weakSelf.tableView.mj_footer endRefreshingWithNoMoreData];
        }else{
            [weakSelf.tableView.mj_footer endRefreshing];
        }
    } failure:^(NSDictionary *response) {
        DLog(@"\n>>>[getCommunityMessage failure]:%@",response);
        [weakSelf shownoNetWorkViewWithType:0];
        [weakSelf setRefreshBlock:^{
            [weakSelf loadData];
        }];
    }];
    
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
    
    //    [self loadData];
}
#pragma - mark UITableView

#pragma mark  -  TableViewDelegate  -
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    self.tableView.mj_footer.hidden = self.cellDataArr.count == 0;
    return _cellDataArr.count==0 ? 1: _cellDataArr.count;
}
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return _cellDataArr.count==0 ? 0:1;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 95;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    BGMessageTypeCell *cell = [tableView dequeueReusableCellWithIdentifier:@"BGMessageTypeCell" forIndexPath:indexPath];
    if ([Tool arrayIsNotEmpty:self.cellDataArr]) {
        BGSysMsgModel *model = _cellDataArr[indexPath.section];
        [cell updataWithCellArray:model];
        cell.userHomepageBtnClicked = ^{
            if (![Tool isLogin]) {
                [WHIndicatorView toast:@"请先登录!"];
                [BGAppDelegateHelper showLoginViewController];
                return;
            }
            BGUserHomepageViewController *userVC = BGUserHomepageViewController.new;
            userVC.member_id = model.member_id;
            [self.navigationController pushViewController:userVC animated:YES];
        };
        cell.communityEssayBtnClicked = ^{
            if (![Tool isLogin]) {
                [WHIndicatorView toast:@"请先登录!"];
                [BGAppDelegateHelper showLoginViewController];
                return;
            }
            if (model.post_type.intValue == 2) {
                BGDouYinViewController *detailVC = BGDouYinViewController.new;
                detailVC.postID = model.post_id;
                detailVC.isSingle = YES;
                [self.navigationController pushViewController:detailVC animated:YES];
            }else{
                BGEssayDetailViewController *detailVC = BGEssayDetailViewController.new;
                detailVC.postID = model.post_id;
                [self.navigationController pushViewController:detailVC animated:YES];
            }
        };
        cell.communityCommentBtnClicked = ^{
            if (![Tool isLogin]) {
                [WHIndicatorView toast:@"请先登录!"];
                [BGAppDelegateHelper showLoginViewController];
                return;
            }
            BGEssayCommentDetailViewController *detailVC = BGEssayCommentDetailViewController.new;
            detailVC.ID = model.review_id;
            detailVC.type = @"1";
            [self.navigationController pushViewController:detailVC animated:YES];
        };
      
        
    }
    
    return cell;
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
    
    
}
- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    return UIView.new;
}
-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    if (_cellDataArr.count == 0) {
        return 0.01;
    }else{
        return section == 0? 6:3;
    }
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

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
