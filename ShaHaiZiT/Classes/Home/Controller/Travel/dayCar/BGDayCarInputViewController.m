//
//  BGDayCarInputViewController.m
//  shzTravelC
//
//  Created by biao on 2018/8/23.
//  Copyright © 2018年 biao. All rights reserved.
//

#import "BGDayCarInputViewController.h"
#import "BGAirPriceInfoModel.h"
#import <UIImageView+WebCache.h>
#import "BGPickViewController.h"
#import "UITextField+BGLimit.h"
#import "SHZSelectTimeViewController.h"
#import "BGAirApi.h"
#import "BGDayCarOrderPayViewController.h"
#import "BGOrderTravelApi.h"

@interface BGDayCarInputViewController ()<UITextViewDelegate,pickViewDelegate>
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *contentCenterY;
@property (weak, nonatomic) IBOutlet UIImageView *carImgView;
@property (weak, nonatomic) IBOutlet UIButton *selectDateBtn;
@property (weak, nonatomic) IBOutlet UITextField *originTextField;
@property (weak, nonatomic) IBOutlet UITextField *destinationTextField;
@property (weak, nonatomic) IBOutlet UITextField *personNameTextField;
@property (weak, nonatomic) IBOutlet UITextField *personPhoneTextField;
@property (weak, nonatomic) IBOutlet UIButton *selectAdultBtn;
@property (weak, nonatomic) IBOutlet UIButton *selectChildBtn;
@property (weak, nonatomic) IBOutlet UIButton *selectPackageBtn;
@property (weak, nonatomic) IBOutlet UITextField *adultNumTextField;
@property (weak, nonatomic) IBOutlet UITextField *childNumTextField;
@property (weak, nonatomic) IBOutlet UITextField *packageNumTextField;
@property (weak, nonatomic) IBOutlet UITextView *noteTextView;
@property (weak, nonatomic) IBOutlet UIButton *sureBtn;
@property (nonatomic, strong) UILabel *placeholderLabel;
@property (nonatomic, assign) int selectType;
@property (nonatomic, strong) NSDate *carStartDate;
@property (nonatomic, strong) NSDate *carEndDate;
@property (nonatomic, copy) NSString *dayStr;

@end

@implementation BGDayCarInputViewController

