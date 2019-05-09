//
//  BGWalletAddBankCardViewController.m
//  shzTravelC
//
//  Created by 孙林茂 on 2018/5/12.
//  Copyright © 2018年 biao. All rights reserved.
//

#import "BGWalletAddBankCardViewController.h"
#import "BGPickViewController.h"
#import "BGPurseApi.h"
#import "UITextField+BGLimit.h"
#import "BGMyBankCardModel.h"

@interface BGWalletAddBankCardViewController ()<pickViewDelegate>
@property (weak, nonatomic) IBOutlet UITextField *nameTextField;
@property (weak, nonatomic) IBOutlet UITextField *bankNameTextField;
@property (weak, nonatomic) IBOutlet UITextField *bankNumTextField;
@property (weak, nonatomic) IBOutlet UIButton *sureBtn;
@property (nonatomic, strong) NSMutableArray *bankNameArr;
@property(nonatomic,copy) NSString *bankIdStr;

@end

@implementation BGWalletAddBankCardViewController
-(NSMutableArray *)bankNameArr{
    if (!_bankNameArr) {
        self.bankNameArr = [NSMutableArray array];
    }
    return _bankNameArr;
}
- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self loadSubViews];
}
-(void)loadSubViews {
    
    self.navigationItem.title = @"添加银行卡";
    self.view.backgroundColor = kAppBgColor;
    [self.bankNameTextField setEnabled:NO];
    self.bankNumTextField.digitsChars = @[@"0",@"1",@"2",@"3",@"4",@"5",@"6",@"7",@"8",@"9"];
    self.bankIdStr = @"";
}

- (IBAction)btnSelectedBankClicked:(UIButton *)sender {
    [ProgressHUDHelper showLoading];
    __block typeof(self)weakSelf = self;
    [BGPurseApi getBankNameList:nil succ:^(NSDictionary *response) {
          DLog(@"\n>>>[getBankNameList success]:%@",response);
        weakSelf.bankNameArr = [BGMyBankCardModel mj_objectArrayWithKeyValuesArray:BGdictSetObjectIsNil(response[@"result"])];
        NSMutableArray *nameArr = [[NSMutableArray alloc] init];
        for (BGMyBankCardModel *model in weakSelf.bankNameArr) {
            [nameArr addObject:model.name];
        }
        BGPickViewController *pick = [[BGPickViewController alloc] initWithNibName:@"BGPickViewController" bundle:nil];
        pick.delegate = self;
        pick.arry = nameArr;
        pick.modalPresentationStyle = UIModalPresentationCustom;
        
        [weakSelf presentViewController:pick animated:YES completion:nil];
        
    } failure:^(NSDictionary *response) {
          DLog(@"\n>>>[getBankNameList failure]:%@",response);
    }];
   
    
}

- (IBAction)btnSureAddBankCardClicked:(UIButton *)sender {
    [self keyboarkHidden];
    if (_nameTextField.text.length<1) {
        [WHIndicatorView toast:@"请填写真实姓名"];
        return;
    }
   
    if ([Tool isBlankString:_bankIdStr]) {
        [WHIndicatorView toast:@"请选择开户银行"];
        return;
    }
    if (_bankNumTextField.text.length<1) {
         [WHIndicatorView toast:@"请填写银行卡号"];
        return;
    }
    
   
    [ProgressHUDHelper showLoading];
    NSMutableDictionary *param = [[NSMutableDictionary alloc] init];
    [param setObject:_bankIdStr forKey:@"bank_id"];        // 银行
    [param setObject:self.bankNumTextField.text forKey:@"bank_number"];   // 卡号
    [param setObject:self.nameTextField.text forKey:@"cardholder"];    // 开户名
  
    
    __block typeof(self)weakSelf = self;
    [BGPurseApi addBankCard:param succ:^(NSDictionary *response) {
          DLog(@"\n>>>[addBankCard success]:%@",response);
        if (self.refreshEditBlock) {
            self.refreshEditBlock();
        }
        if (self.isCanSelect) {
           [[NSNotificationCenter defaultCenter] postNotificationName:@"AddBankRefreshNotification" object:nil];
        }
        [weakSelf.navigationController popViewControllerAnimated:YES];
    } failure:^(NSDictionary *response) {
          DLog(@"\n>>>[addBankCard failure]:%@",response);
    }];
}


-(void)getTextStr:(NSString *)text index:(NSInteger)index{
  _bankNameTextField.text = text;
    BGMyBankCardModel *model = self.bankNameArr[index];
    self.bankIdStr = model.ID;
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
