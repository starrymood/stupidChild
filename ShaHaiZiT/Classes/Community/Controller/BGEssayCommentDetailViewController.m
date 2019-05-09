//
//  BGEssayCommentDetailViewController.m
//  shzTravelC
//
//  Created by biao on 2018/7/31.
//  Copyright © 2018年 biao. All rights reserved.
//

#import "BGEssayCommentDetailViewController.h"
#import "BGCommunityApi.h"
#import "BGEssayCommentFirstModel.h"
#import "BGEssayCommentSModel.h"
#import "BGUserHomepageViewController.h"
#import "BGEssayCommentOneCell.h"
#import <UIImageView+WebCache.h>
#import "IQKeyboardManager.h"
#import "UITextField+BGLimit.h"

#define textViewHeight 44
@interface BGEssayCommentDetailViewController ()<UITableViewDelegate,UITableViewDataSource,UITextFieldDelegate>

@property (weak, nonatomic) IBOutlet UIButton *userHomepageBtn;
@property (weak, nonatomic) IBOutlet UIButton *firstLikeBtn;
@property (weak, nonatomic) IBOutlet UIButton *replyBtn;
@property (weak, nonatomic) IBOutlet UIImageView *firstHeadImgView;
@property (weak, nonatomic) IBOutlet UILabel *firstNickNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *firstContentLabel;
@property (weak, nonatomic) IBOutlet UILabel *firstPostTimeLabel;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (nonatomic,strong)NSMutableArray *cellDataArr;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *viewHeight;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *contentCenterY;
@property (nonatomic, strong) UIView *backView;
@property (nonatomic, strong) UIView *inputView;
@property (nonatomic, strong) UITextField *inputTextField;
@property (nonatomic, strong) BGEssayCommentFirstModel *fModel;
@property (nonatomic, strong) BGEssayCommentSModel *sModel;
@property (nonatomic, assign) BOOL isSInput;
@property (nonatomic, copy) NSString *nickNameStr;

@end

