//
//  BGRegisterViewController.m
//  shzTravelC
//
//  Created by 孙林茂 on 2018/5/7.
//  Copyright © 2018年 biao. All rights reserved.
//

#import "BGRegisterViewController.h"
#import "BGSystemApi.h"
#import "BGWebViewController.h"
#import "JPUSHService.h"
#import "SHZCountryViewController.h"
#import <SafariServices/SafariServices.h>

@interface BGRegisterViewController ()
@property (weak, nonatomic) IBOutlet UIView *registerView;
@property (weak, nonatomic) IBOutlet UIButton *eyeBtn;
@property (weak, nonatomic) IBOutlet UITextField *phoneTextField;
@property (weak, nonatomic) IBOutlet UITextField *secureTextField;
@property (weak, nonatomic) IBOutlet UITextField *codeTextField;
@property (weak, nonatomic) IBOutlet UIButton *codeBtn;
@property (weak, nonatomic) IBOutlet UIButton *loginBtn;

@property (weak, nonatomic) IBOutlet UIImageView *secureImgView;
@property (weak, nonatomic) IBOutlet UIView *secureLineView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *codeBtnTopHeight;
@property (weak, nonatomic) IBOutlet UILabel *registerTitleLabel;
@property (weak, nonatomic) IBOutlet UIButton *btnCountry;

@property(weak,nonatomic)NSTimer *timer;
@property (nonatomic,assign) int timeI;
@property (nonatomic, copy) NSMutableDictionary *countryPhoneDic;

@end

@implementation BGRegisterViewController
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
    _registerView.clipsToBounds = YES;
    _registerView.layer.cornerRadius = 10;

    if (_isBinding) {
        _secureImgView.hidden = YES;
        _secureTextField.hidden = YES;
        _eyeBtn.hidden = YES;
        _secureLineView.hidden = YES;
        self.registerTitleLabel.text = @"绑定手机号码";
        [self.loginBtn setTitle:@"绑定" forState:(UIControlStateNormal)];
        _codeBtnTopHeight.constant = 0;
    }
    
    UIView *shadowView = [[UIView alloc]initWithFrame:_registerView.frame];
    
    [self.view addSubview:shadowView];
    
    shadowView.layer.shadowColor = UIColorFromRGB(0x0E4E7D).CGColor;
    
    shadowView.layer.shadowOffset = CGSizeMake(0, 10);
    
    shadowView.layer.shadowOpacity = 0.2;
    
    shadowView.layer.shadowRadius = 5.0;
    
    shadowView.layer.cornerRadius = 5.0;
    
    shadowView.clipsToBounds = NO;
    
    [shadowView addSubview:_registerView];
}
- (IBAction)btnCountryClicked:(UIButton *)sender {
    SHZCountryViewController *countryVC = [[SHZCountryViewController alloc] initWithNibName:@"SHZCountryViewController" bundle:nil];
    [countryVC countryCellDic:^(NSDictionary *countryDic) {
        [self.btnCountry setTitle:[NSString stringWithFormat:@"+%@ ",countryDic[@"c_code"]] forState:UIControlStateNormal];
        [self.countryPhoneDic setDictionary:countryDic];
    }];
    [self.navigationController pushViewController:countryVC animated:YES];
}

