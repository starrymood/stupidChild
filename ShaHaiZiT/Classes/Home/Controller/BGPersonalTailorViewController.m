//
//  BGPersonalTailorViewController.m
//  shzTravelC
//
//  Created by biao on 2018/8/2.
//  Copyright © 2018年 biao. All rights reserved.
//

#import "BGPersonalTailorViewController.h"
#import "FSCalendar.h"
#import "BGAirApi.h"
#import <UIImageView+WebCache.h>
#import "BGMineCustomTwoCell.h"
#import "BGPickViewController.h"
#import "BGAreaSelectViewController.h"
#import "BGChatViewController.h"
#import "BGOrderTravelApi.h"
#import "BGChatViewController.h"

#define CalendarViewHeight 248
#define CalendarViewY      (SCREEN_HEIGHT-CalendarViewHeight-SafeAreaBottomHeight)
#define BGFormat(appendix) [NSString stringWithFormat:@"%@",appendix]
@interface BGPersonalTailorViewController ()<UITableViewDataSource, UITableViewDelegate,FSCalendarDelegate,FSCalendarDataSource,FSCalendarDelegateAppearance,pickViewDelegate,UITextViewDelegate>

@property (nonatomic, strong) FSCalendar *calendar;                // 日历控件
@property(strong, nonatomic) NSCalendar *gregorianCalendar;
@property (nonatomic, strong) UIView *backView;
@property (nonatomic, copy) NSString *timeStampStr;

@property (nonatomic, strong) UITableView *tableView;

@property (nonatomic, copy) NSArray *travelArr;

@property (nonatomic, copy) NSArray *stayArr;

@property (nonatomic, copy) NSArray *repastArr;

@property (nonatomic, strong) UIImageView *headImgView;

@property (nonatomic, strong) UIView *headerView;

@property (nonatomic, strong) NSMutableArray *saveDataArr;

@property (nonatomic, assign) NSInteger selectIndex;

@property (nonatomic, strong) NSMutableArray *tempArr;

@property (nonatomic, strong) UILabel *placeholderLabel;

@property (nonatomic, copy) NSString *service_id;

@property (nonatomic, copy) NSString *service_name;

@property(nonatomic,copy) NSString *country_name;
@property(nonatomic,copy) NSString *country_id;
@property(nonatomic,copy) NSString *region_name;
@property(nonatomic,copy) NSString *region_id;

@end

