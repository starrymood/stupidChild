//
//  SHZSelectTimeViewController.m
//  shahaizic
//
//  Created by 彪哥 on 2018/1/10.
//  Copyright © 2018年 彪哥. All rights reserved.
//

#import "SHZSelectTimeViewController.h"
#import "FSCalendar.h"
#import "RangePickerCell.h"
#import "FSCalendarExtensions.h"

@interface SHZSelectTimeViewController ()
<FSCalendarDataSource, FSCalendarDelegate, FSCalendarDelegateAppearance>

@property (weak, nonatomic) IBOutlet FSCalendar *calendarView;
@property(strong, nonatomic) NSCalendar *gregorianCalendar;
@property (strong, nonatomic) NSDateFormatter *dateFormatter;

// The start date of the range
@property (strong, nonatomic) NSDate *date1;
// The end date of the range
@property (strong, nonatomic) NSDate *date2;

- (void)configureCell:(__kindof FSCalendarCell *)cell forDate:(NSDate *)date atMonthPosition:(FSCalendarMonthPosition)position;

@end

@implementation SHZSelectTimeViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    self.gregorianCalendar = [NSCalendar calendarWithIdentifier:NSCalendarIdentifierGregorian];
    self.dateFormatter = [[NSDateFormatter alloc] init];
    self.dateFormatter.dateFormat = @"yyyy-MM-dd";

    self.calendarView.firstWeekday = 1;     //设置周为第一天
    self.calendarView.appearance.weekdayTextColor = kApp999Color;  //星期字体颜色
    self.calendarView.appearance.headerTitleColor = kApp333Color;    //头部字体颜色
    self.calendarView.appearance.headerMinimumDissolvedAlpha = 0.0;     //上、下月标签静止时透明度
    self.calendarView.appearance.headerDateFormat = @"yyyy年MM月";    //头部日期显示格式
    self.calendarView.appearance.borderRadius = 1.0;  // 设置当前选择是圆形,0.0是正方形
    NSLocale *locale = [[NSLocale alloc] initWithLocaleIdentifier:@"zh_CN"];//设置为中文
    self.calendarView.locale = locale;  // 设置周次是中文显示
    self.calendarView.appearance.caseOptions = FSCalendarCaseOptionsWeekdayUsesSingleUpperCase;  // 设置周次为一,二
    self.calendarView.appearance.titleWeekendColor = kAppRedColor;      //周末字体颜色
//    self.calendarView.appearance.selectionColor = [Tool colorWithHexString:selectFontColor];    //选中背景颜色
//    self.calendarView.appearance.todayColor = [UIColor clearColor];             //今天背景颜色
//    self.calendarView.appearance.titleTodayColor = [UIColor blackColor];        //今天字体颜色
    self.calendarView.today = nil;
    self.calendarView.allowsMultipleSelection = YES; //设置是否用户多选
    self.calendarView.pagingEnabled = NO;      //是否启用分页

//    self.calendarView.scrollDirection = FSCalendarScrollDirectionHorizontal;  //设置翻页方式为水平
    self.calendarView.placeholderType = FSCalendarPlaceholderTypeNone;

    [self.calendarView registerClass:[RangePickerCell class] forCellReuseIdentifier:@"cell"];

    if (self.startDate) {
        self.date1 = self.startDate;
        self.date2 = self.endDate;
        [self configureVisibleCells];
    }
    
    //创建点击跳转显示上一月和下一月button
    /*
    UIButton *previousButton = [UIButton buttonWithType:UIButtonTypeCustom];
    previousButton.frame = CGRectMake(kAppWidth/2-68, 10, 25, 20);
    previousButton.titleLabel.font = [UIFont systemFontOfSize:18];
    [previousButton setTitle:@"<" forState:UIControlStateNormal];
    [previousButton setTitleColor:[Tool colorWithHexString:TwoLevelFontColor] forState:UIControlStateNormal];
    [previousButton addTarget:self action:@selector(previousClicked:) forControlEvents:UIControlEventTouchUpInside];
    [self.calendarView addSubview:previousButton];
    
    UIButton *nextButton = [UIButton buttonWithType:UIButtonTypeCustom];
    nextButton.frame = CGRectMake(kAppWidth/2+40, 10, 25, 20);
    nextButton.titleLabel.font = [UIFont systemFontOfSize:18];
    [nextButton setTitle:@">" forState:UIControlStateNormal];
    [nextButton setTitleColor:[Tool colorWithHexString:TwoLevelFontColor] forState:UIControlStateNormal];
    [nextButton addTarget:self action:@selector(nextClicked:) forControlEvents:UIControlEventTouchUpInside];
    [self.calendarView addSubview:nextButton];
    */
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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

