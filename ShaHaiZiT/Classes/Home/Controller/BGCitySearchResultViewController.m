//
//  BGCitySearchResultViewController.m
//  shzTravelC
//
//  Created by biao on 2018/9/21.
//  Copyright © 2018年 biao. All rights reserved.
//

#import "BGCitySearchResultViewController.h"
#import "BGAirCitySearchViewController.h"
#import "BGAirportCategoryModel.h"
#import "BGAirApi.h"
#import "BGAirRightCell.h"
#import "BGPersonalTailorViewController.h"
#import "BGAirChooseProductViewController.h"
#import "BGLineHotViewController.h"
#import "BGHomeSearchViewController.h"
#import "BGHomePreSearchViewController.h"
#import "BGVisaListViewController.h"

@interface BGCitySearchResultViewController ()<UICollectionViewDelegate,UICollectionViewDataSource>

@property (nonatomic, strong) UICollectionView *collectionView;

@property (nonatomic,strong)NSMutableArray *cellDataArr;

@property (nonatomic, strong) UIView *noneView;

@end

@implementation BGCitySearchResultViewController

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
        if (_category==6) {
            showMsgLabel.text = @"暂未搜索到该国家";
        }else{
            showMsgLabel.text = _category<3?@"暂未搜索到该机场":@"暂未搜索到该城市";

        }
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
    self.navigationController.navigationBarHidden = YES;
}
-(void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    self.navigationController.navigationBarHidden = NO;
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
    [self setupLayoutAndCollectionView];
    [self loadData];
    
}
-(void)loadSubViews{
    self.view.backgroundColor = kAppBgColor;
    
    //得到当前视图控制器中的所有控制器
    NSMutableArray *array = [self.navigationController.viewControllers mutableCopy];
    
    for (int i = 0; i < array.count; i++) {
        if ([array[i] isKindOfClass:[BGAirCitySearchViewController class]] || [array[i] isKindOfClass:[BGHomeSearchViewController class]]) {
            [array removeObjectAtIndex:i];
            //把删除后的控制器数组再次赋值
            [self.navigationController setViewControllers:[array copy] animated:YES];
        }
    }
    
    
    UIView *whiteView = UIView.new;
    whiteView.backgroundColor = kAppWhiteColor;
    whiteView.frame = CGRectMake(0, 0, SCREEN_WIDTH, SafeAreaTopHeight-kNavigationBarH+3);
    [self.view addSubview:whiteView];
    // 搜索框
    UIView *topView = UIView.new;
    topView.backgroundColor = kAppWhiteColor;
    topView.frame = CGRectMake(0, SafeAreaTopHeight-kNavigationBarH+3, SCREEN_WIDTH, kNavigationBarH);
    [self.view addSubview:topView];
    
    UIButton *button = UIButton.new;
    [button setImage:[UIImage imageNamed:@"btn_back_black"] forState:UIControlStateNormal];
    [button setImage:[UIImage imageNamed:@"btn_back_green"] forState:UIControlStateHighlighted];
    button.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
    
    @weakify(self);
    [[button rac_signalForControlEvents:(UIControlEventTouchUpInside)] subscribeNext:^(__kindof UIControl * _Nullable x) {
        @strongify(self);
        // 点击button的响应事件
        [self.navigationController popViewControllerAnimated:YES];
    }];
    button.frame = CGRectMake(15, 9, 40, 30);
    button.contentEdgeInsets = UIEdgeInsetsMake(0, 0, 0, 0);
    button.titleLabel.font = [UIFont systemFontOfSize:15];
    [topView addSubview:button];
    
    UIButton *searchBtn = [UIButton buttonWithType:(UIButtonTypeCustom)];
    searchBtn.frame = CGRectMake(41, 7, SCREEN_WIDTH-29-41, 30);
    searchBtn.backgroundColor = UIColorFromRGB(0xEBF1F6);
    searchBtn.clipsToBounds = YES;
    searchBtn.layer.cornerRadius = 15;
    
    [[searchBtn rac_signalForControlEvents:(UIControlEventTouchUpInside)] subscribeNext:^(__kindof UIControl * _Nullable x) {
        @strongify(self);
        // 点击button的响应事件
        if (self.isHome) {
            BGHomePreSearchViewController *searchVC = BGHomePreSearchViewController.new;
            CATransition *transition = [CATransition animation];
            transition.type = kCATransitionFade;
            transition.subtype = kCATransitionFromBottom;
            [self.navigationController.view.layer addAnimation:transition forKey:kCATransition];
            [self.navigationController pushViewController:searchVC animated:NO];
        }else{
            BGAirCitySearchViewController *searchVC = BGAirCitySearchViewController.new;
            CATransition *transition = [CATransition animation];
            transition.type = kCATransitionFade;
            transition.subtype = kCATransitionFromBottom;
            [self.navigationController.view.layer addAnimation:transition forKey:kCATransition];
            [self.navigationController pushViewController:searchVC animated:NO];
        }
    }];
    
    UIImageView *searchImgView = [[UIImageView alloc] initWithImage:BGImage(@"community_search")];
    searchImgView.frame = CGRectMake(14, 8, 16, 14);
    [searchBtn addSubview:searchImgView];
    
    UILabel *searchLabel = UILabel.new;
    searchLabel.frame = CGRectMake(35, 9, 100, 13);
    if ([Tool isBlankString:_name]) {
        [searchLabel setTextColor:kApp999Color];
        searchLabel.text = @"搜索";
    }else{
        [searchLabel setTextColor:kApp333Color];
        searchLabel.text = _name;
    }
    [searchLabel setFont:kFont(13)];
    [searchBtn addSubview:searchLabel];
    
    [topView addSubview:searchBtn];
}
/**
 * 创建布局和collectionView
 */
