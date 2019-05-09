//
//  BGWalletWithDrawViewController.m
//  shzTravelC
//
//  Created by 孙林茂 on 2018/5/10.
//  Copyright © 2018年 biao. All rights reserved.
//

#import "BGWalletWithDrawViewController.h"
#import "BGWalletSubmitSuccessViewController.h"
#import "BGWalletBankCardViewController.h"
#import "BGPurseApi.h"
#import <UIImageView+WebCache.h>
#import <JCAlertController.h>

#define myDotNumbers     @"0123456789.\n"
#define myNumbers          @"0123456789\n"
@interface BGWalletWithDrawViewController ()<UITextFieldDelegate>
@property (weak, nonatomic) IBOutlet UIImageView *bankLogoImgView;
@property (weak, nonatomic) IBOutlet UILabel *bankNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *bankTipsLabel;

@property (weak, nonatomic) IBOutlet UILabel *feeLabel;
@property (weak, nonatomic) IBOutlet UITextField *balanceTextField;
@property (weak, nonatomic) IBOutlet UILabel *balanceLimitLabel;
@property (weak, nonatomic) IBOutlet UIButton *sureBtn;

@property (nonatomic, copy) NSString *cardIdStr;
@property (nonatomic, copy) NSString *submitBankCardInfoStr;
@property(nonatomic,copy) NSString *moneyStr;
@property(nonatomic,copy) NSString *feeStr;

@end

@implementation BGWalletWithDrawViewController

-(void)dealloc{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"AddBankRefreshNotification" object:nil];
}
- (void)viewDidLoad {
    [super viewDidLoad];

    [self loadSubViews];
    [self loadData];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(AddBankRefreshAction) name:@"AddBankRefreshNotification" object:nil];
}
-(void)loadData {
    
    [ProgressHUDHelper showLoading];
    __block typeof(self)weakSelf = self;
    [BGPurseApi getPurseBalance:nil succ:^(NSDictionary *response) {
        DLog(@"\n>>>[getPurseBalance success]:%@",response);
        [weakSelf updataWithDic:BGdictSetObjectIsNil(response[@"result"])];
    } failure:^(NSDictionary *response) {
        DLog(@"\n>>>[getPurseBalance failure]:%@",response);
    }];
}
-(void)updataWithDic:(NSDictionary *)dataDic {
    self.moneyStr = [NSString stringWithFormat:@"%.2f",[BGdictSetObjectIsNil(dataDic[@"money"]) doubleValue]];
    
     _balanceLimitLabel.text = [NSString stringWithFormat:@"可用余额%@元",_moneyStr];
    
    [BGPurseApi getDefaultBankCard:nil succ:^(NSDictionary *response) {
        DLog(@"\n>>>[getDefaultBankCard success]:%@",response);
        [self getDefaultBankCard:BGdictSetObjectIsNil(response[@"result"])];
    } failure:^(NSDictionary *response) {
        DLog(@"\n>>>[getDefaultBankCard failure]:%@",response);
        self.bankNameLabel.text = @"暂无";
        self.bankTipsLabel.text = @"";
    }];
}
-(void)getDefaultBankCard:(NSDictionary *)dataDic {
    self.sureBtn.userInteractionEnabled = YES;
    [self.sureBtn setTitle:[NSString stringWithFormat:@"预计%@个工作日内到账,确认提现",BGdictSetObjectIsNil(dataDic[@"withdrawal_date"])] forState:(UIControlStateNormal)];
    [self.bankLogoImgView sd_setImageWithURL:[NSURL URLWithString:BGdictSetObjectIsNil(dataDic[@"bank_logo"])]];
 self.bankNameLabel.text = [NSString stringWithFormat:@"`%@",BGdictSetObjectIsNil(dataDic[@"name"])];
    self.bankTipsLabel.text = [NSString stringWithFormat:@"尾号%@储蓄卡",BGdictSetObjectIsNil(dataDic[@"bank_number"])];
    self.feeStr = [NSString stringWithFormat:@"%.2f",[BGdictSetObjectIsNil(dataDic[@"bank_rate"]) doubleValue]];
    self.cardIdStr = [NSString stringWithFormat:@"%@",BGdictSetObjectIsNil(dataDic[@"id"])];
    self.feeLabel.text = [NSString stringWithFormat:@"提现金额（收取%.1f%%服务费）",[BGdictSetObjectIsNil(dataDic[@"bank_rate"]) doubleValue]];
    self.submitBankCardInfoStr = [NSString stringWithFormat:@"%@ 尾号%@",self.bankNameLabel.text,BGdictSetObjectIsNil(dataDic[@"bank_number"])];
}

-(void)loadSubViews {
    self.navigationItem.title = @"提现";
    self.view.backgroundColor = kAppBgColor;
    self.cardIdStr = @"";
    self.moneyStr = @"";
}
- (IBAction)btnMoneyAllClicked:(UIButton *)sender {
    if (![Tool isBlankString:self.moneyStr]) {
        self.balanceTextField.text = self.moneyStr;
    }
}

