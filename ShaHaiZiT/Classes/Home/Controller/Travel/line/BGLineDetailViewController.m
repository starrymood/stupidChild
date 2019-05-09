//
//  BGLineDetailViewController.m
//  shzTravelC
//
//  Created by biao on 2018/8/29.
//  Copyright © 2018年 biao. All rights reserved.
//

#import "BGLineDetailViewController.h"
#import "BGAirApi.h"
#import <UIImageView+WebCache.h>
#import "BGCommunityApi.h"
#import "BGAirPriceCommentModel.h"
#import "BGHotLineModel.h"
#import "BGTravelCommentListViewController.h"
#import "XHStarRateView.h"
#import <JCAlertController.h>
#import "BGPickViewController.h"
#import "UITextField+BGLimit.h"
#import "FSCalendar.h"
#import "BGLineConfirmViewController.h"
#import <UMShare/UMShare.h>
#import <UShareUI/UShareUI.h>
#import <SDCycleScrollView.h>
#import "BGOrderTravelApi.h"
#import "BGLineSpotViewController.h"
#import "BGChatViewController.h"

#define CalendarViewHeight 248
#define CalendarViewY      (SCREEN_HEIGHT-CalendarViewHeight-SafeAreaBottomHeight)
@interface BGLineDetailViewController ()<UITextViewDelegate,pickViewDelegate,FSCalendarDelegate,FSCalendarDataSource,FSCalendarDelegateAppearance,UIWebViewDelegate>
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *contentCenterY;
@property (weak, nonatomic) IBOutlet SDCycleScrollView *cycleScrollView;
@property (weak, nonatomic) IBOutlet UILabel *titleeLabel;
@property (weak, nonatomic) IBOutlet UILabel *gradesLabel;
@property (weak, nonatomic) IBOutlet UIView *titleeView;
@property (weak, nonatomic) IBOutlet UITextView *subtitleTextView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *subtitleViewHeight;
@property (weak, nonatomic) IBOutlet UIImageView *cHeadImgView;
@property (weak, nonatomic) IBOutlet UILabel *cNickNameLabel;
@property (weak, nonatomic) IBOutlet UIImageView *cGradesImgView;
@property (weak, nonatomic) IBOutlet UITextView *cNoteView;
@property (weak, nonatomic) IBOutlet UILabel *cTimeLabel;
@property (weak, nonatomic) IBOutlet UIButton *selectAdultBtn;
@property (weak, nonatomic) IBOutlet UIButton *selectPackageBtn;
@property (weak, nonatomic) IBOutlet UIView *commentView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *commentViewHeight;
@property (weak, nonatomic) IBOutlet UIButton *commentNumBtn;
@property (weak, nonatomic) IBOutlet UIWebView *detailWebView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *lineViewHeight;
@property (weak, nonatomic) IBOutlet UIButton *selectDateBtn;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *dateViewTop;
@property (weak, nonatomic) IBOutlet UILabel *unsubscribeLabel;
@property (weak, nonatomic) IBOutlet UITextField *personNameTextField;
@property (weak, nonatomic) IBOutlet UITextField *personPhoneTextField;
@property (weak, nonatomic) IBOutlet UITextField *peopleNumTextField;
@property (weak, nonatomic) IBOutlet UITextField *packageNumTextField;
@property (weak, nonatomic) IBOutlet UILabel *unitPriceLabel;
@property (weak, nonatomic) IBOutlet UILabel *orderPriceLabel;
@property (weak, nonatomic) IBOutlet UITextView *noteTextView;
@property (weak, nonatomic) IBOutlet UIButton *payBtn;
@property (weak, nonatomic) IBOutlet UILabel *spotNameLabel;
@property (weak, nonatomic) IBOutlet UIImageView *spotImgView;
@property (weak, nonatomic) IBOutlet UILabel *spotTitleLabel;
@property (weak, nonatomic) IBOutlet UILabel *spotSubtitleLabel;
@property (weak, nonatomic) IBOutlet UIButton *spotBtn;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *webViewTopConstraint;
@property (weak, nonatomic) IBOutlet UIView *spotTitleView;
@property (weak, nonatomic) IBOutlet UIView *spotContentView;
@property (weak, nonatomic) IBOutlet UIButton *connectServiceBtn;
@property (weak, nonatomic) IBOutlet UIButton *collectionBtn;
@property (weak, nonatomic) IBOutlet UIButton *unsubscribeBtn;

