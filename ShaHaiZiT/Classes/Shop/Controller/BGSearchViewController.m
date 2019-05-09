//
//  BGSearchViewController.m
//  shzTravelC
//
//  Created by biao on 2018/6/7.
//  Copyright © 2018年 biao. All rights reserved.
//

#import "BGSearchViewController.h"
#import "EVNCustomSearchBar.h"
#import "SKTagView.h"
#import "BGShopListViewController.h"

#define kEVNScreenStatusBarHeight [[UIApplication sharedApplication] statusBarFrame].size.height
#define kCachePath ([NSHomeDirectory()stringByAppendingPathComponent:@"Documents/download"])

@interface BGSearchViewController ()<EVNCustomSearchBarDelegate>
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

@end

@implementation BGSearchViewController
- (NSMutableArray *)dataSource {
    if (!_dataSource) {
        self.dataSource = [NSMutableArray array];
    }
    return _dataSource;
}
- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    self.navigationController.navigationBarHidden = NO;
    
    // 弹出键盘
    [self.searchBar becomeFirstResponder];
}

- (void)viewDidLoad {
    [super viewDidLoad];

    self.navigationItem.leftBarButtonItem = [self itemWithImage:@"btn_back_black" highImage:@"btn_back_green" target:self action:@selector(clickedBackItem)];
    
    UILabel *label = UILabel.new;
    label.frame = CGRectMake(15, SafeAreaTopHeight+25, 100, 20);
    label.font = kFont(15);
    label.textAlignment = NSTextAlignmentLeft;
    label.text = @"最近搜索";
    [self.view addSubview:label];
    
    self.deleteHisBtn = [UIButton buttonWithType:(UIButtonTypeCustom)];
    _deleteHisBtn.frame = CGRectMake(SCREEN_WIDTH-40, label.y, 30, 20);
    [_deleteHisBtn setImage:BGImage(@"mine_collection_delete") forState:(UIControlStateNormal)];
    [self.view addSubview:_deleteHisBtn];
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
        _searchBar.iconImage = BGImage(@"home_search");
        _searchBar.iconAlign = EVNCustomSearchBarIconAlignCenter;
        [_searchBar setPlaceholder:@"在万千海外商品中搜索"];  // 搜索框的占位符
        _searchBar.placeholderColor = kApp666Color;
        _searchBar.delegate = self; // 设置代理
        [_searchBar sizeToFit];
    }
    return _searchBar;
}

#pragma mark: EVNCustomSearchBar delegate method
/*
- (BOOL)searchBarShouldBeginEditing:(EVNCustomSearchBar *)searchBar
{
    NSLog(@"class: %@ function:%s", NSStringFromClass([self class]), __func__);
    return YES;
}

- (void)searchBarTextDidBeginEditing:(EVNCustomSearchBar *)searchBar
{
    NSLog(@"class: %@ function:%s", NSStringFromClass([self class]), __func__);
}

- (BOOL)searchBarShouldEndEditing:(EVNCustomSearchBar *)searchBar
{
    NSLog(@"class: %@ function:%s", NSStringFromClass([self class]), __func__);
    return YES;
}

- (void)searchBarTextDidEndEditing:(EVNCustomSearchBar *)searchBar
{
    NSLog(@"class: %@ function:%s", NSStringFromClass([self class]), __func__);
}

- (void)searchBar:(EVNCustomSearchBar *)searchBar textDidChange:(NSString *)searchText
{
    NSLog(@"class: %@ function:%s", NSStringFromClass([self class]), __func__);
}

- (BOOL)searchBar:(EVNCustomSearchBar *)searchBar shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text
{
    NSLog(@"class: %@ function:%s", NSStringFromClass([self class]), __func__);
    return YES;
}
*/
- (void)searchBarSearchButtonClicked:(EVNCustomSearchBar *)searchBar
{
    if (_searchBar.text.length > 0) {
        [self pushViewWithTitle:_searchBar.text];
    }else{
        [WHIndicatorView toast:@"请输入搜索内容"];
    }
    
//    NSLog(@"class: %@ function:%s", NSStringFromClass([self class]), __func__);
}

- (void)searchBarCancelButtonClicked:(EVNCustomSearchBar *)searchBar
{
    if (_searchBar.text.length > 0) {
       [self pushViewWithTitle:_searchBar.text];
    }else{
        [WHIndicatorView toast:@"请输入搜索内容"];
    }
//    NSLog(@"class: %@ function:%s", NSStringFromClass([self class]), __func__);
}

- (void)touchesEnded:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    [self.searchBar resignFirstResponder];
}

- (UIBarButtonItem *)itemWithImage:(NSString *)image highImage:(NSString *)highImage target:(id)target action:(SEL)action
{
    UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
    [btn setImage:[UIImage imageNamed:image] forState:UIControlStateNormal];
    [btn setImage:[UIImage imageNamed:highImage] forState:UIControlStateHighlighted];
    btn.bounds = CGRectMake(0, 0, 20, 44);
    btn.contentEdgeInsets = UIEdgeInsetsZero;
    
    btn.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
    
    [btn addTarget:target action:action forControlEvents:UIControlEventTouchUpInside];
    return [[UIBarButtonItem alloc] initWithCustomView:btn];
}


/**
 *  读取存储的数组
 *
 *  @return 返回历史搜索数组
 */
-(NSArray *)readNSUserDefaults {
    NSArray *historyArr = [NSKeyedUnarchiver unarchiveObjectWithFile:kCachePath];
    if (nil == historyArr) {
        historyArr = @[];
    }
    
    return historyArr;
}
// 归档
- (void)saveNSUserDefaults:(NSMutableArray *)historyArr {
    
    NSArray *saveArr = [NSArray arrayWithArray:historyArr];
    
    [NSKeyedArchiver archiveRootObject:saveArr toFile:kCachePath];
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
        tag.cornerRadius = 12.0f;
        // 字体
        tag.font = [UIFont boldSystemFontOfSize:13];

        // 背景
        tag.bgColor = UIColorFromRGB(0xF5F5F5);
        // 边框宽度
        //        tag.borderWidth = 0;
        // 边框颜色
        //        tag.borderColor = [UIColor colorWithRed:191/255.0 green:191/255.0 blue:191/255.0 alpha:1];
        // 字体颜色
        tag.textColor = kApp333Color;
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
        [weakSelf pushViewWithTitle:weakSelf.dataSource[index]];
    };

    
    // 获取刚才加入所有tag之后的内在高度
    CGFloat tagHeight = self.tagView.intrinsicContentSize.height;
    //    NSLog(@"高度%lf",tagHeight);
    self.tagView.frame = CGRectMake(0, _deleteHisBtn.y+_deleteHisBtn.height+10, SCREEN_WIDTH, tagHeight);
    [self.tagView layoutSubviews];
    [self.view addSubview:self.tagView];
    
}
-(void)cleanHistoryBtnClickedAction {
    [_dataSource removeAllObjects];
    [self saveNSUserDefaults:_dataSource];
    [self.tagView removeAllTags];
}
// 搜索跳转界面
- (void)pushViewWithTitle:(NSString *)title {
    
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
        if ([array[i] isKindOfClass:[BGShopListViewController class]]) {
            [array removeObjectAtIndex:i];
            //把删除后的控制器数组再次赋值
            [self.navigationController setViewControllers:[array copy] animated:YES];
        }
    }
    
    // 跳转新界面
    BGShopListViewController *listVC = BGShopListViewController.new;
    listVC.keyword = title;
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
