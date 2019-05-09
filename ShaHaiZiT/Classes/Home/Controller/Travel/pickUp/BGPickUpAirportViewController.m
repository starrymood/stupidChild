//
//  BGPickUpAirportViewController.m
//  shzTravelC
//
//  Created by biao on 2018/8/13.
//  Copyright © 2018年 biao. All rights reserved.
//

#import "BGPickUpAirportViewController.h"
#import "BGAirPriceInfoModel.h"
#import <UIImageView+WebCache.h>
#import "BGPickViewController.h"
#import "UITextField+BGLimit.h"
#import "THDatePickerView.h"
#import "BGOrderTravelApi.h"
#import "BGPickUpOrderPayViewController.h"

#define DateViewHeight (SafeAreaBottomHeight+300)
@interface BGPickUpAirportViewController ()<UITextViewDelegate,pickViewDelegate,THDatePickerViewDelegate>
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *contentCenterY;
@property (weak, nonatomic) IBOutlet UIImageView *carImgView;
@property (weak, nonatomic) IBOutlet UIButton *sureBtn;
@property (weak, nonatomic) IBOutlet UIView *sureBgView;
@property (weak, nonatomic) IBOutlet UITextField *flightNumTextField;
@property (weak, nonatomic) IBOutlet UITextField *destinationTextField;
@property (weak, nonatomic) IBOutlet UITextField *arriveTimeTextField;
@property (weak, nonatomic) IBOutlet UIButton *selectArriveTimeBtn;
@property (weak, nonatomic) IBOutlet UITextField *personNameTextField;
@property (weak, nonatomic) IBOutlet UITextField *personPhoneTextField;
@property (weak, nonatomic) IBOutlet UIButton *selectAdultBtn;
@property (weak, nonatomic) IBOutlet UIButton *selectChildBtn;
@property (weak, nonatomic) IBOutlet UIButton *selectPackageBtn;
@property (weak, nonatomic) IBOutlet UITextField *adultNumTextField;
@property (weak, nonatomic) IBOutlet UITextField *childNumTextField;
@property (weak, nonatomic) IBOutlet UITextField *packageNumTextField;
@property (weak, nonatomic) IBOutlet UITextView *noteTextView;
@property (nonatomic, strong) UILabel *placeholderLabel;
@property (nonatomic, assign) int selectType;
@property (weak, nonatomic) THDatePickerView *dateView;
@property (nonatomic, strong) UIView *backView;
@property (weak, nonatomic) IBOutlet UILabel *carNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *peopleNumLabel;

@end

@implementation BGPickUpAirportViewController
-(UIView *)backView{
    if (!_backView) {
        self.backView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT)];
        _backView.backgroundColor = [UIColor clearColor];
    }
    return _backView;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self loadSubViews];
}

