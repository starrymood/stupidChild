//
//  BGReceiveAddressViewController.m
//  shzTravelC
//
//  Created by 孙林茂 on 2018/5/12.
//  Copyright © 2018年 biao. All rights reserved.
//

#import "BGReceiveAddressViewController.h"
#import "BGReceiveAddressCell.h"
#import "BGAddReceiveAddressViewController.h"
#import "BGAddressModel.h"
#import "BGShopApi.h"
#import <JCAlertController.h>
#import "BGMemberApi.h"

@interface BGReceiveAddressViewController ()<UITableViewDelegate, UITableViewDataSource>
@property (nonatomic,strong)UITableView *tableView;
@property (nonatomic, strong) UIView *noneView;
@property (nonatomic,strong)NSMutableArray *cellDataArr;
@property (nonatomic, strong) UIView *footerView;
@property (nonatomic, strong) JCAlertController *alert;

@end

@implementation BGReceiveAddressViewController
-(UIView *)noneView {
    if (!_noneView) {
        self.noneView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT-SafeAreaTopHeight-SafeAreaBottomHeight)];
        _noneView.backgroundColor = kAppBgColor;
        [_noneView setHidden:YES];
        UIImageView *noneImgView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"noToken_bg"]];
        noneImgView.frame = CGRectMake(SCREEN_WIDTH*0.2, 60, SCREEN_WIDTH*0.6, SCREEN_WIDTH*0.6*1.02);
        [_noneView addSubview:noneImgView];
        
        UIButton *addBankBtn = [UIButton buttonWithType:(UIButtonTypeCustom)];
        addBankBtn.frame = CGRectMake((SCREEN_WIDTH-160)*0.5, noneImgView.frame.origin.y+noneImgView.frame.size.height+50, 160, 40);
        [addBankBtn setBackgroundImage:BGImage(@"btn_bgColor") forState:(UIControlStateNormal)];
        addBankBtn.clipsToBounds = YES;
        addBankBtn.layer.cornerRadius = 20;
        [addBankBtn.titleLabel setFont:kFont(16)];
        [addBankBtn setTitle:@"添加新地址" forState:(UIControlStateNormal)];
        [_noneView addSubview:addBankBtn];
        @weakify(self);
        [[addBankBtn rac_signalForControlEvents:(UIControlEventTouchUpInside)] subscribeNext:^(__kindof UIControl * _Nullable x) {
            @strongify(self);
            // 点击button的响应事件
            BGAddReceiveAddressViewController *addVC = BGAddReceiveAddressViewController.new;
            addVC.navigationItem.title = @"添加收货地址";
            addVC.refreshEditBlock = ^{
                [self loadData];
            };
            addVC.isCanSelect = self.isCanSelect;
            [self.navigationController pushViewController:addVC animated:YES];
        }];
        __weak typeof(self)weakSelf = self;
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [weakSelf.noneView setHidden:NO];
        });
    }
    return _noneView;
}
-(NSMutableArray *)cellDataArr {
    if (!_cellDataArr) {
        self.cellDataArr = [NSMutableArray array];
    }
    return _cellDataArr;
}
-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    self.navigationController.navigationBarHidden = NO;
}
- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self loadSubViews];
    [self refreshView];
}
#pragma mark - 加载视图
- (void)loadSubViews {
    
    self.navigationItem.title = @"收货地址";
    self.view.backgroundColor = kAppBgColor;
    
    self.tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, SafeAreaTopHeight, SCREEN_WIDTH, SCREEN_HEIGHT-SafeAreaTopHeight-49) style:(UITableViewStyleGrouped)];
    _tableView.backgroundColor = kAppBgColor;
    _tableView.estimatedRowHeight = 137;
    _tableView.rowHeight = UITableViewAutomaticDimension;
    _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    _tableView.dataSource = self;
    _tableView.delegate = self;
    [self.view addSubview:_tableView];
    
    self.footerView = UIView.new;
    _footerView.backgroundColor = kAppWhiteColor;
    _footerView.frame = CGRectMake(0, SCREEN_HEIGHT-SafeAreaBottomHeight-49, SCREEN_WIDTH, 49);
    [self.view addSubview:_footerView];
    
    UIButton *addAddressBtn = [UIButton buttonWithType:(UIButtonTypeCustom)];
    addAddressBtn.frame = CGRectMake((SCREEN_WIDTH -230)*0.5, 4, 230, 40);
    addAddressBtn.backgroundColor = kAppMainColor;
    addAddressBtn.clipsToBounds = YES;
    addAddressBtn.layer.cornerRadius = 5;
    [addAddressBtn.titleLabel setFont:kFont(16)];
    [addAddressBtn setTitleColor:kAppWhiteColor forState:0];
    [addAddressBtn setTitle:@"添加新地址" forState:(UIControlStateNormal)];
    [_footerView addSubview:addAddressBtn];
    @weakify(self);
    [[addAddressBtn rac_signalForControlEvents:(UIControlEventTouchUpInside)] subscribeNext:^(__kindof UIControl * _Nullable x) {
        @strongify(self);
        // 点击button的响应事件
        BGAddReceiveAddressViewController *addVC = BGAddReceiveAddressViewController.new;
        addVC.navigationItem.title = @"添加收货地址";
        addVC.refreshEditBlock = ^{
            [self loadData];
        };
        addVC.isCanSelect = self.isCanSelect;
        [self.navigationController pushViewController:addVC animated:YES];
    }];
    
    
    [self.tableView registerNib:[UINib nibWithNibName:@"BGReceiveAddressCell" bundle:nil] forCellReuseIdentifier:@"BGReceiveAddressCell"];
}
#pragma mark UITableView + 下拉刷新 隐藏时间
- (void)refreshView
{
    // 设置回调（一旦进入刷新状态，就调用target的action，也就是调用self的loadNewData方法）
    __weak __typeof(self) weakSelf = self;
    
    // 设置回调（一旦进入刷新状态就会调用这个refreshingBlock）
    self.tableView.mj_header = [MJRefreshNormalHeader headerWithRefreshingBlock:^{
        // 设置自动切换透明度(在导航栏下面自动隐藏)
        weakSelf.tableView.mj_header.automaticallyChangeAlpha = YES;
        [weakSelf loadData];
        [weakSelf.tableView.mj_header endRefreshing];
    }];
    
    [self loadData];
}
#pragma mark - 加载数据  -
- (void)loadData {
    
    [ProgressHUDHelper showLoading];
    __block typeof(self) weakSelf = self;
    NSMutableDictionary *param = [NSMutableDictionary dictionary];
    [BGShopApi getAddressList:param succ:^(NSDictionary *response) {
        DLog(@"\n>>>[getAddressList sucess]:%@",response);
        [self hideNodateView];
        self.cellDataArr = [BGAddressModel mj_objectArrayWithKeyValuesArray:response[@"result"]];
        if (weakSelf.cellDataArr.count>0) {
            [weakSelf.noneView removeFromSuperview];
        }
        [weakSelf.tableView reloadData];
    } failure:^(NSDictionary *response) {
        DLog(@"\n>>>[getAddressList failure]:%@",response);
        [self shownoNetWorkViewWithType:0];
        [self setRefreshBlock:^{
            [weakSelf loadData];
        }];
    }];
    
}
#pragma mark  -  TableViewDelegate  -
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return _cellDataArr.count==0 ? 1: _cellDataArr.count;
}
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return _cellDataArr.count==0 ? 0:1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    BGReceiveAddressCell *cell = [tableView dequeueReusableCellWithIdentifier:@"BGReceiveAddressCell" forIndexPath:indexPath];
    if (![Tool arrayIsNotEmpty:_cellDataArr]) {
        return UITableViewCell.new;
    }
    BGAddressModel *model = _cellDataArr[indexPath.section];
    if (!_isCanSelect) {
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    [cell updataWithCellArray:model];
    
    __weak __typeof(self) weakSelf = self;
    // 点击删除按钮的回调方法
    cell.deleteCellClicked = ^{
        [weakSelf deleteAddrActionWithId:model.ID];
    };
    
    // 点击设置默认按钮的回调方法
    cell.setDefaultCellClicked = ^{
        [weakSelf setDefaultCellClickedWithId:model.ID defAddr:model.is_default];
    };
    // 点击编辑按钮的回调方法
    cell.editCellClicked = ^{
        BGAddReceiveAddressViewController *editVC = BGAddReceiveAddressViewController.new;
        editVC.navigationItem.title = @"编辑地址";
        editVC.model = model;
        editVC.refreshEditBlock = ^{
            [weakSelf loadData];
        };
        editVC.isCanSelect = weakSelf.isCanSelect;
        [weakSelf.navigationController pushViewController:editVC animated:YES];
        
    };
    
    return cell;
}

