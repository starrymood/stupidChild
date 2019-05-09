//
//  BGAirOneViewController.m
//  ShaHaiZiT
//
//  Created by biao on 2019/5/6.
//  Copyright © 2019 biao. All rights reserved.
//

#import "BGAirOneViewController.h"
#import "BGPickViewController.h"
#import "BGDateSingleViewController.h"
#import "WGCityListViewController.h"

@interface BGAirOneViewController ()<pickViewDelegate>
@property (weak, nonatomic) IBOutlet UIButton *fromBtn;
@property (weak, nonatomic) IBOutlet UITextField *fromTextField;
@property (weak, nonatomic) IBOutlet UIButton *toBtn;
@property (weak, nonatomic) IBOutlet UITextField *toTextField;
@property (weak, nonatomic) IBOutlet UIButton *exchangeBtn;
@property (weak, nonatomic) IBOutlet UIView *dotLineView;
@property (weak, nonatomic) IBOutlet UIButton *dateBtn;
@property (weak, nonatomic) IBOutlet UILabel *dateLabel;
@property (weak, nonatomic) IBOutlet UITextField *planeTypeTextField;
@property (weak, nonatomic) IBOutlet UIButton *planeTypeBtn;
@property (weak, nonatomic) IBOutlet UIButton *searchBtn;
@property (weak, nonatomic) IBOutlet UIButton *childBtn;
@property (weak, nonatomic) IBOutlet UIButton *babyBtn;

@property (nonatomic, strong) NSString *nowTimeStampStr;
@property(nonatomic,assign) BOOL isChild;
@property(nonatomic,assign) BOOL isBaby;

@end

