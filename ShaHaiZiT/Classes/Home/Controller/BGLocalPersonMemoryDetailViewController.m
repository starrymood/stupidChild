//
//  BGLocalPersonMemoryDetailViewController.m
//  ShaHaiZiT
//
//  Created by biao on 2019/3/28.
//  Copyright © 2019 biao. All rights reserved.
//

#import "BGLocalPersonMemoryDetailViewController.h"
#import "BGAirApi.h"
#import "BGLocalPersonModel.h"
#import "BGLocalMemoryCell.h"
#import "BGLocalPersonMemoryPhotosViewController.h"

@interface BGLocalPersonMemoryDetailViewController ()
@property (weak, nonatomic) IBOutlet UIView *yearView;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (nonatomic, copy) NSString *pageNum;
@property (nonatomic, strong) NSMutableArray *cellDataArr;

@end

@implementation BGLocalPersonMemoryDetailViewController
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

-(void)loadSubViews{
    self.navigationItem.title = @"旅游记忆";
    self.view.backgroundColor = kAppBgColor;
    
    
    _tableView.backgroundColor = kAppBgColor;
    _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    _tableView.separatorColor = kAppBgColor;
    _tableView.estimatedRowHeight = 400;
    [self.tableView registerNib:[UINib nibWithNibName:@"BGLocalMemoryCell" bundle:nil] forCellReuseIdentifier:@"BGLocalMemoryCell"];
    _pageNum = @"1";
    
    for (int i = 0; i<7; i++) {
        UIView *view = (UIView *)[self.yearView viewWithTag:2001+i];
        view.hidden = YES;
    }
    for (int i = 0; i<self.yearArr.count; i++) {
        UIView *view = (UIView *)[self.yearView viewWithTag:2001+i];
        view.hidden = NO;
        UIImageView *imgView = (UIImageView *)[view viewWithTag:1001+i];
        [imgView setImage:BGImage(@"home_local_person_unselected")];
        UILabel *lab = (UILabel *)[view viewWithTag:4001+i];
        NSDictionary *dic = BGdictSetObjectIsNil(self.yearArr[i]);
        lab.text = [NSString stringWithFormat:@"%@",BGdictSetObjectIsNil([dic objectForKey:@"create_year"])];
        if ([lab.text isEqualToString:self.yearStr]) {
            [imgView setImage:BGImage(@"home_local_person_selected")];
            [self loadData];
        }
    }
    
    
    
}

#pragma mark UITableView + 下拉刷新 隐藏时间
- (void)refreshView{
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
    }];
    [self loadData];
}
-(void)loadData{
    
    NSMutableDictionary *param = [[NSMutableDictionary alloc] init];
    
    [param setObject:_yearStr forKey:@"year"];
    [param setObject:_talent_id forKey:@"talent_id"];
    [param setObject:_pageNum forKey:@"pageno"];
    [param setObject:@"5" forKey:@"pagesize"];
    [ProgressHUDHelper showLoading];
    __block typeof(self) weakSelf = self;
    [BGAirApi getLocalPersonMemoryList:param succ:^(NSDictionary *response) {
        DLog(@"\n>>>[getLocalPersonMemoryList sucess]:%@",response);
        [weakSelf hideNodateView];
        if (weakSelf.pageNum.intValue == 1) {
            [weakSelf.cellDataArr removeAllObjects];
            [weakSelf.tableView.mj_footer resetNoMoreData];
        }
        NSMutableArray *tempArr = [BGLocalPersonModel mj_objectArrayWithKeyValuesArray:response[@"result"][@"rows"]];
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
        DLog(@"\n>>>[getLocalPersonMemoryList failure]:%@",response);
        [ProgressHUDHelper removeLoading];
        [self shownoNetWorkViewWithType:0];
        [self setRefreshBlock:^{
            [weakSelf loadData];
        }];
    }];
}

- (IBAction)selectYearBtnClickedAction:(UIButton *)sender {
    NSInteger selectNum = sender.tag-3001;
    UIView *view = (UIView *)[self.yearView viewWithTag:2001+selectNum];
    UILabel *lab = (UILabel *)[view viewWithTag:4001+selectNum];
    if ([lab.text isEqualToString:self.yearStr]) {
        return;
    }
    
    for (int i = 0; i<self.yearArr.count; i++) {
        UIView *view = (UIView *)[self.yearView viewWithTag:2001+i];
        UIImageView *imgView = (UIImageView *)[view viewWithTag:1001+i];
        [imgView setImage:BGImage(@"home_local_person_unselected")];
        NSDictionary *dic = BGdictSetObjectIsNil(self.yearArr[i]);
        if (i == selectNum) {
            [imgView setImage:BGImage(@"home_local_person_selected")];
            self.yearStr = [NSString stringWithFormat:@"%@",BGdictSetObjectIsNil([dic objectForKey:@"create_year"])];
            _pageNum = @"1";
            [self loadData];
        }
    }
}
#pragma mark  -  TableViewDelegate  -
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return _cellDataArr.count;
}
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 1;
}
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    BGLocalPersonModel *model = _cellDataArr[indexPath.section];
    CGFloat rowHeight = [Tool needLinesWithWidth:(SCREEN_WIDTH-40) text:model.content]*13.5+36+37+15+(SCREEN_WIDTH-40)*90/335.0*2+5;
    return rowHeight;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    BGLocalPersonModel *model = _cellDataArr[indexPath.section];
    BGLocalMemoryCell *cell = [tableView dequeueReusableCellWithIdentifier:@"BGLocalMemoryCell" forIndexPath:indexPath];
    if ([Tool arrayIsNotEmpty:_cellDataArr]) {
        [cell updataWithCellArr:model];
    }
    return cell;
}
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
    // @@ 添加登录判断
    if (![Tool isLogin]) {
        [WHIndicatorView toast:@"请先登录!"];
        [BGAppDelegateHelper showLoginViewController];
        return;
    }
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
    BGLocalPersonModel *model = _cellDataArr[indexPath.section];
    BGLocalPersonMemoryPhotosViewController *detailVC = BGLocalPersonMemoryPhotosViewController.new;
    detailVC.photos = [NSArray arrayWithArray:model.landscape_picture];
    [self.navigationController pushViewController:detailVC animated:YES];
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

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