- (FSCalendarCell *)calendar:(FSCalendar *)calendar cellForDate:(NSDate *)date atMonthPosition:(FSCalendarMonthPosition)monthPosition
{
    RangePickerCell *cell = [calendar dequeueReusableCellWithIdentifier:@"cell" forDate:date atMonthPosition:monthPosition];
    return cell;
}

- (void)calendar:(FSCalendar *)calendar willDisplayCell:(FSCalendarCell *)cell forDate:(NSDate *)date atMonthPosition: (FSCalendarMonthPosition)monthPosition
{
    [self configureCell:cell forDate:date atMonthPosition:monthPosition];
}

#pragma mark - FSCalendarDelegate

- (BOOL)calendar:(FSCalendar *)calendar shouldSelectDate:(NSDate *)date atMonthPosition:(FSCalendarMonthPosition)monthPosition
{
    return monthPosition == FSCalendarMonthPositionCurrent;
}

- (BOOL)calendar:(FSCalendar *)calendar shouldDeselectDate:(NSDate *)date atMonthPosition:(FSCalendarMonthPosition)monthPosition
{
    return NO;
}

- (void)calendar:(FSCalendar *)calendar didSelectDate:(NSDate *)date atMonthPosition:(FSCalendarMonthPosition)monthPosition
{
    if (self.date2) {
        [calendar deselectDate:self.date1];
        [calendar deselectDate:self.date2];
        self.date1 = date;
        [calendar deselectDate:self.date1];
        self.date2 = nil;
    } else if (!self.date1) {
        self.date1 = date;
        [calendar deselectDate:self.date1];
    } else {
        self.date2 = date;
        
        NSComparisonResult result = [self.date1 compare:self.date2];
        switch (result) {
            case NSOrderedAscending: //时间小于
//                NSLog(@"FlyElephant:%@--时间小于---%@",self.date1,self.date2);
                self.startDate = self.date1;
                self.endDate = self.date2;
                break;
            case NSOrderedDescending: //时间大于
//                NSLog(@"FlyElephant:%@--时间大于---%@",self.date1,self.date2);
                self.startDate = self.date2;
                self.endDate = self.date1;
                break;
            default:
                self.startDate = self.date1;
                self.endDate = self.date2;
                break;
        }
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            if (self.timeBlock != nil) {
                self.timeBlock(self.startDate, self.endDate);
            }
            [self.navigationController popViewControllerAnimated:YES];
        });
    }
    [self configureVisibleCells];
}

#pragma mark - Private methods

- (void)configureVisibleCells
{
    [self.calendarView.visibleCells enumerateObjectsUsingBlock:^(__kindof FSCalendarCell * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        NSDate *date = [self.calendarView dateForCell:obj];
        FSCalendarMonthPosition position = [self.calendarView monthPositionForCell:obj];
        [self configureCell:obj forDate:date atMonthPosition:position];
    }];
}



- (void)configureCell:(__kindof FSCalendarCell *)cell forDate:(NSDate *)date atMonthPosition:(FSCalendarMonthPosition)position
{
    RangePickerCell *rangeCell = cell;
    if (position != FSCalendarMonthPositionCurrent) {
        rangeCell.middleLayer.hidden = YES;
        rangeCell.selectionLayer.hidden = YES;
        return;
    }
    if (self.date1 && self.date2) {
        // The date is in the middle of the range
        BOOL isMiddle = [date compare:self.date1] != [date compare:self.date2];
        rangeCell.middleLayer.hidden = !isMiddle;
    } else {
        rangeCell.middleLayer.hidden = YES;
    }
    BOOL isSelected = NO;
    isSelected |= self.date1 && [self.gregorianCalendar isDate:date inSameDayAsDate:self.date1];
    isSelected |= self.date2 && [self.gregorianCalendar isDate:date inSameDayAsDate:self.date2];
    rangeCell.selectionLayer.hidden = !isSelected;
}


/*
//上一月按钮点击事件
- (void)previousClicked:(id)sender {
    
    NSDate *currentMonth = self.calendarView.currentPage;
    NSDate *previousMonth = [self.gregorianCalendar dateByAddingUnit:NSCalendarUnitMonth value:-1 toDate:currentMonth options:0];
    [self.calendarView setCurrentPage:previousMonth animated:YES];
}

//下一月按钮点击事件
- (void)nextClicked:(id)sender {
    
    NSDate *currentMonth = self.calendarView.currentPage;
    NSDate *nextMonth = [self.gregorianCalendar dateByAddingUnit:NSCalendarUnitMonth value:1 toDate:currentMonth options:0];
    [self.calendarView setCurrentPage:nextMonth animated:YES];
}
*/

- (void)carStartTimeToEndTime:(TimeBlock)block {
    self.timeBlock = block;
}

@end
