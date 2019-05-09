//
//  BGAreaSelectViewController.m
//  ShaHaiZiT
//
//  Created by biao on 2019/1/18.
//  Copyright © 2019 biao. All rights reserved.
//

#import "BGAreaSelectViewController.h"
#import "YUFoldingTableView.h"
#import "BGAirCitySearchViewController.h"
#import "BGAirportCategoryModel.h"
#import "BGAirRightCell.h"
#import "BGAirApi.h"
#import "BGAirCategoryCell.h"
#import "BGPersonalTailorViewController.h"
#import "BGAirChooseProductViewController.h"
#import "BGLineHotViewController.h"

@interface BGAreaSelectViewController ()<UICollectionViewDelegate,UICollectionViewDataSource,YUFoldingTableViewDelegate>

@property (nonatomic, weak) YUFoldingTableView *foldingTableView;
@property (nonatomic, strong) UICollectionView *collectionView;
// cell的数据数组
@property (nonatomic,strong) NSMutableArray *leftDataArr;

@property (nonatomic, strong) NSMutableArray *collectionDataArr;

@property (nonatomic, strong) UIView *noneView;

@property (nonatomic, strong) UIView *showTipView;

@property(nonatomic,strong) UILabel *showTipLabel;

@property(nonatomic,copy) NSString *areaIdStr;

@end

