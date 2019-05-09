//
//  BGAfterSaleDetailViewController.m
//  shzTravelC
//
//  Created by biao on 2018/6/24.
//  Copyright © 2018年 biao. All rights reserved.
//

#import "BGAfterSaleDetailViewController.h"
#import "BGAfterSaleServiceDetailViewController.h"
#import "BGOrderShopApi.h"

@interface BGAfterSaleDetailViewController ()
@property (weak, nonatomic) IBOutlet UILabel *statusLabel;
@property (weak, nonatomic) IBOutlet UILabel *backMoneyLabel;
@property (weak, nonatomic) IBOutlet UILabel *storeNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *typeLabel;
@property (weak, nonatomic) IBOutlet UILabel *numLabel;
@property (weak, nonatomic) IBOutlet UILabel *moneyLabel;
@property (weak, nonatomic) IBOutlet UILabel *reasonLabel;
@property (weak, nonatomic) IBOutlet UILabel *productNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *snLabel;
@property (weak, nonatomic) IBOutlet UILabel *timeLabel;

@end

@implementation BGAfterSaleDetailViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    self.navigationItem.title = @"售后详情";
    self.view.backgroundColor = kAppBgColor;
    [self loadData];
}
-(void)loadData{
    [ProgressHUDHelper showLoading];
    NSMutableDictionary *param = [[NSMutableDictionary alloc] init];
    [param setObject:_itemId forKey:@"order_item_id"];
    __weak __typeof(self) weakSelf = self;
    [BGOrderShopApi getAfterSaleDetail:param succ:^(NSDictionary *response) {
        DLog(@"\n>>>[getAfterSaleDetail success]:%@",response);
        [weakSelf setDetailInfoActionWithData:BGdictSetObjectIsNil(response[@"result"])];
    } failure:^(NSDictionary *response) {
        DLog(@"\n>>>[getAfterSaleDetail failure]:%@",response);
    }];
}
-(void)setDetailInfoActionWithData:(NSDictionary *)dic{
    
    int stautus = [NSString stringWithFormat:@"%@",BGdictSetObjectIsNil(dic[@"tradestatus"])].intValue;
    switch (stautus) {
        case 0:
            self.statusLabel.text = @"待审核";
            break;
        case 1:
            self.statusLabel.text = @"审核成功待用户处理";
            break;
        case 3:
            self.statusLabel.text = @"商家已退款，待平台退款";
            break;
        case 6:
            self.statusLabel.text = @"平台退款完成,拒绝再次申请";
            break;
            
        default:
            break;
    }
    NSString *moneyStr = [NSString stringWithFormat:@"%@",BGdictSetObjectIsNil(dic[@"apply_alltotal"])];
    self.backMoneyLabel.text = [NSString stringWithFormat:@"退款金额:   ¥ %.2f",moneyStr.doubleValue];
    self.storeNameLabel.text = [NSString stringWithFormat:@"店铺名称:   %@",BGdictSetObjectIsNil(dic[@"store_name"])];
    
    self.typeLabel.text = [NSString stringWithFormat:@"售后类型:   %@",BGdictSetObjectIsNil(dic[@"remark"])];
    self.numLabel.text = [NSString stringWithFormat:@"售后数量:   %@",BGdictSetObjectIsNil(dic[@"num"])];
    self.moneyLabel.text     = [NSString stringWithFormat:@"退款金额:   ¥ %.2f",moneyStr.doubleValue];
    self.reasonLabel.text = [NSString stringWithFormat:@"退款原因:   %@",BGdictSetObjectIsNil(dic[@"reason"])];
    self.productNameLabel.text = [NSString stringWithFormat:@"商品名称:   %@",BGdictSetObjectIsNil(dic[@"name"])];
    self.snLabel.text = [NSString stringWithFormat:@"订单编号:   %@",BGdictSetObjectIsNil(dic[@"order_number"])];
    NSString *timeStr = [NSString stringWithFormat:@"%@",BGdictSetObjectIsNil(dic[@"order_create_time"])];
    if (timeStr.length == 10) {
        self.timeLabel.text = [NSString stringWithFormat:@"订单时间:   %@",[Tool dateFormatter:timeStr.doubleValue dateFormatter:@"yyyy-MM-dd HH:mm:ss"]];
    }
    
}
- (IBAction)btnServiceDetailClicked:(UIButton *)sender {
    BGAfterSaleServiceDetailViewController *serviceVC = BGAfterSaleServiceDetailViewController.new;
    serviceVC.itemId = _itemId;
    [self.navigationController pushViewController:serviceVC animated:YES];
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
