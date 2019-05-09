//
//  BGEssayVideoDetailViewController.m
//  shzTravelC
//
//  Created by biao on 2018/8/2.
//  Copyright © 2018年 biao. All rights reserved.
//

#import "BGEssayVideoDetailViewController.h"
#import "BGCommunityApi.h"
#import "BGEssayDetailOwnerView.h"
#import "BGEssayDetailModel.h"
#import <UIImageView+WebCache.h>
#import "BGUserHomepageViewController.h"
#import <JCAlertController.h>
#import "BGEssayCommentListViewController.h"
#import "BGEssayDetailBottomView.h"
#import "BGEssayEasyCell.h"
#import "BGEssayCommentDetailViewController.h"
#import "BGEssayCommentFirstModel.h"
#import "BGEssayCommentDetailViewController.h"
#import "BGEssayCommentSModel.h"
#import "IQKeyboardManager.h"
#import "UITextField+BGLimit.h"
#import <ZFPlayer/ZFPlayer.h>
#import <ZFPlayer/ZFAVPlayerManager.h>
#import <ZFPlayer/ZFPlayerControlView.h>
#import <UMShare/UMShare.h>
#import <UShareUI/UShareUI.h>

#define textViewHeight 44
#define ownerViewHeight 116.5
#define videoViewHeightScale 0.5625
@interface BGEssayVideoDetailViewController ()<UITableViewDelegate,UITableViewDataSource,UITextFieldDelegate>

@property (nonatomic, strong) NSMutableArray *cellDataArr;

@property (nonatomic, strong) UITableView *tableView;

@property (nonatomic, strong) BGEssayDetailOwnerView *ownerView;

@property (nonatomic, strong) UIView *headerView;

@property (nonatomic, strong) JCAlertController *alert;

@property (nonatomic, strong) BGEssayDetailBottomView *bottomView;

@property (nonatomic, strong) BGEssayDetailModel *fModel;
@property (nonatomic, strong) UIView *backView;
@property (nonatomic, strong) UIView *inputView;
@property (nonatomic, strong) UITextField *inputTextField;

@property (nonatomic, strong) UIImageView *headImgView;

@property (nonatomic, strong) ZFPlayerController *player;
@property (nonatomic, strong) UIView *containerView;
@property (nonatomic, strong) ZFPlayerControlView *controlView;
@property (nonatomic, strong) UIButton *playBtn;
@property (nonatomic, strong) NSArray <NSURL *>*assetURLs;
@property(nonatomic,strong) UIView *whiteFooterView;

@end

@implementation BGEssayVideoDetailViewController
-(UIView *)whiteFooterView{
    if (!_whiteFooterView) {
        self.whiteFooterView = UIView.new;
        _whiteFooterView.backgroundColor = kAppWhiteColor;
    }
    return _whiteFooterView;
}
-(UIView *)inputView{
    if (!_inputView) {
        self.inputView = [[UIView alloc] initWithFrame:CGRectMake(0, SCREEN_HEIGHT+textViewHeight, SCREEN_WIDTH, textViewHeight)];
        self.inputView.backgroundColor = kAppWhiteColor;
        self.inputTextField = [[UITextField alloc] initWithFrame:CGRectMake(10, 5, SCREEN_WIDTH-10*2, textViewHeight-5*2)];
        [_inputView addSubview:_inputTextField];
        _inputTextField.textAlignment = NSTextAlignmentLeft;
        _inputTextField.textColor = kApp333Color;
        _inputTextField.font = kFont(12);
        _inputTextField.placeholder = @"  请输入回复内容";
        _inputTextField.backgroundColor = UIColorFromRGB(0xECF2F6);
        _inputTextField.borderStyle = UITextBorderStyleRoundedRect;
        [_inputTextField setValue:[NSNumber numberWithInt:5] forKey:@"paddingLeft"];
        _inputTextField.returnKeyType = UIReturnKeySend;
        _inputTextField.maxLenght = 300;
        _inputTextField.delegate = self;
        
    }
    return _inputView;
}
-(UIView *)backView{
    if (!_backView) {
        self.backView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT)];
        _backView.backgroundColor = [UIColor clearColor];
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(canaleCallBack)];
        [_backView addGestureRecognizer:tap];
    }
    return _backView;
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
    self.player.viewControllerDisappear = YES;
    [self registerKeyBoardNotification];

}
-(void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    [[IQKeyboardManager sharedManager] setEnable:YES];
    [IQKeyboardManager sharedManager].enableAutoToolbar = YES;
    [self.player setPauseByEvent:YES];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillShowNotification object:UIKeyboardWillHideNotification];
}
-(void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    [IQKeyboardManager sharedManager].enableAutoToolbar = NO;
    [[IQKeyboardManager sharedManager] setEnable:NO];
    self.player.viewControllerDisappear = YES;
}