@property (nonatomic, strong) BGHotLineModel *fModel;
@property (nonatomic, strong) UILabel *placeholderLabel;
@property (nonatomic, assign) int selectType;
@property (nonatomic, strong) FSCalendar *calendar;                // 日历控件
@property(strong, nonatomic) NSCalendar *gregorianCalendar;
@property (nonatomic, strong) UIView *backView;
@property (nonatomic, copy) NSString *timeStampStr;

@end

@implementation BGLineDetailViewController
-(UIView *)backView{
    if (!_backView) {
        self.backView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT)];
        _backView.backgroundColor = [UIColor clearColor];
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(canaleCallBack)];
        [_backView addGestureRecognizer:tap];
    }
    return _backView;
}
- (FSCalendar *)calendar {
    if (!_calendar) {
        _calendar = [[FSCalendar alloc] initWithFrame:CGRectMake(0, SCREEN_HEIGHT, SCREEN_WIDTH, CalendarViewHeight)];
        _calendar.dataSource = self;
        _calendar.delegate = self;
        _calendar.backgroundColor = [UIColor whiteColor];
        
        self.gregorianCalendar = [NSCalendar calendarWithIdentifier:NSCalendarIdentifierGregorian];
        
        _calendar.firstWeekday = 1;     //设置周日为第一天 周一:设为2
        _calendar.appearance.weekdayTextColor = kApp999Color;  //星期字体颜色:"一 二 三"
        _calendar.appearance.headerTitleColor = kApp333Color;    //头部字体颜色:"2018年 05月"
        _calendar.appearance.headerMinimumDissolvedAlpha = 0.0;    //上、下月标签静止时透明度
        _calendar.appearance.headerDateFormat = @"yyyy年 MM月";     //头部日期显示格式
        _calendar.appearance.borderRadius = 1.0;                   // 设置当前选择是圆形,0.0是正方形
        NSLocale *locale = [[NSLocale alloc] initWithLocaleIdentifier:@"zh_CN"];//设置为中文
        _calendar.locale = locale;  // 设置周次是中文显示
        _calendar.appearance.caseOptions = FSCalendarCaseOptionsWeekdayUsesSingleUpperCase;  // 设置周次为一,二 可选"周一 周二"
        _calendar.appearance.titleWeekendColor = kAppRedColor;      //周末字体颜色
        _calendar.appearance.selectionColor = kAppMainColor;    //选中背景颜色
        _calendar.today = nil;
        _calendar.placeholderType = FSCalendarPlaceholderTypeFillSixRows;
        
        //创建点击跳转显示上一月和下一月button
        UIButton *previousButton = [UIButton buttonWithType:UIButtonTypeCustom];
        previousButton.frame = CGRectMake(SCREEN_WIDTH/2-45-90, 10, 80, 20);
        previousButton.titleLabel.font = [UIFont systemFontOfSize:18];
        [previousButton setTitle:@"<" forState:UIControlStateNormal];
        [previousButton setTitleColor:kApp999Color forState:UIControlStateNormal];
        previousButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentRight;
        @weakify(self);
        [[previousButton rac_signalForControlEvents:(UIControlEventTouchUpInside)] subscribeNext:^(__kindof UIControl * _Nullable x) {
            @strongify(self);
            //上一月按钮点击事件
            NSDate *currentMonth = self.calendar.currentPage;
            NSDate *previousMonth = [self.gregorianCalendar dateByAddingUnit:NSCalendarUnitMonth value:-1 toDate:currentMonth options:0];
            [self.calendar setCurrentPage:previousMonth animated:YES];
        }];
        [self.calendar addSubview:previousButton];
        
        UIButton *nextButton = [UIButton buttonWithType:UIButtonTypeCustom];
        nextButton.frame = CGRectMake(SCREEN_WIDTH/2+55, 10, 80, 20);
        nextButton.titleLabel.font = [UIFont systemFontOfSize:18];
        [nextButton setTitle:@">" forState:UIControlStateNormal];
        nextButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
        [nextButton setTitleColor:kApp333Color forState:UIControlStateNormal];
        
        [[nextButton rac_signalForControlEvents:(UIControlEventTouchUpInside)] subscribeNext:^(__kindof UIControl * _Nullable x) {
            @strongify(self);
            //下一月按钮点击事件
            NSDate *currentMonth = self.calendar.currentPage;
            NSDate *nextMonth = [self.gregorianCalendar dateByAddingUnit:NSCalendarUnitMonth value:1 toDate:currentMonth options:0];
            [self.calendar setCurrentPage:nextMonth animated:YES];
        }];
        [_calendar addSubview:nextButton];
        
    }
    return _calendar;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self loadSubViews];
    [self loadData];
}
-(void)loadSubViews{
    self.navigationItem.title = @"线路详情";
    self.view.backgroundColor = kAppBgColor;
    self.selectDateBtn.layer.borderWidth = 1.0;
    self.selectDateBtn.layer.borderColor = kAppMainColor.CGColor;
    self.selectDateBtn.layer.cornerRadius = 3.0;
    self.personNameTextField.maxLenght = 30;
    self.personPhoneTextField.maxLenght = 20;
    self.personPhoneTextField.digitsChars = @[@"0",@"1",@"2",@"3",@"4",@"5",@"6",@"7",@"8",@"9"];
    self.placeholderLabel = [[UILabel alloc] initWithFrame:CGRectMake(3, 3, SCREEN_WIDTH-20-6, 25)];
    _placeholderLabel.enabled = NO;
    _placeholderLabel.text = @"有特别要求您可以在此填写备注";
    _placeholderLabel.numberOfLines = 0;
    _placeholderLabel.font = kFont(14);
    _placeholderLabel.textColor = kApp999Color;
    [_noteTextView addSubview:_placeholderLabel];
    
    self.selectType = 0;
   [self changeViewFrame];
}
-(void)loadData{
    [ProgressHUDHelper showLoading];
    NSMutableDictionary *param = [[NSMutableDictionary alloc] init];
    [param setObject:_product_id forKey:@"product_id"];
    __weak __typeof(self) weakSelf = self;
    [BGAirApi getCarInfoById:param succ:^(NSDictionary *response) {
        DLog(@"\n>>>[getCarInfoById sucess]:%@",response);
        [weakSelf hideNodateView];
        BGHotLineModel *model = [BGHotLineModel mj_objectWithKeyValues:BGdictSetObjectIsNil(response[@"result"])];
        weakSelf.fModel = model;
        [weakSelf updateSubViewsWithModel:model];
    } failure:^(NSDictionary *response) {
        DLog(@"\n>>>[getCarInfoById failure]:%@",response);
        [ProgressHUDHelper removeLoading];
        [self shownoNetWorkViewWithType:0];
        [self setRefreshBlock:^{
            [weakSelf loadData];
        }];
    }];
    
}