-(void)loadSubViews{
    self.navigationItem.title = @"填写信息";
    self.view.backgroundColor = kAppBgColor;
    self.selectType = 0;
    self.contentCenterY.constant = (_sureBgView.y+_sureBtn.y+_sureBtn.height-SCREEN_HEIGHT+SafeAreaTopHeight+SafeAreaBottomHeight+50)*0.5;
    [UIView animateWithDuration:.2 animations:^{
        [self.view layoutIfNeeded];
    }];
    self.flightNumTextField.maxLenght = 20;
    self.flightNumTextField.digitsChars = @[@"0",@"1",@"2",@"3",@"4",@"5",@"6",@"7",@"8",@"9",
                                            @"A",@"B",@"C",@"D",@"E",@"F",@"G",@"H",@"I",@"J",
                                            @"K",@"L",@"M",@"N",@"O",@"P",@"Q",@"R",@"S",@"T",
                                            @"U",@"V",@"W",@"X",@"Y",@"Z"];
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
    
    THDatePickerView *dateView = [[THDatePickerView alloc] initWithFrame:CGRectMake(0, SCREEN_HEIGHT, SCREEN_WIDTH, DateViewHeight)];
    dateView.delegate = self;
    dateView.title = @"请选择航班到达时间";
//    dateView.minuteInterval = 1;
    self.dateView = dateView;
    
    if (_fModel.car_pictures.count>0) {
        [self.carImgView sd_setImageWithURL:[NSURL URLWithString:_fModel.car_pictures[0]] placeholderImage:BGImage(@"img_cycle_placeholder")];
//        self.carImgView.contentMode = UIViewContentModeScaleAspectFit;
    }

    self.carNameLabel.text = _fModel.model_name;
    self.peopleNumLabel.text = [NSString stringWithFormat:@"%@人%@行李",_fModel.passenger_number,_fModel.baggage_number];
    @weakify(self);
    [[self.selectArriveTimeBtn rac_signalForControlEvents:(UIControlEventTouchUpInside)] subscribeNext:^(__kindof UIControl * _Nullable x) {
        @strongify(self);
        // 点击button的响应事件
        [self keyboarkHidden];
        [UIView animateWithDuration:0.3 animations:^{
            self.dateView.frame = CGRectMake(0, SCREEN_HEIGHT - DateViewHeight, SCREEN_WIDTH, DateViewHeight);
            [self.view addSubview:self.backView];
            [self.view addSubview:dateView];
            [UIView transitionWithView:self.backView duration:0.3 options:0 animations:^{
                self.backView.backgroundColor = [UIColor colorWithWhite:0 alpha:0.4];
            } completion:nil];
            [self.dateView show];
        }];
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
    if (_flightNumTextField.text.length<1) {
        [WHIndicatorView toast:@"请填写航班号(请输入大写字母和数字)"];
        return;
    }
    if (_destinationTextField.text.length<1) {
        [WHIndicatorView toast:@"请填写目的地"];
        return;
    }
    if ([_arriveTimeTextField.text isEqualToString:@"选择航班预计到达时间"]) {
        [WHIndicatorView toast:@"请选择航班预计到达时间"];
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

    NSString *timeStampStr = [Tool timeString:_arriveTimeTextField.text withFormatte:@"YYYY-MM-dd HH:mm"];
    NSMutableDictionary *param = [[NSMutableDictionary alloc] init];
    [param setObject:_product_id forKey:@"product_id"];
    [param setObject:_flightNumTextField.text forKey:@"flight_number"];
    [param setObject:_destinationTextField.text forKey:@"destination"];
    [param setObject:timeStampStr forKey:@"start_time"];
    [param setObject:adultNum forKey:@"audit_number"];
    [param setObject:childrenNum forKey:@"children_number"];
    [param setObject:packageNum forKey:@"baggage_number"];
    [param setObject:_personNameTextField.text forKey:@"contact"];
    [param setObject:_personPhoneTextField.text forKey:@"contact_number"];
    [param setObject:_noteTextView.text forKey:@"remark"];
    // @@@
//   NSString *timeStampStr = [Tool timeString:@"2018-12-11 11:11" withFormatte:@"YYYY-MM-dd HH:mm"];
//    NSMutableDictionary *param = [[NSMutableDictionary alloc] init];
//    [param setObject:_product_id forKey:@"product_id"];
//    [param setObject:@"MU12138" forKey:@"flight_number"];
//    [param setObject:@"放鹤路1088号" forKey:@"destination"];
//    [param setObject:timeStampStr forKey:@"start_time"];
//    [param setObject:@"3" forKey:@"audit_number"];
//    [param setObject:@"2" forKey:@"children_number"];
//    [param setObject:@"1" forKey:@"baggage_number"];
//    [param setObject:@"彪哥" forKey:@"contact"];
//    [param setObject:@"15515916027" forKey:@"contact_number"];
//    [param setObject:@"飞雪连天射白鹿,笑书神侠倚碧鸳.京东包车景点简介京东包车景点简介京东包车景点简介 京东包车景点简介京东包车景点简介京东包车景点简介 京东包车景点简介京东包车景 拷贝" forKey:@"remark"];
    
    sender.userInteractionEnabled = NO;
    __weak __typeof(self) weakSelf = self;
    [ProgressHUDHelper showLoading];
    [BGOrderTravelApi uploadPreInfo:param succ:^(NSDictionary *response) {
        DLog(@"\n>>>[uploadPreInfo sucess]:%@",response);
        BGPickUpOrderPayViewController *payVC = BGPickUpOrderPayViewController.new;
        payVC.order_number = [NSString stringWithFormat:@"%@",BGdictSetObjectIsNil(response[@"result"][@"order_number"])];
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
#pragma mark - THDatePickerViewDelegate
/**
 保存按钮代理方法
 
 @param timer 选择的数据
 */
- (void)datePickerViewSaveBtnClickDelegate:(NSString *)timer {
   
    self.arriveTimeTextField.text = timer;
    [UIView transitionWithView:self.backView duration:0.3 options:0 animations:^{
        self.backView.backgroundColor = [UIColor clearColor];
        self.dateView.frame = CGRectMake(0, SCREEN_HEIGHT, SCREEN_WIDTH, DateViewHeight);
    } completion:^(BOOL finished) {
        [self.backView removeFromSuperview];
        self.backView = nil;
    }];
}

/**
 取消按钮代理方法
 */
- (void)datePickerViewCancelBtnClickDelegate {
    [UIView transitionWithView:self.backView duration:0.3 options:0 animations:^{
        self.backView.backgroundColor = [UIColor clearColor];
        self.dateView.frame = CGRectMake(0, SCREEN_HEIGHT, SCREEN_WIDTH, DateViewHeight);
    } completion:^(BOOL finished) {
        [self.backView removeFromSuperview];
        self.backView = nil;
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
