//
//  BGLoginViewController.m
//  shzTravelC
//
//  Created by 孙林茂 on 2018/5/4.
//  Copyright © 2018年 biao. All rights reserved.
//

#import "BGLoginViewController.h"
#import "BGRegisterViewController.h"
#import "BGForgetViewController.h"
#import "BGSystemApi.h"
#import <UMShare/UMShare.h>
#import "JPUSHService.h"
#import "SHZCountryViewController.h"

@interface BGLoginViewController ()
@property (weak, nonatomic) IBOutlet UIView *loginView;
@property (weak, nonatomic) IBOutlet UIView *leftDotLine;
@property (weak, nonatomic) IBOutlet UIView *rightDotLine;
@property (weak, nonatomic) IBOutlet UIButton *eyeBtn;
@property (weak, nonatomic) IBOutlet UIButton *loginBtn;
@property (weak, nonatomic) IBOutlet UITextField *phoneTextField;
@property (weak, nonatomic) IBOutlet UITextField *secureTextField;
@property (weak, nonatomic) IBOutlet UIButton *btnCountry;
@property (nonatomic, copy) NSMutableDictionary *countryPhoneDic;

@end

@implementation BGLoginViewController
-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    self.navigationController.navigationBarHidden = YES;
}
-(void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    self.navigationController.navigationBarHidden = NO;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self loadSubViews];
    _countryPhoneDic = [[NSMutableDictionary alloc] initWithDictionary:@{@"c_code":@"86",@"code":@"CN",@"name":@"中国"}];
}
-(void)loadSubViews{
    _loginView.clipsToBounds = YES;
    _loginView.layer.cornerRadius = 10;
    
    UIView *shadowView = [[UIView alloc]initWithFrame:_loginView.frame];
    
    [self.view addSubview:shadowView];
    
    shadowView.layer.shadowColor = UIColorFromRGB(0x0E4E7D).CGColor;
    
    shadowView.layer.shadowOffset = CGSizeMake(0, 10);
    
    shadowView.layer.shadowOpacity = 0.2;
    
    shadowView.layer.shadowRadius = 5.0;
    
    shadowView.layer.cornerRadius = 5.0;
    
    shadowView.clipsToBounds = NO;
    
    [shadowView addSubview:_loginView];

}
-(void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    [Tool drawDashLine:_leftDotLine lineLength:5 lineSpacing:2 lineColor:kAppDotLineColor];
    [Tool drawDashLine:_rightDotLine lineLength:5 lineSpacing:2 lineColor:kAppDotLineColor];
    if (IS_iPhone5) {
        [UIView animateWithDuration:0.2 animations:^{
            self.loginView.height = 250;
        }];
    }
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
- (IBAction)btnForgetPwdClicked:(UIButton *)sender {
    // 忘记密码
    BGForgetViewController *forgetVC = BGForgetViewController.new;
    // 接收block传来的手机号码
    forgetVC.block= ^(NSString *str){
        self.phoneTextField.text = str;
    };
    [self.navigationController pushViewController:forgetVC animated:YES];
}
- (IBAction)btnLoginClicked:(UIButton *)sender {
    [self keyboarkHidden];
    if (self.secureTextField.text.length >= 6 && self.secureTextField.text.length <= 30) {
        self.loginBtn.userInteractionEnabled = NO;
        [self loginAction];
    } else {
        [WHIndicatorView toast:@"请输入6-30位数字、字母、符号"];
    }
   
}

- (void)loginAction {
    
    NSMutableDictionary *param = [[NSMutableDictionary alloc] init];
    [param setObject:self.phoneTextField.text forKey:@"phone"];
    [param setObject:self.secureTextField.text forKey:@"password"];
//    [param setObject:_countryPhoneDic[@"c_code"] forKey:@"country_code"];
    
    [param setObject:@"" forKey:@"registration_id"];

#if DEBUG
    
#else
    NSString *deviceToken = [JPUSHService registrationID];
    [param setObject:deviceToken forKey:@"registration_id"];     // 极光设备标识
#endif
    
    
    [ProgressHUDHelper showLoading];
    [BGSystemApi LoginByPhone:param succ:^(NSDictionary *response) {
        self.loginBtn.userInteractionEnabled = YES;
        DLog(@"\n>>>[Login sucess]:%@",response);
        [[NSNotificationCenter defaultCenter] postNotificationName:@"LoginSuccessNotification" object:nil];
        if (self.navigationController == [BGAppDelegateHelper delegateRootViewController]) {
            [BGAppDelegateHelper setCustomTabBarControllerAsRootViewController];
        } else {
            [self dismissViewControllerAnimated:YES completion:nil];
        }
    } failure:^(NSDictionary *response) {
        DLog(@"\n>>>[Login failure]:%@",response);
        
        self.loginBtn.userInteractionEnabled = YES;
    }];
}

- (IBAction)btnWeChatLoginClicked:(UIButton *)sender {
    [self keyboarkHidden];
    [self getUserInfoForPlatform:(UMSocialPlatformType_WechatSession)];
}
- (IBAction)btnQQLoginClicked:(UIButton *)sender {
    [self keyboarkHidden];
    [self getUserInfoForPlatform:(UMSocialPlatformType_QQ)];
}

- (IBAction)btnRegisterClicked:(UIButton *)sender {
    [self keyboarkHidden];
    // 立即注册
    BGRegisterViewController *registerVC = BGRegisterViewController.new;
    registerVC.isBinding = NO;
    [self.navigationController pushViewController:registerVC animated:YES];
    
}
/**
 友盟第三方登录
 
 @param platformType 类型
 */
- (void)getUserInfoForPlatform:(UMSocialPlatformType)platformType
{
   
    [[UMSocialManager defaultManager] getUserInfoWithPlatform:platformType currentViewController:self completion:^(id result, NSError *error) {
        
        if (error) {
            [WHIndicatorView toast:@"登录失败,请选择其它登录方式"];
        } else {
            UMSocialUserInfoResponse *resp = result;
            // 授权数据
            if (platformType == UMSocialPlatformType_WechatSession) {
                [self thirdLoginWithUnionid:resp.uid type:@"weixin" headImgUrl:resp.iconurl];
            }else if (platformType == UMSocialPlatformType_QQ) {
                 [self thirdLoginWithUnionid:resp.uid type:@"qq" headImgUrl:resp.iconurl];
            }
        }
        
    }];
    
}

/**
 三方登陆

 @param uid 微信unionid
 @param type 三方名称类型
 */
-(void)thirdLoginWithUnionid:(NSString *)uid type:(NSString *)type headImgUrl:(NSString *)headImgUrl{
    
    NSMutableDictionary *param = [[NSMutableDictionary alloc] init];
    [param setObject:uid forKey:@"open_id"];
    [param setObject:type forKey:@"type"];

    NSString *deviceToken = [JPUSHService registrationID];
    [param setObject:deviceToken forKey:@"registration_id"];     // 极光设备标识
    
    [ProgressHUDHelper showLoading];
    __weak typeof(self) weakSelf = self;

    [BGSystemApi loginByThird:param succ:^(NSDictionary *response) {
        DLog(@"\n>>>[loginByThird sucess]:%@",response);
            [[NSNotificationCenter defaultCenter] postNotificationName:@"LoginSuccessNotification" object:nil];
            if (self.navigationController == [BGAppDelegateHelper delegateRootViewController]) {
                [BGAppDelegateHelper setCustomTabBarControllerAsRootViewController];
            } else {
                [self dismissViewControllerAnimated:YES completion:nil];
            }
    } failure:^(NSDictionary *response) {
        DLog(@"\n>>>[loginByThird failure]:%@",response);
        if ([BGdictSetObjectIsNil(response[@"code"]) integerValue] == 204) {
            BGRemoveUserDefaultObjectForKey(@"Token");
            BGRegisterViewController *registerVC = BGRegisterViewController.new;
            registerVC.isBinding = YES;
            registerVC.uid = uid;
            registerVC.headImgUrl = headImgUrl;
            registerVC.type = type;
            [weakSelf.navigationController pushViewController:registerVC animated:NO];
        }
    }];
}
- (IBAction)btnHideLoginClicked:(UIButton *)sender {
     [self keyboarkHidden];
    [self.navigationController dismissViewControllerAnimated:YES completion:nil];

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
