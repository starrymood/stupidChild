//
//  BGEssayCommentListViewController.m
//  shzTravelC
//
//  Created by biao on 2018/7/30.
//  Copyright © 2018年 biao. All rights reserved.
//

#import "BGEssayCommentListViewController.h"
#import "BGCommunityApi.h"
#import "BGEssayCommentCell.h"
#import "BGEssayCommentFirstModel.h"
#import "BGEssayCommentSModel.h"
#import "BGEssayCommentDetailViewController.h"
#import "BGUserHomepageViewController.h"
#import "IQKeyboardManager.h"
#import "UITextField+BGLimit.h"

#define textViewHeight 44
@interface BGEssayCommentListViewController ()<UITableViewDelegate, UITableViewDataSource,UITextFieldDelegate>

@property (nonatomic,strong)UITableView *tableView;
@property (nonatomic, strong) UIView *noneView;
@property (nonatomic,strong)NSMutableArray *cellDataArr;
// 页数
@property (nonatomic, copy) NSString *pageNum;

@property (nonatomic, strong) UIButton *rightButton;

@property (nonatomic, strong) UIView *backView;
@property (nonatomic, strong) UIView *inputView;
@property (nonatomic, strong) UITextField *inputTextField;

@end

@implementation BGEssayCommentListViewController
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
        showMsgLabel.text = @"暂无评论哦~";
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
-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    self.navigationController.navigationBarHidden = NO;
     [self registerKeyBoardNotification];
}
- (void)viewDidLoad{
    [super viewDidLoad];
    
    [self loadSubViews];
    [self refreshView];
}
#pragma mark - 加载视图
- (void)loadSubViews {
    
    self.view.backgroundColor = kAppBgColor;
    self.navigationItem.title = @"评论列表";
    self.tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, SafeAreaTopHeight, SCREEN_WIDTH, SCREEN_HEIGHT-SafeAreaTopHeight) style:(UITableViewStyleGrouped)];
    _tableView.backgroundColor = kAppBgColor;
    _tableView.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
    _tableView.separatorColor = kAppBgColor;
    _tableView.estimatedRowHeight = SCREEN_HEIGHT;
    _tableView.rowHeight = UITableViewAutomaticDimension;
    _tableView.dataSource = self;
    _tableView.delegate = self;
    [self.view addSubview:_tableView];
    if (!_isVideo) {
        _rightButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _rightButton.frame = CGRectMake(SCREEN_WIDTH-40, 5, 40, 30);
        _rightButton.titleLabel.font = [UIFont systemFontOfSize:15];
        [_rightButton setTitle:@"添加评论" forState:UIControlStateNormal];
        [_rightButton setTitleColor:kApp333Color forState:UIControlStateNormal];
        [_rightButton addTarget:self action:@selector(addNewComment) forControlEvents:UIControlEventTouchUpInside];
        UIBarButtonItem *rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:_rightButton];
        self.navigationItem.rightBarButtonItem = rightBarButtonItem;
    }
    
    [self.tableView registerNib:[UINib nibWithNibName:@"BGEssayCommentCell" bundle:nil] forCellReuseIdentifier:@"BGEssayCommentCell"];
    _pageNum = @"1";
}
-(void)addNewComment{
    if (![Tool isLogin]) {
        [WHIndicatorView toast:@"请先登录!"];
        [BGAppDelegateHelper showLoginViewController];
        return;
    }
    [[[UIApplication sharedApplication] keyWindow] addSubview:self.backView];
    [[[UIApplication sharedApplication] keyWindow] addSubview:self.inputView];
    [self.inputTextField becomeFirstResponder];
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
        [weakSelf loadData];
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
    [self loadData];
}
#pragma mark - 加载数据  -
-(void)loadData
{
    if (_isVideo) {
        NSMutableDictionary *param = [[NSMutableDictionary alloc] init];
        [param setObject:_postID forKey:@"post_id"];
        [param setObject:_pageNum forKey:@"pageno"];
        [param setObject:@"10" forKey:@"pagesize"];
        [ProgressHUDHelper showLoading];
        __block typeof(self) weakSelf = self;
        [BGCommunityApi getVideoCommentList:param succ:^(NSDictionary *response) {
            DLog(@"\n>>>[getVideoCommentList sucess]:%@",response);
            [weakSelf hideNodateView];
            if (weakSelf.pageNum.intValue == 1) {
                [weakSelf.cellDataArr removeAllObjects];
                [weakSelf.tableView.mj_footer resetNoMoreData];
            }
            NSMutableArray *tempArr = [BGEssayCommentFirstModel mj_objectArrayWithKeyValuesArray:BGdictSetObjectIsNil(response[@"result"][@"rows"])];
            NSString *totalPageNumStr = [NSString stringWithFormat:@"%@",BGdictSetObjectIsNil(response[@"result"][@"pages"])];
            if (weakSelf.pageNum.integerValue<=totalPageNumStr.integerValue) {
                [weakSelf.cellDataArr addObjectsFromArray:tempArr];
            }
            if (weakSelf.cellDataArr.count>0) {
                [weakSelf.noneView removeFromSuperview];
            }
            [weakSelf.tableView reloadData];
            
            if (weakSelf.pageNum.integerValue>=totalPageNumStr.integerValue) {
                [weakSelf.tableView.mj_footer endRefreshingWithNoMoreData];
            }else{
                [weakSelf.tableView.mj_footer endRefreshing];
            }
            
        } failure:^(NSDictionary *response) {
            DLog(@"\n>>>[getCommentList failure]:%@",response);
            [self shownoNetWorkViewWithType:0];
            [self setRefreshBlock:^{
                [weakSelf loadData];
            }];
        }];
    }else{
        NSMutableDictionary *param = [[NSMutableDictionary alloc] init];
        [param setObject:_postID forKey:@"post_id"];
        [param setObject:_pageNum forKey:@"pageno"];
        [param setObject:@"10" forKey:@"pagesize"];
        [ProgressHUDHelper showLoading];
        __block typeof(self) weakSelf = self;
        [BGCommunityApi getCommentList:param succ:^(NSDictionary *response) {
            DLog(@"\n>>>[getCommentList sucess]:%@",response);
            [weakSelf hideNodateView];
            if (weakSelf.pageNum.intValue == 1) {
                [weakSelf.cellDataArr removeAllObjects];
                [weakSelf.tableView.mj_footer resetNoMoreData];
            }
            NSMutableArray *tempArr = [BGEssayCommentFirstModel mj_objectArrayWithKeyValuesArray:BGdictSetObjectIsNil(response[@"result"][@"rows"])];
            NSString *totalPageNumStr = [NSString stringWithFormat:@"%@",BGdictSetObjectIsNil(response[@"result"][@"pages"])];
            if (weakSelf.pageNum.integerValue<=totalPageNumStr.integerValue) {
                [weakSelf.cellDataArr addObjectsFromArray:tempArr];
            }
            if ([Tool arrayIsNotEmpty:weakSelf.cellDataArr]) {
                [weakSelf.noneView removeFromSuperview];
            }
            [weakSelf.tableView reloadData];
            
            if (weakSelf.pageNum.integerValue>=totalPageNumStr.integerValue) {
                [weakSelf.tableView.mj_footer endRefreshingWithNoMoreData];
            }else{
                [weakSelf.tableView.mj_footer endRefreshing];
            }
        } failure:^(NSDictionary *response) {
            DLog(@"\n>>>[getCommentList failure]:%@",response);
            [self shownoNetWorkViewWithType:0];
            [self setRefreshBlock:^{
                [weakSelf loadData];
            }];
        }];
    }
    
}