@implementation BGEssayCommentDetailViewController
-(UIView *)inputView{
    if (!_inputView) {
        self.inputView = [[UIView alloc] initWithFrame:CGRectMake(0, SCREEN_HEIGHT+textViewHeight, SCREEN_WIDTH, textViewHeight)];
        self.inputView.backgroundColor = kAppWhiteColor;
        self.inputTextField = [[UITextField alloc] initWithFrame:CGRectMake(10, 5, SCREEN_WIDTH-10*2, textViewHeight-5*2)];
        [_inputView addSubview:_inputTextField];
        _inputTextField.textAlignment = NSTextAlignmentLeft;
        _inputTextField.textColor = kApp333Color;
        _inputTextField.font = kFont(12);
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
-(void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    [IQKeyboardManager sharedManager].enableAutoToolbar = NO;
    [[IQKeyboardManager sharedManager] setEnable:NO];
}
-(void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    [[IQKeyboardManager sharedManager] setEnable:YES];
    [IQKeyboardManager sharedManager].enableAutoToolbar = YES;
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillShowNotification object:UIKeyboardWillHideNotification];
}
- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self loadSubViews];
    [self loadData];
}
#pragma mark - 加载视图
- (void)loadSubViews {
    self.view.backgroundColor = kAppBgColor;
    self.navigationItem.title = @"评论详情";
    
    _tableView.backgroundColor = UIColorFromRGB(0xECF2F6);
    _tableView.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
    _tableView.separatorColor = UIColorFromRGB(0xECF2F6);
    _tableView.estimatedRowHeight = 137;
    _tableView.rowHeight = UITableViewAutomaticDimension;
    _tableView.scrollEnabled = NO;
    [_tableView setHidden:YES];
    self.isSInput = NO;
    
    [self.tableView registerNib:[UINib nibWithNibName:@"BGEssayCommentOneCell" bundle:nil] forCellReuseIdentifier:@"BGEssayCommentOneCell"];
}
#pragma mark - 加载数据  -
-(void)loadData{
    NSMutableDictionary *param = [[NSMutableDictionary alloc] init];
    [param setObject:_ID forKey:@"review_id"];
    [ProgressHUDHelper showLoading];
    __block typeof(self) weakSelf = self;
    [BGCommunityApi getOneCommentDetail:param type:_type.intValue succ:^(NSDictionary *response) {
        DLog(@"\n>>>[getOneCommentDetail sucess]:%@",response);
        BGEssayCommentFirstModel *model = [BGEssayCommentFirstModel mj_objectWithKeyValues:BGdictSetObjectIsNil(response[@"result"])];
        [weakSelf updataWithModel:model];
        weakSelf.fModel = model;
   
    } failure:^(NSDictionary *response) {
        DLog(@"\n>>>[getOneCommentDetail failure]:%@",response);
    }];
    
}
-(void)updataWithModel:(BGEssayCommentFirstModel *)model{
    
    if ([Tool arrayIsNotEmpty:model.children_review]) {
        [self.tableView setHidden:NO];

        self.cellDataArr = [BGEssayCommentSModel mj_objectArrayWithKeyValuesArray:model.children_review];
        CGFloat height = 105 + self.cellDataArr.count*60;

        for (BGEssayCommentSModel *model in self.cellDataArr) {
            NSInteger lineNum = [self needLinesWithWidth:(SCREEN_WIDTH-10-10-10-25-10-12) text:model.review_body];
            height += (lineNum-1)*14.5;
        }
        NSInteger lineNum = [self needLinesWithWidth:(SCREEN_WIDTH-10-10-25-10) text:model.review_body];
        height += (lineNum-1)*14.5;
        self.viewHeight.constant = height;
        [self changeViewFrame];
    }else{
        [self.tableView setHidden:YES];
        NSInteger lineNum = [self needLinesWithWidth:(SCREEN_WIDTH-10-10-25-10) text:model.review_body];
        self.viewHeight.constant = 105+(lineNum-1)*14.5;
        [self changeViewFrame];
    }
    
    
    if (model.is_review_like.intValue == 1) {
        [_firstLikeBtn setImage:BGImage(@"essay_bottom_like_green") forState:(UIControlStateNormal)];
        [_firstLikeBtn setTitle:model.review_like_count forState:(UIControlStateNormal)];
        [_firstLikeBtn setTitleColor:kAppMainColor forState:(UIControlStateNormal)];
    }else{
        [_firstLikeBtn setImage:BGImage(@"essay_bottom_like_white") forState:(UIControlStateNormal)];
        [_firstLikeBtn setTitle:model.review_like_count forState:(UIControlStateNormal)];
        [_firstLikeBtn setTitleColor:kApp666Color forState:(UIControlStateNormal)];
    }
    
    
    [self.firstHeadImgView sd_setImageWithURL:[NSURL URLWithString:model.face] placeholderImage:BGImage(@"defaultUserIcon")];
    self.firstNickNameLabel.text = model.nickname;
    self.firstContentLabel.text = model.review_body;
    self.firstPostTimeLabel.text = [Tool dateFormatter:model.create_time.doubleValue dateFormatter:@"yyyy-MM-dd HH:mm"];;
    
    @weakify(self);
    [[_firstLikeBtn rac_signalForControlEvents:(UIControlEventTouchUpInside)] subscribeNext:^(__kindof UIControl * _Nullable x) {
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
        [BGCommunityApi likeThisComment:param succ:^(NSDictionary *response) {
            DLog(@"\n>>>[likeThisComment sucess]:%@",response);
             NSString *message = BGdictSetObjectIsNil(response[@"msg"]);
            if ([message isEqualToString:@"点赞成功！"]) {
                [self.firstLikeBtn setImage:BGImage(@"essay_bottom_like_green") forState:(UIControlStateNormal)];
                [self.firstLikeBtn setTitle:[NSString stringWithFormat:@"%d",model.review_like_count.intValue+1] forState:(UIControlStateNormal)];
                model.review_like_count = [NSString stringWithFormat:@"%d",model.review_like_count.intValue+1];
                [self.firstLikeBtn setTitleColor:kAppMainColor forState:(UIControlStateNormal)];
            }else{
                [self.firstLikeBtn setImage:BGImage(@"essay_bottom_like_white") forState:(UIControlStateNormal)];
                [self.firstLikeBtn setTitle:[NSString stringWithFormat:@"%d",model.review_like_count.intValue-1] forState:(UIControlStateNormal)];
                model.review_like_count = [NSString stringWithFormat:@"%d",model.review_like_count.intValue-1];
                [self.firstLikeBtn setTitleColor:kApp666Color forState:(UIControlStateNormal)];
            }
        } failure:^(NSDictionary *response) {
            DLog(@"\n>>>[likeThisComment failure]:%@",response);
        }];
    }];
    
    [[_userHomepageBtn rac_signalForControlEvents:(UIControlEventTouchUpInside)] subscribeNext:^(__kindof UIControl * _Nullable x) {
        @strongify(self);
        // 点击button的响应事件
        BGUserHomepageViewController *userVC = BGUserHomepageViewController.new;
        userVC.member_id = model.member_id;
        [self.navigationController pushViewController:userVC animated:YES];
    }];
    [[_replyBtn rac_signalForControlEvents:(UIControlEventTouchUpInside)] subscribeNext:^(__kindof UIControl * _Nullable x) {
        @strongify(self);
        // 点击button的响应事件
        if (![Tool isLogin]) {
            [WHIndicatorView toast:@"请先登录!"];
            [BGAppDelegateHelper showLoginViewController];
            return;
        }
        NSString *shzStr = BGGetUserDefaultObjectForKey(@"UserSHZ");
        NSString *str = [shzStr substringFromIndex:3];
        if ([str isEqualToString:model.member_id]) {
            [WHIndicatorView toast:@"不能回复自己的评论"];
            return;
        }
        self.isSInput = NO;
        [[[UIApplication sharedApplication] keyWindow] addSubview:self.backView];
        [[[UIApplication sharedApplication] keyWindow] addSubview:self.inputView];
        [self.inputTextField becomeFirstResponder];
    }];
    [self.tableView reloadData];
    
}
#pragma mark  -  TableViewDelegate  -
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return _cellDataArr.count;
}
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    BGEssayCommentOneCell *cell = [tableView dequeueReusableCellWithIdentifier:@"BGEssayCommentOneCell" forIndexPath:indexPath];
    if ([Tool arrayIsNotEmpty:_cellDataArr]) {
        BGEssayCommentSModel *sModel = _cellDataArr[indexPath.section];
        [cell updataWithCellArray:sModel];
        @weakify(self);
        [[[cell.sFirstUserBtn rac_signalForControlEvents:(UIControlEventTouchUpInside)] takeUntil:cell.rac_prepareForReuseSignal] subscribeNext:^(__kindof UIControl * _Nullable x) {
            @strongify(self);
            // 点击button的响应事件
            BGUserHomepageViewController *userVC = BGUserHomepageViewController.new;
            userVC.member_id = sModel.member_id;
            [self.navigationController pushViewController:userVC animated:YES];
        }];
        [[[[cell.sSUserBtn rac_signalForControlEvents:(UIControlEventTouchUpInside)] takeUntil:cell.rac_prepareForReuseSignal] takeUntil:cell.rac_prepareForReuseSignal] subscribeNext:^(__kindof UIControl * _Nullable x) {
            // 点击button的响应事件
            BGUserHomepageViewController *userVC = BGUserHomepageViewController.new;
            userVC.member_id = sModel.reply_member_id;
            [self.navigationController pushViewController:userVC animated:YES];
        }];
    }
    
    
    return cell;
}
-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    return 0.01;
}
-(CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section{
    return 0.01;
}
- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    return nil;
}
- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section{
    return nil;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
    
    if ([Tool arrayIsNotEmpty:_cellDataArr]) {
        if (![Tool isLogin]) {
            [WHIndicatorView toast:@"请先登录!"];
            [BGAppDelegateHelper showLoginViewController];
            return;
        }
       
        self.isSInput = YES;
        BGEssayCommentSModel *model = _cellDataArr[indexPath.section];
        self.nickNameStr = model.nickname;
        NSString *shzStr = BGGetUserDefaultObjectForKey(@"UserSHZ");
        NSString *str = [shzStr substringFromIndex:3];
        if ([str isEqualToString:model.member_id]) {
            [WHIndicatorView toast:@"不能回复自己的评论"];
            return;
        }
        self.sModel = model;
        [[[UIApplication sharedApplication] keyWindow] addSubview:self.backView];
        [[[UIApplication sharedApplication] keyWindow] addSubview:self.inputView];
        [self.inputTextField becomeFirstResponder];
    }
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
-(void)changeViewFrame{
    CGFloat height = self.viewHeight.constant;
    CGFloat allHeight = (SCREEN_HEIGHT-SafeAreaTopHeight-SafeAreaBottomHeight-6);
    if (height < allHeight) {
        self.contentCenterY.constant = 1;
    }else{
        self.contentCenterY.constant = (height-allHeight+1)*0.5;
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
    __weak __typeof(self) weakSelf = self;

    [UIView animateWithDuration:duration animations:^{
        weakSelf.backView.backgroundColor = [UIColor clearColor];
        weakSelf.inputView.y = SCREEN_HEIGHT+textViewHeight;
    } completion:^(BOOL finished) {
        [weakSelf.inputView removeFromSuperview];
        weakSelf.inputView = nil;
        [weakSelf.backView removeFromSuperview];
        weakSelf.backView = nil;
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
    
    if (_isSInput) {
        self.inputTextField.placeholder = [NSString stringWithFormat:@"  回复给 %@",self.nickNameStr];
    }else{
        self.inputTextField.placeholder = @"  请输入回复内容";
    }
    // 2.动画
    __weak __typeof(self) weakSelf = self;
    [UIView animateWithDuration:duration animations:^{
        weakSelf.backView.backgroundColor = [UIColor colorWithWhite:0 alpha:0.4];
         weakSelf.inputView.y = SCREEN_HEIGHT-keyboardH-textViewHeight;
    } completion:^(BOOL finished) {
        
    }];
}
-(void)replayActionWithBody:(NSString *)body{
    NSMutableDictionary *param = [[NSMutableDictionary alloc] init];
    [param setObject:body forKey:@"review_body"];
    if (_isSInput) {
        [param setObject:_sModel.review_id forKey:@"post_id"];
        [param setObject:_ID forKey:@"reply_review_id"];
        [param setObject:_sModel.member_id forKey:@"reply_member_id"];
        [param setObject:_type forKey:@"type"];
    }else{
        [param setObject:_fModel.post_id forKey:@"post_id"];
        [param setObject:_ID forKey:@"reply_review_id"];
        [param setObject:_fModel.member_id forKey:@"reply_member_id"];
        [param setObject:_type forKey:@"type"];
    }
    [ProgressHUDHelper showLoading];
    __weak __typeof(self) weakSelf = self;
    [BGCommunityApi AddComment:param succ:^(NSDictionary *response) {
         DLog(@"\n>>>[AddComment sucess]:%@",response);
        [weakSelf canaleCallBack];
        [weakSelf loadData];
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