- (void)setupLayoutAndCollectionView{
    
    CGFloat itemWidth = (SCREEN_WIDTH-30*2-17)*0.5;
    UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
    layout.itemSize = CGSizeMake(itemWidth, itemWidth*1.048);
    layout.minimumInteritemSpacing = 13;
    layout.minimumLineSpacing = 36;
    layout.sectionInset = UIEdgeInsetsMake(24, 30, 49, 30);
    
    
    _collectionView = [[UICollectionView alloc] initWithFrame:CGRectMake(0, SafeAreaTopHeight, SCREEN_WIDTH, SCREEN_HEIGHT-SafeAreaTopHeight) collectionViewLayout:layout];
    _collectionView.showsVerticalScrollIndicator = NO;
    _collectionView.backgroundColor = kAppBgColor;
    _collectionView.delegate = self;
    _collectionView.dataSource = self;
    [_collectionView registerNib:[UINib nibWithNibName:NSStringFromClass([BGAirRightCell class]) bundle:nil] forCellWithReuseIdentifier:@"BGAirRightCell"];
    [self.view addSubview:_collectionView];
}
-(void)loadData {
    NSMutableDictionary *param = [[NSMutableDictionary alloc] init];
    [param setObject:_name forKey:@"name"];
    [param setObject:@(_category) forKey:@"category"];
    [ProgressHUDHelper showLoading];
    __block typeof(self) weakSelf = self;
    [BGAirApi searchAirCity:param category:_category succ:^(NSDictionary *response) {
        DLog(@"\n>>>[searchAirCity sucess]:%@",response);
        weakSelf.cellDataArr = [BGAirportCategoryModel mj_objectArrayWithKeyValuesArray:response[@"result"]];
        if (weakSelf.cellDataArr.count>0) {
            [weakSelf.noneView removeFromSuperview];
        }else{
            [weakSelf.collectionView addSubview:weakSelf.noneView];
        }
        [weakSelf.collectionView reloadData];
    } failure:^(NSDictionary *response) {
        DLog(@"\n>>>[searchAirCity failure]:%@",response);
    }];
}
#pragma - mark UICollectionView
-(NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView{
    return 1;
}
-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    
    return _cellDataArr.count;
    
}
-(UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    BGAirRightCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"BGAirRightCell" forIndexPath:indexPath];
    if (_cellDataArr.count>0) {
        [cell updataWithCellArray:_cellDataArr[indexPath.item] isCar:(_category<3)?NO:YES];
    }
    
    return cell;
}
-(void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{
     BGAirportCategoryModel *model =_cellDataArr[indexPath.item];
    switch (_category) {
        case 1:{
            NSString *titleStr = [NSString stringWithFormat:@"%@%@%@",model.region_name,model.airport_name,@"接机"];
            BGAirChooseProductViewController *productVC = BGAirChooseProductViewController.new;
            productVC.airport_id = model.airport_id;
            productVC.category = _category;
            productVC.titleStr = titleStr;
            [self.navigationController pushViewController:productVC animated:YES];
        }
            break;
        case 2:{
            NSString *titleStr = [NSString stringWithFormat:@"%@%@%@",model.region_name,model.airport_name,@"送机"];
            BGAirChooseProductViewController *productVC = BGAirChooseProductViewController.new;
            productVC.airport_id = model.airport_id;
            productVC.category = _category;
            productVC.titleStr = titleStr;
            [self.navigationController pushViewController:productVC animated:YES];
        }
            break;
        case 3:{
            NSString *titleStr = [NSString stringWithFormat:@"%@%@%@",model.country_name,model.region_name,@"按天包车"];
            BGAirChooseProductViewController *productVC = BGAirChooseProductViewController.new;
            productVC.airport_id = model.region_id;
            productVC.category = _category;
            productVC.titleStr = titleStr;
            [self.navigationController pushViewController:productVC animated:YES];
        }
            break;
        case 4:{
            BGLineHotViewController *lineVC = BGLineHotViewController.new;
            lineVC.regionIdStr = model.region_id;
            [self.navigationController pushViewController:lineVC animated:YES];
        }
            break;
        case 5:{
            NSMutableDictionary *dic = [[NSMutableDictionary alloc] init];
            [dic setObject:model.country_name forKey:@"country_name"];
            [dic setObject:model.region_name forKey:@"region_name"];
            [dic setObject:model.country_id forKey:@"country_id"];
            [dic setObject:model.region_id forKey:@"region_id"];
            
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
        case 6:{
            BGVisaListViewController *productVC = BGVisaListViewController.new;
            NSString *titleStr = [NSString stringWithFormat:@"%@签证",model.country_name];
            productVC.country_id = model.country_id;
            productVC.titleStr = titleStr;
            [self.navigationController pushViewController:productVC animated:YES];
        }
            break;
        default:
            break;
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
