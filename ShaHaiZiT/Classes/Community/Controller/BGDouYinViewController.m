//
//  BGDouYinViewController.m
//  ShaHaiZiT
//
//  Created by biao on 2019/1/20.
//  Copyright © 2019 biao. All rights reserved.
//

#import "BGDouYinViewController.h"
#import <ZFPlayer/ZFPlayer.h>
#import <ZFPlayer/ZFAVPlayerManager.h>
#import <ZFPlayer/ZFPlayerControlView.h>
#import "BGDouYinCell.h"
#import "ZFDouYinControlView.h"
#import "UINavigationController+FDFullscreenPopGesture.h"
#import <MJRefresh/MJRefresh.h>
#import "BGStrategyModel.h"
#import "BGCommunityApi.h"
#import "BGEssayDetailModel.h"
#import "BGPublishUpdatingsViewController.h"
#import "BGCSearchViewController.h"
#import "BGEssayCommentListViewController.h"
#import <UMShare/UMShare.h>
#import <UShareUI/UShareUI.h>
#import <JCAlertController.h>
#import "BGUserHomepageViewController.h"
#import "FavoriteView.h"

@interface BGDouYinViewController ()<UITableViewDelegate,UITableViewDataSource>
@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) ZFPlayerController *player;
@property (nonatomic, strong) ZFDouYinControlView *controlView;
@property (nonatomic, strong) NSMutableArray *dataSource;
@property (nonatomic, strong) NSMutableArray *urls;

@property (nonatomic, strong) UIButton *backBtn;

@property(nonatomic,strong) BGEssayDetailModel *eModel;

@property (nonatomic, strong) JCAlertController *alert;

@end

@implementation BGDouYinViewController
-(void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    [self.player stopCurrentPlayingCell];
}
-(void)viewDidDisappear:(BOOL)animated{
    [super viewDidDisappear:animated];
    [self.player stop];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:self.tableView];
    [self.view addSubview:self.backBtn];
    self.fd_prefersNavigationBarHidden = YES;
    
    if (_isSingle) {
        [self.dataSource removeAllObjects];
        [self.urls removeAllObjects];
        BGStrategyModel *model = [[BGStrategyModel alloc] init];
        [self.dataSource addObject:model];
        

    }else{
        self.dataSource = [NSMutableArray arrayWithArray:self.dataArr];
        for (int i = 0; i<self.dataSource.count; i++) {
            BGStrategyModel *model = _dataSource[i];
            NSURL *url = [NSURL URLWithString:model.file_url];
            [self.urls addObject:url];
        }
        MJRefreshNormalHeader *header = [MJRefreshNormalHeader headerWithRefreshingTarget:self refreshingAction:@selector(loadNewData)];
        self.tableView.mj_header = header;
    }
    
    /// playerManager
    ZFAVPlayerManager *playerManager = [[ZFAVPlayerManager alloc] init];
    
    /// player,tag值必须在cell里设置
    self.player = [ZFPlayerController playerWithScrollView:self.tableView playerManager:playerManager containerViewTag:100];
    self.player.assetURLs = self.urls;
    self.player.disableGestureTypes = ZFPlayerDisableGestureTypesDoubleTap | ZFPlayerDisableGestureTypesPan | ZFPlayerDisableGestureTypesPinch;
    self.player.controlView = self.controlView;
    self.player.allowOrentitaionRotation = NO;
    self.player.WWANAutoPlay = YES;
    /// 1.0是完全消失时候
    self.player.playerDisapperaPercent = 1.0;
    
    @weakify(self)
    self.player.playerDidToEnd = ^(id  _Nonnull asset) {
        @strongify(self)
        [self.player.currentPlayerManager replay];
    };
    if (_isSingle) {
        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:0 inSection:0];
        [self.tableView scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionNone animated:NO];
        [self.tableView zf_filterShouldPlayCellWhileScrolled:^(NSIndexPath *indexPath) {
            @strongify(self)
            [self playTheVideoAtIndexPath:indexPath scrollToTop:NO];
        }];
    }
}

- (void)viewWillLayoutSubviews {
    [super viewWillLayoutSubviews];
    self.backBtn.frame = CGRectMake(15, CGRectGetMaxY([UIApplication sharedApplication].statusBarFrame), 36, 36);
}