-(void)updateSubViewsWithModel:(BGHotLineModel *)model{
    
    self.selectDateBtn.userInteractionEnabled = YES;
    self.selectAdultBtn.userInteractionEnabled = YES;
    self.selectPackageBtn.userInteractionEnabled = YES;
    self.unsubscribeBtn.userInteractionEnabled = YES;
    self.connectServiceBtn.userInteractionEnabled = YES;
    self.payBtn.userInteractionEnabled = YES;
    
    @weakify(self);
    [[self.unsubscribeBtn rac_signalForControlEvents:(UIControlEventTouchUpInside)] subscribeNext:^(__kindof UIControl * _Nullable x) {
        @strongify(self);
        // 点击button的响应事件
        CGFloat width = [JCAlertStyle shareStyle].alertView.width;
        UIWebView *webView = [[UIWebView alloc] initWithFrame:CGRectMake(0, 0, width, SCREEN_HEIGHT*0.6)];
        webView.backgroundColor = kAppWhiteColor;
        [webView loadHTMLString:[Tool attributeByWeb:model.unsubscribe_content width:width scale:width*0.96] baseURL:nil];
        JCAlertController *alert = [JCAlertController alertWithTitle:@"退订政策" contentView:webView];
        JCAlertStyle *style = [JCAlertStyle shareStyle];
        style.background.canDismiss = YES;
        [alert addButtonWithTitle:@"确定" type:JCButtonTypeNormal clicked:^{
            
        }];
        [self presentViewController:alert animated:YES completion:nil];
    }];
    [[self.connectServiceBtn rac_signalForControlEvents:(UIControlEventTouchUpInside)] subscribeNext:^(__kindof UIControl * _Nullable x) {
        @strongify(self);
        // 点击button的响应事件
        if (![Tool isLogin]) {
            [WHIndicatorView toast:@"请先登录!"];
            [BGAppDelegateHelper showLoginViewController];
            return;
        }
        BGChatViewController *conversationVC = [[BGChatViewController alloc]init];
        conversationVC.conversationType = ConversationType_PRIVATE;
        
        conversationVC.targetId = [NSString stringWithFormat:@"%@",model.service_id];
        conversationVC.title = [NSString stringWithFormat:@"%@",model.service_name];
        [self.navigationController pushViewController:conversationVC animated:YES];
    }];
    
    UIButton *shareBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [shareBtn setImage:BGImage(@"travel_share_green") forState:UIControlStateNormal];
    [shareBtn setImage:BGImage(@"travel_share_green") forState:UIControlStateHighlighted];
     shareBtn.bounds = CGRectMake(0, 0, 70, 30);
    shareBtn.contentEdgeInsets = UIEdgeInsetsZero;
   shareBtn.contentHorizontalAlignment = UIControlContentHorizontalAlignmentRight;
    UIBarButtonItem *shareItem = [[UIBarButtonItem alloc] initWithCustomView:shareBtn];
    self.navigationItem.rightBarButtonItem = shareItem;

    self.collectionBtn.userInteractionEnabled = YES;
     NSString *collectionStr = (model.is_collect.intValue == 1) ? @"home_shopBar_collectioned":@"home_shopBar_collection";
    [self.collectionBtn setImage:BGImage(collectionStr) forState:UIControlStateNormal];
    [self.collectionBtn setImage:BGImage(collectionStr) forState:UIControlStateHighlighted];
    
    [[shareBtn rac_signalForControlEvents:(UIControlEventTouchUpInside)] subscribeNext:^(__kindof UIControl * _Nullable x) {
        @strongify(self);
        // 点击button的响应事件
        [self showShareAction];
    }];

    [[self.collectionBtn rac_signalForControlEvents:(UIControlEventTouchUpInside)] subscribeNext:^(__kindof UIControl * _Nullable x) {
        @strongify(self);
        // 点击button的响应事件
        {
            if (![Tool isLogin]) {
                [WHIndicatorView toast:@"请先登录!"];
                [BGAppDelegateHelper showLoginViewController];
                return;
            }
            [ProgressHUDHelper showLoading];
            NSMutableDictionary *param = [[NSMutableDictionary alloc] init];
            [param setObject:self.product_id forKey:@"collect_id"];
            [param setObject:@"5" forKey:@"category"];
            // 点击button的响应事件
            __weak typeof(self) weakSelf = self;
            [BGAirApi addAndCancelFavoriteAction:param succ:^(NSDictionary *response) {
                DLog(@"\n>>>[cancelFavoriteAction success]:%@",response);
                if (model.is_collect.intValue == 1) {
                    [WHIndicatorView toast:@"取消收藏"];
                    model.is_collect = @"0";
                }else{
                    [WHIndicatorView toast:@"已收藏"];
                    model.is_collect = @"1";
                }
                NSString *collectionStr = (model.is_collect.intValue == 1) ? @"home_shopBar_collectioned":@"home_shopBar_collection";
                [weakSelf.collectionBtn setImage:BGImage(collectionStr) forState:UIControlStateNormal];
                [weakSelf.collectionBtn setImage:BGImage(collectionStr) forState:UIControlStateHighlighted];
            } failure:^(NSDictionary *response) {
                DLog(@"\n>>>[cancelFavoriteAction failure]:%@",response);
            }];
        }
    }];
    
    
    self.titleeLabel.text = model.product_name;
    XHStarRateView *starView = [[XHStarRateView alloc] initWithFrame:CGRectMake(SCREEN_WIDTH-95, 15, 80, 13)];
    starView.rateStyle = IncompleteStar;
    starView.userInteractionEnabled = NO;
    [self.titleeView addSubview:starView];
    [starView setCurrentScore:model.recommended.floatValue];

//    self.cycleScrollView.bannerImageViewContentMode = UIViewContentModeScaleAspectFit;
    self.cycleScrollView.pageControlAliment = SDCycleScrollViewPageContolAlimentCenter;
    self.cycleScrollView.backgroundColor = kAppBgColor;
    self.cycleScrollView.imageURLStringsGroup = model.car_pictures;
    self.gradesLabel.text = [NSString stringWithFormat:@"%.1f分",model.recommended.doubleValue];
    
    if ([Tool arrayIsNotEmpty:model.product_schedule]) {
        self.spotNameLabel.text = BGdictSetObjectIsNil(model.product_schedule[0][@"title"]);
        if ([Tool arrayIsNotEmpty:BGdictSetObjectIsNil(model.product_schedule[0][@"children"])]) {
            NSDictionary *spotDic = BGdictSetObjectIsNil(model.product_schedule[0][@"children"][0]);
            [self.spotImgView sd_setImageWithURL:[NSURL URLWithString:spotDic[@"main_picture"]]];
            self.spotTitleLabel.text = spotDic[@"spot_name"];
            self.spotSubtitleLabel.text = spotDic[@"spot_content"];
            @weakify(self);
            [[self.spotBtn rac_signalForControlEvents:(UIControlEventTouchUpInside)] subscribeNext:^(__kindof UIControl * _Nullable x) {
                @strongify(self);
                // 点击button的响应事件
                BGLineSpotViewController *spotVC = BGLineSpotViewController.new;
                spotVC.spot_id = [NSString stringWithFormat:@"%@",spotDic[@"id"]];
                spotVC.navigationItem.title = self.spotTitleLabel.text;
                [self.navigationController pushViewController:spotVC animated:YES];
            }];
        }
    }else{
        self.spotTitleView.hidden = YES;
        self.spotContentView.hidden = YES;
        self.webViewTopConstraint.constant = 6;
    }
    
    if (model.review_count.integerValue > 0) {
        self.commentNumBtn.userInteractionEnabled = YES;
    }
    _commentNumBtn.contentHorizontalAlignment = UIControlContentHorizontalAlignmentRight;
   
    [_commentNumBtn setTitle:[NSString stringWithFormat:@"%@条评价 >",model.review_count] forState:(UIControlStateNormal)];
    [[_commentNumBtn rac_signalForControlEvents:(UIControlEventTouchUpInside)] subscribeNext:^(__kindof UIControl * _Nullable x) {
        @strongify(self);
        // 点击button的响应事件
        BGTravelCommentListViewController *listVC = BGTravelCommentListViewController.new;
        listVC.product_id = self.product_id;
        [self.navigationController pushViewController:listVC animated:YES];
    }];
    if ([Tool arrayIsNotEmpty:model.review_list]) {
        BGAirPriceCommentModel *cModel = [BGAirPriceCommentModel mj_objectWithKeyValues:model.review_list[0]];
        [_cHeadImgView sd_setImageWithURL:[NSURL URLWithString:cModel.face] placeholderImage:BGImage(@"defaultUserIcon")];
        _cNickNameLabel.text = cModel.nickname;
        
        _cTimeLabel.text = [Tool dateFormatter:cModel.create_time.doubleValue dateFormatter:@"yyyy.MM.dd"];
        NSArray *starNameArr = @[@"comment_star_one",@"comment_star_two",@"comment_star_three",@"comment_star_four",@"comment_star_five"];
        if (starNameArr.count>cModel.satisfaction_level.intValue-1) {
            [_cGradesImgView setImage:BGImage(starNameArr[cModel.satisfaction_level.intValue-1])];
        }
        _cNoteView.text = cModel.content;
        
        self.commentViewHeight.constant = [self heightForString:self.cNoteView andWidth:SCREEN_WIDTH-42]+49+36;
        self.dateViewTop.constant = self.commentViewHeight.constant+6+6;
    }else{
        [self.commentView removeFromSuperview];
        self.dateViewTop.constant = 6;
    }

    [_detailWebView loadHTMLString:[Tool attributeByWeb:model.product_content width:SCREEN_WIDTH-20 scale:SCREEN_WIDTH*0.96] baseURL:nil];
    _detailWebView.delegate = self;
    self.subtitleTextView.text = model.product_introduction;
    self.subtitleViewHeight.constant = [self heightForString:self.subtitleTextView andWidth:SCREEN_WIDTH-99]+5;
     self.unsubscribeLabel.text = model.unsubscribe_title;
    self.unitPriceLabel.text = [NSString stringWithFormat:@"%@元",model.product_price];
    self.orderPriceLabel.text = [NSString stringWithFormat:@"%@元",model.product_price];
    [self changeViewFrame];
    
    [[self.selectDateBtn rac_signalForControlEvents:(UIControlEventTouchUpInside)] subscribeNext:^(__kindof UIControl * _Nullable x) {
        @strongify(self);
        // 点击button的响应事件
        [self keyboarkHidden];
        [self showCalendarViewAction];
    }];
    [[self.selectAdultBtn rac_signalForControlEvents:(UIControlEventTouchUpInside)] subscribeNext:^(__kindof UIControl * _Nullable x) {
        @strongify(self);
        // 点击button的响应事件
        [self keyboarkHidden];
        self.selectType = 1;
        BGPickViewController *pick = [[BGPickViewController alloc] initWithNibName:@"BGPickViewController" bundle:nil];
        pick.delegate = self;
        NSMutableArray *arr = [NSMutableArray array];
        for (int i = 1; i<self.fModel.passenger_number.intValue+1; i++) {
            NSString *str = [NSString stringWithFormat:@"%d人",i];
            [arr addObject:str];
        }
        pick.arry = arr;
        pick.modalPresentationStyle = UIModalPresentationCustom;
        
        [self presentViewController:pick animated:YES completion:nil];
    }];
    [[self.selectPackageBtn rac_signalForControlEvents:(UIControlEventTouchUpInside)] subscribeNext:^(__kindof UIControl * _Nullable x) {
        @strongify(self);
        // 点击button的响应事件
        [self keyboarkHidden];
        self.selectType = 3;
        BGPickViewController *pick = [[BGPickViewController alloc] initWithNibName:@"BGPickViewController" bundle:nil];
        pick.delegate = self;
        NSMutableArray *arr = [NSMutableArray array];
        for (int i = 0; i<self.fModel.baggage_number.intValue+1; i++) {
            NSString *str = [NSString stringWithFormat:@"%d个",i];
            [arr addObject:str];
        }
        pick.arry = arr;
        pick.modalPresentationStyle = UIModalPresentationCustom;
        
        [self presentViewController:pick animated:YES completion:nil];
    }];
    [[self.payBtn rac_signalForControlEvents:(UIControlEventTouchUpInside)] subscribeNext:^(__kindof UIControl * _Nullable x) {
        @strongify(self);
        // 点击button的响应事件
        [self uploadInfoAction:x];
    }];
}
-(void)uploadInfoAction:(UIButton *)sender{
    [self keyboarkHidden];
    
    if (![Tool isLogin]) {
        [WHIndicatorView toast:@"请先登录!"];
        [BGAppDelegateHelper showLoginViewController];
        return;
    }
    if ([Tool isBlankString:_timeStampStr]) {
        [WHIndicatorView toast:@"请选择行程日期"];
        return;
    }
    if (_personNameTextField.text.length<1) {
        [WHIndicatorView toast:@"请填写联系人姓名"];
        return;
    }
    if (_personPhoneTextField.text.length<1) {
        [WHIndicatorView toast:@"请填写联系人电话"];
        return;
    }
    if (_peopleNumTextField.text.length<1) {
        [WHIndicatorView toast:@"请选择成人数"];
        return;
    }
    if (_packageNumTextField.text.length<1) {
        [WHIndicatorView toast:@"请选择行李数"];
        return;
    }

    if (_noteTextView.text.length<1) {
        _noteTextView.text = @"";
    }

    NSString *adultNum = [_peopleNumTextField.text substringWithRange:NSMakeRange(0, [_peopleNumTextField.text length] - 1)];
    NSString *packageNum = [_packageNumTextField.text substringWithRange:NSMakeRange(0, [_packageNumTextField.text length] - 1)];

    NSMutableDictionary *param = [[NSMutableDictionary alloc] init];
    [param setObject:_product_id forKey:@"product_id"];
    [param setObject:_timeStampStr forKey:@"start_time"];
    [param setObject:adultNum forKey:@"audit_number"];
    [param setObject:packageNum forKey:@"baggage_number"];
    [param setObject:_personNameTextField.text forKey:@"contact"];
    [param setObject:_personPhoneTextField.text forKey:@"contact_number"];
    [param setObject:_noteTextView.text forKey:@"remark"];
    // @@@
//    NSString *timeStampStr = [Tool timeString:@"2018-12-11 11:11" withFormatte:@"YYYY-MM-dd HH:mm"];
//    NSMutableDictionary *param = [[NSMutableDictionary alloc] init];
//    [param setObject:_product_id forKey:@"product_id"];
//    [param setObject:timeStampStr forKey:@"start_time"];
//    [param setObject:@"3" forKey:@"audit_number"];
//    [param setObject:@"1" forKey:@"baggage_number"];
//    [param setObject:@"彪哥" forKey:@"contact"];
//    [param setObject:@"15515916027" forKey:@"contact_number"];
//    [param setObject:@"飞雪连天射白鹿,笑书神侠倚碧鸳.京东包车景点简介京东包车景点简介京东包车景点简介 京东包车景点简介京东包车景点简介京东包车景点简介 京东包车景点简介京东包车景 拷贝" forKey:@"remark"];
    
    sender.userInteractionEnabled = NO;
    __weak __typeof(self) weakSelf = self;
    [ProgressHUDHelper showLoading];
    [BGOrderTravelApi uploadPreInfo:param succ:^(NSDictionary *response) {
        DLog(@"\n>>>[uploadPreInfo sucess]:%@",response);
        BGLineConfirmViewController *payVC = BGLineConfirmViewController.new;
        payVC.order_number = [NSString stringWithFormat:@"%@",BGdictSetObjectIsNil(response[@"result"][@"order_number"])];
        [weakSelf.navigationController pushViewController:payVC animated:YES];
        sender.userInteractionEnabled = YES;
    } failure:^(NSDictionary *response) {
        DLog(@"\n>>>[uploadPreInfo failure]:%@",response);
        sender.userInteractionEnabled = YES;
    }];
    
}
-(void)changeViewFrame{
    self.contentCenterY.constant = (_payBtn.y+_payBtn.height+self.subtitleViewHeight.constant+self.lineViewHeight.constant-SCREEN_HEIGHT+SafeAreaTopHeight+SafeAreaBottomHeight-50)*0.5;
    
}
- (float)heightForString:(UITextView *)textView andWidth:(float)width{
    CGSize sizeToFit = [textView sizeThatFits:CGSizeMake(width, MAXFLOAT)];
    return sizeToFit.height;
}
#pragma mark - UITextView -
-(void)textViewDidChange:(UITextView *)textView
{
    if ([textView.text length] == 0) {
        [_placeholderLabel setHidden:NO];
    }else{
        [_placeholderLabel setHidden:YES];
    }
    if (textView.text.length > 500) {
        [WHIndicatorView toast:@"请输入小于500个文字"];
        NSString *s = [textView.text substringToIndex:500];
        textView.text = s;
    }
}
-(void)getTextStr:(NSString *)text{
    switch (_selectType) {
        case 1:{
            // 改为订单价格==单价 @@
            _peopleNumTextField.text = text;
//            NSString *adultNum = [text substringWithRange:NSMakeRange(0, [text length] - 1)];
//            self.orderPriceLabel.text = [NSString stringWithFormat:@"%.2f元",_fModel.product_price.doubleValue*adultNum.intValue];
        }
            break;
        case 3:{
            _packageNumTextField.text = text;
        }
            break;
            
        default:
            break;
    }
}

