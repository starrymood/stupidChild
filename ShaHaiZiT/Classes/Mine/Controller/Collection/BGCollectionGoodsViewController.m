//
//  BGCollectionGoodsViewController.m
//  ShaHaiZiT
//
//  Created by biao on 2018/12/26.
//  Copyright © 2018 biao. All rights reserved.
//

#import "BGCollectionGoodsViewController.h"
#import "BGMyCollectionCell.h"
#import "BGShopDetailViewController.h"
#import "BGShopApi.h"
#import "BGShopShowModel.h"
#import "JCAlertController.h"
#import <UIImageView+WebCache.h>
#import "BGAirApi.h"

#define BtnHeight 48
@interface BGCollectionGoodsViewController ()<UITableViewDelegate, UITableViewDataSource>
@property (nonatomic,strong)UITableView *tableView;
@property (nonatomic, strong) UIView *noneView;
@property (nonatomic,strong)NSMutableArray *cellDataArr;
// 页数
@property (nonatomic, copy) NSString *pageNum;

@property (nonatomic, strong) JCAlertController *alert;
@end

@implementation BGCollectionGoodsViewController

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
        showMsgLabel.text = @"您还没有收藏哦~";
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
    [self refreshView];
}
#pragma mark - 加载视图
- (void)loadSubViews {
    
    self.view.backgroundColor = kAppBgColor;
    self.tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT-SafeAreaTopHeight-BtnHeight) style:(UITableViewStyleGrouped)];
    _tableView.backgroundColor = kAppBgColor;
    _tableView.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
    _tableView.separatorColor = kAppBgColor;
    _tableView.estimatedRowHeight = 0;
    _tableView.estimatedSectionHeaderHeight = 0;
    _tableView.estimatedSectionFooterHeight = 0;
    _tableView.dataSource = self;
    _tableView.delegate = self;
    [self.view addSubview:_tableView];
    
    [self.tableView registerNib:[UINib nibWithNibName:@"BGMyCollectionCell" bundle:nil] forCellReuseIdentifier:@"BGMyCollectionCell"];
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
#pragma mark - 加载数据  -
- (void)loadData {
    NSMutableDictionary *param = [[NSMutableDictionary alloc] init];
    [param setObject:_pageNum forKey:@"pageno"];
    [param setObject:@"10" forKey:@"pagesize"];
    [param setObject:@"1" forKey:@"category"];
    [ProgressHUDHelper showLoading];
    __block typeof(self) weakSelf = self;
    [BGAirApi getUserCollectionList:param succ:^(NSDictionary *response) {
        DLog(@"\n>>>[getUserCollectionList sucess]:%@",response);
        [weakSelf hideNodateView];
        if (weakSelf.pageNum.intValue == 1) {
            [weakSelf.cellDataArr removeAllObjects];
            [weakSelf.tableView.mj_footer resetNoMoreData];
        }
        NSMutableArray *tempArr = [BGShopShowModel mj_objectArrayWithKeyValuesArray:response[@"result"][@"rows"]];
        NSString *totalPageNumStr = [NSString stringWithFormat:@"%@",BGdictSetObjectIsNil(response[@"result"][@"pages"])];
        if (weakSelf.pageNum.integerValue<=totalPageNumStr.integerValue) {
            [weakSelf.cellDataArr addObjectsFromArray:tempArr];
        }
        if (weakSelf.cellDataArr.count>0) {
            [weakSelf.noneView removeFromSuperview];
        }
        [weakSelf.tableView reloadData];
        
        if (weakSelf.pageNum.integerValue>=totalPageNumStr.integerValue) {
            [weakSelf.tableView.mj_footer endRefreshingWithNoMoreData];
        }else{
            [weakSelf.tableView.mj_footer endRefreshing];
        }
    } failure:^(NSDictionary *response) {
        DLog(@"\n>>>[getUserCollectionList failure]:%@",response);
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
    BGMyCollectionCell *cell = [tableView dequeueReusableCellWithIdentifier:@"BGMyCollectionCell" forIndexPath:indexPath];
    if ([Tool arrayIsNotEmpty:_cellDataArr]) {
        BGShopShowModel *model = _cellDataArr[indexPath.section];
        [cell updataWithCellArray:model];
        __weak __typeof(self) weakSelf = self;
        cell.deleteCellClicked = ^{
            [weakSelf cancelFavoriteActionWithId:model.goods_id];
        };
    }
    
    
    return cell;
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 118;
}
-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    if (_cellDataArr.count == 0) {
        return 0.01;
    }else{
        return 10;
    }
}
-(CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section{
    if (_cellDataArr.count == 0) {
        return _tableView.frame.size.height;
    }else{
        if (_cellDataArr.count -2 >0) {
            return section==(_cellDataArr.count-1)? 30:0.01;
        }else{
            return 0.01;
        }
    }
}
- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    return nil;
}
- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section{
    if (_cellDataArr.count == 0) {
        return self.noneView;
    }
    return nil;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
    BGShopShowModel *model = _cellDataArr[indexPath.section];
    BGShopDetailViewController *detailVC = BGShopDetailViewController.new;
    detailVC.url = BGWebGoodDetail(model.goods_id);
//    detailVC.navigationItem.title = model.name;
    detailVC.goodsid = model.goods_id;
    
        [self.navigationController pushViewController:detailVC animated:YES];
//    CATransition*transition=[CATransition animation];
//    transition.duration=1.0f;
//    transition.type=@"rippleEffect";
//    transition.subtype=@"fromTop";
//    [self.navigationController.view.layer addAnimation:transition forKey:kCATransition];
//    [self.navigationController pushViewController:detailVC animated:NO];
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    return YES;
}
- (NSString *)tableView:(UITableView *)tableView titleForDeleteConfirmationButtonForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return @"删除";
}
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        BGShopShowModel *model = _cellDataArr[indexPath.section];
        [self cancelFavoriteActionWithId:model.goods_id];
    }
    
}
-(void)cancelFavoriteActionWithId:(NSString *)goodsId{
    
    self.alert = [JCAlertController alertWithTitle:@"提示" message:@"确定要取消收藏吗?"];
    
    [_alert addButtonWithTitle:@"取消" type:JCButtonTypeCancel clicked:^{
        
    }];
    
    __weak __typeof(self) weakSelf = self;
    
    [_alert addButtonWithTitle:@"确定" type:JCButtonTypeNormal clicked:^{
        [ProgressHUDHelper showLoading];
        NSMutableDictionary *param = [[NSMutableDictionary alloc] init];
        [param setObject:goodsId forKey:@"collect_id"];
        [param setObject:@"1" forKey:@"category"];
        // 点击button的响应事件
        [BGAirApi addAndCancelFavoriteAction:param succ:^(NSDictionary *response) {
            DLog(@"\n>>>[cancelFavoriteAction success]:%@",response);
            [WHIndicatorView toast:@"取消收藏"];
            [weakSelf loadData];
        } failure:^(NSDictionary *response) {
            DLog(@"\n>>>[cancelFavoriteAction failure]:%@",response);
        }];
    }];
    [self presentViewController:_alert animated:YES completion:nil];
    
}




@end
