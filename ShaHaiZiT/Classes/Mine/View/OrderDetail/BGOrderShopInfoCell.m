//
//  BGOrderShopInfoCell.m
//  shzTravelC
//
//  Created by 孙林茂 on 2018/5/11.
//  Copyright © 2018年 biao. All rights reserved.
//

#import "BGOrderShopInfoCell.h"
#import "BGShopInfoBaseCell.h"
#import "BGShopModel.h"

@interface BGOrderShopInfoCell()<UITableViewDelegate,UITableViewDataSource>
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *tableViewHeight;
@property (nonatomic, strong) NSMutableArray *cellDataArr;
@property (nonatomic, assign) int orderStatus;
@end
@implementation BGOrderShopInfoCell

-(NSMutableArray *)cellDataArr {
    if (!_cellDataArr) {
        self.cellDataArr = [NSMutableArray array];
    }
    return _cellDataArr;
}

- (void)updataWithCellArray:(NSArray *)arr orderStatus:(int)status{
    
    self.cellDataArr = [BGShopModel mj_objectArrayWithKeyValuesArray:arr];
    _tableViewHeight.constant = 110*(_cellDataArr.count);
    _orderStatus = status;
    if (status == 5 || status == 7 || status == 8) {
        self.userInteractionEnabled = YES;
    }
    [self.tableView reloadData];
}

- (void)awakeFromNib {
    [super awakeFromNib];
 [self.tableView registerNib:[UINib nibWithNibName:@"BGShopInfoBaseCell" bundle:nil] forCellReuseIdentifier:@"BGShopInfoBaseCell"];
//    _tableViewHeight.constant = 110;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
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

@end