@implementation BGPersonalTailorViewController
-(NSMutableArray *)tempArr{
    if (!_tempArr) {
        self.tempArr = [NSMutableArray array];
    }
    return _tempArr;
}
-(NSMutableArray *)saveDataArr{
    if (!_saveDataArr) {
        self.saveDataArr = [NSMutableArray array];
    }
    return _saveDataArr;
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
-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    self.navigationController.navigationBarHidden = NO;
}
- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self loadSubViews];
    [self loadData];
}
- (void)loadSubViews{
    self.view.backgroundColor = kAppBgColor;
    self.navigationItem.title = @"私人订制";
    self.selectIndex = 0;
    self.saveDataArr = @[@"",      // 出行时间
                         @"",      // 目的地
                         @"",      // 游玩天数
                         @"",      // 出行偏好
                         @"",      // 餐饮偏好
                         @"",      // 游客人数
                         @"",      // 备注
                         @""      // 住宿偏好
                         ].mutableCopy;
    self.country_id = @"";
    self.country_name = @"";
    self.region_id = @"";
    self.region_name = @"";
    
    self.headerView = UIView.new;
    _headerView.frame = CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_WIDTH+6+10);
    _headerView.backgroundColor = kAppBgColor;
    
    self.headImgView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 6, SCREEN_WIDTH, SCREEN_WIDTH)];
    [_headImgView setImage:BGImage(@"img_cycle_placeholder")];
    [_headerView addSubview:_headImgView];
    
    self.tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, SafeAreaTopHeight, SCREEN_WIDTH, SCREEN_HEIGHT-SafeAreaTopHeight-SafeAreaBottomHeight) style:(UITableViewStyleGrouped)];
    _tableView.backgroundColor = kAppBgColor;
    _tableView.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
    _tableView.separatorColor = kAppBgColor;
    _tableView.tableHeaderView = _headerView;
    _tableView.dataSource = self;
    _tableView.delegate = self;
    [self.view addSubview:_tableView];
    
    UIView *footerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, 200)];
    footerView.backgroundColor = kAppBgColor;
    UIView *inputView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, 100)];
    inputView.backgroundColor = kAppWhiteColor;
    [footerView addSubview:inputView];
    UITextView *textView = [[UITextView alloc] initWithFrame:CGRectMake(10, 8, SCREEN_WIDTH-20, 90)];
    textView.delegate = self;
    textView.backgroundColor = kAppWhiteColor;
    textView.font = kFont(14);
    textView.textAlignment = NSTextAlignmentLeft;
    [inputView addSubview:textView];
    
    UIButton *sureBtn = [UIButton buttonWithType:(UIButtonTypeCustom)];
    sureBtn.frame = CGRectMake((SCREEN_WIDTH-183)*0.5, 130, 183, 41);
    sureBtn.clipsToBounds = YES;
    [sureBtn setBackgroundImage:BGImage(@"btn_bgColor") forState:(UIControlStateNormal)];
    sureBtn.layer.cornerRadius = 41*0.5;
    [sureBtn.titleLabel setFont:kFont(16)];
    [sureBtn setTitle:@"定制行程" forState:(UIControlStateNormal)];
    [sureBtn setTitleColor:kAppWhiteColor forState:(UIControlStateNormal)];
    [sureBtn addTarget:self action:@selector(uploadInfoAction:) forControlEvents:(UIControlEventTouchUpInside)];
    [footerView addSubview:sureBtn];
    
    
    self.placeholderLabel = [[UILabel alloc] initWithFrame:CGRectMake(3, 3, SCREEN_WIDTH-20-6, 25)];
    _placeholderLabel.enabled = NO;
    _placeholderLabel.text = @"备注";
    _placeholderLabel.numberOfLines = 0;
    _placeholderLabel.font = kFont(14);
    _placeholderLabel.textColor = kApp999Color;
    [textView addSubview:_placeholderLabel];
    
    self.tableView.tableFooterView = footerView;
    
    // 注册cell
    [_tableView registerNib:[UINib nibWithNibName:@"BGMineCustomTwoCell" bundle:nil] forCellReuseIdentifier:@"BGMineCustomTwoCell"];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(selectedCityTipsNotif:) name:@"SelectedCityTipsNotif" object:nil];
}
-(void)uploadInfoAction:(UIButton *)sender{
    [self keyboarkHidden];
    if ([Tool isBlankString:_saveDataArr[0]]) {
        [WHIndicatorView toast:@"请选择出行时间"];
        return;
    }
    if ([Tool isBlankString:_saveDataArr[1]]) {
        [WHIndicatorView toast:@"请输入目的地"];
        return;
    }
    if ([Tool isBlankString:_saveDataArr[2]]) {
        [WHIndicatorView toast:@"请输入游玩天数"];
        return;
    }
    if ([Tool isBlankString:_saveDataArr[3]]) {
        [WHIndicatorView toast:@"请选择出行偏好"];
        return;
    }
    if ([Tool isBlankString:_saveDataArr[4]]) {
        [WHIndicatorView toast:@"请选择餐馆偏好"];
        return;
    }
    if ([Tool isBlankString:_saveDataArr[5]]) {
        [WHIndicatorView toast:@"请选择住宿偏好"];
        return;
    }
        sender.userInteractionEnabled = NO;
    NSString *play_days = [_saveDataArr[2] substringWithRange:NSMakeRange(0, [_saveDataArr[2] length] - 1)];
    NSString *peopleNum = [_saveDataArr[5] substringWithRange:NSMakeRange(0, [_saveDataArr[5] length] - 1)];
    NSMutableDictionary *param = [[NSMutableDictionary alloc] init];
    [param setObject:_timeStampStr forKey:@"start_time"];
    [param setObject:_saveDataArr[1] forKey:@"destination"];
    [param setObject:play_days forKey:@"play_days"];
    [param setObject:_saveDataArr[3] forKey:@"travel_preference"];
    [param setObject:_saveDataArr[4] forKey:@"food_preference"];
    [param setObject:peopleNum forKey:@"passenger_number"];
    [param setObject:_saveDataArr[6] forKey:@"remark"];
    [param setObject:_saveDataArr[7] forKey:@"room_preference"];
    [param setObject:_region_id forKey:@"region_id"];
    [param setObject:_region_name forKey:@"region_name"];
    [param setObject:_country_id forKey:@"country_id"];
    [param setObject:_country_name forKey:@"country_name"];
    [ProgressHUDHelper showLoading];
    __weak __typeof(self) weakSelf = self;
    [BGOrderTravelApi uploadPrivateOrderInfo:param succ:^(NSDictionary *response) {
            DLog(@"\n>>>[uploadPrivateOrderInfo sucess]:%@",response);
        [WHIndicatorView toast:BGdictSetObjectIsNil(response[@"msg"])];
        [weakSelf.navigationController popViewControllerAnimated:NO];
        
        BGChatViewController *conversationVC = [[BGChatViewController alloc]init];
        conversationVC.conversationType = ConversationType_PRIVATE;
        
        conversationVC.targetId = [NSString stringWithFormat:@"%@",BGdictSetObjectIsNil(response[@"result"][@"service_id"])];
        conversationVC.title = [NSString stringWithFormat:@"%@",BGdictSetObjectIsNil(response[@"result"][@"service_name"])];
        
        RCTextMessage *textMessage = [[RCTextMessage alloc] init];
        textMessage.content = [NSString stringWithFormat:@"私人订制-订单编号:   %@",BGdictSetObjectIsNil(response[@"result"][@"order_number"])];
        [conversationVC sendMessage:textMessage pushContent:nil];
        [weakSelf.preNav pushViewController :conversationVC animated:YES];
        
        
        } failure:^(NSDictionary *response) {
            DLog(@"\n>>>[uploadPrivateOrderInfo failure]:%@",response);
            sender.userInteractionEnabled = YES;
    }];
}
-(void)loadData{
    [ProgressHUDHelper showLoading];
    __weak __typeof(self) weakSelf = self;
    [BGAirApi getPreferenceList:nil succ:^(NSDictionary *response) {
        DLog(@"\n>>>[getPreferenceList sucess]:%@",response);
        weakSelf.service_id = [NSString stringWithFormat:@"%@",BGdictSetObjectIsNil(response[@"result"][@"service_id"])];
        weakSelf.service_name = [NSString stringWithFormat:@"%@",BGdictSetObjectIsNil(response[@"result"][@"service_name"])];
        weakSelf.navigationItem.rightBarButtonItem = [UIBarButtonItem itemWithImage:@"hotline_right" highImage:@"hotline_right" target:self action:@selector(clickedHotlineAction)];
        [weakSelf.headImgView sd_setImageWithURL:[NSURL URLWithString:BGFormat(BGdictSetObjectIsNil(response[@"result"][@"image"]))] placeholderImage:BGImage(@"img_cycle_placeholder")];
        weakSelf.travelArr = [NSArray arrayWithArray:BGdictSetObjectIsNil(response[@"result"][@"travel"])];
        weakSelf.stayArr = [NSArray arrayWithArray:BGdictSetObjectIsNil(response[@"result"][@"room"])];
        weakSelf.repastArr = [NSArray arrayWithArray:BGdictSetObjectIsNil(response[@"result"][@"food"])];
        
    } failure:^(NSDictionary *response) {
        DLog(@"\n>>>[getPreferenceList failure]:%@",response);
    }];
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
    [_saveDataArr replaceObjectAtIndex:0 withObject:timeStr];
    [self.tableView reloadSections:[[NSIndexSet alloc]initWithIndex:0] withRowAnimation:UITableViewRowAnimationAutomatic];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self canaleCallBack];
        
    });
}

