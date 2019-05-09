//
//  BGShopCommentView.m
//  shzTravelC
//
//  Created by biao on 2018/6/26.
//  Copyright © 2018年 biao. All rights reserved.
//

#import "BGShopCommentView.h"
#import "BGShopCommentCell.h"
#import "BGShopApi.h"
#import "BGShopCommentModel.h"

@interface BGShopCommentView()<UITableViewDelegate,UITableViewDataSource>
@property (nonatomic,strong) UITableView *tableView;
@property (nonatomic, copy) NSString *goodsIdStr;
@property (nonatomic, strong) NSMutableArray *cellDataArr;
@property (nonatomic, copy) NSString *pageNum;
@property (nonatomic, copy) NSString *onlyimageStr;
@property (nonatomic, strong) UIView *noneView;
@property (nonatomic, strong) UIButton *allBtn;
@property (nonatomic, strong) UIButton *picBtn;
@property (nonatomic, strong) UIButton *addBtn;

@end
@implementation BGShopCommentView
-(instancetype)initWithFrame:(CGRect)frame GoodsId:(NSString *)goodsIdStr{
    if (self = [super initWithFrame:frame]) {
        self.goodsIdStr = goodsIdStr;
        [self loadSubViews];
        [self refreshView];
        
        self.frame = frame;
    }
    return  self;
}
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
        showMsgLabel.text = @"暂无评论~";
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
#pragma mark UITableView + 下拉刷新 隐藏时间
- (void)refreshView {
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
    self.tableView.mj_footer = [MJRefreshAutoNormalFooter footerWithRefreshingBlock:^{
        //每次刷新,页码都加一页
        NSInteger nowPindex = [weakSelf.pageNum integerValue]+1;
        weakSelf.pageNum = [NSString stringWithFormat:@"%zd",nowPindex];
        [weakSelf loadData];
//        [weakSelf.tableView.mj_footer endRefreshing];
    }];
    
    [self loadData];
}