-(void)dealloc{
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"LoginSuccessNotification" object:nil];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self loadSubViews];
    [self refreshView];
    
}

-(void)loadSubViews{
    self.navigationItem.title = @"视频详情";
    self.view.backgroundColor = kAppBgColor;
     self.navigationItem.rightBarButtonItem = [UIBarButtonItem itemWithImage:@"travel_share_green" highImage:@"travel_share_green" target:self action:@selector(clickedShareItem:)];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(LoginSuccessNotification) name:@"LoginSuccessNotification" object:nil];
    
    self.headerView = UIView.new;
    _headerView.backgroundColor = kAppBgColor;
    _headerView.frame = CGRectMake(0, 0, SCREEN_WIDTH, 6+SCREEN_WIDTH*videoViewHeightScale+ownerViewHeight);
    
    self.headImgView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 6, SCREEN_WIDTH, SCREEN_WIDTH*videoViewHeightScale)];
    [_headImgView setImage:BGImage(@"img_cycle_placeholder")];
    [_headerView addSubview:_headImgView];
    
    self.ownerView = [[BGEssayDetailOwnerView alloc] initWithFrame:CGRectMake(0, _headImgView.y+_headImgView.height, SCREEN_WIDTH, ownerViewHeight)];
    _ownerView.concernBtn.userInteractionEnabled = NO;
    _ownerView.createTimeLabel.hidden = YES;
    _ownerView.contentLabelHeight.constant = 12;
    [_headerView addSubview:_ownerView];
    
    self.bottomView = [[BGEssayDetailBottomView alloc] initWithFrame:CGRectMake(0,SCREEN_HEIGHT-SafeAreaBottomHeight-43, SCREEN_WIDTH, 43+SafeAreaBottomHeight)];
    [self.bottomView setHidden:YES];
    
    
    self.tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, SafeAreaTopHeight, SCREEN_WIDTH, SCREEN_HEIGHT-SafeAreaTopHeight-SafeAreaBottomHeight) style:(UITableViewStyleGrouped)];
    _tableView.backgroundColor = kAppBgColor;
    _tableView.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
    _tableView.separatorColor = kAppBgColor;
    _tableView.estimatedRowHeight = 137;
    _tableView.rowHeight = UITableViewAutomaticDimension;
    _tableView.tableHeaderView = _headerView;
    _tableView.dataSource = self;
    _tableView.delegate = self;
    [self.view addSubview:_tableView];
    [self.view addSubview:self.bottomView];
    // 注册cell
    [_tableView registerNib:[UINib nibWithNibName:@"BGEssayEasyCell" bundle:nil] forCellReuseIdentifier:@"BGEssayEasyCell"];
}

