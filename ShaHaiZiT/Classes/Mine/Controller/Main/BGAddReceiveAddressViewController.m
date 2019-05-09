//
//  BGAddReceiveAddressViewController.m
//  shzTravelC
//
//  Created by 孙林茂 on 2018/5/12.
//  Copyright © 2018年 biao. All rights reserved.
//

#import "BGAddReceiveAddressViewController.h"
#import "BGShopApi.h"
#import "UITextField+BGLimit.h"
#import "BGAddressModel.h"
#import "BLAreaPickerView.h"
#import "BGMemberApi.h"

#define PickViewHeight 240
@interface BGAddReceiveAddressViewController ()<BLPickerViewDelegate>
@property (nonatomic,assign) BOOL isDefaultSelected;
@property (nonatomic, assign) BOOL isAreaSelected;
@property (nonatomic, copy) NSString *province_id;
@property (nonatomic, copy) NSString *city_id;
@property (nonatomic, copy) NSString *region_id;
@property(nonatomic,copy) NSString *province_name;
@property(nonatomic,copy) NSString *region_name;
@property(nonatomic,copy) NSString *city_name;

@property (weak, nonatomic) IBOutlet UITextField *nameTextField;
@property (weak, nonatomic) IBOutlet UITextField *phoneTextField;
@property (weak, nonatomic) IBOutlet UILabel *areaLabel;
@property (weak, nonatomic) IBOutlet UITextField *addressDetailTextField;
@property (weak, nonatomic) IBOutlet UIButton *setDefaultBtn;
@property (weak, nonatomic) IBOutlet UIButton *sureBtn;
@property (nonatomic, strong) BLAreaPickerView *pickView;

@end

@implementation BGAddReceiveAddressViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    self.isDefaultSelected = NO;
    self.isAreaSelected = NO;
    if (_model !=nil) {
        [self editAddressData];
    }
    [self loadSubViews];
}
-(void)loadSubViews {
     self.view.backgroundColor = kAppBgColor;
    self.phoneTextField.digitsChars = @[@"0",@"1",@"2",@"3",@"4",@"5",@"6",@"7",@"8",@"9"];
    self.phoneTextField.maxLenght = 20;
    self.addressDetailTextField.maxLenght = 50;
}
-(void)editAddressData {
    
    [_sureBtn setTitle:@"保存" forState:(UIControlStateNormal)];
    
    self.nameTextField.text = _model.name;
    self.phoneTextField.text = _model.mobile;
    self.areaLabel.text = [NSString stringWithFormat:@"%@%@%@",_model.province_name,_model.city_name,_model.region_name];
    self.province_id = _model.province_id;
    self.city_id = _model.city_id;
    self.region_id = _model.region_id;
    self.province_name = _model.province_name;
    self.city_name = _model.city_name;
    self.region_name = _model.region_name;
    
    self.addressDetailTextField.text = _model.address_detail;
    if ([_model.is_default isEqualToString:@"1"]) {
        _isDefaultSelected = YES;
        [_setDefaultBtn setImage:BGImage(@"address_set_as_default") forState:(UIControlStateNormal)];
    }else{
        _isDefaultSelected = NO;
        [_setDefaultBtn setImage:BGImage(@"address_set_as_default_unselected") forState:(UIControlStateNormal)];
    }
}

- (IBAction)btnDefaultSwitchClicked:(UIButton *)sender {
    if (_isDefaultSelected) {
        [sender setImage:BGImage(@"address_set_as_default_unselected") forState:(UIControlStateNormal)];
    }else{
        [sender setImage:BGImage(@"address_set_as_default") forState:(UIControlStateNormal)];
    }
    _isDefaultSelected = !_isDefaultSelected;

}

- (IBAction)btnSelectAreaClicked:(UIButton *)sender {
     [self keyboarkHidden];
    [ProgressHUDHelper showLoading];
    NSMutableDictionary *param = [[NSMutableDictionary alloc] init];
    [param setObject:@"0" forKey:@"parentId"];
    
    [BGMemberApi getAllAddressList:param succ:^(NSDictionary *response) {
//        DLog(@"\n>>>[getAllAddressList sucess]:%@",response);
        NSArray *dataArr = [NSArray arrayWithArray:response[@"result"]];
        self.pickView = [[BLAreaPickerView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, PickViewHeight)];
        self.pickView.pickViewDelegate = self;
        [self.pickView bl_showWithData:dataArr];
    } failure:^(NSDictionary *response) {
        DLog(@"\n>>>[getAllAddressList failure]:%@",response);
    }];
}
- (IBAction)btnAddOrEditClicked:(UIButton *)sender {
    [self keyboarkHidden];
    if (_nameTextField.text.length<1) {
        [WHIndicatorView toast:@"请输入姓名"];
        return;
    }
    
    if (_phoneTextField.text.length<1) {
        [WHIndicatorView toast:@"请输入联系人电话"];
        return;
    }
    
//    if (![Tool isMobile:_phoneTextField.text]) {
//        [WHIndicatorView toast:@"请输入正确的联系人电话"];
//        return;
//    }
    
    if (_areaLabel.text.length < 4) {
        [WHIndicatorView toast:@"请选择收货地址"];
        return;
    }
    
    if (_addressDetailTextField.text.length < 1) {
        [WHIndicatorView toast:@"请输入详细地址"];
        return;
    }
    [self modifyAddressAction];
    
}

