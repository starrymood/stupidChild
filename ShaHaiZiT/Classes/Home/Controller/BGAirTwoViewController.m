//
//  BGAirTwoViewController.m
//  ShaHaiZiT
//
//  Created by biao on 2019/5/6.
//  Copyright © 2019 biao. All rights reserved.
//

#import "BGAirTwoViewController.h"
#import "BGPickViewController.h"

@interface BGAirTwoViewController ()<pickViewDelegate>
@property (weak, nonatomic) IBOutlet UITextField *fromTextField;
@property (weak, nonatomic) IBOutlet UITextField *toTextField;
@property (weak, nonatomic) IBOutlet UIButton *fromBtn;
@property (weak, nonatomic) IBOutlet UIButton *toBtn;
@property (weak, nonatomic) IBOutlet UIButton *exchangeBtn;
@property (weak, nonatomic) IBOutlet UIView *dotLineView;
@property (weak, nonatomic) IBOutlet UIButton *searchBtn;

@property (nonatomic, strong) NSString *nowTimeStampStr;

@end

@implementation BGAirTwoViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor = kAppBgColor;
    [Tool drawDashLine:self.dotLineView lineLength:18 lineSpacing:8 lineColor:UIColorFromRGB(0xDCDCDC)];
    @weakify(self);
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
        [WHIndicatorView toast:@"出发地"];
    }];
    // 选择目的地
    [[self.toBtn rac_signalForControlEvents:(UIControlEventTouchUpInside)] subscribeNext:^(__kindof UIControl * _Nullable x) {
        @strongify(self);
        // 点击button的响应事件
        [WHIndicatorView toast:@"目的地"];
    }];
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