- (void)loadNewData {
   
     __weak typeof(self) weakself = self;
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        /// 下拉时候一定要停止当前播放，不然有新数据，播放位置会错位。
        [weakself.player stopCurrentPlayingCell];
        weakself.pageNum = @"1";
        [weakself requestData];
       
    });
}

- (void)requestData {
    
    NSMutableDictionary *param = [[NSMutableDictionary alloc] init];
    [param setObject:_classification_id forKey:@"classification_id"];
    [param setObject:_pageNum forKey:@"pageno"];
    [param setObject:@"15" forKey:@"pagesize"];
    __block typeof(self) weakSelf = self;
    [BGCommunityApi getPostList:param succ:^(NSDictionary *response) {
        DLog(@"\n>>>[getPostList sucess]:%@",response);
        [weakSelf.tableView.mj_header endRefreshing];
        NSMutableArray *tempArr = [BGStrategyModel mj_objectArrayWithKeyValuesArray:response[@"result"][@"rows"]];
        
        NSMutableArray *dataArr = [[NSMutableArray alloc] init];
        for (BGStrategyModel *model in tempArr) {
            if (model.type.intValue == 2) {
                [dataArr addObject:model];
            }
        }
        if (weakSelf.pageNum.intValue == 1) {
            if ([Tool arrayIsNotEmpty:dataArr]) {
                [weakSelf.dataSource removeAllObjects];
                [weakSelf.urls removeAllObjects];
            }
            
        }
        [weakSelf.dataSource addObjectsFromArray:dataArr];
        for (int i = 0; i<dataArr.count; i++) {
            BGStrategyModel *model = dataArr[i];
            NSURL *url = [NSURL URLWithString:model.file_url];
            [self.urls addObject:url];
        }
        if (weakSelf.pageNum.intValue == 1) {
            /// 找到可以播放的视频并播放
            @weakify(self)
            [weakSelf.tableView zf_filterShouldPlayCellWhileScrolled:^(NSIndexPath *indexPath) {
                @strongify(self)
                [self playTheVideoAtIndexPath:indexPath scrollToTop:NO];
            }];
        }else{
            weakSelf.player.assetURLs = weakSelf.urls;
            
        }
        
    } failure:^(NSDictionary *response) {
        DLog(@"\n>>>[getPostList failure]:%@",response);
        [weakSelf.tableView.mj_header endRefreshing];
    }];
}

- (void)playTheIndex:(NSInteger)index {
    @weakify(self)
    /// 指定到某一行播放
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:index inSection:0];
    [self.tableView scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionNone animated:NO];
    [self.tableView zf_filterShouldPlayCellWhileScrolled:^(NSIndexPath *indexPath) {
        @strongify(self)
        [self playTheVideoAtIndexPath:indexPath scrollToTop:NO];
    }];
    /// 如果是最后一行，去请求新数据
    if (index == self.dataSource.count-1) {
        /// 加载下一页数据
        NSInteger nowPindex = [self.pageNum integerValue]+1;
        self.pageNum = [NSString stringWithFormat:@"%zd",nowPindex];
        [self requestData];
       
    }
}


- (BOOL)shouldAutorotate {
    return NO;
}

- (UIStatusBarStyle)preferredStatusBarStyle {
    return UIStatusBarStyleLightContent;
}

- (BOOL)prefersStatusBarHidden {
    return self.player.isStatusBarHidden;
}

- (UIStatusBarAnimation)preferredStatusBarUpdateAnimation {
    return UIStatusBarAnimationSlide;
}

#pragma mark - UIScrollViewDelegate  列表播放必须实现

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    [scrollView zf_scrollViewDidEndDecelerating];
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate {
    [scrollView zf_scrollViewDidEndDraggingWillDecelerate:decelerate];
}

- (void)scrollViewDidScrollToTop:(UIScrollView *)scrollView {
    [scrollView zf_scrollViewDidScrollToTop];
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    [scrollView zf_scrollViewDidScroll];
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
    [scrollView zf_scrollViewWillBeginDragging];
}

