//
//  BGForgetViewController.m
//  shzTravelC
//
//  Created by 孙林茂 on 2018/5/7.
//  Copyright © 2018年 biao. All rights reserved.
//

#import "BGForgetViewController.h"
#import "BGSystemApi.h"
#import "SHZCountryViewController.h"

@interface BGForgetViewController ()
@property (weak, nonatomic) IBOutlet UIView *forgetView;
@property (weak, nonatomic) IBOutlet UITextField *phoneTextField;
@property (weak, nonatomic) IBOutlet UITextField *codeTextField;
@property (weak, nonatomic) IBOutlet UITextField *secureTextField;
@property (weak, nonatomic) IBOutlet UITextField *confirmTextField;
@property (weak, nonatomic) IBOutlet UIButton *codeBtn;
@property (weak, nonatomic) IBOutlet UIButton *loginBtn;
@property (nonatomic, copy) NSMutableDictionary *countryPhoneDic;
@property (weak, nonatomic) IBOutlet UIButton *btnCountry;

@property(weak,nonatomic)NSTimer *timer;
@property (nonatomic,assign) int timeI;

@end

@implementation BGForgetViewController
//懒加载定时器
- (NSTimer *)timer {
    if (!_timer) {
        _timeI = 60;
        self.timer = [NSTimer scheduledTimerWithTimeInterval:1.0  target:self selector:@selector(timeChange) userInfo:nil repeats:YES];
    }
    return _timer;
}
-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    self.navigationController.navigationBarHidden = YES;
}

-(void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    self.navigationController.navigationBarHidden = NO;
//    if (_timer) {
//        [self removeTimerAction];
//    }
}
- (void)viewDidLoad {
    [super viewDidLoad];
    [self loadSubViews];
    _countryPhoneDic = [[NSMutableDictionary alloc] initWithDictionary:@{@"c_code":@"86",@"code":@"CN",@"name":@"中国"}];
}
-(void)loadSubViews{
    _forgetView.clipsToBounds = YES;
    _forgetView.layer.cornerRadius = 10;
//    _forgetView.layer.borderWidth = 1;
//    _forgetView.layer.borderColor = kAppDotLineColor.CGColor;
    
    UIView *shadowView = [[UIView alloc]initWithFrame:_forgetView.frame];
    
    [self.view addSubview:shadowView];
    
    shadowView.layer.shadowColor = UIColorFromRGB(0x0E4E7D).CGColor;
    
    shadowView.layer.shadowOffset = CGSizeMake(0, 10);
    
    shadowView.layer.shadowOpacity = 0.2;
    
    shadowView.layer.shadowRadius = 5.0;
    
    shadowView.layer.cornerRadius = 5.0;
    
    shadowView.clipsToBounds = NO;
    
    [shadowView addSubview:_forgetView];
    
}
- (IBAction)btnCountryClicked:(UIButton *)sender {
    SHZCountryViewController *countryVC = [[SHZCountryViewController alloc] initWithNibName:@"SHZCountryViewController" bundle:nil];
    [countryVC countryCellDic:^(NSDictionary *countryDic) {
        [self.btnCountry setTitle:[NSString stringWithFormat:@"+%@ ",countryDic[@"c_code"]] forState:UIControlStateNormal];
        [self.countryPhoneDic setDictionary:countryDic];
    }];
    [self.navigationController pushViewController:countryVC animated:YES];
}

- (IBAction)btnGetSMSCodeClicked:(UIButton *)sender {
    [self keyboarkHidden];
    if ([_countryPhoneDic[@"code"] isEqualToString:@"CN"]) {
        self.codeBtn.enabled = NO;
        [self sendSMSCodeAction];
    }else{
        if ([self.phoneTextField.text hasPrefix:@"0"]) {
            [WHIndicatorView toast:@"国际号码前无需加0"];
            return;
        }
        self.codeBtn.enabled = NO;
        [self sendSMSCodeAction];
    }
}
/**
 发送短信验证码
 */
-(void)sendSMSCodeAction {
    
    [self keyboarkHidden];
    NSMutableDictionary *param = [[NSMutableDictionary alloc] init];
    
    [param setObject:self.phoneTextField.text forKey:@"mobile"];      // 手机号码
    [param setObject:_countryPhoneDic[@"c_code"] forKey:@"country_code"];
    [ProgressHUDHelper showLoading];
    [BGSystemApi sendFindSMSCode:param succ:^(NSDictionary *response) {
        DLog(@"\n>>>[sendFindSMSCode sucess]:%@",response);
        
        self.timer.fireDate = [NSDate distantPast];
        [WHIndicatorView toast:@"短信验证码已发送"];
        
    } failure:^(NSDictionary *response) {
        self.codeBtn.enabled = YES;
        DLog(@"\n>>>[sendFindSMSCode failure]:%@",response);
    }];
}

- (IBAction)btnSureClicked:(UIButton *)sender {
     [self keyboarkHidden];
    if (self.codeTextField.text.length == 6) {
        if (self.secureTextField.text.length >= 6 && self.secureTextField.text.length <= 30) {
            if ([self.secureTextField.text isEqualToString:self.confirmTextField.text]) {
                self.loginBtn.userInteractionEnabled = NO;
                [self setNewPassword];
            }else{
                [WHIndicatorView toast:@"两次输入不一致,请重新输入"];
            }
            
        } else {
            [WHIndicatorView toast:@"请输入6-30位数字、字母、符号"];
        }
    } else {
        [WHIndicatorView toast:@"请输入6位验证码"];
    }
    
}

/**
 根据短信验证码设置新密码
 */
-(void)setNewPassword {
    
    NSMutableDictionary *param = [[NSMutableDictionary alloc] init];
    [param setObject:self.phoneTextField.text forKey:@"mobile"]; // 手机号码
    [param setObject:self.secureTextField.text forKey:@"password"];  // 密码
    [param setObject:self.codeTextField.text forKey:@"mobilecode"];     // 验证码
    DLog(@"\n>>>[forgot param]:%@",param);
    [ProgressHUDHelper showLoading];
    __block typeof(self) weakSelf = self;
    [BGSystemApi retrievePassword:param succ:^(NSDictionary *response) {
        weakSelf.loginBtn.userInteractionEnabled = YES;
        DLog(@"\n>>>[forgot sucess]:%@",response);
        [WHIndicatorView toast:response[@"msg"]];
        if(weakSelf.block != nil) {
            weakSelf.block(weakSelf.phoneTextField.text);
        }
         [weakSelf removeTimerAction];
        [weakSelf.navigationController popViewControllerAnimated:YES];
    } failure:^(NSDictionary *response) {
        weakSelf.loginBtn.userInteractionEnabled = YES;
        DLog(@"\n>>>[forgot failure]:%@",response);
    }];
}
- (IBAction)btnBackClicked:(UIButton *)sender {
    [self keyboarkHidden];
    [self.navigationController popViewControllerAnimated:YES];
}
/**
 定时器方法
 */
- (void)timeChange {
    _timeI--;
    [_codeBtn setTitle:[NSString stringWithFormat:@"%d 秒",_timeI] forState:UIControlStateNormal];
    if (_timeI < 1) {
        [_codeBtn setTitle:[NSString stringWithFormat:@"重新发送"] forState:UIControlStateNormal];
        _codeBtn.enabled = YES;
        [self removeTimerAction];
        
    }
}
//移除定时器
-(void)removeTimerAction {
    [_timer invalidate];
    //把定时器清空
    _timer = nil;
}
//设置block,设置要传的值
- (void)text:(phoneNumBlock)block
{
    self.block = block;
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
