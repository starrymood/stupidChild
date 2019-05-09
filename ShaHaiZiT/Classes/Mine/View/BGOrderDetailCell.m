//
//  BGOrderDetailCell.m
//  shzTravelC
//
//  Created by 孙林茂 on 2018/5/10.
//  Copyright © 2018年 biao. All rights reserved.
//

#import "BGOrderDetailCell.h"
#import "BGShopInfoBaseCell.h"
#import "BGOrderModel.h"
#import "BGShopModel.h"

@interface BGOrderDetailCell()<UITableViewDelegate,UITableViewDataSource>

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *tableViewHeight;

@property (weak, nonatomic) IBOutlet UILabel *orderIdLabel;
@property (weak, nonatomic) IBOutlet UILabel *orderStatusLabel;
@property (weak, nonatomic) IBOutlet UILabel *orderNumLabel;
@property (weak, nonatomic) IBOutlet UILabel *orderAmountLabel;
@property (weak, nonatomic) IBOutlet UIButton *firstBtn;
@property (weak, nonatomic) IBOutlet UIButton *sureBtn;

@property (nonatomic, strong) NSMutableArray *cellDataArr;
@property (nonatomic, assign) int orderStatus;
@end
@implementation BGOrderDetailCell

-(NSMutableArray *)cellDataArr {
    if (!_cellDataArr) {
        self.cellDataArr = [NSMutableArray array];
    }
    return _cellDataArr;
}

- (void)awakeFromNib {
    [super awakeFromNib];
    _sureBtn.layer.cornerRadius = 5;
    _sureBtn.layer.borderColor = kAppMainColor.CGColor;
    _sureBtn.layer.borderWidth = 1;
    _firstBtn.layer.cornerRadius = 5;
    _firstBtn.layer.borderColor = kAppMainColor.CGColor;
    _firstBtn.layer.borderWidth = 1;
    
    [self.tableView registerNib:[UINib nibWithNibName:@"BGShopInfoBaseCell" bundle:nil] forCellReuseIdentifier:@"BGShopInfoBaseCell"];

}
-(void)updataWithCellArray:(BGOrderModel *)model{
        
    // 商品详情
    self.cellDataArr = [BGShopModel mj_objectArrayWithKeyValuesArray:model.goods_list];
    _tableViewHeight.constant = 110*(_cellDataArr.count);
    [self.tableView reloadData];
    
    // 订单号
    self.orderIdLabel.text = [NSString stringWithFormat:@"订单号: %@",model.order_number];
    // 商品数
    self.orderNumLabel.text = [NSString stringWithFormat:@"共 %@ 件商品",model.total_num];
    // 实付款
    self.orderAmountLabel.text = [NSString stringWithFormat:@"¥ %.2f",model.need_pay_money.doubleValue];
    
    _orderStatus = model.status.intValue;
    switch (model.status.intValue) {
        case 1:{
            self.tableView.userInteractionEnabled = NO;
            _firstBtn.hidden = NO;
            _sureBtn.hidden = NO;
            [_firstBtn setTitle:@"取消订单" forState:(UIControlStateNormal)];
            [_sureBtn setTitle:@"确认付款" forState:(UIControlStateNormal)];
            self.orderStatusLabel.text = @"待付款";
        }
            break;
        case 2:{
            self.tableView.userInteractionEnabled = NO;
            _firstBtn.hidden = YES;
            _sureBtn.hidden = NO;
            [_sureBtn setTitle:@"提醒发货" forState:(UIControlStateNormal)];
            self.orderStatusLabel.text = @"待发货";
        }
            break;
        case 3:{
            self.tableView.userInteractionEnabled = NO;
            _firstBtn.hidden = NO;
            _sureBtn.hidden = NO;
            _firstBtn.hidden = YES;
            [_sureBtn setTitle:@"确认收货" forState:(UIControlStateNormal)];
            self.orderStatusLabel.text = @"待收货";
        }
            break;
        case 5:{
            self.tableView.userInteractionEnabled = YES;
            _firstBtn.hidden = NO;
            _firstBtn.hidden = YES;
            if ([model.review_state isEqualToString:@"0"]) {
                _sureBtn.hidden = NO;
                [_sureBtn setTitle:@"评价订单" forState:(UIControlStateNormal)];
            }else{
               _sureBtn.hidden = YES;
            }
            self.orderStatusLabel.text = @"已完成";
        }
            break;
        case 6:{
            self.tableView.userInteractionEnabled = NO;
            _firstBtn.hidden = YES;
            _sureBtn.hidden = YES;
            self.orderStatusLabel.text = @"交易关闭";
        }
            break;
        case 7:{
            self.tableView.userInteractionEnabled = YES;
            _firstBtn.hidden = YES;
            _sureBtn.hidden = YES;
             self.orderStatusLabel.text = @"售后中";
        }
            break;
        case 8:{
            self.tableView.userInteractionEnabled = YES;
            _firstBtn.hidden = YES;
            _sureBtn.hidden = YES;
            self.orderStatusLabel.text = @"售后完成";
        }
            break;
            
        default:{
            self.tableView.userInteractionEnabled = NO;
            _firstBtn.hidden = YES;
            _sureBtn.hidden = YES;
            self.orderStatusLabel.text = @"";
        }
            break;
    }
    
    
}

#pragma mark  -  TableViewDelegate  -
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return _cellDataArr.count;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    BGShopInfoBaseCell *cell = [tableView dequeueReusableCellWithIdentifier:@"BGShopInfoBaseCell" forIndexPath:indexPath];
    BGShopModel *model = _cellDataArr[indexPath.row];
    [cell updataWithCellArray:model orderStatus:_orderStatus];
    cell.afterSaleBtnClick = ^(NSString *itemId, NSString *num) {
        if (self.afterSaleBtnClick) {
            self.afterSaleBtnClick(itemId, num);
        }
    };
    return cell;
}
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 110;
}
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 0.01;
}
-(CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section{
    return 0.01;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
    if (self.didSelectRowClicked) {
        self.didSelectRowClicked();
    }
    
}

- (IBAction)btnSureClicked:(UIButton *)sender {
    if(self.sureBtnClicked) {
        self.sureBtnClicked();
    }
}
- (IBAction)btnFirstClicked:(UIButton *)sender {
    if (self.firstBtnClicked) {
        self.firstBtnClicked();
    }
}

@end