#pragma mark  -  TableViewDelegate  -
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 7;
}
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    BGMineCustomTwoCell *cell = [tableView dequeueReusableCellWithIdentifier:@"BGMineCustomTwoCell" forIndexPath:indexPath];
    [cell.twoNameLabel setFont:kFont(14)];
    [cell.twoDetailLabel setFont:kFont(14)];
    switch (indexPath.section) {

        case 0:{
            cell.twoNameLabel.text = @"出行时间";
            cell.twoDetailLabel.text = _saveDataArr[0];
            return cell;
        }
            break;
        case 1:{
            cell.twoNameLabel.text = @"目的地";
            cell.twoDetailLabel.text = _saveDataArr[1];
            return cell;
        }
            break;
        case 2:{
            cell.twoNameLabel.text = @"游玩天数";
            cell.twoDetailLabel.text = _saveDataArr[2];
            return cell;
        }
            break;
        case 3:{
            cell.twoNameLabel.text = @"游客人数";
            cell.twoDetailLabel.text = _saveDataArr[5];
            return cell;
        }
            break;
        case 4:{
            cell.twoNameLabel.text = @"出行偏好";
            cell.twoDetailLabel.text = _saveDataArr[3];
            return cell;
        }
            break;
        case 5:{
            cell.twoNameLabel.text = @"餐馆偏好";
            cell.twoDetailLabel.text = _saveDataArr[4];
            return cell;
        }
            break;
        case 6:{
            cell.twoNameLabel.text = @"住宿偏好";
            cell.twoDetailLabel.text = _saveDataArr[7];
            return cell;
        }
            break;
            
        default:
            return UITableViewCell.new;
            break;
    }
    
    
}
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
    [self keyboarkHidden];

    switch (indexPath.section) {
        case 0:{
            [self showCalendarViewAction];
        }
            break;
        case 1:{
            BGAreaSelectViewController *cityVC = BGAreaSelectViewController.new;
            cityVC.category = 5;
            CATransition *transition = [CATransition animation];
            transition.type = kCATransitionMoveIn;
            transition.subtype = kCATransitionFromTop;
            [self.navigationController.view.layer addAnimation:transition forKey:kCATransition];
            [self.navigationController pushViewController:cityVC animated:NO];
        }
            break;
        case 2:{
            self.selectIndex = 4;
            BGPickViewController *pick = [[BGPickViewController alloc] initWithNibName:@"BGPickViewController" bundle:nil];
            pick.delegate = self;
            [self.tempArr removeAllObjects];
            for (int i = 1; i<31; i++) {
                NSString *str = [NSString stringWithFormat:@"%d天",i];
                [_tempArr addObject:str];
            }
            pick.arry = [NSMutableArray arrayWithArray:_tempArr];
            pick.modalPresentationStyle = UIModalPresentationCustom;
            [self presentViewController:pick animated:YES completion:nil];
        }
            break;
        case 3:{
            self.selectIndex = 3;
            BGPickViewController *pick = [[BGPickViewController alloc] initWithNibName:@"BGPickViewController" bundle:nil];
            pick.delegate = self;
            [self.tempArr removeAllObjects];
            for (int i = 1; i<31; i++) {
                NSString *str = [NSString stringWithFormat:@"%d人",i];
                [_tempArr addObject:str];
            }
            pick.arry = [NSMutableArray arrayWithArray:_tempArr];
            pick.modalPresentationStyle = UIModalPresentationCustom;
            [self presentViewController:pick animated:YES completion:nil];
        }
            break;
        case 4:{
            self.selectIndex = 1;
            BGPickViewController *pick = [[BGPickViewController alloc] initWithNibName:@"BGPickViewController" bundle:nil];
            pick.delegate = self;
            [self.tempArr removeAllObjects];
            for (NSDictionary *dic in self.travelArr) {
                NSString *nameStr = dic[@"name"];
                [_tempArr addObject:nameStr];
            }
            pick.arry = [NSMutableArray arrayWithArray:_tempArr];
            pick.modalPresentationStyle = UIModalPresentationCustom;
            [self presentViewController:pick animated:YES completion:nil];
        }
            break;
        case 5:{
            self.selectIndex = 2;
            BGPickViewController *pick = [[BGPickViewController alloc] initWithNibName:@"BGPickViewController" bundle:nil];
            pick.delegate = self;
            [self.tempArr removeAllObjects];
            for (NSDictionary *dic in self.repastArr) {
                NSString *nameStr = dic[@"name"];
                [_tempArr addObject:nameStr];
            }
            pick.arry = [NSMutableArray arrayWithArray:_tempArr];
            pick.modalPresentationStyle = UIModalPresentationCustom;
            [self presentViewController:pick animated:YES completion:nil];
        }
            break;
        case 6:{
            self.selectIndex = 5;
            BGPickViewController *pick = [[BGPickViewController alloc] initWithNibName:@"BGPickViewController" bundle:nil];
            pick.delegate = self;
            [self.tempArr removeAllObjects];
            for (NSDictionary *dic in self.stayArr) {
                NSString *nameStr = dic[@"name"];
                [_tempArr addObject:nameStr];
            }
            pick.arry = [NSMutableArray arrayWithArray:_tempArr];
            pick.modalPresentationStyle = UIModalPresentationCustom;
            [self presentViewController:pick animated:YES completion:nil];
        }
            break;
            
        default:
            break;
    }
}
-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    return section == 0 ? 3:0.01;
}
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 45;
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
-(void)getTextStr:(NSString *)text{
    switch (self.selectIndex) {
        case 1:{
            [_saveDataArr replaceObjectAtIndex:3 withObject:text];
            [self.tableView reloadSections:[[NSIndexSet alloc]initWithIndex:4] withRowAnimation:UITableViewRowAnimationAutomatic];
            
        }
            break;
        case 2:{
            [_saveDataArr replaceObjectAtIndex:4 withObject:text];
            [self.tableView reloadSections:[[NSIndexSet alloc]initWithIndex:5] withRowAnimation:UITableViewRowAnimationAutomatic];
            
            
        }
            break;
        case 3:{
            [_saveDataArr replaceObjectAtIndex:5 withObject:text];
            [self.tableView reloadSections:[[NSIndexSet alloc]initWithIndex:3] withRowAnimation:UITableViewRowAnimationAutomatic];
        }
            break;
        case 4:{
            [_saveDataArr replaceObjectAtIndex:2 withObject:text];
            [self.tableView reloadSections:[[NSIndexSet alloc]initWithIndex:2] withRowAnimation:UITableViewRowAnimationAutomatic];
        }
            break;
        case 5:{
            [_saveDataArr replaceObjectAtIndex:7 withObject:text];
            [self.tableView reloadSections:[[NSIndexSet alloc]initWithIndex:6] withRowAnimation:UITableViewRowAnimationAutomatic];
        }
            break;
            
        default:
            break;
    }
}


