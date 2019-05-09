//
//  BGApplyAfterSaleViewController.m
//  shzTravelC
//
//  Created by biao on 2018/6/22.
//  Copyright © 2018年 biao. All rights reserved.
//

#import "BGApplyAfterSaleViewController.h"
#import "BGOrderShopApi.h"
#import "BGPickViewController.h"
#import "BGAfterSaleReasonModel.h"
#import "BGOrderViewController.h"

@interface BGApplyAfterSaleViewController ()<UITextViewDelegate,pickViewDelegate>
@property (weak, nonatomic) IBOutlet UILabel *orderIdLabel;
@property (weak, nonatomic) IBOutlet UILabel *orderUploadTimeLabel;
@property (weak, nonatomic) IBOutlet UIButton *typeBtn;
@property (weak, nonatomic) IBOutlet UILabel *typeLabel;
@property (weak, nonatomic) IBOutlet UIButton *numBtn;
@property (weak, nonatomic) IBOutlet UILabel *numLabel;
@property (weak, nonatomic) IBOutlet UIButton *moneyBtn;
@property (weak, nonatomic) IBOutlet UILabel *moneyLabel;
@property (weak, nonatomic) IBOutlet UIButton *reasonBtn;
@property (weak, nonatomic) IBOutlet UILabel *reasonLabel;
@property (weak, nonatomic) IBOutlet UITextView *textView;
@property (weak, nonatomic) IBOutlet UIButton *sureBtn;
@property (nonatomic, strong) UILabel *placeholderLabel;
@property (weak, nonatomic) IBOutlet UILabel *yuNumLabel;
@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
@property (nonatomic, copy) NSMutableArray *typeArr;
@property (nonatomic, copy) NSMutableArray *reasonArr;
@property (nonatomic, assign) NSInteger typeIndex;
@property (nonatomic, assign) NSInteger numIndex;
@property (nonatomic, assign) NSInteger reasonIndex;
@property (nonatomic, assign) NSInteger selectedType;

@end

@implementation BGApplyAfterSaleViewController
-(NSMutableArray *)typeArr{
    if (!_typeArr) {
        self.typeArr = [NSMutableArray array];
    }
    return _typeArr;
}
-(NSMutableArray *)reasonArr{
    if (!_reasonArr) {
        self.reasonArr = [NSMutableArray array];
    }
    return _reasonArr;
}
-(void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    NSInteger screenHeight = _sureBtn.y+_sureBtn.height+40;
    if (screenHeight > SCREEN_HEIGHT) {
        self.scrollView.contentSize = CGSizeMake(SCREEN_WIDTH,screenHeight);
    }else{
        self.scrollView.contentSize = CGSizeMake(SCREEN_WIDTH,SCREEN_HEIGHT);
    }
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationItem.title = @"申请售后";
    [self loadSubViews];
}

