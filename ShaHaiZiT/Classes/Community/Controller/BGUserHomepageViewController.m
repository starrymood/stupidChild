//
//  BGUserHomepageViewController.m
//  shzTravelC
//
//  Created by biao on 2018/7/20.
//  Copyright © 2018年 biao. All rights reserved.
//

#import "BGUserHomepageViewController.h"
#import "BGMineHeaderView.h"
#import <UIImageView+WebCache.h>
#import "BGWaterFallLayout.h"
#import "BGStrategyCell.h"
#import "BGStrategyModel.h"
#import "BGCommunityApi.h"
#import "BGEssayDetailViewController.h"
#import "BGDouYinViewController.h"

#define kHeaderViewHeight (282)
#define BGNumFormat(appendix)  [NSString stringWithFormat:@"%@",appendix]
@interface BGUserHomepageViewController ()<UICollectionViewDataSource,UICollectionViewDelegate,BGWaterFallLayoutDelegate>

@property (nonatomic, strong) BGMineHeaderView *headerView;
@property (nonatomic, strong) NSMutableArray *cellDataArr;

@property (nonatomic,strong) UICollectionView *collectionView;

@property (nonatomic, strong) UIView *topView;
@property (nonatomic, strong) UIButton *concernBtn;
@property (nonatomic, strong) UIButton *backBtn;
// 页数
@property (nonatomic, copy) NSString *pageNum;

@property (nonatomic, strong) UIView *noneView;

@property(nonatomic,assign) BOOL isFirst;

@end

@implementation BGUserHomepageViewController
-(UIView *)noneView {
    if (!_noneView) {
        self.noneView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT-SafeAreaTopHeight)];
        _noneView.backgroundColor = kAppBgColor;
        [_noneView setHidden:YES];
        UIImageView *noneImgView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"noToken_bg"]];
        noneImgView.frame = CGRectMake(SCREEN_WIDTH*0.2, 30, SCREEN_WIDTH*0.6, SCREEN_WIDTH*0.6*1.02);
        [_noneView addSubview:noneImgView];
        
        UILabel *showMsgLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, noneImgView.frame.origin.y+noneImgView.frame.size.height+50, SCREEN_WIDTH-20, 20)];
        showMsgLabel.textAlignment = NSTextAlignmentCenter;
        [showMsgLabel setTextColor:kAppTipBGColor];
        showMsgLabel.font = kFont(14);
        showMsgLabel.text = @"暂无动态~";
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
    self.navigationController.navigationBarHidden = YES;
    [self loadUserInfoAction];
}
- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self creatHeaderView];
    [self setupLayoutAndCollectionView];
    [self refreshView];
}