#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.dataSource.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    BGDouYinCell *cell = [tableView dequeueReusableCellWithIdentifier:@"BGDouYinCell" forIndexPath:indexPath];
    BGStrategyModel *zModel = self.dataSource[indexPath.row];
    if (![Tool isBlankString:self.eModel.ID]) {
        NSString *replacedStr;
        if (_isSingle) {
            replacedStr = [NSString stringWithFormat:@"%@?vframe/jpg/offset/0",self.eModel.file_url[0]];
            [self.controlView resetControlView];
            [self.controlView showCoverViewWithUrl:replacedStr];
        }else{
             replacedStr = [NSString stringWithFormat:@"%@?vframe/jpg/offset/0",zModel.file_url];
        }
        [cell updataWithCellArray:self.eModel pic:replacedStr];
        @weakify(self);
        [[[[cell.publishBtn rac_signalForControlEvents:(UIControlEventTouchUpInside)] takeUntil:cell.rac_prepareForReuseSignal] takeUntil:cell.rac_prepareForReuseSignal] subscribeNext:^(__kindof UIControl * _Nullable x) {
             @strongify(self);
            // 点击button的响应事件
            if (![Tool isLogin]) {
                [WHIndicatorView toast:@"请先登录!"];
                [BGAppDelegateHelper showLoginViewController];
                return;
            }
            BGPublishUpdatingsViewController *updatingVC = BGPublishUpdatingsViewController.new;
            updatingVC.isEdit = NO;
            [self.navigationController pushViewController:updatingVC animated:YES];
        }];
        [[[[cell.searchBtn rac_signalForControlEvents:(UIControlEventTouchUpInside)] takeUntil:cell.rac_prepareForReuseSignal] takeUntil:cell.rac_prepareForReuseSignal] subscribeNext:^(__kindof UIControl * _Nullable x) {
             @strongify(self);
            // 点击button的响应事件
            // @@ 添加登录判断
            if (![Tool isLogin]) {
                [WHIndicatorView toast:@"请先登录!"];
                [BGAppDelegateHelper showLoginViewController];
                return;
            }
            
            BGCSearchViewController *searchVC = BGCSearchViewController.new;
            CATransition *transition = [CATransition animation];
            transition.type = kCATransitionFade;
            transition.subtype = kCATransitionFromBottom;
            [self.navigationController.view.layer addAnimation:transition forKey:kCATransition];
            [self.navigationController pushViewController:searchVC animated:NO];
        }];
        [[[[cell.messageBtn rac_signalForControlEvents:(UIControlEventTouchUpInside)] takeUntil:cell.rac_prepareForReuseSignal] takeUntil:cell.rac_prepareForReuseSignal] subscribeNext:^(__kindof UIControl * _Nullable x) {
             @strongify(self);
            // 点击button的响应事件
            // @@ 添加登录判断
            if (![Tool isLogin]) {
                [WHIndicatorView toast:@"请先登录!"];
                [BGAppDelegateHelper showLoginViewController];
                return;
            }
            BGEssayCommentListViewController *listVC = BGEssayCommentListViewController.new;
            listVC.postID = self.eModel.ID;
            listVC.isVideo = NO;
            listVC.type = @"1";
            [self.navigationController pushViewController:listVC animated:YES];
        }];
        [[[[cell.shareBtn rac_signalForControlEvents:(UIControlEventTouchUpInside)] takeUntil:cell.rac_prepareForReuseSignal] takeUntil:cell.rac_prepareForReuseSignal] subscribeNext:^(__kindof UIControl * _Nullable x) {
             @strongify(self);
            // 点击button的响应事件
            // @@ 添加登录判断
            if (![Tool isLogin]) {
                [WHIndicatorView toast:@"请先登录!"];
                [BGAppDelegateHelper showLoginViewController];
                return;
            }
            [self showShareAction];
        }];
         __weak typeof(self) weakself = self;
        cell.headImgViewClicked = ^{
            // @@ 添加登录判断
            if (![Tool isLogin]) {
                [WHIndicatorView toast:@"请先登录!"];
                [BGAppDelegateHelper showLoginViewController];
                return;
            }
            BGUserHomepageViewController *userVC = BGUserHomepageViewController.new;
            userVC.member_id = self.eModel.member_id;
            [weakself.navigationController pushViewController:userVC animated:YES];
        };
    }
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [self playTheVideoAtIndexPath:indexPath scrollToTop:NO];
}