/**
 显示日历选择器
 */
-(void)showCalendarViewAction{
    [[[UIApplication sharedApplication] keyWindow] addSubview:self.backView];
    [[[UIApplication sharedApplication] keyWindow] addSubview:self.calendar];
    __block typeof(self) weakSelf = self;
    [UIView transitionWithView:self.backView duration:0.3 options:0 animations:^{
        weakSelf.backView.backgroundColor = [UIColor colorWithWhite:0 alpha:0.4];
        weakSelf.calendar.y = CalendarViewY;
    } completion:nil];
}
/**
 隐藏日历界面
 */
- (void)canaleCallBack{
    __block typeof(self) weakSelf = self;
    [UIView transitionWithView:self.backView duration:0.3 options:0 animations:^{
        weakSelf.backView.backgroundColor = [UIColor clearColor];
        weakSelf.calendar.y = SCREEN_HEIGHT;
    } completion:^(BOOL finished) {
        [weakSelf.calendar removeFromSuperview];
        weakSelf.calendar = nil;
        [weakSelf.backView removeFromSuperview];
        weakSelf.backView = nil;
    }];
}

#pragma mark - FSCalendarDataSource

- (NSDate *)minimumDateForCalendar:(FSCalendar *)calendar
{
    return [self.gregorianCalendar dateByAddingUnit:NSCalendarUnitMonth value:0 toDate:[NSDate date] options:0];
}

