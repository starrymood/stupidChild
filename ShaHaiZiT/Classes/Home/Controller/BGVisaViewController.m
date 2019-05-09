//
//  BGVisaViewController.m
//  ShaHaiZiT
//
//  Created by biao on 2019/1/19.
//  Copyright © 2019 biao. All rights reserved.
//

#import "BGVisaViewController.h"
#import "BGAirCitySearchViewController.h"
#import "BGAirportCategoryModel.h"
#import "BGAirApi.h"
#import "BGAirCategoryCell.h"
#import "BGAirRightCell.h"
#import "BGVisaListViewController.h"

@interface BGVisaViewController ()
<UITableViewDelegate,UITableViewDataSource,UICollectionViewDelegate,UICollectionViewDataSource>

@property (nonatomic,strong) UITableView *continentTableView;

@property (nonatomic, strong) UICollectionView *collectionView;

// cell的数据数组
@property (nonatomic,strong) NSMutableArray *leftDataArr;

@property (nonatomic, strong) NSMutableArray *collectionDataArr;

@property (nonatomic, strong) UIView *noneView;

@property (nonatomic, strong) UIView *showTipView;

@property(nonatomic,strong) UILabel *showTipLabel;

@end

@implementation BGVisaViewController

-(UIView *)noneView {
    if (!_noneView) {
        self.noneView = [[UIView alloc] initWithFrame:CGRectMake(106, SafeAreaTopHeight+6, SCREEN_WIDTH-106, SCREEN_HEIGHT-SafeAreaTopHeight-6)];
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

-(NSMutableArray *)leftDataArr{
    if (!_leftDataArr) {
        self.leftDataArr = [NSMutableArray array];
    }
    return _leftDataArr;
}
-(NSMutableArray *)collectionDataArr{
    if (!_collectionDataArr) {
        self.collectionDataArr = [NSMutableArray array];
    }
    return _collectionDataArr;
}
-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    self.navigationController.navigationBarHidden = YES;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self setSearchBar];
    
    [self setLeftTableView];
    
    [self setRightCollectionView];
    
    [self loadLeftData];
    
    
}


-(void)setLeftTableView {
    
    self.continentTableView = [[UITableView alloc] initWithFrame:CGRectMake(0, SafeAreaTopHeight+6, 100, SCREEN_HEIGHT-SafeAreaTopHeight-SafeAreaBottomHeight-6) style:(UITableViewStylePlain)];
    _continentTableView.backgroundColor = kAppWhiteColor;
    _continentTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    _continentTableView.tableFooterView = [UIView new];
    
    _continentTableView.dataSource = self;
    _continentTableView.delegate = self;
    [self.view addSubview:_continentTableView];
    
    [self.continentTableView registerNib:[UINib nibWithNibName:@"BGAirCategoryCell" bundle:nil] forCellReuseIdentifier:@"BGAirCategoryCell"];
    
}

-(void)setRightCollectionView {
    
    CGFloat itemWidth = (SCREEN_WIDTH-100-6-12-26-17)*0.5;
    UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
    layout.itemSize = CGSizeMake(itemWidth, itemWidth*104/109);
    layout.minimumInteritemSpacing = 17;
    layout.minimumLineSpacing = 10;
    layout.sectionInset = UIEdgeInsetsMake(0, 12, 49, 26);
    
    self.showTipView = [[UIView alloc] initWithFrame:CGRectMake(106, SafeAreaTopHeight+6, SCREEN_WIDTH-106, 14+11+11)];
    _showTipView.backgroundColor = kAppWhiteColor;
    [self.view addSubview:_showTipView];
    self.showTipLabel = [[UILabel alloc] initWithFrame:CGRectMake(13, 11, _showTipView.width-13-26, 14)];
    _showTipLabel.textColor = UIColorFromRGB(0xFF4A4A);
    _showTipLabel.font = kFont(14);
    [_showTipView addSubview:_showTipLabel];
    _showTipLabel.text = @"热门国家";
    _collectionView = [[UICollectionView alloc] initWithFrame:CGRectMake(106, _showTipView.y+_showTipView.height, SCREEN_WIDTH-106, SCREEN_HEIGHT-_showTipView.y-_showTipView.height) collectionViewLayout:layout];
    _collectionView.showsVerticalScrollIndicator = NO;
    _collectionView.backgroundColor = kAppWhiteColor;
    _collectionView.delegate = self;
    _collectionView.dataSource = self;
    [_collectionView registerNib:[UINib nibWithNibName:NSStringFromClass([BGAirRightCell class]) bundle:nil] forCellWithReuseIdentifier:@"BGAirRightCell"];
    [self.view addSubview:_collectionView];
}

-(void)loadRightData {
    _showTipLabel.text = @"热门国家";
    [ProgressHUDHelper showLoading];
    NSMutableDictionary *param = [[NSMutableDictionary alloc] init];
    [param setObject:@"6" forKey:@"category"];
    __weak __typeof(self) weakSelf = self;
        [BGAirApi getRecommendCountryList:param succ:^(NSDictionary *response) {
            DLog(@"\n>>>[getRecommendCountryList sucess]:%@",response);
            if ([Tool arrayIsNotEmpty:response[@"result"]]) {
                [weakSelf.noneView removeFromSuperview];
                weakSelf.collectionDataArr = [BGAirportCategoryModel mj_objectArrayWithKeyValuesArray:response[@"result"]];
                [weakSelf.collectionView reloadData];
            }else{
                [self.view addSubview:self.noneView];
            }
           
        } failure:^(NSDictionary *response) {
            DLog(@"\n>>>[getRecommendCountryList failure]:%@",response);
             [self.view addSubview:self.noneView];
        }];
    
}
-(void)loadLeftData {
    
    [ProgressHUDHelper showLoading];
    __weak __typeof(self) weakSelf = self;
    NSMutableDictionary *param = [[NSMutableDictionary alloc] init];
    [param setObject:@"6" forKey:@"category"];
    [BGAirApi getContinentList:param succ:^(NSDictionary *response) {
        DLog(@"\n>>>[getContinentList sucess]:%@",response);
        weakSelf.leftDataArr = [BGAirportCategoryModel mj_objectArrayWithKeyValuesArray:response[@"result"]];
        [weakSelf.continentTableView reloadData];
        [weakSelf.continentTableView selectRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0] animated:NO scrollPosition:(UITableViewScrollPositionTop)];
        [weakSelf loadRightData];
    } failure:^(NSDictionary *response) {
        DLog(@"\n>>>[getContinentList failure]:%@",response);
    }];
}