- (IBAction)btnSelectBankCardClicked:(UIButton *)sender {
    
    BGWalletBankCardViewController *bankCardVC = BGWalletBankCardViewController.new;
    bankCardVC.isCanSelect = YES;
    bankCardVC.refreshEditBlock = ^{
        [self loadData];
    };
    [self.navigationController pushViewController:bankCardVC animated:YES];
}

- (IBAction)btnSureClicked:(UIButton *)sender {
    if ([Tool isBlankString:_cardIdStr]) {
        [WHIndicatorView toast:@"请选择提现银行卡"];
        return;
    }
    if (_balanceTextField.text.length<1) {
        [WHIndicatorView toast:@"请输入提现金额"];
        return;
    }
    if (_balanceTextField.text.doubleValue<0.01) {
        [WHIndicatorView toast:@"请输入提现金额"];
        return;
    }
    NSString *tipStr = [NSString stringWithFormat:@"提现金额：%.2f元\n本次服务费：%.2f元",_balanceTextField.text.doubleValue,_balanceTextField.text.doubleValue*_feeStr.doubleValue/100];
       JCAlertController *alert = [JCAlertController alertWithTitle:@"收费提示" message:tipStr];
        
        [alert addButtonWithTitle:@"取消" type:JCButtonTypeCancel clicked:^{
            
        }];
        [alert addButtonWithTitle:@"继续提现" type:JCButtonTypeNormal clicked:^{
            [self withDrawAction];
        }];
    
    JCAlertStyle *style = [JCAlertStyle shareStyle];
    style.background.canDismiss = YES;
    [self presentViewController:alert animated:YES completion:nil];
    
}
-(void)withDrawAction{
    [ProgressHUDHelper showLoading];
    __block typeof(self)weakSelf = self;
    NSMutableDictionary *param = [[NSMutableDictionary alloc] init];
    NSString *moneyStr = [NSString stringWithFormat:@"%.2f",_balanceTextField.text.doubleValue];
    [param setObject:_cardIdStr forKey:@"bank_card_id"];
    [param setObject:moneyStr forKey:@"withdraw_money"];
    [BGPurseApi withDraw:param succ:^(NSDictionary *response) {
        DLog(@"\n>>>[withDraw success]:%@",response);
        
        BGWalletSubmitSuccessViewController *submitVC = BGWalletSubmitSuccessViewController.new;
        submitVC.timeStr = BGdictSetObjectIsNil(response[@"result"][@"arrival_time"]) ?:@"";
        submitVC.bankCardStr = weakSelf.submitBankCardInfoStr;
        NSString *feeStr = [NSString stringWithFormat:@"%@",response[@"result"][@"handling_fee"]?:@"0"];
        submitVC.balanceStr = [NSString stringWithFormat:@"%.2f",(moneyStr.doubleValue-feeStr.doubleValue)];
        [weakSelf.navigationController pushViewController:submitVC animated:YES];
    } failure:^(NSDictionary *response) {
        DLog(@"\n>>>[withDraw failure]:%@",response);
    }];
    
    
}
- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    
    // 判断是否输入内容，或者用户点击的是键盘的删除按钮
    if (![string isEqualToString:@""]) {
        NSCharacterSet *cs;
        // 小数点在字符串中的位置 第一个数字从0位置开始
        
        NSInteger dotLocation = [textField.text rangeOfString:@"."].location;
        
        // 判断字符串中是否有小数点，并且小数点不在第一位
        
        // NSNotFound 表示请求操作的某个内容或者item没有发现，或者不存在
        
        // range.location 表示的是当前输入的内容在整个字符串中的位置，位置编号从0开始
        
        if (dotLocation == NSNotFound && range.location != 0) {
            
            // 取只包含“myDotNumbers”中包含的内容，其余内容都被去掉
            
            /* [NSCharacterSet characterSetWithCharactersInString:myDotNumbers]的作用是去掉"myDotNumbers"中包含的所有内容，只要字符串中有内容与"myDotNumbers"中的部分内容相同都会被舍去在上述方法的末尾加上invertedSet就会使作用颠倒，只取与“myDotNumbers”中内容相同的字符
             */
            cs = [[NSCharacterSet characterSetWithCharactersInString:myDotNumbers] invertedSet];
            if (range.location >= 7) {
                [WHIndicatorView toast:@"单笔金额已超过最大限制"];
                if ([string isEqualToString:@"."] && range.location == 7) {
                    return YES;
                }
                return NO;
            }
        }else {
            
            cs = [[NSCharacterSet characterSetWithCharactersInString:myNumbers] invertedSet];
            
        }
        // 按cs分离出数组,数组按@""分离出字符串
        
        NSString *filtered = [[string componentsSeparatedByCharactersInSet:cs] componentsJoinedByString:@""];
        
        BOOL basicTest = [string isEqualToString:filtered];
        
        if (!basicTest) {
            
            [WHIndicatorView toast:@"只能输入数字和小数点"];
            
            return NO;
            
        }
        
        if (dotLocation != NSNotFound && range.location > dotLocation + 2) {
            
            [WHIndicatorView toast:@"小数点后最多两位"];
            
            return NO;
        }
        if (textField.text.length > 9) {
            [WHIndicatorView toast:@"单笔金额已超过最大限制"];
            return NO;
            
        }
    }
    return YES;
    
}
-(void)AddBankRefreshAction{
    [self loadData];
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