@implementation BGAreaSelectViewController
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
-(void)loadLeftData {
    
    [ProgressHUDHelper showLoading];
    __weak __typeof(self) weakSelf = self;
    NSMutableDictionary *param = [[NSMutableDictionary alloc] init];
    [param setObject:@(_category) forKey:@"category"];
    [BGAirApi getContinentList:param succ:^(NSDictionary *response) {
        DLog(@"\n>>>[getContinentList sucess]:%@",response);
        weakSelf.leftDataArr = [BGAirportCategoryModel mj_objectArrayWithKeyValuesArray:response[@"result"]];
        [weakSelf.foldingTableView reloadData];
        weakSelf.areaIdStr = @"0";
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
        searchVC.category = self.category;
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
    switch (_category) {
        case 1:
            searchLabel.text = @"您将降落在哪座机场";
            break;
        case 2:
            searchLabel.text = @"您将出发在哪座机场";
            break;
        default:
            searchLabel.text = @"您想要去哪座城市";
            break;
    }
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
        if (self.category>4) {
            CATransition *transition = [CATransition animation];
            transition.type = kCATransitionReveal;
            transition.subtype = kCATransitionFromBottom;
            [self.navigationController.view.layer addAnimation:transition forKey:kCATransition];
            [self.navigationController popViewControllerAnimated:NO];
        }else{
            [self.navigationController popViewControllerAnimated:YES];
        }
    }];
    
}
// 创建tableView
- (void)setLeftTableView{
    YUFoldingTableView *foldingTableView = [[YUFoldingTableView alloc] initWithFrame:CGRectMake(0, SafeAreaTopHeight+6, 100, SCREEN_HEIGHT-SafeAreaTopHeight-SafeAreaBottomHeight-6)];
    foldingTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    _foldingTableView = foldingTableView;
    
    
    [self.view addSubview:foldingTableView];
    foldingTableView.foldingDelegate = self;
     [self.foldingTableView registerNib:[UINib nibWithNibName:@"BGAirCategoryCell" bundle:nil] forCellReuseIdentifier:@"BGAirCategoryCell"];
    
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
    _showTipLabel.text = (_category<3)?@"热门机场":@"热门目的地";
    _collectionView = [[UICollectionView alloc] initWithFrame:CGRectMake(106, _showTipView.y+_showTipView.height, SCREEN_WIDTH-106, SCREEN_HEIGHT-_showTipView.y-_showTipView.height) collectionViewLayout:layout];
    _collectionView.showsVerticalScrollIndicator = NO;
    _collectionView.backgroundColor = kAppWhiteColor;
    _collectionView.delegate = self;
    _collectionView.dataSource = self;
    [_collectionView registerNib:[UINib nibWithNibName:NSStringFromClass([BGAirRightCell class]) bundle:nil] forCellWithReuseIdentifier:@"BGAirRightCell"];
    [self.view addSubview:_collectionView];
}
-(void)loadRightData {

    _showTipLabel.text = (_category<3)?@"热门机场":@"热门目的地";
    [ProgressHUDHelper showLoading];
    NSMutableDictionary *param = [[NSMutableDictionary alloc] init];
    [param setObject:@(_category) forKey:@"category"];
    __weak __typeof(self) weakSelf = self;
    if (_category<3) {
        [BGAirApi getAreaDetailInfo:param succ:^(NSDictionary *response) {
            DLog(@"\n>>>[getAreaDetailInfo sucess]:%@",response);
            weakSelf.collectionDataArr = [BGAirportCategoryModel mj_objectArrayWithKeyValuesArray:response[@"result"]];
            [weakSelf.collectionView reloadData];
        } failure:^(NSDictionary *response) {
            DLog(@"\n>>>[getAreaDetailInfo failure]:%@",response);
        }];
    }else{
        [BGAirApi getRecommendCityList:param succ:^(NSDictionary *response) {
            DLog(@"\n>>>[getRecommendCityList sucess]:%@",response);
            weakSelf.collectionDataArr = [BGAirportCategoryModel mj_objectArrayWithKeyValuesArray:response[@"result"]];
            [weakSelf.collectionView reloadData];

        } failure:^(NSDictionary *response) {
            DLog(@"\n>>>[getRecommendCityList failure]:%@",response);

        }];
    }
    
}
-(void)loadCollectionViewDataWithID:(NSString *)idStr{
    [ProgressHUDHelper showLoading];
    _showTipLabel.text = @"";
    NSMutableDictionary *param = [[NSMutableDictionary alloc] init];
    __weak __typeof(self) weakSelf = self;
    [param setObject:@(_category) forKey:@"category"];
    if (_category<3) {
        [param setObject:idStr forKey:@"country_id"];
        [BGAirApi getAreaListById:param succ:^(NSDictionary *response) {
            DLog(@"\n>>>[getAreaListById sucess]:%@",response);

            
            if ([Tool arrayIsNotEmpty:response[@"result"]]) {
                 [weakSelf.noneView removeFromSuperview];
                weakSelf.collectionDataArr = [BGAirportCategoryModel mj_objectArrayWithKeyValuesArray:response[@"result"]];
                [weakSelf.collectionView reloadData];
            }else{
                [self.view addSubview:self.noneView];
            }
            
        } failure:^(NSDictionary *response) {
            DLog(@"\n>>>[getAreaListById failure]:%@",response);
            [self.view addSubview:self.noneView];

        }];
    }else{
        [param setObject:idStr forKey:@"parent_id"];
        [BGAirApi getCityListByRegionID:param succ:^(NSDictionary *response) {
            DLog(@"\n>>>[getCityListByRegionID sucess]:%@",response);
            if ([Tool arrayIsNotEmpty:response[@"result"]]) {
                [weakSelf.noneView removeFromSuperview];
                weakSelf.collectionDataArr = [BGAirportCategoryModel mj_objectArrayWithKeyValuesArray:response[@"result"]];
                [weakSelf.collectionView reloadData];
            }else{
                [self.view addSubview:self.noneView];
            }
            
        } failure:^(NSDictionary *response) {
            DLog(@"\n>>>[getCityListByRegionID failure]:%@",response);
            [self.view addSubview:self.noneView];
        }];
    }
    
}
#pragma mark - YUFoldingTableViewDelegate / required（必须实现的代理）
- (NSInteger )numberOfSectionForYUFoldingTableView:(YUFoldingTableView *)yuTableView
{
    return _leftDataArr.count;
}
- (NSInteger )yuFoldingTableView:(YUFoldingTableView *)yuTableView numberOfRowsInSection:(NSInteger )section
{
    BGAirportCategoryModel *model =_leftDataArr[section];
    NSMutableArray *tempArr = [BGAirportCategoryModel mj_objectArrayWithKeyValuesArray:model.children];
    return tempArr.count;
}
- (CGFloat )yuFoldingTableView:(YUFoldingTableView *)yuTableView heightForHeaderInSection:(NSInteger )section
{
    return 62;
}
- (CGFloat )yuFoldingTableView:(YUFoldingTableView *)yuTableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 40;
}
- (UITableViewCell *)yuFoldingTableView:(YUFoldingTableView *)yuTableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    BGAirportCategoryModel *model = self.leftDataArr[indexPath.section];
    NSMutableArray *tempArr = [BGAirportCategoryModel mj_objectArrayWithKeyValuesArray:model.children];
    BGAirCategoryCell *cell = [yuTableView dequeueReusableCellWithIdentifier:@"BGAirCategoryCell" forIndexPath:indexPath];
    [cell updataWithCellArray:tempArr[indexPath.row] isShow:NO];
    
    
    
    
    return cell;
}
- (UIColor *)yuFoldingTableView:(YUFoldingTableView *)yuTableView textColorForTitleInSection:(NSInteger )section{
    
    if (section == 0) {
        return UIColorFromRGB(0xFF4848);
    }
    return kAppMainColor;
}

