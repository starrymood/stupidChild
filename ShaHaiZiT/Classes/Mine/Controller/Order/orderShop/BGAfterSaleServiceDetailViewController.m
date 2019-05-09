//
//  BGAfterSaleServiceDetailViewController.m
//  shzTravelC
//
//  Created by biao on 2018/6/24.
//  Copyright © 2018年 biao. All rights reserved.
//

#import "BGAfterSaleServiceDetailViewController.h"
#import "BGOrderShopApi.h"
#import "BGAfterSaleMemberCell.h"
#import "BGAfterSaleStoreCell.h"

@interface BGAfterSaleServiceDetailViewController ()<UITableViewDelegate, UITableViewDataSource>

@property (nonatomic,strong)UITableView *tableView;

@property (nonatomic, copy) NSDictionary *memberDic;
@property (nonatomic, copy) NSDictionary *storeDic;
@property (nonatomic, copy) NSDictionary *SHZDic;

@end

@implementation BGAfterSaleServiceDetailViewController
-(NSDictionary *)SHZDic{
    if (!_SHZDic) {
        self.SHZDic = [NSDictionary dictionary];
    }
    return _SHZDic;
}
-(NSDictionary *)memberDic{
    if (!_memberDic) {
        self.memberDic = [NSDictionary dictionary];
    }
    return _memberDic;
}
-(NSDictionary *)storeDic{
    if (!_storeDic) {
        self.storeDic = [NSDictionary dictionary];
    }
    return _storeDic;
}
- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self loadSubViews];
    [self loadData];
}
#pragma mark - 加载视图
- (void)loadSubViews {
    
    self.navigationItem.title = @"服务详情";
    self.view.backgroundColor = kAppBgColor;
    self.tableView = [[UITableView alloc] initWithFrame:CGRectMake(10, SafeAreaTopHeight, SCREEN_WIDTH-20, SCREEN_HEIGHT-SafeAreaTopHeight) style:(UITableViewStyleGrouped)];
    _tableView.backgroundColor = kAppBgColor;
    _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    _tableView.estimatedRowHeight = 137;
    _tableView.estimatedSectionHeaderHeight = 0;
    _tableView.estimatedSectionFooterHeight = 0;
    _tableView.dataSource = self;
    _tableView.delegate = self;
    [self.view addSubview:_tableView];
    
    [self.tableView registerNib:[UINib nibWithNibName:@"BGAfterSaleMemberCell" bundle:nil] forCellReuseIdentifier:@"BGAfterSaleMemberCell"];
    [self.tableView registerNib:[UINib nibWithNibName:@"BGAfterSaleStoreCell" bundle:nil] forCellReuseIdentifier:@"BGAfterSaleStoreCell"];
}
-(void)loadData{
    [ProgressHUDHelper showLoading];
    NSMutableDictionary *param = [[NSMutableDictionary alloc] init];
    [param setObject:_itemId forKey:@"order_item_id"];
    __weak __typeof(self) weakSelf = self;
    [BGOrderShopApi getAfterSaleServiceDetail:param succ:^(NSDictionary *response) {
        DLog(@"\n>>>[getAfterSaleServiceDetail success]:%@",response);
        weakSelf.memberDic = BGdictSetObjectIsNil(response[@"result"][@"member"]);
        weakSelf.storeDic = BGdictSetObjectIsNil(response[@"result"][@"store"]);
        weakSelf.SHZDic = BGdictSetObjectIsNil(response[@"result"][@"SHZ"]);
        [weakSelf.tableView reloadData];
    } failure:^(NSDictionary *response) {
        DLog(@"\n>>>[getAfterSaleServiceDetail failure]:%@",response);
    }];
}

#pragma mark  -  TableViewDelegate  -
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    if ([Tool isBlankDictionary:self.SHZDic]) {
        if ([Tool isBlankDictionary:self.storeDic]) {
            return 1;
        }else{
            return 2;
        }
    }else{
        return 3;
    }
    
}
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    switch (indexPath.section) {
        case 0:{
            BGAfterSaleMemberCell *cell = [tableView dequeueReusableCellWithIdentifier:@"BGAfterSaleMemberCell" forIndexPath:indexPath];
            cell.layer.cornerRadius = 5;
            if (self.memberDic.count != 0) {
                [cell updataWithCellArray:self.memberDic];
            }
            return cell;
        }
            break;
        case 1:{
            BGAfterSaleStoreCell *cell = [tableView dequeueReusableCellWithIdentifier:@"BGAfterSaleStoreCell" forIndexPath:indexPath];
            cell.layer.cornerRadius = 5;
            if (self.storeDic.count != 0) {
                [cell updataWithCellArray:self.storeDic isStore:YES];
            }
            return cell;
        }
            break;
        case 2:{
            BGAfterSaleStoreCell *cell = [tableView dequeueReusableCellWithIdentifier:@"BGAfterSaleStoreCell" forIndexPath:indexPath];
            cell.layer.cornerRadius = 5;
            if (self.SHZDic.count != 0) {
                [cell updataWithCellArray:self.SHZDic isStore:NO];
            }
            return cell;
        }
            break;
            
        default:{
            return [UITableViewCell new];
        }
            break;
    }
    
    
}

-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    return 10;
}
-(CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section{
     return 0.01;
}
- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    return nil;
}
- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section{
    
    return nil;
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
