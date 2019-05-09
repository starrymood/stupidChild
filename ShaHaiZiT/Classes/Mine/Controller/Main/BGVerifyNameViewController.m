//
//  BGVerifyNameViewController.m
//  ShaHaiZiT
//
//  Created by biao on 2018/12/27.
//  Copyright © 2018 biao. All rights reserved.
//

#import "BGVerifyNameViewController.h"
#import "UITextField+BGLimit.h"
#import "BGSystemApi.h"

@interface BGVerifyNameViewController ()
@property (weak, nonatomic) IBOutlet UITextField *nameTextField;
@property (weak, nonatomic) IBOutlet UITextField *numTextField;
@property (weak, nonatomic) IBOutlet UIButton *sureBtn;

@end

@implementation BGVerifyNameViewController
-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    self.navigationController.navigationBarHidden = NO;
}

- (void)viewDidLoad {
    [super viewDidLoad];

    [self loadSubViews];
    [self loadData];
}

-(void)loadSubViews {
    
    self.navigationItem.title = @"实名认证";
    self.view.backgroundColor = kAppBgColor;
    self.numTextField.maxLenght = 30;
}
-(void)loadData{
    [ProgressHUDHelper showLoading];
    NSMutableDictionary *param = [[NSMutableDictionary alloc] init];
    __weak __typeof(self) weakSelf = self;
    [BGSystemApi getVerifyInfo:param succ:^(NSDictionary *response) {
        DLog(@"\n>>>[getVerifyInfo sucess]:%@",response);
        [weakSelf hideNodateView];
        weakSelf.nameTextField.text = BGdictSetObjectIsNil(response[@"result"][@"name"]);
        weakSelf.numTextField.text = BGdictSetObjectIsNil(response[@"result"][@"id_card"]);
        [weakSelf.sureBtn setTitle:@"更改信息" forState:(UIControlStateNormal)];
    } failure:^(NSDictionary *response) {
        DLog(@"\n>>>[getVerifyInfo failure]:%@",response);
        [ProgressHUDHelper removeLoading];
        if ([[NSString stringWithFormat:@"%@",BGdictSetObjectIsNil(response[@"code"])] intValue] != 300) {
            [self shownoNetWorkViewWithType:0];
            [self setRefreshBlock:^{
                [weakSelf loadData];
            }];
        }
    }];
    
}
- (IBAction)deleteNameBtnClickedAction:(UIButton *)sender {
    self.nameTextField.text = @"";
    
}
- (IBAction)deleteNumBtnClickedAction:(UIButton *)sender {
    self.numTextField.text = @"";
}
- (IBAction)uploadInfoBtnClickedAction:(UIButton *)sender {
    [self keyboarkHidden];
    if ([Tool isBlankString:_nameTextField.text]) {
        [WHIndicatorView toast:@"请输入订购人的姓名"];
        return;
    }
    if ([Tool isBlankString:_numTextField.text]) {
        [WHIndicatorView toast:@"请输入订购人的身份证号"];
        return;
    }
    [ProgressHUDHelper showLoading];
    NSMutableDictionary *param = [[NSMutableDictionary alloc] init];
    [param setObject:_nameTextField.text forKey:@"name"];
    [param setObject:_numTextField.text forKey:@"id_card"];
    __weak __typeof(self) weakSelf = self;
    [BGSystemApi uploadVerifyInfo:param succ:^(NSDictionary *response) {
        DLog(@"\n>>>[uploadVerifyInfo sucess]:%@",response);
        [WHIndicatorView toast:BGdictSetObjectIsNil(response[@"msg"])];
        [weakSelf.navigationController popViewControllerAnimated:YES];
    } failure:^(NSDictionary *response) {
        DLog(@"\n>>>[uploadVerifyInfo failure]:%@",response);
        [ProgressHUDHelper removeLoading];
    }];
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