-(void)updateSubViewsWithModel:(BGEssayDetailModel *)model{
    model.post_id = _video_id;
    model.type = @"2";
    self.fModel = model;
    [self.bottomView updataWithModel:model];
    [self.bottomView setHidden:NO];
    @weakify(self);
    [[self.bottomView.commentBtn rac_signalForControlEvents:(UIControlEventTouchUpInside)] subscribeNext:^(__kindof UIControl * _Nullable x) {
        @strongify(self);
        // 点击button的响应事件
        if (![Tool isLogin]) {
            [WHIndicatorView toast:@"请先登录!"];
            [BGAppDelegateHelper showLoginViewController];
            return;
        }
        [[[UIApplication sharedApplication] keyWindow] addSubview:self.backView];
        [[[UIApplication sharedApplication] keyWindow] addSubview:self.inputView];
        [self.inputTextField becomeFirstResponder];
    }];
    
    [self.cellDataArr removeAllObjects];
    self.cellDataArr = [NSMutableArray arrayWithArray:model.review_list];
    [self.tableView reloadData];
    
    NSInteger lineNum = [self needLinesWithWidth:(SCREEN_WIDTH-17*2) text:model.video_description];
    
    _headerView.height = 6+SCREEN_WIDTH*videoViewHeightScale+ownerViewHeight+(lineNum-1)*14.5;
    [_ownerView removeFromSuperview];
    
    self.ownerView = [[BGEssayDetailOwnerView alloc] initWithFrame:CGRectMake(0, _headImgView.y+_headImgView.height, SCREEN_WIDTH, ownerViewHeight+(lineNum-1)*14.5)];
    [_headerView addSubview:_ownerView];
    [_ownerView.concernBtn setHidden:YES];
    _ownerView.createTimeLabel.hidden = YES;
    _ownerView.contentLabelHeight.constant = 12;
    _ownerView.commentNumLabel.text = [NSString stringWithFormat:@"共%@条评论",model.review_count];
    _ownerView.contentLabel.text = model.video_description;
    _tableView.tableHeaderView = _headerView;
    
    self.navigationItem.title = model.video_title;
    
    
    [self.headImgView sd_setImageWithURL:[NSURL URLWithString:model.video_image] placeholderImage:BGImage(@"img_cycle_placeholder")];
    
    // ZFPlayer
    [self.headerView addSubview:self.containerView];
    [self.headerView addSubview:self.playBtn];
    
    ZFAVPlayerManager *playerManager = [[ZFAVPlayerManager alloc] init];
    /// 播放器相关
    self.player = [ZFPlayerController playerWithPlayerManager:playerManager containerView:self.containerView];
    //        self.player.disableGestureTypes = ZFPlayerDisableGestureTypesPan;
    self.player.controlView = self.controlView;
    
    self.player.orientationWillChange = ^(ZFPlayerController * _Nonnull player, BOOL isFullScreen) {
        @strongify(self)
        [self setNeedsStatusBarAppearanceUpdate];
    };
    
    /// 播放完自动播放下一个
    self.player.playerDidToEnd = ^(id  _Nonnull asset) {
        @strongify(self)
        //        [self.player stop];
        [self.containerView setHidden:YES];
        [self.playBtn setHidden:NO];
    };
    
    self.assetURLs = @[[NSURL URLWithString:model.video_url]];
    
    self.player.assetURLs = self.assetURLs;
    self.player.WWANAutoPlay = YES;
    
    [_ownerView.headImgView sd_setImageWithURL:[NSURL URLWithString:model.logo] placeholderImage:BGImage(@"defaultUserIcon")];
    _ownerView.nickNameLabel.text = model.nickname;
    
    [[_ownerView.commentListBtn rac_signalForControlEvents:(UIControlEventTouchUpInside)] subscribeNext:^(__kindof UIControl * _Nullable x) {
        @strongify(self);
        // 点击button的响应事件
        BGEssayCommentListViewController *listVC = BGEssayCommentListViewController.new;
        listVC.postID = self.video_id;
        listVC.isVideo = YES;
        listVC.type = @"2";
        [self.navigationController pushViewController:listVC animated:YES];
    }];
}
- (void)refreshView{
    // 设置回调（一旦进入刷新状态，就调用target的action，也就是调用self的loadNewData方法）
    __weak __typeof(self) weakSelf = self;
    
    // 设置回调（一旦进入刷新状态就会调用这个refreshingBlock）
    self.tableView.mj_header = [MJRefreshNormalHeader headerWithRefreshingBlock:^{
        // 设置自动切换透明度(在导航栏下面自动隐藏)
        weakSelf.tableView.mj_header.automaticallyChangeAlpha = YES;
        [weakSelf loadData];
        [weakSelf.tableView.mj_header endRefreshing];
    }];
    
    [self loadData];
}
-(void)loadData {
    [ProgressHUDHelper showLoading];
    [self.player stop];
    [self.playBtn setHidden:NO];
    NSMutableDictionary *param = [[NSMutableDictionary alloc] init];
    [param setObject:_video_id forKey:@"video_id"];
    __weak __typeof(self) weakSelf = self;
    [BGCommunityApi getVideoDetail:param succ:^(NSDictionary *response) {
        DLog(@"\n>>>[getEssayDetail sucess]:%@",response);
        [weakSelf hideNodateView];
        
        BGEssayDetailModel *model = [BGEssayDetailModel mj_objectWithKeyValues:BGdictSetObjectIsNil(response[@"result"])];
        [weakSelf updateSubViewsWithModel:model];
    } failure:^(NSDictionary *response) {
        DLog(@"\n>>>[getEssayDetail failure]:%@",response);
        [ProgressHUDHelper removeLoading];
        [weakSelf shownoNetWorkViewWithType:0];
        [weakSelf setRefreshBlock:^{
            [weakSelf loadData];
        }];
    }];
}
#pragma mark  -  TableViewDelegate  -
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return _cellDataArr.count>0?_cellDataArr.count:1;
}
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    if ([Tool arrayIsNotEmpty:_cellDataArr]) {
        BGEssayEasyCell *cell = [tableView dequeueReusableCellWithIdentifier:@"BGEssayEasyCell" forIndexPath:indexPath];
        BGEssayCommentFirstModel *model = [BGEssayCommentFirstModel mj_objectWithKeyValues:_cellDataArr[indexPath.section]];
        [cell updataWithCellArray:model];
        return cell;
    }else{
        UITableViewCell *nullCell = UITableViewCell.new;
        nullCell.selectionStyle = UITableViewCellSelectionStyleNone;
        return nullCell;
    }
}
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
    BGEssayCommentListViewController *listVC = BGEssayCommentListViewController.new;
    listVC.postID = self.video_id;
    listVC.isVideo = YES;
    listVC.type = @"2";
    [self.navigationController pushViewController:listVC animated:YES];
    
}
-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    return 0.01;
}