-(void)loadData{
    
    [ProgressHUDHelper showLoading];
    NSMutableDictionary *param = [[NSMutableDictionary alloc] init];
    [param setObject:_goodsIdStr forKey:@"goods_id"];
    [param setObject:_pageNum forKey:@"pageno"];
    [param setObject:@"10" forKey:@"pagesize"];
    [param setObject:_onlyimageStr forKey:@"only_image"];
    __weak __typeof(self) weakSelf = self;
    [BGShopApi getCommentList:param succ:^(NSDictionary *response) {
        DLog(@"\n>>>[getCommentList sucess]:%@",response);
        if (weakSelf.pageNum.intValue == 1) {
            [weakSelf.cellDataArr removeAllObjects];
             [weakSelf.tableView.mj_footer resetNoMoreData];
        }
        NSMutableArray *tempArr = [BGShopCommentModel mj_objectArrayWithKeyValuesArray:response[@"result"][@"rows"]];
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
        DLog(@"\n>>>[getCommentList failure]:%@",response);
    }];
}
-(void)loadSubViews {
    _pageNum = @"1";
    _onlyimageStr = @"0";
    self.tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 26, SCREEN_WIDTH, self.bounds.size.height-26) style:(UITableViewStyleGrouped)];
    _tableView.backgroundColor = kAppBgColor;
    _tableView.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
    _tableView.separatorColor = kAppLineBGColor;
    _tableView.estimatedRowHeight = SCREEN_HEIGHT;
    _tableView.tableFooterView = [UIView new];
    
    _tableView.dataSource = self;
    _tableView.delegate = self;
    [self addSubview:_tableView];
    
    _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    _tableView.estimatedRowHeight = 137;
    _tableView.rowHeight = UITableViewAutomaticDimension;
    
    [self.tableView registerNib:[UINib nibWithNibName:@"BGShopCommentCell" bundle:nil] forCellReuseIdentifier:@"BGShopCommentCell"];
    
   
    
    UIView *lineView = UIView.new;
    lineView.backgroundColor = kAppBgColor;
    lineView.frame = CGRectMake(0, 0, SCREEN_WIDTH, 6);
    
    UIView *btnView = UIView.new;
    btnView.backgroundColor = kAppWhiteColor;
    btnView.frame = CGRectMake(0, lineView.y+lineView.height, SCREEN_WIDTH, 55);
    
    [self addSubview:lineView];
    [self addSubview:btnView];
    
    float btnWidth = (SCREEN_WIDTH-15*2 -25*2 )/3.0*0.8;
    self.allBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    _allBtn.frame = CGRectMake(15+(btnWidth+25)*0, 15, btnWidth, 27);
    _allBtn.titleLabel.font = kFont(13);
    _allBtn.clipsToBounds = YES;
    _allBtn.layer.cornerRadius = _allBtn.height*0.5;
    [_allBtn setTitleColor:kAppWhiteColor forState:UIControlStateNormal];
    _allBtn.backgroundColor = kAppMainColor;
    [_allBtn setTitle:@"全部" forState:UIControlStateNormal];
    [btnView addSubview:_allBtn];
    @weakify(self);
    [[_allBtn rac_signalForControlEvents:(UIControlEventTouchUpInside)] subscribeNext:^(__kindof UIControl * _Nullable x) {
        @strongify(self);
        // 点击button的响应事件
        [self.allBtn setTitleColor:kAppWhiteColor forState:UIControlStateNormal];
        self.allBtn.backgroundColor = kAppMainColor;
        [self.picBtn setTitleColor:kAppBlackColor forState:UIControlStateNormal];
        self.picBtn.backgroundColor = UIColorFromRGB(0xDFFDE6);
        [self.addBtn setTitleColor:kAppBlackColor forState:UIControlStateNormal];
        self.addBtn.backgroundColor = UIColorFromRGB(0xDFFDE6);
        self.pageNum = @"1";
        self.onlyimageStr = @"0";
        [self loadData];
    }];

    self.picBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    _picBtn.frame = CGRectMake(15+(btnWidth+25)*1, 15, btnWidth, 27);
    _picBtn.titleLabel.font = kFont(13);
    _picBtn.clipsToBounds = YES;
    _picBtn.layer.cornerRadius = _picBtn.height*0.5;
    [_picBtn setTitleColor:kAppBlackColor forState:UIControlStateNormal];
    _picBtn.backgroundColor = UIColorFromRGB(0xDFFDE6);
    [_picBtn setTitle:@"有图" forState:UIControlStateNormal];
    [btnView addSubview:_picBtn];
    [[_picBtn rac_signalForControlEvents:(UIControlEventTouchUpInside)] subscribeNext:^(__kindof UIControl * _Nullable x) {
        @strongify(self);
        // 点击button的响应事件
        [self.allBtn setTitleColor:kAppBlackColor forState:UIControlStateNormal];
        self.allBtn.backgroundColor = UIColorFromRGB(0xDFFDE6);
        [self.picBtn setTitleColor:kAppWhiteColor forState:UIControlStateNormal];
        self.picBtn.backgroundColor = kAppMainColor;
        [self.addBtn setTitleColor:kAppBlackColor forState:UIControlStateNormal];
        self.addBtn.backgroundColor = UIColorFromRGB(0xDFFDE6);
        self.pageNum = @"1";
        self.onlyimageStr = @"1";
        [self loadData];
    }];
    
    self.addBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    _addBtn.frame = CGRectMake(15+(btnWidth+25)*2, 15, btnWidth, 27);
    _addBtn.titleLabel.font = kFont(13);
    _addBtn.clipsToBounds = YES;
    _addBtn.layer.cornerRadius = _addBtn.height*0.5;
    [_addBtn setTitleColor:kAppBlackColor forState:UIControlStateNormal];
    _addBtn.backgroundColor = UIColorFromRGB(0xDFFDE6);
    [_addBtn setTitle:@"无图" forState:UIControlStateNormal];
    [btnView addSubview:_addBtn];
    [[_addBtn rac_signalForControlEvents:(UIControlEventTouchUpInside)] subscribeNext:^(__kindof UIControl * _Nullable x) {
        @strongify(self);
        // 点击button的响应事件
        [self.allBtn setTitleColor:kAppBlackColor forState:UIControlStateNormal];
        self.allBtn.backgroundColor = UIColorFromRGB(0xDFFDE6);
        [self.picBtn setTitleColor:kAppBlackColor forState:UIControlStateNormal];
        self.picBtn.backgroundColor = UIColorFromRGB(0xDFFDE6);
        [self.addBtn setTitleColor:kAppWhiteColor forState:UIControlStateNormal];
        self.addBtn.backgroundColor = kAppMainColor;
        self.pageNum = @"1";
        self.onlyimageStr = @"2";
        [self loadData];
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
    BGShopCommentCell *cell = [tableView dequeueReusableCellWithIdentifier:@"BGShopCommentCell" forIndexPath:indexPath];
    if ([Tool arrayIsNotEmpty:self.cellDataArr]) {
        [cell updataWithCellArray:_cellDataArr[indexPath.section]];

    }
    return cell;
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
        return 0.01;
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



@end