-(void)loadSubViews {
    self.view.backgroundColor = kAppBgColor;
    
    self.typeBtn.layer.borderWidth = 1;
    self.typeBtn.layer.borderColor = kApp999Color.CGColor;
    self.typeBtn.layer.cornerRadius = 5;
    
    self.numBtn.layer.borderWidth = 1;
    self.numBtn.layer.borderColor = kApp999Color.CGColor;
    self.numBtn.layer.cornerRadius = 5;
    
    self.moneyBtn.layer.borderWidth = 1;
    self.moneyBtn.layer.borderColor = kApp999Color.CGColor;
    self.moneyBtn.layer.cornerRadius = 5;
    
    self.reasonBtn.layer.borderWidth = 1;
    self.reasonBtn.layer.borderColor = kApp999Color.CGColor;
    self.reasonBtn.layer.cornerRadius = 5;
    
    self.placeholderLabel = [[UILabel alloc] initWithFrame:CGRectMake(3, 3, SCREEN_WIDTH-20-6, 25)];
    _placeholderLabel.enabled = NO;
    _placeholderLabel.text = @"请详细描述您的售后原因";
    _placeholderLabel.numberOfLines = 0;
    _placeholderLabel.font = kFont(14);
    _placeholderLabel.textColor = kApp999Color;
    [_textView addSubview:_placeholderLabel];
    
    self.orderIdLabel.text = [NSString stringWithFormat:@"订单编号:   %@",_order_number];
    if (_isDetail) {
         self.orderUploadTimeLabel.text = [NSString stringWithFormat:@"提交时间:   %@",_creatTime];
    }else{
        if (_creatTime.length == 10) {
            self.orderUploadTimeLabel.text = [NSString stringWithFormat:@"提交时间:   %@",[Tool dateFormatter:_creatTime.doubleValue dateFormatter:@"yyyy-MM-dd HH:mm:ss"]];
        }
    }
    self.typeIndex = 0;
    self.numIndex = 0;
    self.reasonIndex = 0;
}
- (IBAction)btnTypeClicked:(UIButton *)sender {
    _selectedType = 1;
    [ProgressHUDHelper showLoading];
        __weak __typeof(self) weakSelf = self;
    NSMutableDictionary *param = [NSMutableDictionary dictionary];
    [BGOrderShopApi getAfterSaleTypeAndReason:param succ:^(NSDictionary *response) {
        DLog(@"\n>>>[getAfterSaleTypeAndReason success]:%@",response);
        weakSelf.typeArr = [BGAfterSaleReasonModel mj_objectArrayWithKeyValuesArray:BGdictSetObjectIsNil(response[@"result"][@"refund_type"])];
        NSMutableArray *arr = [[NSMutableArray alloc] init];
        for (BGAfterSaleReasonModel *model in weakSelf.typeArr) {
            [arr addObject:model.cfg_value];
        }
        BGPickViewController *pick = [[BGPickViewController alloc] initWithNibName:@"BGPickViewController" bundle:nil];
        pick.delegate = self;
        pick.arry = arr;
        pick.modalPresentationStyle = UIModalPresentationCustom;
        
        [weakSelf presentViewController:pick animated:YES completion:nil];
    } failure:^(NSDictionary *response) {
        DLog(@"\n>>>[getAfterSaleTypeAndReason failure]:%@",response);
    }];
}
- (IBAction)btnNumClicked:(UIButton *)sender {
    _selectedType = 2;
    NSMutableArray *arr = [[NSMutableArray alloc] init];
    if (_maxNum > 0) {
        for (int i = 0; i<_maxNum; i++) {
            NSString *numStr = [NSString stringWithFormat:@"%d",i+1];
            [arr addObject:numStr];
        }
        BGPickViewController *pick = [[BGPickViewController alloc] initWithNibName:@"BGPickViewController" bundle:nil];
        pick.delegate = self;
        pick.arry = arr;
        pick.modalPresentationStyle = UIModalPresentationCustom;
        
        [self presentViewController:pick animated:YES completion:nil];
    }
   
}
- (IBAction)btnReasonClicked:(UIButton *)sender {
    _selectedType = 3;
    [ProgressHUDHelper showLoading];
    __weak __typeof(self) weakSelf = self;
    NSMutableDictionary *param = [NSMutableDictionary dictionary];
    [BGOrderShopApi getAfterSaleTypeAndReason:param succ:^(NSDictionary *response) {
        DLog(@"\n>>>[getAfterSaleTypeAndReason success]:%@",response);
        weakSelf.reasonArr = [BGAfterSaleReasonModel mj_objectArrayWithKeyValuesArray:BGdictSetObjectIsNil(response[@"result"][@"refund_reason"])];
        NSMutableArray *arr = [[NSMutableArray alloc] init];
        for (BGAfterSaleReasonModel *model in weakSelf.reasonArr) {
            [arr addObject:model.cfg_value];
        }
        BGPickViewController *pick = [[BGPickViewController alloc] initWithNibName:@"BGPickViewController" bundle:nil];
        pick.delegate = self;
        pick.arry = arr;
        pick.modalPresentationStyle = UIModalPresentationCustom;
        
        [weakSelf presentViewController:pick animated:YES completion:nil];
    } failure:^(NSDictionary *response) {
        DLog(@"\n>>>[getAfterSaleTypeAndReason failure]:%@",response);
    }];
}