-(void)creatHeaderView{
    
    self.view.backgroundColor = kAppBgColor;
    self.isFirst = YES;
    self.topView = UIView.new;
    _topView.backgroundColor = kAppBgColor;
    _topView.frame = CGRectMake(0, 0, SCREEN_WIDTH, kHeaderViewHeight);

    self.headerView = [[BGMineHeaderView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, 282)];
    [_topView addSubview:_headerView];
    self.concernBtn = [UIButton buttonWithType:(UIButtonTypeCustom)];
    _concernBtn.frame = CGRectMake((SCREEN_WIDTH-120)*0.5, _headerView.y+_headerView.height-17, 120, 34);
    [_concernBtn setTitle:@"关注" forState:(UIControlStateNormal)];
    [_concernBtn setBackgroundImage:BGImage(@"btn_bgColor") forState:(UIControlStateNormal)];
    [_concernBtn setBackgroundImage:BGImage(@"btn_bgColor") forState:(UIControlStateHighlighted)];
    [_concernBtn setTitleColor:kAppWhiteColor forState:(UIControlStateNormal)];
    _concernBtn.userInteractionEnabled = NO;
    [_concernBtn.titleLabel setFont:kFont(16)];
    _concernBtn.layer.masksToBounds = YES;
    _concernBtn.layer.cornerRadius = _concernBtn.height*0.5;
    @weakify(self);
    [[_concernBtn rac_signalForControlEvents:(UIControlEventTouchUpInside)] subscribeNext:^(__kindof UIControl * _Nullable x) {
        @strongify(self);
        // 点击button的响应事件
        if (![Tool isLogin]) {
            [WHIndicatorView toast:@"请先登录!"];
            [BGAppDelegateHelper showLoginViewController];
            return;
        }
        
        NSMutableDictionary *param = [[NSMutableDictionary alloc] init];
        [param setObject:self.member_id forKey:@"member_id"];
        [param setObject:@"1" forKey:@"type"];
        [ProgressHUDHelper showLoading];
        [BGCommunityApi modifyConcernStatus:param succ:^(NSDictionary *response) {
            DLog(@"\n>>>[modifyConcernStatus sucess]:%@",response);
            [WHIndicatorView toast:response[@"msg"]];
            [self loadUserInfoAction];
        } failure:^(NSDictionary *response) {
            DLog(@"\n>>>[modifyConcernStatus failure]:%@",response);
        }];
    }];
    
    self.backBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [_backBtn setImage:BGImage(@"btn_back_white") forState:UIControlStateNormal];
    _backBtn.frame = CGRectMake(16, SafeAreaTopHeight-kNavigationBarH+7, 70, 30);
    _backBtn.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
    _backBtn.contentEdgeInsets = UIEdgeInsetsZero;
    [[_backBtn rac_signalForControlEvents:(UIControlEventTouchUpInside)] subscribeNext:^(__kindof UIControl * _Nullable x) {
        @strongify(self);
        // 点击button的响应事件
        [self.navigationController popViewControllerAnimated:YES];
    }];
}
/**
 * 创建布局和collectionView
 */
- (void)setupLayoutAndCollectionView{
    
    // 创建布局
    BGWaterFallLayout * waterFallLayout = [[BGWaterFallLayout alloc]init];
    waterFallLayout.delegate = self;
    
    // 创建collectionView
    UICollectionView *collectionView = [[UICollectionView alloc]initWithFrame:CGRectMake(0, _topView.height+_topView.y, SCREEN_WIDTH, SCREEN_HEIGHT-_topView.height-_topView.y) collectionViewLayout:waterFallLayout];
    collectionView.backgroundColor = kAppBgColor;
    
    collectionView.dataSource = self;
    collectionView.delegate = self;
    collectionView.contentInset = UIEdgeInsetsMake(17, 0, 0, 0);
    [self.view addSubview:collectionView];
    [self.view addSubview:self.topView];
    [self.view addSubview:_backBtn];
    [self.view addSubview:_concernBtn];
    // 注册
    [collectionView registerNib:[UINib nibWithNibName:NSStringFromClass([BGStrategyCell class]) bundle:nil] forCellWithReuseIdentifier:@"BGStrategyCell"];
    
    self.collectionView = collectionView;
    _pageNum = @"1";
}
#pragma mark UITableView + 下拉刷新 隐藏时间
- (void)refreshView
{
    // 设置回调（一旦进入刷新状态，就调用target的action，也就是调用self的loadNewData方法）
    __weak __typeof(self) weakSelf = self;
    
    // 设置回调（一旦进入刷新状态就会调用这个refreshingBlock）
    self.collectionView.mj_header = [MJRefreshNormalHeader headerWithRefreshingBlock:^{
        // 设置自动切换透明度(在导航栏下面自动隐藏)
        weakSelf.collectionView.mj_header.automaticallyChangeAlpha = YES;
        weakSelf.pageNum = @"1";
        [weakSelf loadData];
        [weakSelf.collectionView.mj_header endRefreshing];
    }];
    // 上拉刷新
    self.collectionView.mj_footer = [MJRefreshAutoNormalFooter footerWithRefreshingBlock:^{
        //每次刷新,页码都加一页
        NSInteger nowPindex = [weakSelf.pageNum integerValue]+1;
        weakSelf.pageNum = [NSString stringWithFormat:@"%zd",nowPindex];
        [weakSelf loadData];
//        [weakSelf.collectionView.mj_footer endRefreshing];
    }];
    self.collectionView.mj_header.ignoredScrollViewContentInsetTop = 17;
    
}
-(void)loadUserInfoAction {
    // @@ 添加登录判断
    if (![Tool isLogin]) {
        [WHIndicatorView toast:@"请先登录!"];
        [BGAppDelegateHelper showLoginViewController];
        return;
    }
    
    NSMutableDictionary *param = [[NSMutableDictionary alloc] init];
    [param setObject:_member_id forKey:@"user_id"];
    [ProgressHUDHelper showLoading];
    __block typeof(self) weakSelf = self;
    [BGCommunityApi getOtherUserInfo:param succ:^(NSDictionary *response) {
        DLog(@"\n>>>[getOtherUserInfo sucess]:%@",response);
        [weakSelf hideNodateView];
        if (weakSelf.isFirst) {
            [weakSelf loadData];
            weakSelf.isFirst = NO;
        }
        [weakSelf updateUserInfoActionWithData:BGdictSetObjectIsNil(response[@"result"])];
        
    } failure:^(NSDictionary *response) {
        DLog(@"\n>>>[getOtherUserInfo failure]:%@",response);
        [self shownoNetWorkViewWithType:0];
        [self setRefreshBlock:^{
            [weakSelf loadUserInfoAction];
        }];
    }];
}

