//
//  BGSettingViewController.m
//  shzTravelC
//
//  Created by 孙林茂 on 2018/5/10.
//  Copyright © 2018年 biao. All rights reserved.
//

#import "BGSettingViewController.h"
#import "BGMineCustomTwoCell.h"
#import "JCAlertController.h"
#import "BGWebViewController.h"
#import <RongIMKit/RongIMKit.h>
#import "BGFeedbackViewController.h"
#import "BGSystemApi.h"
#import "BGVerifyNameViewController.h"

@interface BGSettingViewController ()<UITableViewDelegate,UITableViewDataSource>

@property (nonatomic,strong)UITableView *tableView;
@property (nonatomic, strong) JCAlertController *alert;
@property (nonatomic, copy) NSString *cacheSizeStr;
@property (nonatomic, strong) UIView *footerView;
@property (nonatomic, strong) UIButton *quitLoginBtn;

@end

@implementation BGSettingViewController
-(UIView *)footerView{
    if (!_footerView) {
        self.footerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, 60)];
        _footerView.backgroundColor = kAppClearColor;
        
        CGFloat btnWidth = (SCREEN_WIDTH-230)*0.5;
        self.quitLoginBtn = [[UIButton alloc] initWithFrame:CGRectMake(btnWidth, 20, 230, 40)];
        _quitLoginBtn.backgroundColor = kAppMainColor;
        [_quitLoginBtn setTitle:@"退出登录" forState:(UIControlStateNormal)];
        [_quitLoginBtn.titleLabel setFont:kFont(16)];
        [_quitLoginBtn.titleLabel setTextColor:kAppWhiteColor];
        _quitLoginBtn.layer.cornerRadius = 5;
        _quitLoginBtn.clipsToBounds = YES;
        [_quitLoginBtn addTarget:self action:@selector(handleQuitLoginAction:) forControlEvents:(UIControlEventTouchUpInside)];
        
        [_footerView addSubview:_quitLoginBtn];
    }
    return _footerView;
}
-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    self.navigationController.navigationBarHidden = NO;
    self.cacheSizeStr = [NSString stringWithFormat:@"%.2fM",[self folderSizeAtPath:[self getPath]]];
    [self loadSubViews];
    
}

- (void)viewDidLoad {
    [super viewDidLoad];
}
#pragma mark - 加载视图
- (void)loadSubViews {
    
    self.navigationItem.title = @"设置";
    self.view.backgroundColor = kAppWhiteColor;
    self.tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, SafeAreaTopHeight, SCREEN_WIDTH, SCREEN_HEIGHT-SafeAreaTopHeight) style:(UITableViewStylePlain)];
    //    _tableView.scrollEnabled = NO;
    _tableView.backgroundColor = kAppBgColor;
    _tableView.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
    _tableView.separatorColor = kAppLineBGColor;
    _tableView.dataSource = self;
    _tableView.delegate = self;
    [self.view addSubview:_tableView];
    
    self.tableView.rowHeight = 45;
    
    // 注册cell
    [self.tableView registerNib:[UINib nibWithNibName:@"BGMineCustomTwoCell" bundle:nil] forCellReuseIdentifier:@"BGMineCustomTwoCell"];
    
}