- (IBAction)btnSureClicked:(UIButton *)sender {
    
    if ([self.typeLabel.text isEqualToString:@"请选择"]) {
        [WHIndicatorView toast:@"请选择售后类型"];
        return;
    }
    if ([self.numLabel.text isEqualToString:@"请选择"]) {
        [WHIndicatorView toast:@"请选择售后数量"];
        return;
    }
    if ([self.reasonLabel.text isEqualToString:@"请选择"]) {
        [WHIndicatorView toast:@"请选择售后原因"];
        return;
    }
    
    sender.enabled = NO;
    [ProgressHUDHelper showLoading];
    NSMutableDictionary *param = [[NSMutableDictionary alloc] init];
    [param setObject:_itemId forKey:@"order_item_id"];
    BGAfterSaleReasonModel *typeModel = _typeArr[_typeIndex];
    BGAfterSaleReasonModel *reasonModel = _reasonArr[_reasonIndex];
    [param setObject:typeModel.code forKey:@"typeCode"];
    [param setObject:reasonModel.code forKey:@"reasonCode"];
      [param setObject:@(_numIndex+1) forKey:@"num"];
    if (_textView.text.length >0) {
        [param setObject:_textView.text forKey:@"reasonDetail"];
    }
    [BGOrderShopApi submitAfterSaleInfo:param succ:^(NSDictionary *response) {
        DLog(@"\n>>>[submitAfterSaleInfo success]:%@",response);
        [WHIndicatorView toast:response[@"msg"]];

        for (UIViewController *controller in self.navigationController.viewControllers) {
            if ([controller isKindOfClass:[BGOrderViewController class]]) {
                BGOrderViewController *orderVC =(BGOrderViewController *)controller;
                orderVC.ninaDefaultPage = 0;
                BGSetUserDefaultObjectForKey(@"4", @"ShopOrderDefaultNum");
                [self.navigationController popToViewController:orderVC animated:YES];
            }
        }
    } failure:^(NSDictionary *response) {
        DLog(@"\n>>>[submitAfterSaleInfo failure]:%@",response);
        sender.enabled = YES;
    }];
}
#pragma mark - UITextView -
-(void)textViewDidChange:(UITextView *)textView
{
    if ([textView.text length] == 0) {
        [_placeholderLabel setHidden:NO];
    }else{
        [_placeholderLabel setHidden:YES];
    }
    NSInteger wordCount = textView.text.length;
    self.yuNumLabel.text = [NSString stringWithFormat:@"%zd/200",wordCount];
    [self wordLimit: textView];
}

-(BOOL)wordLimit:(UITextView *)text {
    
    if (text.text.length > 200) {
        [WHIndicatorView toast:@"请输入小于200个文字"];
        NSString *s = [text.text substringToIndex:200];
        text.text = s;
        self.yuNumLabel.text = @"200/200";
    }
    return nil;
}
-(void)getTextStr:(NSString *)text index:(NSInteger)index{
    
    switch (_selectedType) {
        case 1:{
            _typeIndex = index;
            self.typeLabel.text = text;
        }
            break;
        case 2:{
            _numIndex = index;
            self.numLabel.text = text;
            [self getAfterSaleRefundMoney];
        }
            break;
        case 3:{
            _reasonIndex = index;
            self.reasonLabel.text = text;
        }
            break;
            
        default:
            break;
    }
}
-(void)getAfterSaleRefundMoney{
    [ProgressHUDHelper showLoading];
    NSMutableDictionary *param = [[NSMutableDictionary alloc] init];
    [param setObject:_itemId forKey:@"order_item_id"];
    [param setObject:@(_numIndex+1) forKey:@"num"];
    __weak __typeof(self) weakSelf = self;
    [BGOrderShopApi getAfterSaleRefundMoney:param succ:^(NSDictionary *response) {
         DLog(@"\n>>>[getAfterSaleRefundMoney success]:%@",response);
        weakSelf.moneyLabel.text = [NSString stringWithFormat:@"¥ %.2f", [BGdictSetObjectIsNil(response[@"result"][@"apply_alltotal"]) doubleValue]];
    } failure:^(NSDictionary *response) {
         DLog(@"\n>>>[getAfterSaleRefundMoney failure]:%@",response);
    }];
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