- (NSDate *)maximumDateForCalendar:(FSCalendar *)calendar
{
    return [self.gregorianCalendar dateByAddingUnit:NSCalendarUnitMonth value:5 toDate:[NSDate date] options:0];
}

- (NSString *)calendar:(FSCalendar *)calendar titleForDate:(NSDate *)date
{
    if ([self.gregorianCalendar isDateInToday:date]) {
        return @"今天";
    }
    return nil;
}

#pragma mark - FSCalendarDelegate

- (BOOL)calendar:(FSCalendar *)calendar shouldSelectDate:(NSDate *)date atMonthPosition:(FSCalendarMonthPosition)monthPosition
{
    return monthPosition == FSCalendarMonthPositionNext || FSCalendarMonthPositionCurrent;
}

- (void)calendar:(FSCalendar *)calendar didSelectDate:(NSDate *)date atMonthPosition:(FSCalendarMonthPosition)monthPosition
{
    if (monthPosition == FSCalendarMonthPositionNext || monthPosition == FSCalendarMonthPositionPrevious) {
        [calendar setCurrentPage:date animated:YES];
    }
    
    NSTimeInterval timeStamp = [date timeIntervalSince1970]*1000;
    self.timeStampStr = [NSString stringWithFormat:@"%.f",timeStamp/1000];
    NSString *timeStr = [Tool dateFormatter:_timeStampStr.doubleValue dateFormatter:@"yyyy-MM-dd"];
    [_selectDateBtn setTitle:timeStr forState:(UIControlStateNormal)];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self canaleCallBack];
        
    });
}
#pragma mark - clickedShareItem

