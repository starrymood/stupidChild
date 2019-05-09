//
//  BGShopBargainViewController.m
//  ShaHaiZiT
//
//  Created by biao on 2019/1/18.
//  Copyright © 2019 biao. All rights reserved.
//

#import "BGShopBargainViewController.h"
#import <UIImageView+WebCache.h>
#import "BGShopBargainDetailViewController.h"
#import "BGShopBargainCell.h"
#import "BGShopBargainModel.h"
#import "BGShopApi.h"
#import "UIImage+ImgSize.h"
#import <UMShare/UMShare.h>
#import <UShareUI/UShareUI.h>

#define BGString(appendix) [NSString stringWithFormat:@"%@",appendix]
@interface BGShopBargainViewController ()<UITableViewDataSource, UITableViewDelegate>

@property (nonatomic, strong) UITableView *tableView;

@property (nonatomic, strong) NSMutableArray *cellDataArr;

@property (nonatomic, strong) UIView *noneView;
// 页数
@property (nonatomic, copy) NSString *pageNum;

@property(nonatomic,copy) NSDictionary *shareDic;

@property(nonatomic,strong) UIImageView *imgView;

@property(nonatomic,strong) UIView *headerView;

@property(nonatomic,assign) BOOL isFirst;

@end

@implementation BGShopBargainViewController
-(UIView *)noneView {
    if (!_noneView) {
        self.noneView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT-SafeAreaTopHeight-SCREEN_WIDTH-6)];
        _noneView.backgroundColor = kAppBgColor;
        [_noneView setHidden:YES];
        UIImageView *noneImgView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"noToken_bg"]];
        noneImgView.frame = CGRectMake(SCREEN_WIDTH*0.2, 60, SCREEN_WIDTH*0.6, SCREEN_WIDTH*0.6*1.02);
        [_noneView addSubview:noneImgView];
        
        UILabel *showMsgLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, noneImgView.frame.origin.y+noneImgView.frame.size.height+50, SCREEN_WIDTH-20, 20)];
        showMsgLabel.textAlignment = NSTextAlignmentCenter;
        [showMsgLabel setTextColor:kAppTipBGColor];
        showMsgLabel.font = kFont(14);
        showMsgLabel.text = @"暂无砍价商品~";
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
    self.navigationController.navigationBarHidden = NO;
   
    if (_isFirst) {
        [self loadShareData];
        self.isFirst = NO;
    }else{
        self.pageNum = @"1";
        [self loadData];
    }
}
- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self loadSubViews];
    [self refreshView];
}
- (void)loadShareData {
    
    [ProgressHUDHelper showLoading];
    __weak typeof(self) weakSelf = self;
    NSMutableDictionary *param = [NSMutableDictionary dictionary];
    [BGShopApi getBargainShareInfo:param succ:^(NSDictionary *response) {
        DLog(@"\n>>>[getBargainShareInfo sucess]:%@",response);
        [weakSelf hideNodateView];
        weakSelf.navigationItem.rightBarButtonItem = [UIBarButtonItem itemWithImage:@"product_details_share_icon" highImage:@"travel_share_green" target:self action:@selector(clickedShareItem:)];

        [weakSelf loadData];
        weakSelf.shareDic = BGdictSetObjectIsNil(response[@"result"]);
        NSString *imgUrl = BGString(BGdictSetObjectIsNil(weakSelf.shareDic[@"good_image"]));
        CGSize imageSize = [UIImage getImageSizeWithURL:imgUrl];
        weakSelf.imgView = [[UIImageView alloc] initWithImage:BGImage(@"img_placeholder")];
        weakSelf.headerView.frame = CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_WIDTH*imageSize.width/imageSize.height+6);
        weakSelf.imgView.frame = CGRectMake(0, 6, SCREEN_WIDTH, SCREEN_WIDTH*imageSize.width/imageSize.height);
        [weakSelf.imgView sd_setImageWithURL:[NSURL URLWithString:imgUrl]];
        [weakSelf.headerView addSubview:weakSelf.imgView];
        weakSelf.tableView.tableHeaderView = weakSelf.headerView;
        
    } failure:^(NSDictionary *response) {
        DLog(@"\n>>>[getBargainShareInfo failure]:%@",response);
        [ProgressHUDHelper removeLoading];
        [self shownoNetWorkViewWithType:0];
        [self setRefreshBlock:^{
            [weakSelf loadShareData];
        }];
    }];
}
- (void)loadSubViews {
    
    self.navigationItem.title = @"砍价免费拿";
    self.view.backgroundColor = kAppBgColor;
    self.headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, 6+SCREEN_WIDTH)];
    _headerView.backgroundColor = kAppBgColor;
    
    self.tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, SafeAreaTopHeight, SCREEN_WIDTH, SCREEN_HEIGHT-SafeAreaTopHeight) style:(UITableViewStyleGrouped)];
    _tableView.backgroundColor = kAppBgColor;
    _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    _tableView.separatorColor = kAppBgColor;
    _tableView.estimatedRowHeight = SCREEN_HEIGHT;
    _tableView.tableHeaderView = self.headerView;
    _tableView.dataSource = self;
    _tableView.delegate = self;
    [self.view addSubview:_tableView];
    
    // 注册cell
    [_tableView registerNib:[UINib nibWithNibName:@"BGShopBargainCell" bundle:nil] forCellReuseIdentifier:@"BGShopBargainCell"];
    _pageNum = @"1";
     self.isFirst = YES;
}
#pragma mark UITableView + 下拉刷新 隐藏时间
- (void)refreshView
{
    // 设置回调（一旦进入刷新状态，就调用target的action，也就是调用self的loadNewData方法）
    __weak __typeof(self) weakSelf = self;
    
    // 设置回调（一旦进入刷新状态就会调用这个refreshingBlock）
    self.tableView.mj_header = [MJRefreshNormalHeader headerWithRefreshingBlock:^{
        // 设置自动切换透明度(在导航栏下面自动隐藏)
        weakSelf.tableView.mj_header.automaticallyChangeAlpha = YES;
        weakSelf.pageNum = @"1";
        [weakSelf loadShareData];
        [weakSelf.tableView.mj_header endRefreshing];
    }];
    
    // 上拉刷新
    self.tableView.mj_footer = [MJRefreshAutoFooter footerWithRefreshingBlock:^{
        //每次刷新,页码都加一页
        NSInteger nowPindex = [weakSelf.pageNum integerValue]+1;
        weakSelf.pageNum = [NSString stringWithFormat:@"%zd",nowPindex];
        [weakSelf loadData];
        //        [weakSelf.tableView.mj_footer endRefreshing];
    }];
//    [self loadShareData];
}
-(void)loadData {
    NSMutableDictionary *param = [[NSMutableDictionary alloc] init];
    [param setObject:_pageNum forKey:@"pageno"];
    [param setObject:@"10" forKey:@"pagesize"];
    [ProgressHUDHelper showLoading];
    __weak typeof(self) weakSelf = self;
    [BGShopApi getBargainList:param succ:^(NSDictionary *response) {
        DLog(@"\n>>>[getBargainList sucess]:%@",response);
        
        if (weakSelf.pageNum.intValue == 1) {
            [weakSelf.cellDataArr removeAllObjects];
            [weakSelf.tableView.mj_footer resetNoMoreData];
        }
        NSMutableArray *tempArr = [BGShopBargainModel mj_objectArrayWithKeyValuesArray:BGdictSetObjectIsNil(response[@"result"][@"rows"])];
        NSString *totalPageNumStr = [NSString stringWithFormat:@"%@",BGdictSetObjectIsNil(response[@"result"][@"pages"])];
        if (weakSelf.pageNum.integerValue<=totalPageNumStr.integerValue) {
            [weakSelf.cellDataArr addObjectsFromArray:tempArr];
        }
        [weakSelf.tableView reloadData];
        if (weakSelf.pageNum.integerValue>=totalPageNumStr.integerValue) {
            [weakSelf.tableView.mj_footer endRefreshingWithNoMoreData];
        }else{
            [weakSelf.tableView.mj_footer endRefreshing];
        }
    } failure:^(NSDictionary *response) {
        DLog(@"\n>>>[getBargainList failure]:%@",response);
    }];
}
#pragma mark  -  TableViewDelegate  -
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    self.tableView.mj_footer.hidden = self.cellDataArr.count == 0;
    return _cellDataArr.count;
}
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    BGShopBargainModel *model = _cellDataArr[indexPath.section];
    BGShopBargainCell *cell = [tableView dequeueReusableCellWithIdentifier:@"BGShopBargainCell" forIndexPath:indexPath];
    if ([Tool arrayIsNotEmpty:_cellDataArr]) {
        [cell updataWithCellArray:model];
        __weak typeof(self) weakSelf = self;
        cell.sureBtnClicked = ^{
            if ([Tool isBlankString:model.msg_id]) {
                [ProgressHUDHelper showLoading];
                __weak typeof(self) weakSelf = self;
                NSMutableDictionary *param = [NSMutableDictionary dictionary];
                [param setObject:model.reduce_id forKey:@"reduce_id"];
                [BGShopApi getBargainDetail:param succ:^(NSDictionary *response) {
                    DLog(@"\n>>>[getBargainDetail sucess]:%@",response);
                    BGShopBargainDetailViewController *detailVC = BGShopBargainDetailViewController.new;
                    detailVC.reduce_id = model.reduce_id;
                    detailVC.msg_id = BGString(BGdictSetObjectIsNil(response[@"result"][@"msg_id"]));
                    detailVC.shareDic = [NSDictionary dictionaryWithDictionary:weakSelf.shareDic];
                    [weakSelf.navigationController pushViewController:detailVC animated:YES];
                    
                } failure:^(NSDictionary *response) {
                    DLog(@"\n>>>[getBargainDetail failure]:%@",response);
                    [ProgressHUDHelper removeLoading];
                   
                }];
            }else{
                BGShopBargainDetailViewController *detailVC = BGShopBargainDetailViewController.new;
                detailVC.reduce_id = model.reduce_id;
                detailVC.msg_id = model.msg_id;
                detailVC.shareDic = [NSDictionary dictionaryWithDictionary:weakSelf.shareDic];
                [weakSelf.navigationController pushViewController:detailVC animated:YES];
            }
            
        };
    }
    return cell;
}
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
    
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    return 140;
}

