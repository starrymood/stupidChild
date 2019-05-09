//
//  BGEssayDetailViewController.m
//  shzTravelC
//
//  Created by biao on 2018/7/27.
//  Copyright © 2018年 biao. All rights reserved.
//

#import "BGEssayDetailViewController.h"
#import "BGCommunityApi.h"
#import "BGEssayDetailOwnerView.h"
#import "BGEssayDetailModel.h"
#import <UIImageView+WebCache.h>
#import "BGUserHomepageViewController.h"
#import <JCAlertController.h>
#import "BGEssayCommentListViewController.h"
#import "BGEssayDetailBottomView.h"
#import "BGEssayCommentCell.h"
#import "BGEssayCommentDetailViewController.h"
#import "BGEssayCommentFirstModel.h"
#import "BGEssayCommentDetailViewController.h"
#import "BGEssayCommentSModel.h"
#import "IQKeyboardManager.h"
#import "UITextField+BGLimit.h"
#import <UMShare/UMShare.h>
#import <UShareUI/UShareUI.h>
#import "MCScrollView.h"
#import "UIImage+ImgSize.h"
#import "BGEssayEasyCell.h"

#define textViewHeight 44
#define ownerViewHeight 136.5
#define videoHeightScale 0.5625
@interface BGEssayDetailViewController ()<UITableViewDelegate,UITableViewDataSource,UITextFieldDelegate,MCScrollViewDelegate>

@property (nonatomic, strong) NSMutableArray *cellDataArr;

@property (nonatomic, strong) UITableView *tableView;

@property (nonatomic, strong) BGEssayDetailOwnerView *ownerView;

@property (nonatomic, strong) UIView *headerView;

@property (nonatomic, assign) BOOL isConcern;

@property (nonatomic, strong) JCAlertController *alert;

@property (nonatomic, strong) BGEssayDetailBottomView *bottomView;

@property (nonatomic, strong) BGEssayDetailModel *fModel;
@property (nonatomic, strong) UIView *backView;
@property (nonatomic, strong) UIView *inputView;
@property (nonatomic, strong) UITextField *inputTextField;

@property (nonatomic, strong)MCScrollView *imageScrollView;

@property (nonatomic, strong)  NSMutableArray *imageArray;

@property (nonatomic, assign)  CGFloat imageScrollView_high;
@property(nonatomic,strong) UIView *whiteFooterView;

@end

