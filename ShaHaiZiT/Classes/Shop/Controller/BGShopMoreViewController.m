//
//  BGShopMoreViewController.m
//  shzTravelC
//
//  Created by 孙林茂 on 2018/5/10.
//  Copyright © 2018年 biao. All rights reserved.
//

#import "BGShopMoreViewController.h"
#import "BGShopCategoryCell.h"
#import "BGShopMoreRightCell.h"
#import "BGShopListViewController.h"
#import "BGShopApi.h"
#import "BGShopSortsModel.h"

#define BGSelectedCategory self.leftDataArr[self.tableView.indexPathForSelectedRow.row]
@interface BGShopMoreViewController ()<UITableViewDelegate,UITableViewDataSource,UICollectionViewDelegateFlowLayout,UICollectionViewDelegate,UICollectionViewDataSource>

@property (nonatomic,strong) UITableView *tableView;

@property (nonatomic, strong) UICollectionView *collectionView;

// cell的数据数组
@property (nonatomic,strong) NSMutableArray *leftDataArr;

@property(nonatomic,strong) NSMutableArray *rightDataArr;

@property (nonatomic, strong) UIView *noneView;

@end

@implementation BGShopMoreViewController
-(UIView *)noneView {
    if (!_noneView) {
        self.noneView = [[UIView alloc] initWithFrame:CGRectMake(104, SafeAreaTopHeight+6, SCREEN_WIDTH-104, SCREEN_HEIGHT-SafeAreaTopHeight-6)];
        _noneView.backgroundColor = kAppBgColor;
        [_noneView setHidden:YES];
        UIImageView *noneImgView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"noToken_bg"]];
        noneImgView.frame = CGRectMake((SCREEN_WIDTH-106)*0.2, 60, (SCREEN_WIDTH-106)*0.6, (SCREEN_WIDTH-106)*0.6*1.02);
        [_noneView addSubview:noneImgView];
        
        UILabel *showMsgLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, noneImgView.frame.origin.y+noneImgView.frame.size.height+50, (SCREEN_WIDTH-106)-20, 20)];
        showMsgLabel.textAlignment = NSTextAlignmentCenter;
        [showMsgLabel setTextColor:kAppTipBGColor];
        showMsgLabel.font = kFont(14);
        showMsgLabel.text = @"暂无数据";
        [_noneView addSubview:showMsgLabel];
        
        __weak typeof(self)weakSelf = self;
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [weakSelf.noneView setHidden:NO];
        });
    }
    return _noneView;
}
-(NSMutableArray *)rightDataArr{
    if (!_rightDataArr) {
        self.rightDataArr = [NSMutableArray array];
    }
    return _rightDataArr;
}
-(NSMutableArray *)leftDataArr{
    if (!_leftDataArr) {
        self.leftDataArr = [NSMutableArray array];
    }
    return _leftDataArr;
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    self.navigationController.navigationBarHidden = NO;
}