-(void)modifyAddressAction {
    [ProgressHUDHelper showLoading];
    if (_model != nil) {
        NSMutableDictionary *param = [[NSMutableDictionary alloc] init];
        [param setObject:_model.ID forKey:@"id"];
        [param setObject:_nameTextField.text forKey:@"name"];
        [param setObject:_addressDetailTextField.text forKey:@"address_detail"];
        [param setObject:_phoneTextField.text forKey:@"mobile"];
        [param setObject:_province_id forKey:@"province_id"];
        [param setObject:_city_id forKey:@"city_id"];
        [param setObject:_region_id forKey:@"region_id"];
        [param setObject:_province_name forKey:@"province_name"];
        [param setObject:_city_name forKey:@"city_name"];
        [param setObject:_region_name forKey:@"region_name"];
        [param setObject:[NSString stringWithFormat:@"%d",_isDefaultSelected] forKey:@"is_default"];

        [BGShopApi editAddress:param succ:^(NSDictionary *response) {
            DLog(@"\n>>>[editAddress success]:%@",response);
            [WHIndicatorView toast:@"修改地址成功"];
            if (self.refreshEditBlock) {
                self.refreshEditBlock();
            }
            if (self.isCanSelect) {
                [[NSNotificationCenter defaultCenter] postNotificationName:@"AddAddressRefreshNotification" object:nil];
            }
            [self.navigationController popViewControllerAnimated:YES];
        } failure:^(NSDictionary *response) {
            DLog(@"\n>>>[editAddress failure]:%@",response);
            
        }];
    }else{
        NSMutableDictionary *param = [[NSMutableDictionary alloc] init];
        [param setObject:_nameTextField.text forKey:@"name"];
        [param setObject:_addressDetailTextField.text forKey:@"address_detail"];
        [param setObject:_phoneTextField.text forKey:@"mobile"];
        [param setObject:_province_id forKey:@"province_id"];
        [param setObject:_city_id forKey:@"city_id"];
        [param setObject:_region_id forKey:@"region_id"];
        [param setObject:_province_name forKey:@"province_name"];
        [param setObject:_city_name forKey:@"city_name"];
        [param setObject:_region_name forKey:@"region_name"];
        [param setObject:[NSString stringWithFormat:@"%d",_isDefaultSelected] forKey:@"is_default"];
        
        [BGShopApi addNewAddress:param succ:^(NSDictionary *response) {
            DLog(@"\n>>>[addNewAddress success]:%@",response);
            [WHIndicatorView toast:@"添加地址成功"];
            if (self.refreshEditBlock) {
                self.refreshEditBlock();
            }
            if (self.isCanSelect) {
                [[NSNotificationCenter defaultCenter] postNotificationName:@"AddAddressRefreshNotification" object:nil];
            }
            [self.navigationController popViewControllerAnimated:YES];
        } failure:^(NSDictionary *response) {
            DLog(@"\n>>>[addNewAddress failure]:%@",response);
            
        }];
    }
   
}

#pragma mark - - BLPickerViewDelegate
- (void)bl_selectedAreaResultWithProvince:(NSString *)provinceTitle city:(NSString *)cityTitle area:(NSString *)areaTitle province_id:(NSString *)province_id city_id:(NSString *)city_id region_id:(NSString *)region_id{
    
    // 修改地区
    NSMutableDictionary *param = [[NSMutableDictionary alloc] init];
    [param setObject:provinceTitle forKey:@"province"];
    [param setObject:cityTitle forKey:@"city"];
    [param setObject:areaTitle forKey:@"region"];
    [param setObject:province_id forKey:@"province_id"];
    [param setObject:city_id forKey:@"city_id"];
    [param setObject:region_id forKey:@"region_id"];
    
    self.province_id = province_id;
    self.city_id = city_id;
    self.region_id = region_id;
    self.province_name = provinceTitle;
    self.city_name = cityTitle;
    self.region_name = areaTitle;
    
    self.areaLabel.text = [NSString stringWithFormat:@"%@%@%@",provinceTitle,cityTitle,areaTitle];
    
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