-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    return section==0?6:3;
}
-(UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section{
    return nil;
}
-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    return nil;
}
-(CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section{
    return 0.01;
}
#pragma mark - clickedShareItem

- (void)clickedShareItem:(UIButton *)btn{
    [self showShareAction];
}

-(void)showShareAction {
    [UMSocialUIManager setPreDefinePlatforms:@[@(UMSocialPlatformType_WechatSession),@(UMSocialPlatformType_WechatTimeLine),@(UMSocialPlatformType_QQ),@(UMSocialPlatformType_Qzone),@(UMSocialPlatformType_Sina)]];
    [UMSocialUIManager showShareMenuViewInWindowWithPlatformSelectionBlock:^(UMSocialPlatformType platformType, NSDictionary *userInfo) {
        // 根据获取的platformType确定所选平台进行下一步操作
        NSData *imgData = [NSData dataWithContentsOfURL:[NSURL URLWithString:BGdictSetObjectIsNil(self.shareDic[@"share_image"])]];
        UIImage *shareImg = [UIImage imageWithData:imgData];
        [self doShareTitle:BGdictSetObjectIsNil(self.shareDic[@"title"]) description:BGdictSetObjectIsNil(self.shareDic[@"share_message"]) image:shareImg url:BGdictSetObjectIsNil(self.shareDic[@"share_url"]) shareType:(platformType)];
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
                DLog(@"/n[share]");
                [WHIndicatorView toast:@"分享成功"];
            }
        }
    }];
    
}
@end