- (void)viewDidLoad {
    [super viewDidLoad];
   
    [self loadSubViews];
}
-(void)loadSubViews{
    self.navigationItem.title = @"填写信息";
    self.view.backgroundColor = kAppBgColor;
    self.selectType = 0;
    self.contentCenterY.constant = (_sureBtn.y+_sureBtn.height-SCREEN_HEIGHT+SafeAreaTopHeight+SafeAreaBottomHeight+50)*0.5;
    [UIView animateWithDuration:.2 animations:^{
        [self.view layoutIfNeeded];
    }];
    self.selectDateBtn.layer.cornerRadius = 5.0;
    self.selectDateBtn.layer.borderColor = kAppMainColor.CGColor;
    self.selectDateBtn.layer.borderWidth = 0.5;
    self.originTextField.maxLenght = 40;
    self.destinationTextField.maxLenght = 40;
    self.personNameTextField.maxLenght = 30;
    self.personPhoneTextField.maxLenght = 20;
    self.personPhoneTextField.digitsChars = @[@"0",@"1",@"2",@"3",@"4",@"5",@"6",@"7",@"8",@"9"];
    self.placeholderLabel = [[UILabel alloc] initWithFrame:CGRectMake(3, 3, SCREEN_WIDTH-20-6, 25)];
    _placeholderLabel.enabled = NO;
    _placeholderLabel.text = @"您还有什么特别需求";
    _placeholderLabel.numberOfLines = 0;
    _placeholderLabel.font = kFont(14);
    _placeholderLabel.textColor = kApp999Color;
    [_noteTextView addSubview:_placeholderLabel];
    
    
    if (_fModel.car_pictures.count>0) {
        [self.carImgView sd_setImageWithURL:[NSURL URLWithString:_fModel.car_pictures[0]] placeholderImage:BGImage(@"img_cycle_placeholder")];
//        self.carImgView.contentMode = UIViewContentModeScaleAspectFit;
    }
    
    @weakify(self);
    [[self.selectDateBtn rac_signalForControlEvents:(UIControlEventTouchUpInside)] subscribeNext:^(__kindof UIControl * _Nullable x) {
        @strongify(self);
        // 点击button的响应事件
        [self keyboarkHidden];
        SHZSelectTimeViewController *selectTimeVC = [[SHZSelectTimeViewController alloc] initWithNibName:@"SHZSelectTimeViewController" bundle:nil];
        selectTimeVC.navigationItem.title = @"选择行程时间";
        if (self.carStartDate) {
            selectTimeVC.startDate = self.carStartDate;
            selectTimeVC.endDate = self.carEndDate;
        }
        __block typeof(self) weakSelf = self;
        [selectTimeVC carStartTimeToEndTime:^(NSDate *startDate, NSDate *endDate) {
            self.carStartDate = startDate;
            self.carEndDate = endDate;
            [weakSelf refreshTimeLabText];
        }];
        [self.navigationController pushViewController:selectTimeVC animated:YES];
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
    [[self.selectChildBtn rac_signalForControlEvents:(UIControlEventTouchUpInside)] subscribeNext:^(__kindof UIControl * _Nullable x) {
        @strongify(self);
        // 点击button的响应事件
        [self keyboarkHidden];
        self.selectType = 2;
        BGPickViewController *pick = [[BGPickViewController alloc] initWithNibName:@"BGPickViewController" bundle:nil];
        pick.delegate = self;
        NSMutableArray *arr = [NSMutableArray array];
        for (int i = 0; i<self.fModel.passenger_number.intValue; i++) {
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
    [[self.sureBtn rac_signalForControlEvents:(UIControlEventTouchUpInside)] subscribeNext:^(__kindof UIControl * _Nullable x) {
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
    if ([_selectDateBtn.titleLabel.text isEqualToString:@"选择行程日期"]) {
        [WHIndicatorView toast:@"请选择行程时间"];
        return;
    }
    if (_originTextField.text.length<1) {
        [WHIndicatorView toast:@"请填写出发地点"];
        return;
    }
    if (_destinationTextField.text.length<1) {
        [WHIndicatorView toast:@"请填写送达地点"];
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
    if (_adultNumTextField.text.length<1) {
        [WHIndicatorView toast:@"请选择成人数"];
        return;
    }
    if (_childNumTextField.text.length<1) {
        [WHIndicatorView toast:@"请选择儿童数"];
        return;
    }
    if (_packageNumTextField.text.length<1) {
        [WHIndicatorView toast:@"请选择行李数"];
        return;
    }
    NSString *adultNum = [_adultNumTextField.text substringWithRange:NSMakeRange(0, [_adultNumTextField.text length] - 1)];
    NSString *childrenNum = [_childNumTextField.text substringWithRange:NSMakeRange(0, [_childNumTextField.text length] - 1)];
    NSString *packageNum = [_packageNumTextField.text substringWithRange:NSMakeRange(0, [_packageNumTextField.text length] - 1)];
    if (adultNum.intValue + childrenNum.intValue > _fModel.passenger_number.intValue) {
        [WHIndicatorView toast:@"成人和儿童总人数超过乘客人数"];
        return;
    }
    if (packageNum.intValue > _fModel.baggage_number.intValue) {
        [WHIndicatorView toast:@"行李数超过所能携带行李数"];
        return;
    }
    if (_noteTextView.text.length<1) {
        _noteTextView.text = @"";
    }
    NSTimeInterval startTimeInterval = [_carStartDate timeIntervalSince1970];
    NSString *startStr = [NSString stringWithFormat:@"%.0f",startTimeInterval];
    NSTimeInterval endTimeInterval = [_carEndDate timeIntervalSince1970];
    NSString *endStr = [NSString stringWithFormat:@"%.0f",endTimeInterval];


    NSMutableDictionary *param = [[NSMutableDictionary alloc] init];
    [param setObject:_product_id forKey:@"product_id"];
    [param setObject:startStr forKey:@"start_time"];
    [param setObject:endStr forKey:@"end_time"];
    [param setObject:_dayStr forKey:@"play_days"];
    [param setObject:_originTextField.text forKey:@"departure"];
    [param setObject:_destinationTextField.text forKey:@"destination"];
    [param setObject:adultNum forKey:@"audit_number"];
    [param setObject:childrenNum forKey:@"children_number"];
    [param setObject:packageNum forKey:@"baggage_number"];
    [param setObject:_personNameTextField.text forKey:@"contact"];
    [param setObject:_personPhoneTextField.text forKey:@"contact_number"];
    [param setObject:_noteTextView.text forKey:@"remark"];
    
    // @@@
//    NSMutableDictionary *param = [[NSMutableDictionary alloc] init];
//    [param setObject:_product_id forKey:@"product_id"];
//    [param setObject:@"1535904000" forKey:@"start_time"];
//    [param setObject:@"1536163200" forKey:@"end_time"];
//    [param setObject:@"4" forKey:@"play_days"];
//    [param setObject:@"上海" forKey:@"departure"];
//    [param setObject:@"鄂尔多斯" forKey:@"destination"];
//    [param setObject:@"3" forKey:@"audit_number"];
//    [param setObject:@"2" forKey:@"children_number"];
//    [param setObject:@"1" forKey:@"baggage_number"];
//    [param setObject:@"彪哥" forKey:@"contact"];
//    [param setObject:@"15515916027" forKey:@"contact_number"];
//    [param setObject:@"飞雪连天射白鹿,笑书神侠倚碧鸳.京东包车景点简介京东包车景点简介京东包车景点简介 京东包车景点简介京东包车景点简介京东包车景点简介 京东包车景点简介京东包车景 复制" forKey:@"remark"];
    
    sender.userInteractionEnabled = NO;
    __weak __typeof(self) weakSelf = self;
    [ProgressHUDHelper showLoading];
    [BGOrderTravelApi uploadPreInfo:param succ:^(NSDictionary *response) {
        DLog(@"\n>>>[uploadPreInfo sucess]:%@",response);
        BGDayCarOrderPayViewController *payVC = BGDayCarOrderPayViewController.new;
        payVC.order_number = [NSString stringWithFormat:@"%@",BGdictSetObjectIsNil(response[@"result"][@"order_number"])];
        payVC.duringDateStr = self.selectDateBtn.titleLabel.text;
        [weakSelf.navigationController pushViewController:payVC animated:YES];
        sender.userInteractionEnabled = YES;
    } failure:^(NSDictionary *response) {
        DLog(@"\n>>>[uploadPreInfo failure]:%@",response);
        sender.userInteractionEnabled = YES;
    }];
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
        case 1:
            _adultNumTextField.text = text;
            break;
        case 2:
            _childNumTextField.text = text;
            break;
        case 3:
            _packageNumTextField.text = text;
            break;
            
        default:
            break;
    }
}
- (void)refreshTimeLabText {
    if (_carStartDate) {
        NSDateFormatter *format = [[NSDateFormatter alloc] init];
        format.dateFormat = @"yyyy年MM月dd日";
        NSCalendar *gregorian = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
        unsigned int unitFlags = NSCalendarUnitDay;
        NSDateComponents *comps = [gregorian components:unitFlags fromDate:_carStartDate  toDate:_carEndDate  options:0];
        NSString *dateStr = [NSString stringWithFormat:@"%@-%@ (%ld天)",[format stringFromDate:_carStartDate],[format stringFromDate:_carEndDate],(long)[comps day]+1];
        [self.selectDateBtn setTitle:dateStr forState:(UIControlStateNormal)];
        self.dayStr = [NSString stringWithFormat:@"%ld",(long)[comps day]+1];
    }
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