-(void)loadData {
    NSMutableDictionary *param = [[NSMutableDictionary alloc] init];
    [param setObject:_member_id forKey:@"member_id"];
    [param setObject:_pageNum forKey:@"pageno"];
    [param setObject:@"7" forKey:@"pagesize"];
    [ProgressHUDHelper showLoading];
    __block typeof(self) weakSelf = self;
    [BGCommunityApi getOtherUserPostList:param succ:^(NSDictionary *response) {
        DLog(@"\n>>>[getOtherUserPostList sucess]:%@",response);
//        [weakSelf hideNodateView];
        if (weakSelf.pageNum.intValue == 1) {
            [weakSelf.cellDataArr removeAllObjects];
            [weakSelf.collectionView.mj_footer resetNoMoreData];
        }
        NSMutableArray *tempArr = [BGStrategyModel mj_objectArrayWithKeyValuesArray:response[@"result"][@"rows"]];
        NSString *totalPageNumStr = [NSString stringWithFormat:@"%@",BGdictSetObjectIsNil(response[@"result"][@"pages"])];
        if (weakSelf.pageNum.integerValue<=totalPageNumStr.integerValue) {
            [weakSelf.cellDataArr addObjectsFromArray:tempArr];
        }
        if (weakSelf.cellDataArr.count>0) {
            [weakSelf.noneView removeFromSuperview];
        }else{
            [weakSelf.collectionView addSubview:weakSelf.noneView];
        }
        [weakSelf.collectionView reloadData];
        
        if (weakSelf.pageNum.integerValue>=totalPageNumStr.integerValue) {
            [weakSelf.collectionView.mj_footer endRefreshingWithNoMoreData];
        }else{
            [weakSelf.collectionView.mj_footer endRefreshing];
        }
    } failure:^(NSDictionary *response) {
        DLog(@"\n>>>[getOtherUserPostList failure]:%@",response);
    }];
}
-(void)updateUserInfoActionWithData:(NSDictionary *)dic{
    
    int isConcern = [BGNumFormat(dic[@"is_concern"]) intValue];
    if (isConcern == 1) {
        _concernBtn.userInteractionEnabled = YES;
        [_concernBtn setTitle:@"已关注" forState:(UIControlStateNormal)];
        [_concernBtn setTitleColor:kApp666Color forState:(UIControlStateNormal)];
    }else if (isConcern == 0){
        _concernBtn.userInteractionEnabled = YES;
        [_concernBtn setTitle:@"关注" forState:(UIControlStateNormal)];
        [_concernBtn setTitleColor:kAppWhiteColor forState:(UIControlStateNormal)];
    }
    
    // 头像
    [_headerView.headImgView sd_setImageWithURL:[NSURL URLWithString:dic[@"face"]] placeholderImage:BGImage(@"defaultUserIcon")];
    // 昵称
    _headerView.mineNameLabel.text = dic[@"nickname"];
    // 傻孩子账号
    _headerView.shzIdLabel.text = dic[@"shz"];
    // 个性签名
    _headerView.mineAutographLabel.text = dic[@"signature"];
    _headerView.concernLabel.text = BGNumFormat(dic[@"concern_count"]);
    _headerView.fansLabel.text = BGNumFormat(dic[@"fans_count"]);
    _headerView.collectedLabel.text = BGNumFormat(dic[@"collection_count"]);
    _headerView.likeLabel.text = BGNumFormat(dic[@"member_like_count"]);
}
#pragma mark UICollectionViewDataSource
- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView{
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    
    self.collectionView.mj_footer.hidden = self.cellDataArr.count == 0;
    
    return self.cellDataArr.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    
    BGStrategyCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"BGStrategyCell" forIndexPath:indexPath];
    cell.layer.cornerRadius = 5;
    
    BGStrategyModel *model = self.cellDataArr[indexPath.item];
    [cell updataWithCellArray:model];
    
    return cell;
}