@implementation BGEssayDetailViewController
-(UIView *)whiteFooterView{
    if (!_whiteFooterView) {
        self.whiteFooterView = UIView.new;
        _whiteFooterView.backgroundColor = kAppWhiteColor;
    }
    return _whiteFooterView;
}
-(NSMutableArray *)imageArray{
    if (!_imageArray) {
        self.imageArray = [NSMutableArray array];
    }
    return _imageArray;
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
     [self registerKeyBoardNotification];
}
-(void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    [[IQKeyboardManager sharedManager] setEnable:YES];
    [IQKeyboardManager sharedManager].enableAutoToolbar = YES;
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillShowNotification object:UIKeyboardWillHideNotification];
    
}
-(void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    [IQKeyboardManager sharedManager].enableAutoToolbar = NO;
    [[IQKeyboardManager sharedManager] setEnable:NO];
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
    
    self.navigationItem.title = @"帖子详情";
    self.view.backgroundColor = kAppBgColor;
    self.navigationItem.rightBarButtonItem = [UIBarButtonItem itemWithImage:@"product_details_share_icon" highImage:@"product_details_share_icon" target:self action:@selector(clickedShareItem:)];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(LoginSuccessNotification) name:@"LoginSuccessNotification" object:nil];
   
    
    self.headerView = UIView.new;
    _headerView.backgroundColor = kAppBgColor;
    _headerView.frame = CGRectMake(0, 0, SCREEN_WIDTH, 6+SCREEN_WIDTH*videoHeightScale+ownerViewHeight);
    
    self.imageScrollView_high = SCREEN_WIDTH*videoHeightScale;
    self.imageScrollView = [[MCScrollView alloc] initWithFrame:CGRectMake(0, 6, SCREEN_WIDTH, self.imageScrollView_high)];
    _imageScrollView.userInteractionEnabled = YES;
    _imageScrollView.mcDelegate = self;
    [_headerView addSubview:_imageScrollView];
    
    self.ownerView = [[BGEssayDetailOwnerView alloc] initWithFrame:CGRectMake(0, _imageScrollView.y+_imageScrollView.height, SCREEN_WIDTH, ownerViewHeight)];
    _ownerView.concernBtn.layer.borderColor = kAppMainColor.CGColor;
    _ownerView.createTimeLabel.hidden = NO;
    _ownerView.contentLabelHeight.constant = 32;
    _ownerView.concernBtn.layer.borderWidth = 1.0;
    _ownerView.concernBtn.userInteractionEnabled = NO;
    [_headerView addSubview:_ownerView];
    
    self.bottomView = [[BGEssayDetailBottomView alloc] initWithFrame:CGRectMake(0,SCREEN_HEIGHT-SafeAreaBottomHeight-43, SCREEN_WIDTH, 43+SafeAreaBottomHeight)];
    [self.bottomView setHidden:YES];
    
    self.tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, SafeAreaTopHeight, SCREEN_WIDTH, SCREEN_HEIGHT-SafeAreaTopHeight-SafeAreaBottomHeight-43) style:(UITableViewStyleGrouped)];
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
    model.post_id = _postID;
    model.type = @"1";
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
    
    NSInteger lineNum = [self needLinesWithWidth:(SCREEN_WIDTH-17*2) text:model.content];
    
    [_ownerView removeFromSuperview];
    self.navigationItem.title = model.post_title;
    
    if (model.type.intValue == 1) {
        [self.imageArray removeAllObjects];
        if (model.file_url.count<2) {
            _imageScrollView.userInteractionEnabled = NO;
        }
        
        dispatch_queue_t queue = dispatch_queue_create("com.lai.www", DISPATCH_QUEUE_SERIAL);
        
        for (int i = 0; i<model.file_url.count; i++) {
            NSMutableDictionary *dataDic = [[NSMutableDictionary alloc] init];
            NSString *urlStr = [NSString stringWithFormat:@"%@",model.file_url[i]];
            [dataDic setObject:urlStr forKey:@"url"];
            __weak typeof(self) weakSelf = self;
            dispatch_async(queue, ^{
                [WHAPIClient GET:[NSString stringWithFormat:@"%@?imageInfo",urlStr] param:nil tokenType:3 succ:^(NSDictionary *response) {
                    DLog(@"response:%@",response);
                    [dataDic setObject:[NSString stringWithFormat:@"%@",response[@"height"]] forKey:@"height"];
                    [dataDic setObject:[NSString stringWithFormat:@"%@",response[@"width"]] forKey:@"width"];
                    [weakSelf.imageArray addObject:dataDic];
                    if (i == model.file_url.count-1) {
                        [weakSelf.imageScrollView removeFromSuperview];
                        CGFloat scale = [[weakSelf.imageArray[0] objectForKey:@"height"] floatValue]/[[weakSelf.imageArray[0] objectForKey:@"width"] floatValue];
                        weakSelf.imageScrollView_high = SCREEN_WIDTH*scale;
                        weakSelf.imageScrollView = [[MCScrollView alloc] initWithFrame:CGRectMake(0, 6, SCREEN_WIDTH, weakSelf.imageScrollView_high)];
                        weakSelf.imageScrollView.imageItemArray = weakSelf.imageArray;
                        if (model.file_url.count<2) {
                            weakSelf.imageScrollView.userInteractionEnabled = NO;
                        }else{
                            weakSelf.imageScrollView.userInteractionEnabled = YES;
                        }
                        weakSelf.imageScrollView.mcDelegate = self;
                        [weakSelf.headerView addSubview:weakSelf.imageScrollView];
                        
                        weakSelf.headerView.height = 6+self.imageScrollView_high+ownerViewHeight+(lineNum-1)*14.5;
                        weakSelf.ownerView.frame = CGRectMake(0, weakSelf.imageScrollView.y+weakSelf.imageScrollView.height, SCREEN_WIDTH, ownerViewHeight+(lineNum-1)*14.5);
                        
                        weakSelf.ownerView.concernBtn.layer.borderColor = kAppMainColor.CGColor;
                        weakSelf.ownerView.concernBtn.layer.borderWidth = 1.0;
                        [weakSelf.ownerView.concernBtn setBackgroundColor:kAppWhiteColor];
                        weakSelf.ownerView.concernBtn.userInteractionEnabled = NO;
                        [weakSelf.headerView addSubview:weakSelf.ownerView];
                        weakSelf.ownerView.commentNumLabel.text = [NSString stringWithFormat:@"共%@条评论",model.review_count];
                        weakSelf.ownerView.contentLabel.text = model.content;
                        weakSelf.ownerView.createTimeLabel.hidden = NO;
                        weakSelf.ownerView.contentLabelHeight.constant = 32;
                        weakSelf.ownerView.createTimeLabel.text = [NSString stringWithFormat:@"帖子发表时间：%@",[Tool dateFormatter:model.create_time.doubleValue dateFormatter:@"yyyy-MM-dd HH:mm"]];
                        weakSelf.tableView.tableHeaderView = weakSelf.headerView;
                    }
                    
                } failure:^(NSDictionary *response) {
                    
                }];
            });
            
            
        }
        
        
    }
    
    [_ownerView.headImgView sd_setImageWithURL:[NSURL URLWithString:model.face] placeholderImage:BGImage(@"defaultUserIcon")];
    _ownerView.nickNameLabel.text = model.nickname;
     _ownerView.concernBtn.userInteractionEnabled = YES;
    [[_ownerView.commentListBtn rac_signalForControlEvents:(UIControlEventTouchUpInside)] subscribeNext:^(__kindof UIControl * _Nullable x) {
        @strongify(self);
        // 点击button的响应事件
        BGEssayCommentListViewController *listVC = BGEssayCommentListViewController.new;
        listVC.postID = self.postID;
        listVC.isVideo = NO;
        listVC.type = @"1";
        [self.navigationController pushViewController:listVC animated:YES];
    }];
    if (model.is_concern.intValue == 1) {
        _isConcern = YES;
        [_ownerView.concernBtn setTitle:@"已关注" forState:(UIControlStateNormal)];
        [_ownerView.concernBtn setTitleColor:kAppWhiteColor forState:(UIControlStateNormal)];
        [_ownerView.concernBtn setBackgroundColor:kAppMainColor];
        _ownerView.concernBtn.layer.borderColor = kAppMainColor.CGColor;
    }else{
        _isConcern = NO;
        [_ownerView.concernBtn setTitle:@"关注" forState:(UIControlStateNormal)];
        [_ownerView.concernBtn setTitleColor:kAppMainColor forState:(UIControlStateNormal)];
        [_ownerView.concernBtn setBackgroundColor:kAppWhiteColor];
        _ownerView.concernBtn.layer.borderColor = kAppMainColor.CGColor;
    }
    [[_ownerView.enterHomepageBtn rac_signalForControlEvents:(UIControlEventTouchUpInside)] subscribeNext:^(__kindof UIControl * _Nullable x) {
        @strongify(self);
        // 点击button的响应事件
        BGUserHomepageViewController *userVC = BGUserHomepageViewController.new;
        userVC.member_id = model.member_id;
        [self.navigationController pushViewController:userVC animated:YES];
    }];
    [[_ownerView.concernBtn rac_signalForControlEvents:(UIControlEventTouchUpInside)] subscribeNext:^(__kindof UIControl * _Nullable x) {
        @strongify(self);
        // 点击button的响应事件
        if (![Tool isLogin]) {
            [WHIndicatorView toast:@"请先登录!"];
            [BGAppDelegateHelper showLoginViewController];
            return;
        }
        NSMutableDictionary *param = [[NSMutableDictionary alloc] init];
        [param setObject:model.member_id forKey:@"member_id"];
        [param setObject:@"1" forKey:@"type"];
        [ProgressHUDHelper showLoading];
        __weak __typeof(self) weakSelf = self;
        [BGCommunityApi modifyConcernStatus:param succ:^(NSDictionary *response) {
            DLog(@"\n>>>[modifyConcernStatus sucess]:%@",response);
            if (weakSelf.isConcern) {
                [WHIndicatorView toast:@"取消关注成功"];
                [weakSelf.ownerView.concernBtn setTitle:@"关注" forState:(UIControlStateNormal)];
                [weakSelf.ownerView.concernBtn setTitleColor:kAppMainColor forState:(UIControlStateNormal)];
                [weakSelf.ownerView.concernBtn setBackgroundColor:kAppWhiteColor];
                weakSelf.ownerView.concernBtn.layer.borderColor = kAppMainColor.CGColor;
                weakSelf.isConcern = NO;
            }else{
                [WHIndicatorView toast:@"关注成功"];
                
                [weakSelf.ownerView.concernBtn setTitle:@"已关注" forState:(UIControlStateNormal)];
                [weakSelf.ownerView.concernBtn setTitleColor:kAppWhiteColor forState:(UIControlStateNormal)];
                [weakSelf.ownerView.concernBtn setBackgroundColor:kAppMainColor];
                weakSelf.ownerView.concernBtn.layer.borderColor = kAppMainColor.CGColor;
                weakSelf.isConcern = YES;
            }
        } failure:^(NSDictionary *response) {
            DLog(@"\n>>>[modifyConcernStatus failure]:%@",response);
        }];
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
    
    NSMutableDictionary *param = [[NSMutableDictionary alloc] init];
    [param setObject:_postID forKey:@"post_id"];
    __weak __typeof(self) weakSelf = self;
    [BGCommunityApi getEssayDetail:param succ:^(NSDictionary *response) {
        DLog(@"\n>>>[getEssayDetail sucess]:%@",response);
        [weakSelf hideNodateView];
        
        BGEssayDetailModel *model = [BGEssayDetailModel mj_objectWithKeyValues:BGdictSetObjectIsNil(response[@"result"])];
        [weakSelf updateSubViewsWithModel:model];
    } failure:^(NSDictionary *response) {
        DLog(@"\n>>>[getEssayDetail failure]:%@",response);
        [ProgressHUDHelper removeLoading];
        if ([BGdictSetObjectIsNil(response[@"msg"]) isEqualToString:@"该帖子已不存在！"]) {
            [weakSelf.navigationController popViewControllerAnimated:YES];
            return ;
        }
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
    listVC.postID = self.postID;
    listVC.isVideo = NO;
    listVC.type = @"1";
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

//-(void)useMethodToFindBlackLineAndShow{
//    UIImageView* blackLineImageView = [self findHairlineImageViewUnder:self.navigationController.navigationBar];
//    //隐藏黑线（在viewWillAppear时隐藏，在viewWillDisappear时显示）
//    blackLineImageView.hidden = NO;
//}


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
    [param setObject:@"1" forKey:@"type"];
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


#pragma mark - clickedShareItem

- (void)clickedShareItem:(UIButton *)btn{
    [self showShareAction];
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
            [self doShareTitle:self.fModel.post_title description:self.fModel.content image:[UIImage imageNamed:@"applogo"] url:[NSString stringWithFormat:@"%@login.html?icode=%@",BGWebMainHtml,BGGetUserDefaultObjectForKey(@"inviteCode")] shareType:(platformType)];
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
#pragma mark MCScrollViewDelegate
-(void)MCScrollViewDidScroll:(UIScrollView *)scrollView viewHeight:(CGFloat)height
{
    self.imageScrollView_high = height;
    __weak __typeof(self) weakSelf = self;

    [UIView animateWithDuration:0.15 // 动画时长
                          delay:0.0 // 动画延迟
                        options:UIViewAnimationOptionCurveEaseIn // 动画过渡效果
                     animations:^{
                         weakSelf.imageScrollView.frame = CGRectMake(0, 6, SCREEN_WIDTH, weakSelf.imageScrollView_high);
                         NSInteger lineNum = [weakSelf needLinesWithWidth:(SCREEN_WIDTH-17*2) text:weakSelf.fModel.content];
                        weakSelf.headerView.height = 6+weakSelf.imageScrollView_high+ownerViewHeight+(lineNum-1)*14.5;
                         weakSelf.ownerView.frame = CGRectMake(0, weakSelf.imageScrollView.y+weakSelf.imageScrollView.height,  SCREEN_WIDTH, ownerViewHeight+(lineNum-1)*14.5);
                         [weakSelf.tableView beginUpdates];
                         weakSelf.tableView.tableHeaderView = weakSelf.headerView;
                         [weakSelf.tableView endUpdates];
                     }
                     completion:^(BOOL finished) {
                         // 动画完成后执行
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