@implementation BGAirOneViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor = kAppBgColor;
    [Tool drawDashLine:self.dotLineView lineLength:18 lineSpacing:8 lineColor:UIColorFromRGB(0xDCDCDC)];
     @weakify(self);
    
    NSTimeInterval timeStamp = [self getZeroWithTimeInterverl:[[NSDate date] timeIntervalSince1970]];
    self.nowTimeStampStr = [NSString stringWithFormat:@"%.f",timeStamp+3600*24*7];
    NSString *startStr = [Tool dateFormatter:_nowTimeStampStr.doubleValue dateFormatter:@"MM-dd"];
    NSString *weakStr = [Tool getWeekDayFordate:_nowTimeStampStr.doubleValue];
    self.dateLabel.text = [NSString stringWithFormat:@"%@ %@",startStr,weakStr];
    
    self.isChild = NO;
    self.isBaby = NO;
    
    [[self.childBtn rac_signalForControlEvents:(UIControlEventTouchUpInside)] subscribeNext:^(__kindof UIControl * _Nullable x) {
        @strongify(self);
        // 点击button的响应事件
        if (self.isChild) {
            [self.childBtn setImage:BGImage(@"home_air_child_unselected") forState:(UIControlStateNormal)];
            [self.childBtn setImage:BGImage(@"home_air_child_unselected") forState:(UIControlStateHighlighted)];
        }else{
            [self.childBtn setImage:BGImage(@"home_air_child_selected") forState:(UIControlStateNormal)];
            [self.childBtn setImage:BGImage(@"home_air_child_selected") forState:(UIControlStateHighlighted)];
        }
        self.isChild = !self.isChild;
    }];
    
    [[self.babyBtn rac_signalForControlEvents:(UIControlEventTouchUpInside)] subscribeNext:^(__kindof UIControl * _Nullable x) {
        @strongify(self);
        // 点击button的响应事件
        if (self.isBaby) {
            [self.babyBtn setImage:BGImage(@"home_air_baby_unselected") forState:(UIControlStateNormal)];
            [self.babyBtn setImage:BGImage(@"home_air_baby_unselected") forState:(UIControlStateHighlighted)];
        }else{
            [self.babyBtn setImage:BGImage(@"home_air_baby_selected") forState:(UIControlStateNormal)];
            [self.babyBtn setImage:BGImage(@"home_air_baby_selected") forState:(UIControlStateHighlighted)];
        }
        self.isBaby = !self.isBaby;
    }];
   
    [[self.exchangeBtn rac_signalForControlEvents:(UIControlEventTouchUpInside)] subscribeNext:^(__kindof UIControl * _Nullable x) {
        @strongify(self);
        // 点击button的响应事件
        // 交换城市动画
        CGRect fromCityFrame = self.fromTextField.frame;
        CGRect toCityFrame = self.toTextField.frame;
        
        [UIView animateWithDuration:0.3f animations:^{
            self.fromTextField.frame = toCityFrame;
            self.toTextField.frame = fromCityFrame;
        } completion:^(BOOL finished) {
            if (finished) {
                self.fromTextField.frame = fromCityFrame;
                self.toTextField.frame = toCityFrame;
                
                NSString *fromCityName = self.fromTextField.text;
                self.fromTextField.text = self.toTextField.text;
                self.toTextField.text = fromCityName;
            }
        }];
    }];
    
    
    // 选择出发地
    [[self.fromBtn rac_signalForControlEvents:(UIControlEventTouchUpInside)] subscribeNext:^(__kindof UIControl * _Nullable x) {
        @strongify(self);
        // 点击button的响应事件
        
        [self.navigationController pushViewController:[WGCityListViewController new] animated:YES];
        
        [WHIndicatorView toast:@"出发地"];
    }];
    // 选择目的地
    [[self.toBtn rac_signalForControlEvents:(UIControlEventTouchUpInside)] subscribeNext:^(__kindof UIControl * _Nullable x) {
        @strongify(self);
        // 点击button的响应事件
        [WHIndicatorView toast:@"目的地"];
    }];
    // 选择出行日期
    [[self.dateBtn rac_signalForControlEvents:(UIControlEventTouchUpInside)] subscribeNext:^(__kindof UIControl * _Nullable x) {
        @strongify(self);
        // 点击button的响应事件
        BGDateSingleViewController *cityVC = BGDateSingleViewController.new;
        __weak typeof(self) weakSelf = self;
        cityVC.refreshEditBlock = ^(NSString * _Nonnull timeStampStr) {
            weakSelf.nowTimeStampStr = timeStampStr;
            NSTimeInterval now = [weakSelf getZeroWithTimeInterverl:[[NSDate date] timeIntervalSince1970]];
            double time = timeStampStr.doubleValue - now;
            NSString *weakStr;
            if (time == 0) {
                weakStr = @"今天";
            }else if (time == 86400){
                weakStr = @"明天";
            }else if (time == 172800){
                weakStr = @"后天";
            }else{
                weakStr = [Tool getWeekDayFordate:timeStampStr.doubleValue];
            }
            NSString *startStr = [Tool dateFormatter:timeStampStr.doubleValue dateFormatter:@"MM-dd"];
            weakSelf.dateLabel.text = [NSString stringWithFormat:@"%@ %@",startStr,weakStr];
            
        };
        CATransition *transition = [CATransition animation];
        transition.type = kCATransitionMoveIn;
        transition.subtype = kCATransitionFromTop;
        [self.navigationController.view.layer addAnimation:transition forKey:kCATransition];
        [self.navigationController pushViewController:cityVC animated:NO];
    }];
    // 选择舱位
    [[self.planeTypeBtn rac_signalForControlEvents:(UIControlEventTouchUpInside)] subscribeNext:^(__kindof UIControl * _Nullable x) {
        @strongify(self);
        // 点击button的响应事件
        BGPickViewController *pick = [[BGPickViewController alloc] initWithNibName:@"BGPickViewController" bundle:nil];
        pick.delegate = self;
        pick.arry = @[@"不限",@"头等舱",@"商务舱",@"经济舱"].mutableCopy;
        pick.modalPresentationStyle = UIModalPresentationCustom;
        [self presentViewController:pick animated:YES completion:nil];
    }];
}
-(void)getTextStr:(NSString *)text{
    self.planeTypeTextField.text = text;
}
- (double)getZeroWithTimeInterverl:(NSTimeInterval) timeInterval
{
    NSDate *originalDate = [NSDate dateWithTimeIntervalSince1970:timeInterval];
    NSDateFormatter *dateFomater = [[NSDateFormatter alloc]init];
    dateFomater.dateFormat = @"yyyy年MM月dd日";
    NSString *original = [dateFomater stringFromDate:originalDate];
    NSDate *ZeroDate = [dateFomater dateFromString:original];
    return [ZeroDate timeIntervalSince1970];
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