-(CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section{
    if (_cellDataArr.count>0) {
        return (section == _cellDataArr.count-1)? 37:0.01;
    }else{
        return 0.01;
    }
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    return nil;
}
- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section{
    
    return self.whiteFooterView;
}

- (NSInteger)needLinesWithWidth:(CGFloat)width text:(NSString *)text{
    //创建一个labe
    UILabel * label = [[UILabel alloc]init];
    //font和当前label保持一致
    label.font = kFont(12);
    NSInteger sum = 0;
    //总行数受换行符影响，所以这里计算总行数，需要用换行符分隔这段文字，然后计算每段文字的行数，相加即是总行数。
    NSArray * splitText = [text componentsSeparatedByString:@"\n"];
    for (NSString * sText in splitText) {
        label.text = sText;
        //获取这段文字一行需要的size
        CGSize textSize = [label systemLayoutSizeFittingSize:CGSizeZero];
        //size.width/所需要的width 向上取整就是这段文字占的行数
        NSInteger lines = ceilf(textSize.width/width);
        //当是0的时候，说明这是换行，需要按一行算。
        lines = lines == 0?1:lines;
        sum += lines;
    }
    return sum;
}

-(void)LoginSuccessNotification{
    [self loadData];
}
#pragma mark - ----------------------- 键盘事件 -----------------------
#pragma mark 键盘监听
- (void)registerKeyBoardNotification
{
    // 键盘即将弹出, 就会发出UIKeyboardWillShowNotification
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
    // 键盘即将隐藏, 就会发出UIKeyboardWillHideNotification
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
    
    
}
#pragma mark - 事件处理

/**
 *  键盘即将隐藏
 */
- (void)keyboardWillHide:(NSNotification *)note
{
    // 1.键盘弹出需要的时间
    CGFloat duration = [note.userInfo[UIKeyboardAnimationDurationUserInfoKey] doubleValue];
    
    // 2.动画
    [UIView animateWithDuration:duration animations:^{
        self.backView.backgroundColor = [UIColor clearColor];
        self.inputView.y = SCREEN_HEIGHT+textViewHeight;
    } completion:^(BOOL finished) {
        [self.inputView removeFromSuperview];
        self.inputView = nil;
        [self.backView removeFromSuperview];
        self.backView = nil;
    }];
}
/**
 *  键盘即将弹出
 */
- (void)keyboardWillShow:(NSNotification *)note
{
    // 1.键盘弹出需要的时间
    CGFloat duration = [note.userInfo[UIKeyboardAnimationDurationUserInfoKey] doubleValue];
    // 取出键盘高度
    CGRect keyboardF = [note.userInfo[UIKeyboardFrameEndUserInfoKey] CGRectValue];
    CGFloat keyboardH = keyboardF.size.height;
    
    
    // 2.动画
    [UIView animateWithDuration:duration animations:^{
        self.backView.backgroundColor = [UIColor colorWithWhite:0 alpha:0.4];
        self.inputView.y = SCREEN_HEIGHT-keyboardH-textViewHeight;
    } completion:^(BOOL finished) {
        
    }];
}
-(void)replayActionWithBody:(NSString *)body{
    NSMutableDictionary *param = [[NSMutableDictionary alloc] init];
    [param setObject:body forKey:@"review_body"];
    
    [param setObject:_fModel.post_id forKey:@"post_id"];
    [param setObject:@"0" forKey:@"reply_review_id"];
    [param setObject:@"0" forKey:@"reply_member_id"];
    [param setObject:@"2" forKey:@"type"];
    [ProgressHUDHelper showLoading];
    [BGCommunityApi AddComment:param succ:^(NSDictionary *response) {
        DLog(@"\n>>>[AddComment sucess]:%@",response);
        [self canaleCallBack];
        [self loadData];
    } failure:^(NSDictionary *response) {
        DLog(@"\n>>>[AddComment failure]:%@",response);
    }];
}
-(BOOL)textFieldShouldReturn:(UITextField *)textField{
    if (textField.text.length<1) {
        [WHIndicatorView toast:@"请输入回复内容"];
        return NO;
    }else{
        [self replayActionWithBody:textField.text];
    }
    return NO;
}
-(void)canaleCallBack{
    [self.inputTextField resignFirstResponder];
}



- (void)viewWillLayoutSubviews {
    [super viewWillLayoutSubviews];
    CGFloat x = 0;
    CGFloat y = CGRectGetMaxY(self.navigationController.navigationBar.frame);
    CGFloat w = CGRectGetWidth(self.view.frame);
    CGFloat h = w*9/16;
    self.containerView.frame = CGRectMake(0, 6, SCREEN_WIDTH, SCREEN_WIDTH*videoViewHeightScale);
    
    w = 44;
    h = w;
    x = (CGRectGetWidth(self.containerView.frame)-w)/2;
    y = (CGRectGetHeight(self.containerView.frame)-h)/2;
    self.playBtn.frame = CGRectMake(x, y, w, h);
}


- (UIStatusBarStyle)preferredStatusBarStyle {
    if (self.player.isFullScreen) {
        return UIStatusBarStyleLightContent;
    }
    return UIStatusBarStyleDefault;
}

- (BOOL)prefersStatusBarHidden {
    return self.player.isStatusBarHidden;
}

- (UIStatusBarAnimation)preferredStatusBarUpdateAnimation {
    return UIStatusBarAnimationSlide;
}

- (BOOL)shouldAutorotate {
    return NO;
}

- (UIInterfaceOrientationMask)supportedInterfaceOrientations {
    if (self.player.isFullScreen) {
        return UIInterfaceOrientationMaskLandscape;
    }
    return UIInterfaceOrientationMaskPortrait;
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [self.view endEditing:YES];
    self.player.currentPlayerManager.muted = !self.player.currentPlayerManager.muted;
}

- (ZFPlayerControlView *)controlView {
    if (!_controlView) {
        _controlView = [ZFPlayerControlView new];
//        [_controlView addToolView];
//        [_controlView.portraitControlView addToolView];
//        [_controlView.landScapeControlView addToolView];
//         _controlView.portraitControlView.videoHeightScale = 1;
    }
    return _controlView;
}

- (UIView *)containerView {
    if (!_containerView) {
        _containerView = [UIView new];
        _containerView.backgroundColor = kAppClearColor;
    }
    return _containerView;
}

- (UIButton *)playBtn {
    if (!_playBtn) {
        _playBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [_playBtn setImage:[UIImage imageNamed:@"new_allPlay_44x44_"] forState:UIControlStateNormal];
        [_playBtn addTarget:self action:@selector(playClick) forControlEvents:UIControlEventTouchUpInside];
    }
    return _playBtn;
}
- (void)playClick {
    [self.containerView setHidden:NO];
    [self.playBtn setHidden:YES];
    [self.player playTheIndex:0];
}
#pragma mark - clickedShareItem

- (void)clickedShareItem:(UIButton *)btn{
    [self showShareAction];
}
-(void)showShareAction {
    [UMSocialUIManager setPreDefinePlatforms:@[@(UMSocialPlatformType_WechatSession),@(UMSocialPlatformType_WechatTimeLine),@(UMSocialPlatformType_QQ),@(UMSocialPlatformType_Qzone),@(UMSocialPlatformType_Sina)]];
    
    [UMSocialUIManager showShareMenuViewInWindowWithPlatformSelectionBlock:^(UMSocialPlatformType platformType, NSDictionary *userInfo) {
        // 根据获取的platformType确定所选平台进行下一步操作
        [self doShareTitle:self.fModel.video_title description:self.fModel.video_description image:[UIImage imageNamed:@"applogo"] url:[NSString stringWithFormat:@"%@login.html?icode=%@",BGWebMainHtml,BGGetUserDefaultObjectForKey(@"inviteCode")] shareType:(platformType)];
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
//                UMSocialShareResponse *resp = data;
//                DLog(@"\n>>>[UMSocialManager message]:%@ originalResponse:%@",resp.message,resp.originalResponse);
                [WHIndicatorView toast:@"分享成功"];
            }else{
//                DLog(@"/n[share]");
                [WHIndicatorView toast:@"分享成功"];
            }
        }
    }];
    
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
