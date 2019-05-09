//
//  BGDateSingleViewController.m
//  ShaHaiZiT
//
//  Created by biao on 2019/5/8.
//  Copyright © 2019 biao. All rights reserved.
//

#import "BGDateSingleViewController.h"
#import <FSCalendar.h>
#import "BGAirOneViewController.h"

@interface BGDateSingleViewController ()<FSCalendarDelegate,FSCalendarDataSource,FSCalendarDelegateAppearance>

@property (nonatomic, weak) FSCalendar *calendarView;

@property(strong, nonatomic) NSCalendar *gregorianCalendar;

@end

@implementation BGDateSingleViewController

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    self.navigationController.navigationBarHidden = NO;
}
- (void)loadView
{
    UIView *view = [[UIView alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    view.backgroundColor = kAppBgColor;
    self.view = view;
    
    self.navigationItem.title = @"选择日期";
    FSCalendar *calendarView = [[FSCalendar alloc] initWithFrame:CGRectMake(0, SafeAreaTopHeight+6, SCREEN_WIDTH, SCREEN_HEIGHT-SafeAreaTopHeight-6-SafeAreaBottomHeight)];
    self.calendarView = calendarView;
    _calendarView.delegate = self;
    _calendarView.dataSource = self;
    _calendarView.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:_calendarView];
    self.gregorianCalendar = [NSCalendar calendarWithIdentifier:NSCalendarIdentifierGregorian];
    self.calendarView.firstWeekday = 1;     //设置周为第一天
    self.calendarView.appearance.weekdayTextColor = kApp999Color;  //星期字体颜色
    self.calendarView.appearance.headerTitleColor = kApp333Color;    //头部字体颜色
    self.calendarView.appearance.titleWeekendColor = kAppRedColor;      //周末字体颜色
    //    self.calendarView.appearance.todayColor = kAppRedColor;
    self.calendarView.appearance.headerDateFormat = @"yyyy年MM月";    //头部日期显示格式
    self.calendarView.appearance.borderRadius = 1.0;  // 设置当前选择是圆形,0.0是正方形
    self.calendarView.appearance.headerMinimumDissolvedAlpha = 0;
    NSLocale *locale = [[NSLocale alloc] initWithLocaleIdentifier:@"zh_CN"];//设置为中文
    self.calendarView.locale = locale;  // 设置周次是中文显示
    self.calendarView.appearance.caseOptions = FSCalendarCaseOptionsWeekdayUsesSingleUpperCase;  // 设置周次为一,二
    self.calendarView.appearance.selectionColor = kAppMainColor;    //选中背景颜色
    self.calendarView.today = nil;
    self.calendarView.allowsMultipleSelection = NO; //设置是否用户多选
    self.calendarView.pagingEnabled = NO;      //是否启用分页
    self.calendarView.placeholderType = FSCalendarPlaceholderTypeNone;
    
    
}
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

#pragma mark - FSCalendarDataSource

- (NSDate *)minimumDateForCalendar:(FSCalendar *)calendar
{
    return [self.gregorianCalendar dateByAddingUnit:NSCalendarUnitMonth value:0 toDate:[NSDate date] options:0];
}

- (NSDate *)maximumDateForCalendar:(FSCalendar *)calendar
{
    return [self.gregorianCalendar dateByAddingUnit:NSCalendarUnitMonth value:12 toDate:[NSDate date] options:0];
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
    NSString *timeStampStr = [NSString stringWithFormat:@"%.f",timeStamp/1000];
   
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        CATransition *transition = [CATransition animation];
        transition.type = kCATransitionReveal;
        transition.subtype = kCATransitionFromBottom;
        [self.navigationController.view.layer addAnimation:transition forKey:kCATransition];
        [self.navigationController popViewControllerAnimated:NO];
        if (self.refreshEditBlock) {
            self.refreshEditBlock(timeStampStr);
        }
        
    });
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