#pragma mark - UITextView -
-(void)textViewDidChange:(UITextView *)textView
{
    if ([textView.text length] == 0) {
        [_placeholderLabel setHidden:NO];
    }else{
        [_placeholderLabel setHidden:YES];
    }
    [self wordLimit: textView];
    [_saveDataArr replaceObjectAtIndex:6 withObject:textView.text];
    
}

-(void)wordLimit:(UITextView *)text {
    if (text.text.length > 500) {
        [WHIndicatorView toast:@"请输入小于500个文字"];
        NSString *s = [text.text substringToIndex:500];
        text.text = s;
    }
}
-(void)selectedCityTipsNotif:(NSNotification *)no{
    NSMutableDictionary *dic = [NSMutableDictionary dictionaryWithDictionary:[no object]];
    self.country_id = dic[@"country_id"];
    self.country_name = dic[@"country_name"];
    self.region_id = dic[@"region_id"];
    self.region_name = dic[@"region_name"];
    [_saveDataArr replaceObjectAtIndex:1 withObject:[NSString stringWithFormat:@"%@ %@",_country_name,_region_name]];
    [self.tableView reloadSections:[[NSIndexSet alloc]initWithIndex:1] withRowAnimation:UITableViewRowAnimationAutomatic];
}
-(void)dealloc{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"SelectedCityTipsNotif" object:nil];
}
-(void)clickedHotlineAction{
    if (![Tool isLogin]) {
        [WHIndicatorView toast:@"请先登录!"];
        [BGAppDelegateHelper showLoginViewController];
        return;
    }
    BGChatViewController *conversationVC = [[BGChatViewController alloc]init];
    conversationVC.conversationType = ConversationType_PRIVATE;
    
    conversationVC.targetId = [NSString stringWithFormat:@"%@",self.service_id];
    conversationVC.title = [NSString stringWithFormat:@"%@",self.service_name];
    [self.navigationController pushViewController:conversationVC animated:YES];
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