// 点击退出登录按钮
- (void)handleQuitLoginAction:(UIButton *)sender {
    self.alert = [JCAlertController alertWithTitle:@"提示" message:@"确定退出登录?"];
    __weak __typeof(self) weakSelf = self;
    
    [_alert addButtonWithTitle:@"取消" type:JCButtonTypeCancel clicked:^{
        
    }];
    [_alert addButtonWithTitle:@"确定" type:JCButtonTypeWarning clicked:^{
        DLog(@"退出登录");
        [weakSelf exitLoginAction];
    }];
    
    [self presentViewController:_alert animated:YES completion:nil];
    
    
}
- (void)exitLoginAction{
    self.quitLoginBtn.userInteractionEnabled = YES;
     [Tool logoutRongCloudAction];
}
#pragma mark  -  TableViewDelegate  -
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 6;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    BGMineCustomTwoCell *cell = [tableView dequeueReusableCellWithIdentifier:@"BGMineCustomTwoCell" forIndexPath:indexPath];
    if (indexPath.section == 0) {
        switch (indexPath.row) {
            case 0:{
                cell.twoNameLabel.text = @"版本";
                NSDictionary *infoDict = [[NSBundle mainBundle] infoDictionary];
                NSString *vison = infoDict[@"CFBundleShortVersionString"];
                cell.twoDetailLabel.text = [NSString stringWithFormat:@"v%@    ",vison];
                cell.accessoryType = UITableViewCellAccessoryNone;
                cell.userInteractionEnabled = NO;
            }
                break;
            case 1:
                cell.twoNameLabel.text = @"清除缓存";
                cell.twoDetailLabel.text = _cacheSizeStr;
                //                cell.accessoryType = UITableViewCellAccessoryNone;
                break;
            case 2:
                cell.twoNameLabel.text = @"帮助中心";
                cell.twoDetailLabel.text = @"";
                break;
            case 3:
                cell.twoNameLabel.text = @"意见反馈";
                cell.twoDetailLabel.text = @"";
                break;
            case 4:
                cell.twoNameLabel.text = @"关于我们";
                cell.twoDetailLabel.text = @"";
                break;
            case 5:
                cell.twoNameLabel.text = @"海淘实名认证";
                cell.twoDetailLabel.text = @"";
                break;
                
            default:
                break;
        }
        
    }
    return cell;
    
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
    if (indexPath.section == 0) {
        switch (indexPath.row) {
            case 1: {  // 清除缓存
                
                if (![self.cacheSizeStr isEqualToString:@"0.00M"]) {
                    [self showClearCacheAction];
                }else{
                    [WHIndicatorView toast:@"缓存已清除"];
                }
                
            }
                break;
            case 2: {  // 帮助中心
                // @@ 添加登录判断
                if (![Tool isLogin]) {
                    [WHIndicatorView toast:@"请先登录!"];
                    [BGAppDelegateHelper showLoginViewController];
                    return;
                }
                BGWebViewController *webVC = [[BGWebViewController alloc] init];
                webVC.url = BGWebPages(@"help.html");
                [self.navigationController pushViewController:webVC animated:YES];
            }
                break;
            case 3: {  // 意见反馈
                if (![Tool isLogin]) {
                    [WHIndicatorView toast:@"请先登录!"];
                    [BGAppDelegateHelper showLoginViewController];
                    return;
                }
                BGFeedbackViewController *feedbackVC = BGFeedbackViewController.new;
                [self.navigationController pushViewController:feedbackVC animated:YES];
            }
                break;
            case 4: {  // 关于我们
                // @@ 添加登录判断
                if (![Tool isLogin]) {
                    [WHIndicatorView toast:@"请先登录!"];
                    [BGAppDelegateHelper showLoginViewController];
                    return;
                }
                BGWebViewController *webVC = [[BGWebViewController alloc] init];
                webVC.url = BGWebPages(@"about_us.html");
                [self.navigationController pushViewController:webVC animated:YES];
            }
                break;
            case 5: {  // 实名认证
                // @@ 添加登录判断
                if (![Tool isLogin]) {
                    [WHIndicatorView toast:@"请先登录!"];
                    [BGAppDelegateHelper showLoginViewController];
                    return;
                }
                BGVerifyNameViewController *verifyVC = BGVerifyNameViewController.new;
                [self.navigationController pushViewController:verifyVC animated:YES];
            }
                break;
                
            default:
                break;
        }
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 6;
}
-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    return UIView.new;
}

-(UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section{
    if ([Tool isLogin]) {
        return self.footerView;
    }else{
        return UIView.new;
    }
    
}
-(CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    if ([Tool isLogin]) {
        return 60;
    }else{
        return 0.01;
    }
}
-(void)showClearCacheAction{
    
    self.alert = [JCAlertController alertWithTitle:@"提示" message:@"确定清除系统缓存"];
    
    __weak __typeof(self) weakSelf = self;
    
    [_alert addButtonWithTitle:@"取消" type:JCButtonTypeCancel clicked:^{
        
    }];
    [_alert addButtonWithTitle:@"确定" type:JCButtonTypeNormal clicked:^{
        [weakSelf clearCacheActionWithPath:[weakSelf getPath]];
    }];
    
     [self presentViewController:_alert animated:YES completion:nil];
    
}
-(void)clearCacheActionWithPath:(NSString *)path {
    [[RCIM sharedRCIM] clearUserInfoCache];
    NSFileManager * fileManager = [NSFileManager defaultManager];
    if ([fileManager fileExistsAtPath:path]) {
        NSArray *childerFiles = [fileManager subpathsAtPath:path];
        for (NSString * fileName in childerFiles) {
            
            if ([fileName hasSuffix:@".mp4"] || [fileName hasSuffix:@".sqlite"]) {
                
            }else{
                NSString *absolutePath = [path stringByAppendingPathComponent:fileName];
                [fileManager removeItemAtPath:absolutePath error:nil];
            }
        }
        
    }
    [WHIndicatorView toast:@"缓存清除成功"];
    self.cacheSizeStr = [NSString stringWithFormat:@"%.2fM",[self folderSizeAtPath:[self getPath]]];
    [self.tableView reloadData];
    
}
#pragma mark - 清除缓存

- (NSString *)getPath{
    
    NSString * path = [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES)lastObject];
    return path;
}
- (CGFloat)folderSizeAtPath:(NSString *)path
{
    //初始化一个文件管理类对象
    NSFileManager * fileManager = [NSFileManager defaultManager];
    CGFloat folderSize = 0.0;
    //如果文件夹存在
    if ([fileManager fileExistsAtPath:path]) {
        NSArray * childerFiles = [fileManager subpathsAtPath:path];
        for (NSString * fileName in childerFiles) {
            if ([fileName hasSuffix:@".mp4"] || [fileName hasSuffix:@".sqlite"] || [fileName hasSuffix:@".jpg"]) {
                
            }else{
                NSString * absolutePath = [path stringByAppendingPathComponent:fileName];
                folderSize += [self filePathSize:absolutePath];
            }
        }
        return folderSize;
    }
    return 0;
    
}

- (CGFloat)filePathSize:(NSString *)path
{
    NSFileManager * fileManager = [NSFileManager defaultManager];
    if ([fileManager fileExistsAtPath:path]) {
        long long size = [fileManager attributesOfItemAtPath:path error:nil].fileSize;
        return  size / 1024.0 / 1024.0;
        
    }return 0;
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
