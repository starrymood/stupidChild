//
//  BGHomeSearchViewController.m
//  ShaHaiZiT
//
//  Created by biao on 2018/11/21.
//  Copyright © 2018 biao. All rights reserved.
//

#import "BGHomeSearchViewController.h"
#import "EVNCustomSearchBar.h"
#import "BGCitySearchResultViewController.h"
#import "BGHomePreSearchViewController.h"

#define kEVNScreenStatusBarHeight [[UIApplication sharedApplication] statusBarFrame].size.height
@interface BGHomeSearchViewController ()<EVNCustomSearchBarDelegate>
/**
 * 导航搜索框EVNCustomSearchBar
 */
@property (strong, nonatomic) EVNCustomSearchBar *searchBar;

@property (nonatomic, strong) UIView *bgView;

@property(nonatomic,assign) NSInteger category;

@end

@implementation BGHomeSearchViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:UIView.new];
    self.view.backgroundColor = kAppBgColor;
    
//    //得到当前视图控制器中的所有控制器
//    NSMutableArray *array = [self.navigationController.viewControllers mutableCopy];
//
//    for (int i = 0; i < array.count; i++) {
//        if ([array[i] isKindOfClass:[BGHomePreSearchViewController class]]) {
//            [array removeObjectAtIndex:i];
//            //把删除后的控制器数组再次赋值
//            [self.navigationController setViewControllers:[array copy] animated:YES];
//        }
//    }
    
    CGFloat btnWith = (SCREEN_WIDTH-37-50-31*3)*0.25;

    _bgView = [[UIView alloc] initWithFrame:CGRectMake(0, SafeAreaTopHeight+6, SCREEN_WIDTH, btnWith+25)];
    _bgView.backgroundColor = kAppWhiteColor;
    [self.view addSubview:_bgView];
    
    NSArray *nameArr = @[@"接机",@"送机",@"线路",@"包车"];
    NSArray *colorArr = @[@"FFF5F5",@"F3F9FD",@"F4FDF3",@"FCF3FD"];
    for (int i = 0; i<4; i++) {
        UIButton *btn = [UIButton buttonWithType:(UIButtonTypeCustom)];
        btn.frame = CGRectMake(37+i*(btnWith+31), 13, btnWith, btnWith);
        btn.layer.masksToBounds = YES;
        btn.layer.cornerRadius = btnWith*0.5;
        [btn.titleLabel setFont:kFont(11)];
        [btn setTitleColor:kApp333Color forState:(UIControlStateNormal)];
        btn.backgroundColor = UIColorFromRGB([self numberWithHexString:colorArr[i]]);
        [btn setTitle:nameArr[i] forState:(UIControlStateNormal)];
        btn.tag = 1000+i;
        [btn addTarget:self action:@selector(jumpToSearchResultAction:) forControlEvents:(UIControlEventTouchUpInside)];
        [_bgView addSubview:btn];
    }
    
    
    
    [self initSearchBar];
    
}
-(void)jumpToSearchResultAction:(UIButton *)sender{
    
    switch (sender.tag-1000) {
        case 0:{
            _category = 1;
        }
            break;
        case 1:{
             _category = 2;
        }
            break;
        case 2:{
             _category = 4;
        }
            break;
        case 3:{
             _category = 3;
        }
            break;
            
        default:{
            return;
        }
            break;
    }
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
    listVC.name = _name;
    listVC.category = _category;
    listVC.isHome = YES;
    [self.navigationController pushViewController:listVC animated:YES];
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
        [_searchBar setPlaceholder:@"请输入搜索内容"];  // 搜索框的占位符
        _searchBar.placeholderColor = kApp666Color;
        
        [_searchBar setCanNotTouch];
        _searchBar.text = _name;
        _searchBar.delegate = self; // 设置代理
        [_searchBar sizeToFit];
    }
    return _searchBar;
}

#pragma mark: EVNCustomSearchBar delegate method

- (void)searchBarSearchButtonClicked:(EVNCustomSearchBar *)searchBar
{
    
}

- (void)searchBarCancelButtonClicked:(EVNCustomSearchBar *)searchBar
{
    CATransition *transition = [CATransition animation];
    transition.type = kCATransitionReveal;
    transition.subtype = kCATransitionFromBottom;
    [self.navigationController.view.layer addAnimation:transition forKey:kCATransition];
    [self.navigationController popToRootViewControllerAnimated:NO];
}

- (void)touchesEnded:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    [self.searchBar resignFirstResponder];
}

- (NSInteger)numberWithHexString:(NSString *)hexString{
    
    const char *hexChar = [hexString cStringUsingEncoding:NSUTF8StringEncoding];
    
    int hexNumber;
    
    sscanf(hexChar, "%x", &hexNumber);
    
    return (NSInteger)hexNumber;
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