#pragma mark  -  TableViewDelegate  -
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    self.tableView.mj_footer.hidden = self.cellDataArr.count == 0;
    return _cellDataArr.count==0 ? 1: _cellDataArr.count;
}
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return _cellDataArr.count==0 ? 0:1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    BGEssayCommentCell *cell = [tableView dequeueReusableCellWithIdentifier:@"BGEssayCommentCell" forIndexPath:indexPath];
    if ([Tool arrayIsNotEmpty:_cellDataArr]) {
        BGEssayCommentFirstModel *model = _cellDataArr[indexPath.section];
        [cell updataWithCellArray:model];
        @weakify(self);
        [[[cell.userHomepageBtn rac_signalForControlEvents:(UIControlEventTouchUpInside)] takeUntil:cell.rac_prepareForReuseSignal] subscribeNext:^(__kindof UIControl * _Nullable x) {
            @strongify(self);
            // 点击button的响应事件
            BGUserHomepageViewController *userVC = BGUserHomepageViewController.new;
            userVC.member_id = model.member_id;
            [self.navigationController pushViewController:userVC animated:YES];
        }];
        
        [[[cell.firstLikeBtn rac_signalForControlEvents:(UIControlEventTouchUpInside)] takeUntil:cell.rac_prepareForReuseSignal] subscribeNext:^(__kindof UIControl * _Nullable x) {
            @strongify(self);
            // 点击button的响应事件
            if (![Tool isLogin]) {
                [WHIndicatorView toast:@"请先登录!"];
                [BGAppDelegateHelper showLoginViewController];
                return;
            }
            NSMutableDictionary *param = [[NSMutableDictionary alloc] init];
            [param setObject:model.ID forKey:@"review_id"];
            [param setObject:self.type forKey:@"type"];
            [ProgressHUDHelper showLoading];
            __block typeof(self) weakSelf = self;
            [BGCommunityApi likeThisComment:param succ:^(NSDictionary *response) {
                DLog(@"\n>>>[likeThisComment sucess]:%@",response);
                NSString *message = BGdictSetObjectIsNil(response[@"msg"]);
                [WHIndicatorView toast:message];
                if ([message isEqualToString:@"点赞成功！"]) {
                    model.review_like_count = [NSString stringWithFormat:@"%zd",model.review_like_count.integerValue+1];
                    model.is_review_like = @"1";
                    [weakSelf.cellDataArr replaceObjectAtIndex:indexPath.section withObject:model];
                    [weakSelf.tableView reloadSections:[[NSIndexSet alloc] initWithIndex:indexPath.section] withRowAnimation:UITableViewRowAnimationNone];
                }else{
                    model.review_like_count = [NSString stringWithFormat:@"%zd",model.review_like_count.integerValue-1];
                    model.is_review_like = @"0";
                    [weakSelf.cellDataArr replaceObjectAtIndex:indexPath.section withObject:model];
                    [weakSelf.tableView reloadSections:[[NSIndexSet alloc] initWithIndex:indexPath.section] withRowAnimation:UITableViewRowAnimationNone];
                }
            } failure:^(NSDictionary *response) {
                DLog(@"\n>>>[likeThisComment failure]:%@",response);
            }];
            
        }];
        
        [[[cell.replyBtn rac_signalForControlEvents:(UIControlEventTouchUpInside)] takeUntil:cell.rac_prepareForReuseSignal] subscribeNext:^(__kindof UIControl * _Nullable x) {
            @strongify(self);
            // 点击button的响应事件
            if (![Tool isLogin]) {
                [WHIndicatorView toast:@"请先登录!"];
                [BGAppDelegateHelper showLoginViewController];
                return;
            }
            BGEssayCommentDetailViewController *detailVC = BGEssayCommentDetailViewController.new;
            detailVC.ID = model.ID;
            if (self.isVideo) {
                detailVC.type = @"2";
            }else{
                detailVC.type = @"1";
            }
            [self.navigationController pushViewController:detailVC animated:YES];
        }];
        
        [[[cell.sAllReplyBtn rac_signalForControlEvents:(UIControlEventTouchUpInside)] takeUntil:cell.rac_prepareForReuseSignal] subscribeNext:^(__kindof UIControl * _Nullable x) {
            @strongify(self);
            // 点击button的响应事件
            BGEssayCommentDetailViewController *detailVC = BGEssayCommentDetailViewController.new;
            detailVC.ID = model.ID;
            if (self.isVideo) {
                detailVC.type = @"2";
            }else{
                detailVC.type = @"1";
            }
            [self.navigationController pushViewController:detailVC animated:YES];
        }];
      
        if ([Tool arrayIsNotEmpty:model.children_review]) {
            BGEssayCommentSModel *sModel = [BGEssayCommentSModel mj_objectWithKeyValues:model.children_review[0]];
            @weakify(self);
            [[[cell.sFirstUserBtn rac_signalForControlEvents:(UIControlEventTouchUpInside)] takeUntil:cell.rac_prepareForReuseSignal] subscribeNext:^(__kindof UIControl * _Nullable x) {
                @strongify(self);
                // 点击button的响应事件
                BGUserHomepageViewController *userVC = BGUserHomepageViewController.new;
                userVC.member_id = sModel.member_id;
                [self.navigationController pushViewController:userVC animated:YES];
            }];
            [[[cell.sSUserBtn rac_signalForControlEvents:(UIControlEventTouchUpInside)] takeUntil:cell.rac_prepareForReuseSignal] subscribeNext:^(__kindof UIControl * _Nullable x) {
                @strongify(self);
                // 点击button的响应事件
                BGUserHomepageViewController *userVC = BGUserHomepageViewController.new;
                userVC.member_id = sModel.reply_member_id;
                [self.navigationController pushViewController:userVC animated:YES];
            }];
        }
    }
    
    
    return cell;
}
-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    if (_cellDataArr.count == 0) {
        return 0.01;
    }else{
        return 1;
    }
}
-(CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section{
    if (_cellDataArr.count == 0) {
        return _tableView.frame.size.height;
    }else{
        if (_cellDataArr.count -2 >0) {
            return section==(_cellDataArr.count-1)? 30:0.01;
        }else{
            return 0.01;
        }
    }
}
- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    return nil;
}
- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section{
    if (_cellDataArr.count == 0) {
        return self.noneView;
    }
    return nil;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
    if ([Tool arrayIsNotEmpty:_cellDataArr]) {
        BGEssayCommentFirstModel *model = _cellDataArr[indexPath.section];
        BGEssayCommentDetailViewController *detailVC = BGEssayCommentDetailViewController.new;
        detailVC.ID = model.ID;
        if (self.isVideo) {
            detailVC.type = @"2";
        }else{
            detailVC.type = @"1";
        }
        [self.navigationController pushViewController:detailVC animated:YES];
    }
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
    
    [param setObject:_postID forKey:@"post_id"];
    [param setObject:@"0" forKey:@"reply_review_id"];
    [param setObject:@"0" forKey:@"reply_member_id"];
    [param setObject:_type forKey:@"type"];
    [ProgressHUDHelper showLoading];
     __weak typeof(self) weakself = self;
    [BGCommunityApi AddComment:param succ:^(NSDictionary *response) {
        DLog(@"\n>>>[AddComment sucess]:%@",response);
        [weakself canaleCallBack];
        weakself.pageNum = @"1";
        [weakself loadData];
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