-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    if (_cellDataArr.count == 0) {
        return 0.01;
    }else{
        return 10;
    }
}
-(CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section{
    if (_cellDataArr.count == 0) {
        _footerView.hidden = YES;
        return _tableView.frame.size.height;
    }else{
        _footerView.hidden = NO;
        if (_cellDataArr.count -2 >0) {
            return section==(_cellDataArr.count-1)? 30:0.01;
        }
        return 0.01;
    }
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    return nil;
}
- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section{
    if (_cellDataArr.count == 0) {
        return self.noneView;
    }
    return nil;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
}
-(void)deleteAddrActionWithId:(NSString *)addrId{
    
    self.alert = [JCAlertController alertWithTitle:@"提示" message:@"确定要删除吗?"];
    
    [self.alert addButtonWithTitle:@"取消" type:JCButtonTypeCancel clicked:^{
        
    }];
    __weak __typeof(self) weakSelf = self;
    [self.alert addButtonWithTitle:@"删除" type:JCButtonTypeWarning clicked:^{
        [ProgressHUDHelper showLoading];
        NSMutableDictionary *param = [[NSMutableDictionary alloc] init];
        [param setObject:addrId forKey:@"address_id"];
        [BGShopApi deleteAddress:param succ:^(NSDictionary *response) {
            DLog(@"\n>>>[deleteAddress success]:%@",response);
            if (weakSelf.refreshEditBlock) {
                weakSelf.refreshEditBlock();
            }
            [weakSelf loadData];
        } failure:^(NSDictionary *response) {
            DLog(@"\n>>>[deleteAddress failure]:%@",response);
        }];
        
        
    }];
    
    [self presentViewController:_alert animated:YES completion:nil];
    
}
-(void)setDefaultCellClickedWithId:(NSString *)addrId defAddr:(NSString *)defAddr{
    if ([defAddr isEqualToString:@"1"]) {
        return ;
    }
    [ProgressHUDHelper showLoading];
    NSMutableDictionary *param = [[NSMutableDictionary alloc] init];
    [param setObject:addrId forKey:@"address_id"];
    __weak __typeof(self) weakSelf = self;
    [BGShopApi setDefaultAddress:param succ:^(NSDictionary *response) {
        DLog(@"\n>>>[setDefaultAddress success]:%@",response);
        [WHIndicatorView toast:@"设置默认地址成功"];
        if (weakSelf.refreshEditBlock) {
            weakSelf.refreshEditBlock();
        }
        [weakSelf loadData];
    } failure:^(NSDictionary *response) {
        DLog(@"\n>>>[setDefaultAddress failure]:%@",response);
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