#pragma mark  - <LMHWaterFallLayoutDeleaget>
/**
 * 每个item的高度
 */
- (CGFloat)waterFallLayout:(BGWaterFallLayout *)waterFallLayout heightForItemAtIndexPath:(NSUInteger)indexPath itemWidth:(CGFloat)itemWidth{
    
    BGStrategyModel *model = self.cellDataArr[indexPath];
    
    CGFloat imgHeight = 1/[NSString stringWithFormat:@"%@",model.aspectRatio].floatValue ?:0.8;
    NSInteger lineNum = [self needLinesWithWidth:(itemWidth-16) text:model.postTitle];
    CGFloat staticHeight = 73;
    switch (lineNum) {
        case 1:
            staticHeight = 73;
            break;
        case 2:
            staticHeight = 89;
            break;
            
        default:
            staticHeight = 105;
            break;
    }
    
    
    return itemWidth * imgHeight+staticHeight;
}
/**
 * 每列之间的间距
 */
- (CGFloat)columnMarginInWaterFallLayout:(BGWaterFallLayout *)waterFallLayout{
    return 5;
}
/**
 * 每行之间的间距
 */
- (CGFloat)rowMarginInWaterFallLayout:(BGWaterFallLayout *)waterFallLayout{
    
    return 10;
    
}

/**
 * 有多少列
 */
- (NSUInteger)columnCountInWaterFallLayout:(BGWaterFallLayout *)waterFallLayout{
    
    return 2;
    
}

-(void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{
    //    DLog(@"\n>>>[collectionView didSelectItem]:%ld",(long)indexPath.item);
    BGStrategyModel *model = _cellDataArr[indexPath.item];
    if (model.type.intValue == 2) {
        BGDouYinViewController *detailVC = BGDouYinViewController.new;
        detailVC.postID = model.ID;
        detailVC.isSingle = YES;
        [self.navigationController pushViewController:detailVC animated:YES];
    }else{
        BGEssayDetailViewController *detailVC = BGEssayDetailViewController.new;
        detailVC.postID = model.ID;
        [self.navigationController pushViewController:detailVC animated:YES];
    }
}
- (NSInteger)needLinesWithWidth:(CGFloat)width text:(NSString *)text{
    //创建一个labe
    UILabel * label = [[UILabel alloc]init];
    //font和当前label保持一致
    label.font = kFont(13);
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
    return sum;
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
