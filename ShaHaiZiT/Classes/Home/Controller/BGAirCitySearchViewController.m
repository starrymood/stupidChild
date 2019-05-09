//
//  BGAirCitySearchViewController.m
//  shzTravelC
//
//  Created by biao on 2018/8/30.
//  Copyright © 2018年 biao. All rights reserved.
//

#import "BGAirCitySearchViewController.h"
#import "EVNCustomSearchBar.h"
#import "SKTagView.h"
#import "BGCitySearchResultViewController.h"
#import "BGSearchResultsTableViewController.h"
#import "BGAirportCategoryModel.h"
#import "BGAirChooseProductViewController.h"
#import "BGLineHotViewController.h"
#import "BGPersonalTailorViewController.h"
#import "BGVisaListViewController.h"

#define kEVNScreenStatusBarHeight [[UIApplication sharedApplication] statusBarFrame].size.height
#define kCachePathA ([NSHomeDirectory()stringByAppendingPathComponent:@"Documents/history1"])
#define kCachePathB ([NSHomeDirectory()stringByAppendingPathComponent:@"Documents/history2"])
#define kCachePathC ([NSHomeDirectory()stringByAppendingPathComponent:@"Documents/history3"])
#define kCachePathD ([NSHomeDirectory()stringByAppendingPathComponent:@"Documents/history4"])
#define kCachePathE ([NSHomeDirectory()stringByAppendingPathComponent:@"Documents/history5"])
#define kCachePathF ([NSHomeDirectory()stringByAppendingPathComponent:@"Documents/history6"])
@interface BGAirCitySearchViewController ()<EVNCustomSearchBarDelegate>
/**
 * 导航搜索框EVNCustomSearchBar
 */
@property (strong, nonatomic) EVNCustomSearchBar *searchBar;

// 历史搜索collectionView
@property (nonatomic,strong) SKTagView *tagView;
// 历史搜索数据源
@property (nonatomic,strong) NSMutableArray *dataSource;
// 历史搜索删除button
@property (nonatomic,strong) UIButton *deleteHisBtn;

@property (nonatomic, strong) UIView *bgView;

@property (nonatomic, weak) BGSearchResultsTableViewController *searchSuggestionVC;

@end

