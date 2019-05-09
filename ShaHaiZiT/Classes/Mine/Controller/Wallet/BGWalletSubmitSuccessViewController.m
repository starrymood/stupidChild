//
//  BGWalletSubmitSuccessViewController.m
//  shzTravelS
//
//  Created by 孙林茂 on 2018/5/24.
//  Copyright © 2018年 biao. All rights reserved.
//

#import "BGWalletSubmitSuccessViewController.h"
#import "BGMyWalletViewController.h"

@interface BGWalletSubmitSuccessViewController ()
@property (weak, nonatomic) IBOutlet UILabel *recieveTimeLabel;
@property (weak, nonatomic) IBOutlet UILabel *recieveBankCardLabel;
@property (weak, nonatomic) IBOutlet UILabel *recieveBalanceLabel;

@end

@implementation BGWalletSubmitSuccessViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    [self loadSubViews];
}

-(void)loadSubViews {
    
    self.navigationItem.title = @"提现申请成功";
    self.view.backgroundColor = kAppBgColor;
    // 左上角隐藏返回键
    UIBarButtonItem *leftItem = [[UIBarButtonItem alloc] initWithTitle:@"" style:(UIBarButtonItemStyleDone) target:self action:nil];
    self.navigationItem.leftBarButtonItem = leftItem;
    self.recieveTimeLabel.text = [Tool dateFormatter:_timeStr.doubleValue dateFormatter:@"yyyy-MM-dd HH:mm"];
    self.recieveBankCardLabel.text = _bankCardStr;
    self.recieveBalanceLabel.text = [NSString stringWithFormat:@"￥%@(已扣除手续费)",self.balanceStr];
    
}
- (IBAction)btnDoneClicked:(UIButton *)sender {
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
