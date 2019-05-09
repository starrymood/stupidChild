//
//  BGWalletOrderPayResultViewController.m
//  shzTravelC
//
//  Created by biao on 2018/6/13.
//  Copyright © 2018年 biao. All rights reserved.
//

#import "BGWalletOrderPayResultViewController.h"
#import "BGOrderViewController.h"
#import "BGAddressModel.h"

@interface BGWalletOrderPayResultViewController ()

@property (weak, nonatomic) IBOutlet UIImageView *payStatusImgView;
@property (weak, nonatomic) IBOutlet UILabel *payResultLabel;
@property (weak, nonatomic) IBOutlet UILabel *orderNumLabel;
@property (weak, nonatomic) IBOutlet UILabel *moneyLabel;
@property (weak, nonatomic) IBOutlet UIButton *checkOrderBtn;
@property (weak, nonatomic) IBOutlet UILabel *nameAndPhoneLabel;
@property (weak, nonatomic) IBOutlet UILabel *addressLabel;
@property (weak, nonatomic) IBOutlet UIView *shopView;

@end

@implementation BGWalletOrderPayResultViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self loadSubViews];
  
}
-(void)loadSubViews {
    
    self.checkOrderBtn.layer.borderColor = kAppMainColor.CGColor;
    self.checkOrderBtn.layer.borderWidth = 1.0;
    self.checkOrderBtn.layer.cornerRadius = 5;
    
    self.orderNumLabel.text = _order_num;
    self.moneyLabel.text = _payBalanceStr;
    
    if (_isPaySuccess) {
        self.navigationItem.title = @"订单支付成功";
        [self.payStatusImgView setImage:BGImage(@"pay_success_icon")];
        self.payResultLabel.text = @"支付成功";
    }else{
        self.navigationItem.title = @"订单支付失败";
        [self.payStatusImgView setImage:BGImage(@"pay_failure_icon")];
        self.payResultLabel.text = @"支付失败";
    }
    
    self.view.backgroundColor = kAppBgColor;
    self.navigationItem.leftBarButtonItem = [UIBarButtonItem itemWithImage:@"btn_back_black" highImage:@"btn_back_green" target:self action:@selector(clickedBackItem:)];
    
    if (_isShop == 333) {
        
        if (_addressDic != nil) {
            self.shopView.hidden = NO;
            if (_addressDic.count == 4) {
                self.nameAndPhoneLabel.text = [NSString stringWithFormat:@"%@   %@",_addressDic[@"ship_name"],_addressDic[@"ship_mobile"]];
                
                self.addressLabel.text = [NSString stringWithFormat:@"%@ %@",_addressDic[@"shipping_area"],_addressDic[@"ship_addr"]];
            }else{
                BGAddressModel *model = [BGAddressModel mj_objectWithKeyValues:_addressDic];
                self.nameAndPhoneLabel.text = [NSString stringWithFormat:@"%@   %@",model.name,model.mobile];
                
                self.addressLabel.text = [NSString stringWithFormat:@"%@ %@ %@ %@",model.province_name,model.city_name,model.region_name,model.address_detail];
            }
        }
        
    }
}
- (IBAction)btnCheckOrderClicked:(UIButton *)sender {

    if (_isNew) {
        BGOrderViewController *orderVC = BGOrderViewController.new;
        if (_isPaySuccess) {
            if (_isShop != 333) {
                orderVC.ninaDefaultPage = 1;
                BGSetUserDefaultObjectForKey(@"1", @"TravelOrderDefaultNum");
            }else{
                orderVC.ninaDefaultPage = 0;
                BGSetUserDefaultObjectForKey(@"1", @"ShopOrderDefaultNum");
            }
        }else{
            if (_isShop != 333) {
                orderVC.ninaDefaultPage = 1;
                BGSetUserDefaultObjectForKey(@"0", @"TravelOrderDefaultNum");
            }else{
                orderVC.ninaDefaultPage = 0;
                BGSetUserDefaultObjectForKey(@"0", @"ShopOrderDefaultNum");
            }
        }
        [self.navigationController pushViewController:orderVC animated:YES];
    }else{

        for (UIViewController *controller in self.navigationController.viewControllers) {
            if ([controller isKindOfClass:[BGOrderViewController class]]) {
                BGOrderViewController *orderVC =(BGOrderViewController *)controller;
                if (_isPaySuccess) {
                    if (_isShop != 333) {
                        [orderVC changeDefaultPageWithPage:2];
                        orderVC.isJump = YES;
                        orderVC.jumpNum = 2;
                    }else{
                        [orderVC changeDefaultPageWithPage:1];
                        orderVC.isJump = YES;
                        orderVC.jumpNum = 2;
                    }
                }else{
                    if (_isShop != 333) {
                        [orderVC changeDefaultPageWithPage:2];
                        orderVC.isJump = YES;
                        orderVC.jumpNum = 1;
                    }else{
                        [orderVC changeDefaultPageWithPage:1];
                        orderVC.isJump = YES;
                        orderVC.jumpNum = 1;
                    }
                }
                [self.navigationController popToViewController:orderVC animated:YES];
            }
        }
}
}
- (void)clickedBackItem:(UIBarButtonItem *)btn{
   [self.navigationController popToRootViewControllerAnimated:YES];
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