#pragma mark - YUFoldingTableViewDelegate / optional （可选择实现的）

- (NSString *)yuFoldingTableView:(YUFoldingTableView *)yuTableView titleForHeaderInSection:(NSInteger)section
{
    BGAirportCategoryModel *model = self.leftDataArr[section];
    return model.name;
}

- (void )yuFoldingTableView:(YUFoldingTableView *)yuTableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    BGAirportCategoryModel *sModel = self.leftDataArr[indexPath.section];
    NSMutableArray *tempArr = [BGAirportCategoryModel mj_objectArrayWithKeyValuesArray:sModel.children];
    BGAirportCategoryModel *model = tempArr[indexPath.row];
    [self loadCollectionViewDataWithID:model.ID];
}

/**
 *  点击sectionHeaderView
 */
- (void )yuFoldingTableView:(YUFoldingTableView *)yuTableView didSelectHeaderViewAtSection:(NSInteger)section{
    if (section == 0) {
        [self loadRightData];
    }else{
        DLog(@"statusArray:%@",yuTableView.statusArray);
        if ([yuTableView.statusArray[section] integerValue] == YUFoldingSectionStateShow) {
            [self.foldingTableView selectRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:section] animated:NO scrollPosition:(UITableViewScrollPositionTop)];
            if ([self.foldingTableView.foldingDelegate respondsToSelector:@selector(yuFoldingTableView:didSelectRowAtIndexPath:)]) {
                [self.foldingTableView.foldingDelegate yuFoldingTableView:self.foldingTableView didSelectRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:section]];
            }
        }else{
            
        }
       
    }
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
    if (_category<3) {
        [cell updataWithCellArray:_collectionDataArr[indexPath.item] isCar:NO];
    }else{
        [cell updataWithCellArray:_collectionDataArr[indexPath.item] isCar:YES];
    }
    
    return cell;
}
-(void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{
    switch (_category) {
        case 1:{
            BGAirportCategoryModel *model =_collectionDataArr[indexPath.item];
            NSString *titleStr = [NSString stringWithFormat:@"%@%@%@",model.region_name,model.airport_name,@"接机"];
            BGAirChooseProductViewController *productVC = BGAirChooseProductViewController.new;
            productVC.airport_id = model.airport_id;
            productVC.category = _category;
            productVC.titleStr = titleStr;
            [self.navigationController pushViewController:productVC animated:YES];
        }
            break;
        case 2:{
            BGAirportCategoryModel *model =_collectionDataArr[indexPath.item];
            NSString *titleStr = [NSString stringWithFormat:@"%@%@%@",model.region_name,model.airport_name,@"送机"];
            BGAirChooseProductViewController *productVC = BGAirChooseProductViewController.new;
            productVC.airport_id = model.airport_id;
            productVC.category = _category;
            productVC.titleStr = titleStr;
            [self.navigationController pushViewController:productVC animated:YES];
        }
            break;
        case 3:{
            BGAirportCategoryModel *model =_collectionDataArr[indexPath.item];
            NSString *titleStr;
            if ([Tool isBlankString:model.country_name]) {
                NSIndexPath *indexPathC = [self.foldingTableView indexPathForSelectedRow];
                BGAirportCategoryModel *zModel =_leftDataArr[indexPathC.section];
                NSMutableArray *tempArr = [BGAirportCategoryModel mj_objectArrayWithKeyValuesArray:zModel.children];
                BGAirportCategoryModel *cModel = tempArr[indexPathC.row];
                titleStr= [NSString stringWithFormat:@"%@%@%@",cModel.name,model.name,@"按天包车"];
            }else{
                titleStr = [NSString stringWithFormat:@"%@%@%@",model.country_name,model.region_name,@"按天包车"];
            }
            BGAirChooseProductViewController *productVC = BGAirChooseProductViewController.new;
            if ([Tool isBlankString:model.region_id]) {
                productVC.airport_id = model.ID;
            }else{
                productVC.airport_id = model.region_id;
            }
            productVC.category = _category;
            productVC.titleStr = titleStr;
            [self.navigationController pushViewController:productVC animated:YES];
        }
            break;
        case 4:{
            BGAirportCategoryModel *model =_collectionDataArr[indexPath.item];
            BGLineHotViewController *lineVC = BGLineHotViewController.new;
            if ([Tool isBlankString:model.region_id]) {
                lineVC.regionIdStr = model.ID;
            }else{
                 lineVC.regionIdStr = model.region_id;
            }
            [self.navigationController pushViewController:lineVC animated:YES];
        }
            break;
        case 5:{
            BGAirportCategoryModel *model =_collectionDataArr[indexPath.item];
            NSMutableDictionary *dic = [[NSMutableDictionary alloc] init];
            if ([Tool isBlankString:model.country_name]) {
                NSIndexPath *indexPathC = [self.foldingTableView indexPathForSelectedRow];
                BGAirportCategoryModel *zModel =_leftDataArr[indexPathC.section];
                NSMutableArray *tempArr = [BGAirportCategoryModel mj_objectArrayWithKeyValuesArray:zModel.children];
                BGAirportCategoryModel *cModel = tempArr[indexPathC.row];
                
                [dic setObject:cModel.name forKey:@"country_name"];
                [dic setObject:model.name forKey:@"region_name"];
                [dic setObject:cModel.ID forKey:@"country_id"];
                [dic setObject:model.ID forKey:@"region_id"];
            }else{
                [dic setObject:model.country_name forKey:@"country_name"];
                [dic setObject:model.region_name forKey:@"region_name"];
                [dic setObject:model.country_id forKey:@"country_id"];
                [dic setObject:model.region_id forKey:@"region_id"];
            }
            
            
            [[NSNotificationCenter defaultCenter] postNotificationName:@"SelectedCityTipsNotif" object:dic];
            
            for (UIViewController *controller in self.navigationController.viewControllers) {
                if ([controller isKindOfClass:[BGPersonalTailorViewController class]]) {
                    BGPersonalTailorViewController *personalVC = (BGPersonalTailorViewController *)controller;
                    CATransition *transition = [CATransition animation];
                    transition.type = kCATransitionReveal;
                    transition.subtype = kCATransitionFromBottom;
                    [self.navigationController.view.layer addAnimation:transition forKey:kCATransition];
                    [self.navigationController popToViewController:personalVC animated:NO];
                }
            }
        }
            break;
        default:
            break;
    }
    
}
@end