#pragma mark - ZFTableViewCellDelegate

- (void)zf_playTheVideoAtIndexPath:(NSIndexPath *)indexPath {
    [self playTheVideoAtIndexPath:indexPath scrollToTop:NO];
}

#pragma mark - private method

- (void)backClick:(UIButton *)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

/// play the video
- (void)playTheVideoAtIndexPath:(NSIndexPath *)indexPath scrollToTop:(BOOL)scrollToTop {
    
     [self.player playTheIndexPath:indexPath scrollToTop:scrollToTop];
    if (!_isSingle) {
        BGStrategyModel *data = self.dataSource[indexPath.row];
        [self loadDataWithID:data.ID index:indexPath];
        [self.controlView resetControlView];
        NSString *replacedStr = [NSString stringWithFormat:@"%@?vframe/jpg/offset/0",data.file_url];
        [self.controlView showCoverViewWithUrl:replacedStr];
    }else{
        [self loadDataWithID:self.postID index:indexPath];
    }
   
    
}

#pragma mark - getter

- (UITableView *)tableView {
    if (!_tableView) {
        _tableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
        _tableView.pagingEnabled = YES;
        _tableView.backgroundColor = [UIColor lightGrayColor];
        _tableView.delegate = self;
        _tableView.dataSource = self;
        _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        _tableView.showsVerticalScrollIndicator = NO;
        if (@available(iOS 11.0, *)) {
            _tableView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
        } else {
            self.automaticallyAdjustsScrollViewInsets = NO;
        }
        _tableView.estimatedRowHeight = 0;
        _tableView.estimatedSectionFooterHeight = 0;
        _tableView.estimatedSectionHeaderHeight = 0;
        _tableView.frame = self.view.bounds;
        _tableView.rowHeight = _tableView.frame.size.height;
        [self.tableView registerNib:[UINib nibWithNibName:@"BGDouYinCell" bundle:nil] forCellReuseIdentifier:@"BGDouYinCell"];
        
        /// 停止的时候找出最合适的播放
        @weakify(self)
        _tableView.zf_scrollViewDidStopScrollCallback = ^(NSIndexPath * _Nonnull indexPath) {
            @strongify(self)
            if (!self.isSingle) {
                if (indexPath.row == self.dataSource.count-1) {
                    /// 加载下一页数据
                    NSInteger nowPindex = [self.pageNum integerValue]+1;
                    self.pageNum = [NSString stringWithFormat:@"%zd",nowPindex];
                    [self requestData];
                }
            }
            
            [self playTheVideoAtIndexPath:indexPath scrollToTop:NO];
        };
    }
    return _tableView;
}

- (ZFDouYinControlView *)controlView {
    if (!_controlView) {
        _controlView = [ZFDouYinControlView new];
    }
    return _controlView;
}

- (NSMutableArray *)dataSource {
    if (!_dataSource) {
        _dataSource = @[].mutableCopy;
    }
    return _dataSource;
}

- (NSMutableArray *)urls {
    if (!_urls) {
        _urls = @[].mutableCopy;
    }
    return _urls;
}