- (void)viewDidLoad {
    [super viewDidLoad];

    [self loadSubViews];

    [self setLeftTableView];
    
    [self setRightCollectionView];
    
    [self loadLeftData];
}
-(void)loadSubViews {
    
    self.navigationItem.title = @"更多分类";
    self.view.backgroundColor = kAppBgColor;
    
}
-(void)setLeftTableView {

    self.tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, SafeAreaTopHeight+6, 100, SCREEN_HEIGHT-SafeAreaTopHeight-SafeAreaBottomHeight-6) style:(UITableViewStylePlain)];
    _tableView.backgroundColor = kAppWhiteColor;
    _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    _tableView.tableFooterView = [UIView new];
    
    _tableView.dataSource = self;
    _tableView.delegate = self;
    [self.view addSubview:_tableView];
    
    [self.tableView registerNib:[UINib nibWithNibName:@"BGShopCategoryCell" bundle:nil] forCellReuseIdentifier:@"BGShopCategoryCell"];
    
}
-(void)setRightCollectionView {
    
    CGFloat itemWidth = (SCREEN_WIDTH-100-4-10-8-8-10)/3.0;
    UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
    layout.itemSize = CGSizeMake(itemWidth, itemWidth*75/79.0);
    layout.minimumLineSpacing = 12;
    layout.minimumInteritemSpacing = 8;
//    layout.sectionInset = UIEdgeInsetsMake(1, 10, 14, 10);
//    layout.headerReferenceSize = CGSizeMake(SCREEN_WIDTH, 38);
    
    _collectionView = [[UICollectionView alloc] initWithFrame:CGRectMake(100+4, SafeAreaTopHeight+6, SCREEN_WIDTH-100-4, SCREEN_HEIGHT-SafeAreaTopHeight-6) collectionViewLayout:layout];
    _collectionView.showsVerticalScrollIndicator = NO;
    _collectionView.backgroundColor = kAppWhiteColor;
    _collectionView.delegate = self;
    _collectionView.dataSource = self;
    [_collectionView registerNib:[UINib nibWithNibName:NSStringFromClass([BGShopMoreRightCell class]) bundle:nil] forCellWithReuseIdentifier:@"BGShopMoreRightCell"];
    [_collectionView registerClass:[UICollectionReusableView class] forSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:@"headerView"];
    
    [self.view addSubview:_collectionView];
}
-(void)loadLeftData {
    
    [ProgressHUDHelper showLoading];
    NSMutableDictionary *param = [NSMutableDictionary dictionary];
    [BGShopApi getGoodsSort:param succ:^(NSDictionary *response) {
         DLog(@"\n>>>[getGoodsSortA sucess]:%@",response);
        self.leftDataArr = [BGShopSortsModel mj_objectArrayWithKeyValuesArray:response[@"result"]];
        [self.tableView reloadData];
//        [self.tableView selectRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0] animated:NO scrollPosition:(UITableViewScrollPositionTop)];
        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:0 inSection:0];
        [self.tableView selectRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0] animated:YES scrollPosition:UITableViewScrollPositionTop];
        if ([self.tableView.delegate respondsToSelector:@selector(tableView:didSelectRowAtIndexPath:)]) {
            [self.tableView.delegate tableView:self.tableView didSelectRowAtIndexPath:indexPath];
        }
    } failure:^(NSDictionary *response) {
         DLog(@"\n>>>[getGoodsSortA failure]:%@",response);
        
    }];
    
}
#pragma - mark UITableView

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{

    return _leftDataArr.count;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 62;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    BGShopCategoryCell *cell = [tableView dequeueReusableCellWithIdentifier:@"BGShopCategoryCell" forIndexPath:indexPath];
    if ([Tool arrayIsNotEmpty:_leftDataArr]) {
        [cell updataWithCellArray:self.leftDataArr[indexPath.row]];
    }
    return cell;
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
    BGShopSortsModel *model = self.leftDataArr[indexPath.row];
    [self.rightDataArr removeAllObjects];
    self.rightDataArr = [BGShopSortsModel mj_objectArrayWithKeyValuesArray:model.children];
    [self.collectionView reloadData];
    if ([Tool arrayIsNotEmpty:_rightDataArr]) {
        [self.noneView removeFromSuperview];
    }else{
        [self.view addSubview:self.noneView];
    }
    
    
}
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 0.01;
}
#pragma - mark UICollectionView
-(NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView{
    return _rightDataArr.count;
}
-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
 BGShopSortsModel *model = self.rightDataArr[section];
    return model.children.count;
    
}
-(UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    BGShopSortsModel *model = self.rightDataArr[indexPath.section];
    NSMutableArray *arr = [NSMutableArray array];
    arr = [BGShopSortsModel mj_objectArrayWithKeyValuesArray:model.children];
    BGShopMoreRightCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"BGShopMoreRightCell" forIndexPath:indexPath];
    if ([Tool arrayIsNotEmpty:arr]) {
         [cell updataWithCellArray:arr[indexPath.row]];
    }
    UITapGestureRecognizer * tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(tapAction:)];
    [cell.contentView addGestureRecognizer:tap];
    
    return cell;
}
-(void)tapAction:(UITapGestureRecognizer *)tap{
    CGPoint point = [tap locationInView:self.collectionView];
    NSIndexPath * indexPath = [self.collectionView indexPathForItemAtPoint:point];
    
    BGShopSortsModel *model = self.rightDataArr[indexPath.section];
    NSMutableArray *arr = [NSMutableArray array];
    arr = [BGShopSortsModel mj_objectArrayWithKeyValuesArray:model.children];
    BGShopSortsModel *cModel = arr[indexPath.row];
    BGShopListViewController *listVC = BGShopListViewController.new;
    listVC.cat_id = cModel.ID;
    [self.navigationController pushViewController:listVC animated:YES];

}

-(UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath{
 
    if([kind isEqualToString:UICollectionElementKindSectionHeader])
    {
    UICollectionReusableView *headerView = [collectionView dequeueReusableSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:@"headerView" forIndexPath:indexPath];
    headerView.backgroundColor = [UIColor whiteColor];
    
    for (UIView *view in headerView.subviews) {
        [view removeFromSuperview];
    }
        UIView *lineView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, _collectionView.width, 3)];
        lineView.backgroundColor = kAppBgColor;
        if (indexPath.section != 0) {
            [headerView addSubview:lineView];
        }
    UILabel *label = [[UILabel alloc] init];
        if (indexPath.section == 0) {
            label.frame = CGRectMake(10, 0, _collectionView.width-10, headerView.height);
        }else{
            label.frame = CGRectMake(10, 3, _collectionView.width-10, headerView.height-3);
        }
    label.textColor = kApp333Color;
    label.font = kFont(13);
    BGShopSortsModel *model = self.rightDataArr[indexPath.section];
    label.text = model.name;
    [headerView addSubview:label];
    
    return headerView;
    }
    return UICollectionReusableView.new;
}
- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout insetForSectionAtIndex:(NSInteger)section{
    BGShopSortsModel *model = self.rightDataArr[section];
    if ([Tool arrayIsNotEmpty:model.children]) {
        return UIEdgeInsetsMake(1, 10, 14, 10);
    }else{
        return UIEdgeInsetsZero;
    }
}
- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout referenceSizeForHeaderInSection:(NSInteger)section{
    if (section == 0) {
    return CGSizeMake(SCREEN_WIDTH, 35);
    }else{
     return CGSizeMake(SCREEN_WIDTH, 38);
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