@implementation BGAirCitySearchViewController
- (BGSearchResultsTableViewController *)searchSuggestionVC
{
    if (!_searchSuggestionVC) {
        BGSearchResultsTableViewController *searchSuggestionVC = [[BGSearchResultsTableViewController alloc] initWithStyle:UITableViewStylePlain];
        searchSuggestionVC.category = _category;
        __weak typeof(self) weakSelf = self;
        searchSuggestionVC.didSelectLocation = ^(BGAirportCategoryModel *model) {
            switch (weakSelf.category) {
                case 1:{
                    NSString *titleStr = [NSString stringWithFormat:@"%@%@%@",model.region_name,model.airport_name,@"接机"];
                    BGAirChooseProductViewController *productVC = BGAirChooseProductViewController.new;
                    productVC.airport_id = model.airport_id;
                    productVC.category = weakSelf.category;
                    productVC.titleStr = titleStr;
                    [weakSelf.navigationController pushViewController:productVC animated:YES];
                }
                    break;
                case 2:{
                    NSString *titleStr = [NSString stringWithFormat:@"%@%@%@",model.region_name,model.airport_name,@"送机"];
                    BGAirChooseProductViewController *productVC = BGAirChooseProductViewController.new;
                    productVC.airport_id = model.airport_id;
                    productVC.category = weakSelf.category;
                    productVC.titleStr = titleStr;
                    [weakSelf.navigationController pushViewController:productVC animated:YES];
                }
                    break;
                case 3:{
                    NSString *titleStr = [NSString stringWithFormat:@"%@%@%@",model.country_name,model.region_name,@"按天包车"];
                    BGAirChooseProductViewController *productVC = BGAirChooseProductViewController.new;
                    productVC.airport_id = model.region_id;
                    productVC.category = weakSelf.category;
                    productVC.titleStr = titleStr;
                    [weakSelf.navigationController pushViewController:productVC animated:YES];
                }
                    break;
                case 4:{
                    BGLineHotViewController *lineVC = BGLineHotViewController.new;
                    lineVC.regionIdStr = model.region_id;
                    [weakSelf.navigationController pushViewController:lineVC animated:YES];
                }
                    break;
                case 5:{
                    NSMutableDictionary *dic = [[NSMutableDictionary alloc] init];
                    [dic setObject:model.country_name forKey:@"country_name"];
                    [dic setObject:model.region_name forKey:@"region_name"];
                    [dic setObject:model.country_id forKey:@"country_id"];
                    [dic setObject:model.region_id forKey:@"region_id"];
                    
                    [[NSNotificationCenter defaultCenter] postNotificationName:@"SelectedCityTipsNotif" object:dic];
                    
                    for (UIViewController *controller in weakSelf.navigationController.viewControllers) {
                        if ([controller isKindOfClass:[BGPersonalTailorViewController class]]) {
                            BGPersonalTailorViewController *personalVC = (BGPersonalTailorViewController *)controller;
                            CATransition *transition = [CATransition animation];
                            transition.type = kCATransitionReveal;
                            transition.subtype = kCATransitionFromBottom;
                            [weakSelf.navigationController.view.layer addAnimation:transition forKey:kCATransition];
                            [weakSelf.navigationController popToViewController:personalVC animated:NO];
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
            
        };
        
        
        searchSuggestionVC.view.frame = CGRectMake(0, SafeAreaTopHeight, SCREEN_WIDTH, SCREEN_HEIGHT-SafeAreaTopHeight-SafeAreaBottomHeight-45);
        searchSuggestionVC.view.backgroundColor = [UIColor colorWithWhite:0.95 alpha:1.0];
        
        [self.view addSubview:searchSuggestionVC.view];
        [self addChildViewController:searchSuggestionVC];
        _searchSuggestionVC = searchSuggestionVC;
    }
    return _searchSuggestionVC;
}
- (NSMutableArray *)dataSource {
    if (!_dataSource) {
        self.dataSource = [NSMutableArray array];
    }
    return _dataSource;
}
- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    
    self.navigationController.navigationBarHidden = NO;
    
    // 弹出键盘
    [self.searchBar becomeFirstResponder];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:UIView.new];
    self.view.backgroundColor = kAppBgColor;
    _bgView = [[UIView alloc] initWithFrame:CGRectMake(0, SafeAreaTopHeight+6, SCREEN_WIDTH, 80)];
    _bgView.backgroundColor = kAppWhiteColor;
    [self.view addSubview:_bgView];
    UILabel *label = UILabel.new;
    label.frame = CGRectMake(13, 15, 100, 20);
    label.font = kFont(12);
    label.textAlignment = NSTextAlignmentLeft;
    label.text = @"最近搜索";
    label.textColor = kApp333Color;
    [_bgView addSubview:label];
    
    self.deleteHisBtn = [UIButton buttonWithType:(UIButtonTypeCustom)];
    _deleteHisBtn.frame = CGRectMake(SCREEN_WIDTH-54, label.y, 30, 20);
    [_deleteHisBtn setImage:BGImage(@"mine_collection_delete") forState:(UIControlStateNormal)];
    [_bgView addSubview:_deleteHisBtn];
    @weakify(self);
    [[_deleteHisBtn rac_signalForControlEvents:(UIControlEventTouchUpInside)] subscribeNext:^(__kindof UIControl * _Nullable x) {
        @strongify(self);
        // 点击button的响应事件
        [self cleanHistoryBtnClickedAction];
    }];
    
    [self initSearchBar];
    
    // 解档
    self.dataSource = [NSMutableArray arrayWithArray:[self readNSUserDefaults]];
    [self configTagView];
}
- (void)clickedBackItem{
    
    CATransition *transition = [CATransition animation];
    transition.type = kCATransitionReveal;
    transition.subtype = kCATransitionFromBottom;
    [self.navigationController.view.layer addAnimation:transition forKey:kCATransition];
    [self.navigationController popViewControllerAnimated:NO];
}

#pragma mark: 设置顶部导航搜索部分
- (void)initSearchBar
{
    self.navigationItem.titleView = self.searchBar;
    if (@available(iOS 11.0, *))
    {
        [self.searchBar.heightAnchor constraintLessThanOrEqualToConstant:kNavigationBarH].active = YES;
    }
}

#pragma mark: getter method EVNCustomSearchBar
- (EVNCustomSearchBar *)searchBar
{
    if (!_searchBar)
    {
        _searchBar = [[EVNCustomSearchBar alloc] initWithFrame:CGRectMake(0, kEVNScreenStatusBarHeight, SCREEN_WIDTH, kNavigationBarH)];
        
        _searchBar.backgroundColor = [UIColor clearColor]; // 清空searchBar的背景色
        _searchBar.iconImage = BGImage(@"community_search");
        _searchBar.iconAlign = EVNCustomSearchBarIconAlignCenter;
        switch (_category) {
            case 1:
                [_searchBar setPlaceholder:@"您将降落在哪座机场" ];
                break;
            case 2:
                [_searchBar setPlaceholder: @"您将出发在哪座机场"];
                break;
            case 6:
                [_searchBar setPlaceholder: @"您想要去哪个国家"];
                break;
            default:
                [_searchBar setPlaceholder:@"您想要去哪座城市"];
                break;
        }
        
        _searchBar.placeholderColor = kApp666Color;
        
        [_searchBar isShowCancelButtonWithDone:NO];
        _searchBar.delegate = self; // 设置代理
        [_searchBar sizeToFit];
    }
    return _searchBar;
}

#pragma mark: EVNCustomSearchBar delegate method

- (void)searchBarSearchButtonClicked:(EVNCustomSearchBar *)searchBar
{
    if (_searchBar.text.length > 0) {
        [self pushViewWithTitle:_searchBar.text isPerson:NO];
    }else{
        [WHIndicatorView toast:@"请输入搜索内容"];
    }
    
    //    NSLog(@"class: %@ function:%s", NSStringFromClass([self class]), __func__);
}
- (void)searchBar:(EVNCustomSearchBar *)searchBar textDidChange:(NSString *)searchText{
    if ([searchText isEqualToString:@""]) {
        self.searchSuggestionVC.view.hidden = YES;
    }
    else
    {
        self.searchSuggestionVC.view.hidden = NO;
        [self.view bringSubviewToFront:self.searchSuggestionVC.view];
        
        //创建一个消息对象
        NSNotification * notice = [NSNotification notificationWithName:@"searchBarDidChange" object:nil userInfo:@{@"searchText":searchText}];
        //发送消息
        [[NSNotificationCenter defaultCenter]postNotification:notice];
    }
    
}
- (void)searchBarCancelButtonClicked:(EVNCustomSearchBar *)searchBar
{
    [self clickedBackItem];
    //    NSLog(@"class: %@ function:%s", NSStringFromClass([self class]), __func__);
}

- (void)touchesEnded:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    [self.searchBar resignFirstResponder];
}


/**
 *  读取存储的数组
 *
 *  @return 返回历史搜索数组
 */
-(NSArray *)readNSUserDefaults {
    NSArray *historyArr;
    if (_category == 1) {
        historyArr = [NSKeyedUnarchiver unarchiveObjectWithFile:kCachePathA];
    }else if (_category == 2){
        historyArr = [NSKeyedUnarchiver unarchiveObjectWithFile:kCachePathB];
    }else if (_category == 3){
        historyArr = [NSKeyedUnarchiver unarchiveObjectWithFile:kCachePathC];
    }else if (_category == 4){
        historyArr = [NSKeyedUnarchiver unarchiveObjectWithFile:kCachePathD];
    }else if (_category == 5){
        historyArr = [NSKeyedUnarchiver unarchiveObjectWithFile:kCachePathE];
    }else{
        historyArr = [NSKeyedUnarchiver unarchiveObjectWithFile:kCachePathF];
    }
    if (nil == historyArr) {
        historyArr = @[];
    }
    
    return historyArr;
}
// 归档
- (void)saveNSUserDefaults:(NSMutableArray *)historyArr {
    
    NSArray *saveArr = [NSArray arrayWithArray:historyArr];
    if (_category == 1) {
        [NSKeyedArchiver archiveRootObject:saveArr toFile:kCachePathA];
    }else if (_category == 2){
        [NSKeyedArchiver archiveRootObject:saveArr toFile:kCachePathB];
    }else if (_category == 3){
        [NSKeyedArchiver archiveRootObject:saveArr toFile:kCachePathC];
    }else if (_category == 4){
        [NSKeyedArchiver archiveRootObject:saveArr toFile:kCachePathD];
    }else if (_category == 5){
        [NSKeyedArchiver archiveRootObject:saveArr toFile:kCachePathE];
    } else{
        [NSKeyedArchiver archiveRootObject:saveArr toFile:kCachePathF];
    }
    
    [self.tagView removeFromSuperview];
    [self configTagView];
}

// 配置历史搜索
- (void)configTagView {
    
    [self.tagView removeAllTags];
    
    self.tagView = [[SKTagView alloc] init];
    
    // 整个tagView对应其SuperView的上左下右距离
    self.tagView.padding = UIEdgeInsetsMake(10, 10, 10, 10);
    // 上下行之间的距离
    self.tagView.lineSpacing = 15;
    // item之间的距离
    self.tagView.interitemSpacing = 15;
    // 最大宽度
    self.tagView.preferredMaxLayoutWidth = SCREEN_WIDTH;
    self.tagView.singleLine = NO;
    // 开始加载
    [_dataSource enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        // 初始化标签
        SKTag *tag = [[SKTag alloc] initWithText:self.dataSource[idx]];
        // 标签相对于自己容器的上左下右的距离
        tag.padding = UIEdgeInsetsMake(3, 15, 3, 15);
        // 弧度
        tag.cornerRadius = 11.0f;
        // 字体
        tag.font = kFont(13);
        
        // 背景
        tag.bgColor = kAppWhiteColor;
        // 边框宽度
        tag.borderWidth = 0.5;
        // 边框颜色
        tag.borderColor = kAppMainColor;
        // 字体颜色
        tag.textColor = kAppMainColor;
        // 是否可点击
        tag.enable = YES;
        // 加入到tagView
        [self.tagView addTag:tag];
    }];
    
    // 点击事件回调
    // 防止循环引用
    __weak typeof (self)weakSelf = self;
    
    self.tagView.didTapTagAtIndex = ^(NSUInteger index) {
        // 跳转搜索界面
        [weakSelf pushViewWithTitle:weakSelf.dataSource[index] isPerson:NO];
    };
    
    
    // 获取刚才加入所有tag之后的内在高度
    CGFloat tagHeight = self.tagView.intrinsicContentSize.height;
    //    NSLog(@"高度%lf",tagHeight);
    _bgView.height = tagHeight + 45;

    self.tagView.frame = CGRectMake(0, _deleteHisBtn.y+_deleteHisBtn.height+10, SCREEN_WIDTH, tagHeight);
    [self.tagView layoutSubviews];
    [_bgView addSubview:self.tagView];
    
}
-(void)cleanHistoryBtnClickedAction {
    [_dataSource removeAllObjects];
    [self saveNSUserDefaults:_dataSource];
    [self.tagView removeAllTags];
}
// 搜索跳转界面
- (void)pushViewWithTitle:(NSString *)title isPerson:(BOOL)isPerson{
    
    // 判断新增加的string是否存在,若存在则删除
    if ([_dataSource containsObject:title]) {
        
        [_dataSource removeObject:title];
    }
    [_dataSource insertObject:title atIndex:0];
    // 数组归档
    [self saveNSUserDefaults:_dataSource];
    
    //得到当前视图控制器中的所有控制器
        NSMutableArray *array = [self.navigationController.viewControllers mutableCopy];
        for (int i = 0; i < array.count; i++) {
            if ([array[i] isKindOfClass:[BGCitySearchResultViewController class]]) {
                [array removeObjectAtIndex:i];
                //把删除后的控制器数组再次赋值
                [self.navigationController setViewControllers:[array copy] animated:YES];
            }
        }
        // 跳转新界面
        BGCitySearchResultViewController *listVC = BGCitySearchResultViewController.new;
        listVC.name = title;
        listVC.category = _category;
        listVC.isHome = NO;
        [self.navigationController pushViewController:listVC animated:YES];
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