-(void)setSearchBar{
    
    self.view.backgroundColor = kAppBgColor;
    
    UIView *whiteView = UIView.new;
    whiteView.backgroundColor = kAppWhiteColor;
    whiteView.frame = CGRectMake(0, 0, SCREEN_WIDTH, SafeAreaTopHeight-kNavigationBarH+3);
    [self.view addSubview:whiteView];
    // 搜索框
    UIView *topView = UIView.new;
    topView.backgroundColor = kAppWhiteColor;
    topView.frame = CGRectMake(0, SafeAreaTopHeight-kNavigationBarH+3, SCREEN_WIDTH, kNavigationBarH);
    [self.view addSubview:topView];
    @weakify(self);
    UIButton *searchBtn = [UIButton buttonWithType:(UIButtonTypeCustom)];
    searchBtn.frame = CGRectMake(22, 7, SCREEN_WIDTH-54-22, 30);
    searchBtn.backgroundColor = UIColorFromRGB(0xEBF1F6);
    searchBtn.clipsToBounds = YES;
    searchBtn.layer.cornerRadius = 15;
    
    [[searchBtn rac_signalForControlEvents:(UIControlEventTouchUpInside)] subscribeNext:^(__kindof UIControl * _Nullable x) {
        @strongify(self);
        // 点击button的响应事件
        BGAirCitySearchViewController *searchVC = BGAirCitySearchViewController.new;
        searchVC.category = 6;
        CATransition *transition = [CATransition animation];
        transition.type = kCATransitionFade;
        transition.subtype = kCATransitionFromBottom;
        [self.navigationController.view.layer addAnimation:transition forKey:kCATransition];
        [self.navigationController pushViewController:searchVC animated:NO];
    }];
    
    UIImageView *searchImgView = [[UIImageView alloc] initWithImage:BGImage(@"community_search")];
    searchImgView.frame = CGRectMake(14, 8, 16, 14);
    [searchBtn addSubview:searchImgView];
    
    UILabel *searchLabel = UILabel.new;
    searchLabel.frame = CGRectMake(35, 9, 160, 13);
    [searchLabel setTextColor:kApp999Color];
    searchLabel.text = @"您想要去哪个国家";
    [searchLabel setFont:kFont(12)];
    [searchBtn addSubview:searchLabel];
    
    [topView addSubview:searchBtn];
    
    UIButton *cancelBtn = [UIButton buttonWithType:(UIButtonTypeCustom)];
    cancelBtn.frame = CGRectMake(searchBtn.x+searchBtn.width+5, searchBtn.y+3, 44, 30-6);
    [cancelBtn setTitle:@"取消" forState:(UIControlStateNormal)];
    [cancelBtn setTitleColor:kApp333Color forState:(UIControlStateNormal)];
    [cancelBtn.titleLabel setFont:kFont(14)];
    [topView addSubview:cancelBtn];
    
    [[cancelBtn rac_signalForControlEvents:(UIControlEventTouchUpInside)] subscribeNext:^(__kindof UIControl * _Nullable x) {
        @strongify(self);
        // 点击button的响应事件
        [self.navigationController popViewControllerAnimated:YES];
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
    
    BGAirCategoryCell *cell = [tableView dequeueReusableCellWithIdentifier:@"BGAirCategoryCell" forIndexPath:indexPath];
    [cell updataWithCellArray:self.leftDataArr[indexPath.row] isShow:YES];
    return cell;
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.row == 0) {
        [self loadRightData];
    }else{
        _showTipLabel.text = @"";
        BGAirportCategoryModel *model = self.leftDataArr[indexPath.row];
        self.collectionDataArr = [BGAirportCategoryModel mj_objectArrayWithKeyValuesArray:model.children];
        if ([Tool arrayIsNotEmpty:self.collectionDataArr]) {
            [self.noneView removeFromSuperview];
            [self.collectionView reloadData];
        }else{
            [self.view addSubview:self.noneView];
        }
    }
    
}
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 0.01;
}
#pragma - mark UICollectionView
-(NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView{
    return 1;
}
-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    
    return _collectionDataArr.count;
    
}
-(UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    BGAirRightCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"BGAirRightCell" forIndexPath:indexPath];
     [cell updataWithCellArray:_collectionDataArr[indexPath.item] isCar:YES];
    
    return cell;
}
-(void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{
    BGAirportCategoryModel *model =_collectionDataArr[indexPath.item];
    BGVisaListViewController *productVC = BGVisaListViewController.new;
    if ([Tool isBlankString:model.name]) {
        NSString *titleStr = [NSString stringWithFormat:@"%@签证",model.country_name];
        productVC.country_id = model.country_id;
        productVC.titleStr = titleStr;
    }else{
        NSString *titleStr = [NSString stringWithFormat:@"%@签证",model.name];
        productVC.country_id = model.ID;
        productVC.titleStr = titleStr;
    }
   
    [self.navigationController pushViewController:productVC animated:YES];
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