- (UIButton *)backBtn {
    if (!_backBtn) {
        _backBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [_backBtn setImage:[UIImage imageNamed:@"zfplayer_back"] forState:UIControlStateNormal];
        [_backBtn addTarget:self action:@selector(backClick:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _backBtn;
}

-(void)loadDataWithID:(NSString *)postID index:(NSIndexPath *)indexPath{

    NSMutableDictionary *param = [[NSMutableDictionary alloc] init];
    [param setObject:postID forKey:@"post_id"];
    __weak __typeof(self) weakSelf = self;
    [BGCommunityApi getEssayDetail:param succ:^(NSDictionary *response) {
        DLog(@"\n>>>[getEssayDetail sucess]:%@",response);
        
        weakSelf.eModel = [BGEssayDetailModel mj_objectWithKeyValues:BGdictSetObjectIsNil(response[@"result"])];
        if (weakSelf.isSingle) {
//            [self.dataSource addObject:weakSelf.eModel];
            NSURL *url = [NSURL URLWithString:weakSelf.eModel.file_url[0]];
            [weakSelf.urls addObject:url];
            [weakSelf.player playTheIndexPath:indexPath scrollToTop:NO];
//            NSIndexPath *indexPath = [NSIndexPath indexPathForRow:0 inSection:0];
//            [self.tableView scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionNone animated:NO];
//            [self.tableView zf_filterShouldPlayCellWhileScrolled:^(NSIndexPath *indexPath) {
//                [self playTheVideoAtIndexPath:indexPath scrollToTop:NO];
//            }];
        }
        [weakSelf.tableView reloadData];
//        [weakSelf.tableView reloadRowsAtIndexPaths:[NSArray arrayWithObjects:indexPath, nil] withRowAnimation:UITableViewRowAnimationNone];
    } failure:^(NSDictionary *response) {
        DLog(@"\n>>>[getEssayDetail failure]:%@",response);
        
    }];
}
-(void)showShareAction {
    
    [UMSocialUIManager setPreDefinePlatforms:@[@(UMSocialPlatformType_WechatSession),@(UMSocialPlatformType_WechatTimeLine),@(UMSocialPlatformType_QQ),@(UMSocialPlatformType_Qzone),@(UMSocialPlatformType_Sina)]];
    
    [UMSocialUIManager addCustomPlatformWithoutFilted:UMSocialPlatformType_UserDefine_Begin+3
                                     withPlatformIcon:[UIImage imageNamed:@"community_report_icon"]
                                     withPlatformName:@"举报"];
    [UMSocialUIManager addCustomPlatformWithoutFilted:UMSocialPlatformType_UserDefine_Begin+4
                                     withPlatformIcon:[UIImage imageNamed:@"community_shield_icon"]
                                     withPlatformName:@"不感兴趣"];
    
    [UMSocialShareUIConfig shareInstance].sharePageGroupViewConfig.sharePageGroupViewPostionType = UMSocialSharePageGroupViewPositionType_Bottom;
    [UMSocialShareUIConfig shareInstance].sharePageScrollViewConfig.shareScrollViewPageItemStyleType = UMSocialPlatformItemViewBackgroudType_None;
    
    [UMSocialUIManager showShareMenuViewInWindowWithPlatformSelectionBlock:^(UMSocialPlatformType platformType, NSDictionary *userInfo) {
        if (platformType == UMSocialPlatformType_UserDefine_Begin+3) {
            if (![Tool isLogin]) {
                [WHIndicatorView toast:@"请先登录!"];
                [BGAppDelegateHelper showLoginViewController];
                return;
            }
            // 点击button的响应事件
            UIAlertController *menu = [UIAlertController alertControllerWithTitle:nil message:nil preferredStyle:(UIAlertControllerStyleActionSheet)];
            __block typeof(self) weakSelf = self;
            
            UIAlertAction *cameraAction = [UIAlertAction actionWithTitle:@"举报" style:UIAlertActionStyleDestructive handler:^(UIAlertAction * _Nonnull action) {
                weakSelf.alert = [JCAlertController alertWithTitle:@"提示" message:@"确定要举报吗?"];
                
                [weakSelf.alert addButtonWithTitle:@"取消" type:JCButtonTypeCancel clicked:^{
                    
                }];
                [weakSelf.alert addButtonWithTitle:@"举报" type:JCButtonTypeWarning clicked:^{
                    [ProgressHUDHelper showLoading];
                    NSMutableDictionary *param = [[NSMutableDictionary alloc] init];
                    [param setObject:self.postID forKey:@"report_id"];
                    [BGCommunityApi reportEssayAction:param succ:^(NSDictionary *response) {
                        DLog(@"\n>>>[reportEssayAction sucess]:%@",response);
                        [WHIndicatorView toast:BGdictSetObjectIsNil(response[@"msg"])];
                    } failure:^(NSDictionary *response) {
                        DLog(@"\n>>>[reportEssayAction failure]:%@",response);
                    }];
                }];
                
                [weakSelf presentViewController:weakSelf.alert animated:YES completion:nil];
                
            }];
            UIAlertAction *actionNo = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
                
            }];
            
            [menu addAction:actionNo];
            [menu addAction:cameraAction];
            [self presentViewController:menu animated:YES completion:nil];
        }else if (platformType == UMSocialPlatformType_UserDefine_Begin+4){
            if (![Tool isLogin]) {
                [WHIndicatorView toast:@"请先登录!"];
                [BGAppDelegateHelper showLoginViewController];
                return;
            }
            // 点击button的响应事件
            UIAlertController *menu = [UIAlertController alertControllerWithTitle:nil message:nil preferredStyle:(UIAlertControllerStyleActionSheet)];
            __block typeof(self) weakSelf = self;
            
            UIAlertAction *cameraAction = [UIAlertAction actionWithTitle:@"不感兴趣" style:UIAlertActionStyleDestructive handler:^(UIAlertAction * _Nonnull action) {
                weakSelf.alert = [JCAlertController alertWithTitle:@"提示" message:@"确定要屏蔽该条动态吗?"];
                
                [weakSelf.alert addButtonWithTitle:@"取消" type:JCButtonTypeCancel clicked:^{
                    
                }];
                [weakSelf.alert addButtonWithTitle:@"屏蔽" type:JCButtonTypeWarning clicked:^{
                    [ProgressHUDHelper showLoading];
                    NSMutableDictionary *param = [[NSMutableDictionary alloc] init];
                    [param setObject:self.postID forKey:@"post_id"];
                    [BGCommunityApi shieldEssayAction:param succ:^(NSDictionary *response) {
                        DLog(@"\n>>>[shieldEssayAction sucess]:%@",response);
                        [WHIndicatorView toast:BGdictSetObjectIsNil(response[@"msg"])];
                        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                            if (self.refreshEditBlock) {
                                self.refreshEditBlock();
                            }
                            [self.navigationController popViewControllerAnimated:YES];
                        });
                    } failure:^(NSDictionary *response) {
                        DLog(@"\n>>>[shieldEssayAction failure]:%@",response);
                    }];
                }];
                
                [weakSelf presentViewController:weakSelf.alert animated:YES completion:nil];
                
            }];
            UIAlertAction *actionNo = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
                
            }];
            
            [menu addAction:actionNo];
            [menu addAction:cameraAction];
            [self presentViewController:menu animated:YES completion:nil];
        }else{
            // 根据获取的platformType确定所选平台进行下一步操作
            [self doShareTitle:self.eModel.post_title description:self.eModel.content image:[UIImage imageNamed:@"applogo"] url:[NSString stringWithFormat:@"%@login.html?icode=%@",BGWebMainHtml,BGGetUserDefaultObjectForKey(@"inviteCode")] shareType:(platformType)];
        }
    }];
}
#pragma mark- 分享公共方法
- (void)doShareTitle:(NSString *)tieleStr
         description:(NSString *)descriptionStr
               image:(UIImage *)image
                 url:(NSString *)url
           shareType:(UMSocialPlatformType)type
{
    [ProgressHUDHelper showLoading];
    
    //创建分享消息对象
    UMSocialMessageObject *messageObject = [UMSocialMessageObject messageObject];
    
    //创建网页内容对象
    UMShareWebpageObject *shareObject = [UMShareWebpageObject shareObjectWithTitle:tieleStr descr:descriptionStr thumImage:image];
    //设置网页地址
    shareObject.webpageUrl = url;
    
    //分享消息对象设置分享内容对象
    messageObject.shareObject = shareObject;
    [ProgressHUDHelper removeLoading];
    //调用分享接口
    [[UMSocialManager defaultManager] shareToPlatform:type messageObject:messageObject currentViewController:self completion:^(id data, NSError *error) {
        if (error) {
            [WHIndicatorView toast:@"分享失败"];
        }else{
            if ([data isKindOfClass:[UMSocialShareResponse class]]) {
                [WHIndicatorView toast:@"分享成功"];
            }else{
                //                DLog(@"/n[share]");
                [WHIndicatorView toast:@"分享成功"];
            }
        }
    }];
    
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
