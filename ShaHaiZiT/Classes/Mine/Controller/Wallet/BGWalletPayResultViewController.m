//
//  BGWalletPayResultViewController.m
//  shzTravelC
//
//  Created by 孙林茂 on 2018/5/11.
//  Copyright © 2018年 biao. All rights reserved.
//

#import "BGWalletPayResultViewController.h"
#import "BGMyWalletViewController.h"

@interface BGWalletPayResultViewController ()
@property (weak, nonatomic) IBOutlet UIImageView *payResultImg;
@property (weak, nonatomic) IBOutlet UIButton *backBtn;
@property (weak, nonatomic) IBOutlet UILabel *pageTitleLabel;


@end

@implementation BGWalletPayResultViewController
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
    
    self.backBtn.layer.cornerRadius = 10;
    self.backBtn.layer.borderWidth = 2;
    self.backBtn.layer.borderColor = kAppMainColor.CGColor;
    
    if (self.isPaySuccess) {
         self.pageTitleLabel.text = @"充值成功";
        self.payResultImg.image = [UIImage imageNamed:@"mine_pay_result_success"];
    } else {
        self.pageTitleLabel.text = @"充值失败";
        self.payResultImg.image = [UIImage imageNamed:@"mine_pay_result_fail"];
    }
    
}

- (IBAction)btnBackHomeClicked:(UIButton *)sender {
    
    for (UIViewController *controller in self.navigationController.viewControllers) {
        if ([controller isKindOfClass:[BGMyWalletViewController class]]) {
            [[NSNotificationCenter defaultCenter] postNotificationName:@"MyWalletRefreshNotification" object:nil];
            BGMyWalletViewController *walletVC =(BGMyWalletViewController *)controller;
            [self.navigationController popToViewController:walletVC animated:YES];
        }
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