-(void)showShareAction {
    
    [UMSocialUIManager setPreDefinePlatforms:@[@(UMSocialPlatformType_WechatSession),@(UMSocialPlatformType_WechatTimeLine),@(UMSocialPlatformType_QQ),@(UMSocialPlatformType_Qzone),@(UMSocialPlatformType_Sina)]];
    
    [UMSocialUIManager showShareMenuViewInWindowWithPlatformSelectionBlock:^(UMSocialPlatformType platformType, NSDictionary *userInfo) {
            // 根据获取的platformType确定所选平台进行下一步操作
            [self doShareTitle:self.fModel.product_name description:self.fModel.product_introduction image:[UIImage imageNamed:@"applogo"] url:[NSString stringWithFormat:@"%@login.html?icode=%@",BGWebMainHtml,BGGetUserDefaultObjectForKey(@"inviteCode")] shareType:(platformType)];
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
-(void)webViewDidFinishLoad:(UIWebView *)webView{
    //HTML5的高度
    NSString *htmlHeight = [webView stringByEvaluatingJavaScriptFromString:@"document.body.scrollHeight"];
    if ([htmlHeight isEqualToString:@"2000"]) {
        self.lineViewHeight.constant = 47;
    }else{
        self.lineViewHeight.constant = [htmlHeight floatValue];
    }
    self.contentCenterY.constant = (_payBtn.y+_payBtn.height+self.lineViewHeight.constant-SCREEN_HEIGHT+SafeAreaTopHeight+SafeAreaBottomHeight-2000)*0.5;
    [UIView animateWithDuration:.2 animations:^{
        [self.view layoutIfNeeded];

    } completion:^(BOOL finished) {

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
