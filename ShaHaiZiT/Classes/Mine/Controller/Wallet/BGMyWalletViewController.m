//
//  BGMyWalletViewController.m
//  shzTravelC
//
//  Created by 孙林茂 on 2018/5/10.
//  Copyright © 2018年 biao. All rights reserved.
//

#import "BGMyWalletViewController.h"
#import "BGWalletAccountDetailViewController.h"
#import "BGWalletWithDrawViewController.h"
#import "BGWalletRechargeViewController.h"
#import "BGWalletCouponViewController.h"
#import "BGWalletBankCardViewController.h"
#import "BGWalletRecommendViewController.h"
#import "BGPurseApi.h"

@interface BGMyWalletViewController ()
@property (weak, nonatomic) IBOutlet UILabel *walletBalanceLabel;
@property (weak, nonatomic) IBOutlet UILabel *couponNumLabel;
@property(nonatomic,copy) NSString *recommendMoneyStr;

@end

@implementation BGMyWalletViewController
-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    self.navigationController.navigationBarHidden = YES;
}
-(void)dealloc{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"MyWalletRefreshNotification" object:nil];
}
-(void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    self.navigationController.navigationBarHidden = NO;
}
- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = kAppBgColor;
    NSString *couponNumStr = [self valueForKeyJude:@"UserCoupon"] ? : @"0";
    if (couponNumStr.intValue > 0) {
        self.couponNumLabel.text = [NSString stringWithFormat:@"%@张",couponNumStr];
    }else{
        self.couponNumLabel.text = @"";
    }
    self.couponNumLabel.hidden = NO;
    [self loadData];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(MyWalletRefreshAction) name:@"MyWalletRefreshNotification" object:nil];
}
-(void)loadData {

    __block typeof(self)weakSelf = self;
    [BGPurseApi getPurseBalance:nil succ:^(NSDictionary *response) {
        DLog(@"\n>>>[getPurseBalance success]:%@",response);
        NSString *moneyStr = BGdictSetObjectIsNil(response[@"result"][@"money"]);
        weakSelf.walletBalanceLabel.text = [NSString stringWithFormat:@"¥%.2f",moneyStr.doubleValue];
        weakSelf.recommendMoneyStr = [NSString stringWithFormat:@"%@",BGdictSetObjectIsNil(response[@"result"][@"commission_count"])];
    } failure:^(NSDictionary *response) {
        DLog(@"\n>>>[getPurseBalance failure]:%@",response);
    }];
}

- (IBAction)btnWalletRechargeClicked:(UIButton *)sender {
    BGWalletRechargeViewController *rechargeVC = BGWalletRechargeViewController.new;
    [self.navigationController pushViewController:rechargeVC animated:YES];
}
- (IBAction)btnWalletWithdrawClicked:(UIButton *)sender {

    BGWalletWithDrawViewController *withDrawVC = BGWalletWithDrawViewController.new;
    [self.navigationController pushViewController:withDrawVC animated:YES];
}
- (IBAction)btnWalletCouponClicked:(UIButton *)sender {
    BGWalletCouponViewController *couponVC = BGWalletCouponViewController.new;
    [self.navigationController pushViewController:couponVC animated:YES];
}

- (IBAction)btnWalletCardClicked:(UIButton *)sender {
    BGWalletBankCardViewController *cardVC = BGWalletBankCardViewController.new;
    cardVC.isCanSelect = NO;
    [self.navigationController pushViewController:cardVC animated:YES];
}

- (IBAction)btnWalletDetailClicked:(UIButton *)sender {
    BGWalletAccountDetailViewController *accountDetailVC = BGWalletAccountDetailViewController.new;
    [self.navigationController pushViewController:accountDetailVC animated:YES];
}
- (IBAction)btnWalletRecommendClicked:(UIButton *)sender {
    BGWalletRecommendViewController *recommendVC = BGWalletRecommendViewController.new;
    if ([Tool isBlankString:self.recommendMoneyStr]) {
        recommendVC.recommendMoneyStr = @"0.00";
    }else{
        recommendVC.recommendMoneyStr = self.recommendMoneyStr;
    }
    [self.navigationController pushViewController:recommendVC animated:YES];
}

-(void)MyWalletRefreshAction{
    [self loadData];
}
- (IBAction)btnBackClicked:(UIButton *)sender {
    [self.navigationController popViewControllerAnimated:YES];
}
-(NSString *)valueForKeyJude:(NSString *)key{
    NSString *valueStr = [NSString stringWithFormat:@"%@", BGGetUserDefaultObjectForKey(key)];
    if ([Tool isBlankString:valueStr]) {
        return nil;
    }else{
        return valueStr;
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
