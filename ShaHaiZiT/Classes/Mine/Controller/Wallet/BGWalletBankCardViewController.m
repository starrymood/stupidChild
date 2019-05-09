//
//  BGWalletBankCardViewController.m
//  shzTravelC
//
//  Created by 孙林茂 on 2018/5/10.
//  Copyright © 2018年 biao. All rights reserved.
//

#import "BGWalletBankCardViewController.h"
#import "BGWalletAddBankCardViewController.h"
#import "BGBankCardCell.h"
#import "BGPurseApi.h"
#import "BGMyBankCardModel.h"

@interface BGWalletBankCardViewController ()<UITableViewDelegate, UITableViewDataSource>
@property (nonatomic,strong)UITableView *tableView;
@property (nonatomic,strong)NSMutableArray *dataArr;
@property (nonatomic, strong) UIView *noneView;

@end

@implementation BGWalletBankCardViewController
-(UIView *)noneView {
    if (!_noneView) {
        self.noneView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT-SafeAreaTopHeight-SafeAreaBottomHeight)];
        _noneView.backgroundColor = kAppBgColor;
        [_noneView setHidden:YES];
        UIImageView *noneImgView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"noToken_bg"]];
        noneImgView.frame = CGRectMake(SCREEN_WIDTH*0.2, 60, SCREEN_WIDTH*0.6, SCREEN_WIDTH*0.6*1.02);
        [_noneView addSubview:noneImgView];
        
        UIButton *addBankBtn = [UIButton buttonWithType:(UIButtonTypeCustom)];
        addBankBtn.frame = CGRectMake((SCREEN_WIDTH-130)*0.5, noneImgView.frame.origin.y+noneImgView.frame.size.height+50, 130, 40);
        [addBankBtn setBackgroundImage:BGImage(@"btn_bgColor") forState:(UIControlStateNormal)];
        addBankBtn.clipsToBounds = YES;
        addBankBtn.layer.cornerRadius = 20;
        [addBankBtn.titleLabel setFont:kFont(16)];
        [addBankBtn setTitle:@"添加银行卡" forState:(UIControlStateNormal)];
        [_noneView addSubview:addBankBtn];
        @weakify(self);
        [[addBankBtn rac_signalForControlEvents:(UIControlEventTouchUpInside)] subscribeNext:^(__kindof UIControl * _Nullable x) {
             @strongify(self);
            // 点击button的响应事件
            BGWalletAddBankCardViewController *addVC = BGWalletAddBankCardViewController.new;
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
-(NSMutableArray *)dataArr{
    if (!_dataArr) {
        self.dataArr = [NSMutableArray array];
    }
    return _dataArr;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self loadSubViews];
    [self loadData];
}

#pragma mark - 加载视图
- (void)loadSubViews {
    
    self.navigationItem.title = @"我的银行卡";
    self.view.backgroundColor = kAppBgColor;
    self.navigationItem.rightBarButtonItem = [UIBarButtonItem itemWithImage:@"bank_card_plus_sign" highImage:@"bank_card_plus_sign" target:self action:@selector(clickedAddItem:)];
    self.tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, SafeAreaTopHeight, SCREEN_WIDTH, SCREEN_HEIGHT-SafeAreaTopHeight) style:(UITableViewStyleGrouped)];
    _tableView.backgroundColor = kAppBgColor;
    _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    _tableView.estimatedRowHeight = 137;
    _tableView.rowHeight = UITableViewAutomaticDimension;
    _tableView.dataSource = self;
    _tableView.delegate = self;
    [self.view addSubview:_tableView];
    
    [self.tableView registerNib:[UINib nibWithNibName:@"BGBankCardCell" bundle:nil] forCellReuseIdentifier:@"BGBankCardCell"];
}
- (void)clickedAddItem:(UIBarButtonItem *)btn{
    BGWalletAddBankCardViewController *addVC = BGWalletAddBankCardViewController.new;
    addVC.refreshEditBlock = ^{
        [self loadData];
    };
    addVC.isCanSelect = _isCanSelect;
    [self.navigationController pushViewController:addVC animated:YES];
}

#pragma mark - 加载数据  -
- (void)loadData {
//    [ProgressHUDHelper showLoading];
    __block typeof(self)weakSelf = self;
    [BGPurseApi getBankCardList:nil succ:^(NSDictionary *response) {
        DLog(@"\n>>>[getBankCardList success]:%@",response);
        weakSelf.dataArr = [BGMyBankCardModel mj_objectArrayWithKeyValuesArray:response[@"result"]];
        if (weakSelf.dataArr.count>0) {
            [weakSelf.noneView removeFromSuperview];
        }
        [weakSelf.tableView reloadData];
        
    } failure:^(NSDictionary *response) {
        DLog(@"\n>>>[getBankCardList failure]:%@",response);
    }];
    
}
#pragma - mark UITableView

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return _dataArr.count==0 ? 1: _dataArr.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return _dataArr.count==0 ? 0:1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    BGBankCardCell *cell = [tableView dequeueReusableCellWithIdentifier:@"BGBankCardCell" forIndexPath:indexPath];
    if (_isCanSelect) {
        cell.userInteractionEnabled = YES;
    }else{
        cell.userInteractionEnabled = NO;
    }
    if ([Tool arrayIsNotEmpty:_dataArr]) {
       [cell updataWithCellArray:_dataArr[indexPath.section]];
    }
    
    return cell;
}
-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    return 0.01;
}
-(CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section{
    if (_dataArr.count == 0) {
        return _tableView.frame.size.height;
    }else{
        return 0.01;
    }
}
- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    return nil;
}
- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section{
   
    if (_dataArr.count == 0) {
        return self.noneView;
    }
    return nil;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    if (_isCanSelect) {
        [tableView deselectRowAtIndexPath:indexPath animated:NO];
        // 选择
        BGMyBankCardModel *model = _dataArr[indexPath.section];
        
//        [ProgressHUDHelper showLoading];
        NSMutableDictionary *param = [[NSMutableDictionary alloc] init];
        [param setObject:model.ID forKey:@"bank_card_id"];
        __block typeof(self)weakSelf = self;
        [BGPurseApi setDefaultBankCard:param succ:^(NSDictionary *response) {
            DLog(@"\n>>>[setDefaultBankCard success]:%@",response);
            [weakSelf loadData];
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                if (self.refreshEditBlock) {
                    self.refreshEditBlock();
                }
                [weakSelf.navigationController popViewControllerAnimated:YES];
            });
        } failure:^(NSDictionary *response) {
            DLog(@"\n>>>[setDefaultBankCard failure]:%@",response);
        }];
    }
}
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (_isCanSelect) {
        return NO;
    }else{
        return YES;

    }
}
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        BGMyBankCardModel *model = _dataArr[indexPath.section];
        NSMutableDictionary *param = [[NSMutableDictionary alloc] init];
        [param setObject:model.ID forKey:@"bank_card_id"];
        [ProgressHUDHelper showLoading];
        __block typeof(self)weakSelf = self;
        [BGPurseApi deleteBankCard:param succ:^(NSDictionary *response) {
            DLog(@"\n>>>[deleteBankCard success]:%@",response);
           
            [weakSelf loadData];
            [WHIndicatorView toast:response[@"msg"]];
        } failure:^(NSDictionary *response) {
            DLog(@"\n>>>[deleteBankCard failure]:%@",response);
        }];
        
    }
   
}
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 154;
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
