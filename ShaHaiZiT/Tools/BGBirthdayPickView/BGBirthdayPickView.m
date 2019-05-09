//
//  BGBirthdayPickView.m
//  shahaizic
//
//  Created by 孙林茂 on 2018/4/5.
//  Copyright © 2018年 樱兰网络. All rights reserved.
//

#import "BGBirthdayPickView.h"

#define CANCLE_LABEL_TAG        11
#define CONFRM_LABEL_TAG        12
#define PickViewHeight          240
@interface BGBirthdayPickView()<UIPickerViewDataSource,UIPickerViewDelegate>

@property (nonatomic,assign) NSInteger year;
@property (nonatomic,assign) NSInteger month;
@property (nonatomic,assign) NSInteger day;
@end
@implementation BGBirthdayPickView


- (id)initWithDelegate:(id<BGBirthDateDelegate>)delegate year:(NSUInteger)year month:(NSUInteger)month day:(NSUInteger)day
{
    if (self = [super init])
    {
        self.backgroundColor = kAppWhiteColor;
        self.delegate = delegate;
        self.month = month;
        self.year = year;
        self.day = day;
        [self createView];
    }
    return self;
}

- (void)createView
{
    UILabel *cancle = [[UILabel alloc] initWithFrame:CGRectMake(10, 5, 60, 30)];
    cancle.userInteractionEnabled = YES;
    cancle.text = @"取消";
    cancle.tag = CANCLE_LABEL_TAG;
    cancle.textColor = kApp999Color;
    cancle.textAlignment = NSTextAlignmentCenter;
    [self addSubview:cancle];
    UITapGestureRecognizer *canTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapClick:)];
    [cancle addGestureRecognizer:canTap];
    
    UILabel *confrm = [[UILabel alloc] initWithFrame:CGRectMake(SCREEN_WIDTH - 70, 5, 60, 30)];
    confrm.userInteractionEnabled = YES;
    confrm.text = @"确认";
    confrm.tag  = CONFRM_LABEL_TAG;
    confrm.textColor = kAppMainColor;
    confrm.textAlignment = NSTextAlignmentCenter;
    [self addSubview:confrm];
    UITapGestureRecognizer *conTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapClick:)];
    [confrm addGestureRecognizer:conTap];
    
    NSDate *currentDate = [NSDate date];//获取当前时间，日期
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"YYYY-MM-dd hh:mm:ss SS"];
    NSString *dateString = [dateFormatter stringFromDate:currentDate];
    
    _yearNum = [[dateString substringWithRange:NSMakeRange(0,4)] intValue];
    UIPickerView *pickView = [[UIPickerView alloc] initWithFrame:CGRectMake(0, 35, SCREEN_WIDTH, PickViewHeight-55)];
    pickView.delegate = self;
    pickView.dataSource = self;
    
    if (_yearNum-self.year <0) {
        [pickView selectRow:_yearNum inComponent:0 animated:YES];
    }else{
        [pickView selectRow:_yearNum-self.year inComponent:0 animated:YES];
    }
   
    [pickView selectRow:self.month-1 inComponent:1 animated:YES];
    [pickView selectRow:self.day-1 inComponent:2 animated:YES];
    [self addSubview:pickView];
}

//  一共有多少列
- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView
{
    return 3;
}

//  第component列一共有多少行
- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component
{
    if(component == 0)
    {
        return 200;
    }
    else if (component == 1)
    {
        return 12;
    }
    else
    {
        if(self.month  == 2)
        {
            if ( ((self.year % 4 == 0) && (self.year % 100 != 0))|| (self.year % 400 == 0))
            {
                return 29;
            }
            else
            {
                return 28;
            }
        }
        else if((self.month == 4 )|| (self.month == 6) || (self.month == 9) || (self.month == 11))
        {
            return 30;
        }
        else
        {
            return 31;
        }
    }
}

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component
{
    if(component == 0)
    {
        self.year = _yearNum - row;
    }
    else if(component == 1)
    {
        self.month = row+1;
    }
    else if(component == 2)
    {
        self.day = row+1;
    }
    [pickerView reloadAllComponents];
}

//自定义 当前列 当前行 要显示的内容
- (UIView *)pickerView:(UIPickerView *)pickerView viewForRow:(NSInteger)row forComponent:(NSInteger)component reusingView:(UIView *)view
{
    UILabel *myView = [[UILabel alloc] initWithFrame:CGRectMake(0.0, 0.0, SCREEN_WIDTH/3 , 30)];
    myView.textAlignment = NSTextAlignmentCenter;
    myView.font = [UIFont systemFontOfSize:14];
    if(component == 0)
    {
        myView.text = [NSString stringWithFormat:@"%ld年",_yearNum - row];
    }
    else if (component == 1)
    {
        if (row < 9)
        {
            myView.text = [NSString stringWithFormat:@"0%ld月",row + 1];
        }
        myView.text = [NSString stringWithFormat:@"%ld月",row + 1];
    }
    else if (component == 2)
    {
        if (row)
        {
            myView.text = [NSString stringWithFormat:@"0%ld日",row + 1];
        }
        myView.text = [NSString stringWithFormat:@"%ld日",row + 1];
    }
    
    return myView;
}

//第component列的宽度是多少
- (CGFloat)pickerView:(UIPickerView *)pickerView widthForComponent:(NSInteger)component
{
    return SCREEN_WIDTH/3 ;
}

//第component列的行高是多少
- (CGFloat)pickerView:(UIPickerView *)pickerView rowHeightForComponent:(NSInteger)component
{
    return 30;
}

- (void)tapClick:(UITapGestureRecognizer *)tap
{
    if(self.delegate)
    {
        NSInteger tag = tap.view.tag;
        if(tag == CANCLE_LABEL_TAG)
        {
            if([self.delegate respondsToSelector:@selector(canaleCallBack)] == YES)
            {
                [self.delegate canaleCallBack];
            }
        }
        else if(tag == CONFRM_LABEL_TAG)
        {
            if([self.delegate respondsToSelector:@selector(confrmCallBack:month:day:)] == YES)
            {
                [self.delegate confrmCallBack:self.year month:self.month day:self.day];
            }
        }
    }
}



@end