- (IBAction)btnEyeShowClicked:(UIButton *)sender {
    self.eyeBtn.selected = !self.eyeBtn.selected;
    if (self.eyeBtn.selected) {
        self.secureTextField.secureTextEntry = NO;
    } else {
        self.secureTextField.secureTextEntry = YES;
    }
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
    
    NSMutableDictionary *param = [[NSMutableDictionary alloc] init];
   
    [ProgressHUDHelper showLoading];
    if (_isBinding) {
        [param setObject:self.phoneTextField.text forKey:@"mobile"];      // 手机号码
        [param setObject:_countryPhoneDic[@"c_code"] forKey:@"country_code"];
        [BGSystemApi sendThirdSMSCode:param succ:^(NSDictionary *response) {
            DLog(@"\n>>>[sendThirdSMSCode sucess]:%@",response);
            
            self.timer.fireDate = [NSDate distantPast];
            [WHIndicatorView toast:@"短信验证码已发送"];
            
            
        } failure:^(NSDictionary *response) {
            self.codeBtn.enabled = YES;
            DLog(@"\n>>>[sendThirdSMSCode failure]:%@",response);
            
        }];
    }else{
         [param setObject:self.phoneTextField.text forKey:@"mobile"];      // 手机号码
        [param setObject:_countryPhoneDic[@"c_code"] forKey:@"country_code"];
        [BGSystemApi sendRegistSMSCode:param succ:^(NSDictionary *response) {
            DLog(@"\n>>>[sendRegistSMSCode sucess]:%@",response);
            
            self.timer.fireDate = [NSDate distantPast];
            [WHIndicatorView toast:@"短信验证码已发送"];
            
            
        } failure:^(NSDictionary *response) {
            self.codeBtn.enabled = YES;
            DLog(@"\n>>>[sendRegistSMSCode failure]:%@",response);
            
        }];
    }
    
}
- (IBAction)btnRegisterClicked:(UIButton *)sender {
//     if ([_countryPhoneDic[@"code"] isEqualToString:@"CN"]) {
//         if (![Tool isMobile:self.phoneTextField.text]) {
//             [WHIndicatorView toast:@"请输入正确的手机号"];
//             return;
//         }
//     }
    
    if (self.codeTextField.text.length != 6) {
        [WHIndicatorView toast:@"请输入6位验证码"];
        return;
    }
    if (_isBinding) {
        
    }else{
        if (self.secureTextField.text.length < 6 || self.secureTextField.text.length > 20) {
            [WHIndicatorView toast:@"请输入6-20位数字、字母、符号"];
            return;
        }
    }
   
    self.loginBtn.userInteractionEnabled = NO;
    [self registerData];
    
}
/**
 注册用户
 */
- (void)registerData {
    
    NSMutableDictionary *param = [[NSMutableDictionary alloc] init];
    [param setObject:self.phoneTextField.text forKey:@"phone"]; // 手机号码
    if (_isBinding) {
        [param setObject:_uid forKey:@"open_id"];  // 三方登录UID
        [param setObject:_headImgUrl forKey:@"face"];  // 三方登录头像
        [param setObject:_type forKey:@"type"];  // 三方登录类型

    }else{
        [param setObject:self.secureTextField.text forKey:@"password"];  // 密码
    }
    
    [param setObject:self.codeTextField.text forKey:@"code"];     // 验证码

    NSString *deviceToken = [JPUSHService registrationID];
    [param setObject:deviceToken forKey:@"registration_id"];     // 极光设备标识
    
    DLog(@"\n>>>[registerData param]:%@",param);
    [ProgressHUDHelper showLoading];
    __block typeof(self) weakSelf = self;
    [BGSystemApi regist:param succ:^(NSDictionary *response) {
        self.loginBtn.userInteractionEnabled = YES;
        DLog(@"\n>>>[regist sucess]:%@",response);
         [weakSelf removeTimerAction];
        if (weakSelf.navigationController == [BGAppDelegateHelper delegateRootViewController]) {
            [BGAppDelegateHelper setCustomTabBarControllerAsRootViewController];
        } else {
            [weakSelf dismissViewControllerAnimated:YES completion:nil];
        }
    } failure:^(NSDictionary *response) {
        DLog(@"\n>>>[regist failure]:%@",response);
        
        weakSelf.loginBtn.userInteractionEnabled = YES;
    }];
    
}

- (IBAction)btnJumpToAgreementClicked:(UIButton *)sender {
    [self keyboarkHidden];
    BGWebViewController *webVC = [[BGWebViewController alloc] init];
    webVC.url = BGWebPages(@"registProtocol.html");
    [self.navigationController pushViewController:webVC animated:YES];
}
- (IBAction)btnJumpToPolicyClicked:(UIButton *)sender {
    [self keyboarkHidden];
    SFSafariViewController *safariVc = [[SFSafariViewController alloc] initWithURL:[NSURL URLWithString:BGWebPages(@"privacyPolicy.html")]];
    [self presentViewController:safariVc animated:YES completion:nil];
}


- (IBAction)btnBackClicked:(UIButton *)sender {
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
