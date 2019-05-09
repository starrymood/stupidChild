//
//  BGShoppingCartViewController.m
//  shzTravelC
//
//  Created by 孙林茂 on 2018/5/10.
//  Copyright © 2018年 biao. All rights reserved.
//

#import "BGShoppingCartViewController.h"
#import "BGShoppingCartCell.h"
#import "BGImageBtn.h"
#import "BGShopModel.h"
#import "BGShopApi.h"
#import "JCAlertController.h"
#import "BGShopDetailViewController.h"
#import "BGFirmOrderViewController.h"

@interface BGShoppingCartViewController ()<UITableViewDelegate,UITableViewDataSource>

@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic,strong) NSMutableArray *cellDataArr;

@property (nonatomic,strong)BGImageBtn *allSelectBtn;   // 全选button
@property (nonatomic,strong) UILabel *totalMoneyLabel;  // 总价label
@property (nonatomic,assign) BOOL isAllSelect;          // 是否全选
@property (nonatomic, strong) UIButton *totalBalanceBtn; // 去结算
@property (nonatomic, assign) BOOL isEdit;
@property (nonatomic, strong) JCAlertController *alert;
@property (nonatomic, strong) NSMutableArray *idsArr;
@property (nonatomic, strong) UIView *noneView;
@end

@implementation BGShoppingCartViewController
-(UIView *)noneView {
    if (!_noneView) {
        self.noneView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT-SafeAreaTopHeight)];
        _noneView.backgroundColor = kAppBgColor;
        [_noneView setHidden:YES];
        UIImageView *noneImgView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"noToken_bg"]];
        noneImgView.frame = CGRectMake(SCREEN_WIDTH*0.2, 60, SCREEN_WIDTH*0.6, SCREEN_WIDTH*0.6*1.02);
        [_noneView addSubview:noneImgView];
        
        UILabel *showMsgLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, noneImgView.frame.origin.y+noneImgView.frame.size.height+50, SCREEN_WIDTH-20, 20)];
        showMsgLabel.textAlignment = NSTextAlignmentCenter;
        [showMsgLabel setTextColor:kAppTipBGColor];
        showMsgLabel.font = kFont(14);
        showMsgLabel.text = @"亲，您还没有加入任何商品哟~";
        [_noneView addSubview:showMsgLabel];
        
        __weak typeof(self)weakSelf = self;
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [weakSelf.noneView setHidden:NO];
        });
    }
    return _noneView;
}
-(NSMutableArray *)idsArr{
    if (!_idsArr) {
        self.idsArr = [NSMutableArray array];
    }
    return _idsArr;
}
- (BGImageBtn *)allSelectBtn {
    if (!_allSelectBtn) {
        self.allSelectBtn = [[BGImageBtn alloc] initWithFrame:CGRectMake(5, 0 ,115, 50)];
    }
    return _allSelectBtn;
}
- (NSMutableArray *)cellDataArr {
    if (!_cellDataArr) {
        self.cellDataArr = [NSMutableArray array];
    }
    return _cellDataArr;
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    self.navigationController.navigationBarHidden = NO;
    [self totalPrice];
}
-(void)dealloc{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"MyCartRefreshNotification" object:nil];
}
- (void)viewDidLoad {
    [super viewDidLoad];

    [self loadSubViews];
    [self refreshView];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(MyCartRefreshAction) name:@"MyCartRefreshNotification" object:nil];
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
        weakSelf.isAllSelect = NO;
        [weakSelf.allSelectBtn changeImage:[UIImage imageNamed:@"shopping_cart_default"]];
        [weakSelf loadData];
        [weakSelf.tableView.mj_header endRefreshing];
    }];
    
    [self loadData];
}
#pragma mark  -   加载视图   -
- (void)loadSubViews {
    
    self.navigationItem.title = @"购物车";
    self.isAllSelect = NO;
    self.tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, SafeAreaTopHeight, SCREEN_WIDTH, SCREEN_HEIGHT-SafeAreaTopHeight-SafeAreaBottomHeight-50) style:(UITableViewStyleGrouped)];
    _tableView.backgroundColor = kAppBgColor;
    _tableView.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
    _tableView.separatorColor = kAppLineBGColor;
    _tableView.dataSource = self;
    _tableView.delegate = self;
    [self.view addSubview:_tableView];
    
    // 注册cell
    [self.tableView registerNib:[UINib nibWithNibName:@"BGShoppingCartCell" bundle:nil] forCellReuseIdentifier:@"BGShoppingCartCell"];
    
    // 结算View
    UIView *footerView = [[UIView alloc] initWithFrame:CGRectMake(0, SCREEN_HEIGHT-50-SafeAreaBottomHeight, SCREEN_WIDTH, 50)];
    
    footerView.backgroundColor = [UIColor whiteColor];
    // 全选button
    [self.allSelectBtn resetdata:@"全选" :[UIImage imageNamed:@"shopping_cart_default"]];
    [_allSelectBtn addTarget:self action:@selector(setAllSelectAction:) forControlEvents:(UIControlEventTouchUpInside)];
    
    [footerView addSubview:_allSelectBtn];
    
    // 结算button
    NSInteger btnWidth = 130;
    self.totalBalanceBtn = [[UIButton alloc] initWithFrame:CGRectMake(SCREEN_WIDTH-btnWidth-10, 4, btnWidth, 42)];
    [_totalBalanceBtn setTitle:@"去结算" forState:(UIControlStateNormal)];
    _totalBalanceBtn.backgroundColor = kAppMainColor;
    _totalBalanceBtn.titleLabel.font = kFont(16);
    [_totalBalanceBtn setTitleColor:kAppWhiteColor forState:(UIControlStateNormal)];
    _totalBalanceBtn.clipsToBounds = YES;
    _totalBalanceBtn.layer.cornerRadius = 5;
    _totalBalanceBtn.layer.borderWidth = 1;
    _totalBalanceBtn.layer.borderColor = kAppMainColor.CGColor;
    [_totalBalanceBtn addTarget:self action:@selector(goToFirmOrderVC) forControlEvents:(UIControlEventTouchUpInside)];
    [footerView addSubview:_totalBalanceBtn];
    
    [self.view addSubview:footerView];
    
    // 商品总价
    self.totalMoneyLabel = [[UILabel alloc] initWithFrame:CGRectMake(95, 0, SCREEN_WIDTH-btnWidth-15-100, 50)];
    _totalMoneyLabel.textAlignment = NSTextAlignmentRight;
    
    _totalMoneyLabel.font = [UIFont systemFontOfSize:15.0];
    // 创建一个属性字符串
    NSMutableAttributedString *attributedStr = [[NSMutableAttributedString alloc] initWithString:@"合计：¥0.00"];
    //设置属性
    // ¥
    [attributedStr setAttributes:@{NSFontAttributeName:kFont(14),NSForegroundColorAttributeName:kApp333Color} range:NSMakeRange(0, 3)];
    [attributedStr setAttributes:@{NSFontAttributeName:kFont(15),NSForegroundColorAttributeName:UIColorFromRGB(0xFF3542)} range:NSMakeRange(3, attributedStr.length-3)];
    // 给总价格赋值
    _totalMoneyLabel.attributedText = attributedStr;
    
    [footerView addSubview:_totalMoneyLabel];
    
    [self initRightNavigationItem];
    
}
-(void)initRightNavigationItem {
    
    self.isEdit = NO;
    UIBarButtonItem *rightItem = [[UIBarButtonItem alloc] initWithTitle:@"编辑" style:(UIBarButtonItemStyleDone) target:self action:@selector(handleRightItem:)];
    [rightItem setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:kFont(14),NSFontAttributeName,kApp333Color,NSForegroundColorAttributeName, nil] forState:(UIControlStateNormal)];
    [rightItem setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:kFont(14),NSFontAttributeName,kApp333Color,NSForegroundColorAttributeName, nil] forState:(UIControlStateHighlighted)];
    self.navigationItem.rightBarButtonItem = rightItem;
    
}
- (void)handleRightItem:(UIBarButtonItem *)sender {
    
    self.isEdit = YES;
    [self changeEditStatus];
    UIBarButtonItem *rightItem = [[UIBarButtonItem alloc] initWithTitle:@"完成" style:(UIBarButtonItemStyleDone) target:self action:@selector(handleDoneItem)];
    [rightItem setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:kFont(14),NSFontAttributeName,kApp999Color,NSForegroundColorAttributeName, nil] forState:(UIControlStateNormal)];
    [rightItem setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:kFont(14),NSFontAttributeName,kApp999Color,NSForegroundColorAttributeName, nil] forState:(UIControlStateHighlighted)];
    self.navigationItem.rightBarButtonItem = rightItem;
    
    [_totalBalanceBtn setTitle:@"删除" forState:(UIControlStateNormal)];
    _totalBalanceBtn.backgroundColor = kAppWhiteColor;
    _totalBalanceBtn.titleLabel.font = kFont(16);
    [_totalBalanceBtn setTitleColor:kAppRedColor forState:(UIControlStateNormal)];
    _totalBalanceBtn.clipsToBounds = YES;
    _totalBalanceBtn.layer.cornerRadius = 5;
    _totalBalanceBtn.layer.borderColor = kAppRedColor.CGColor;
    
}
- (void)handleDoneItem{
    self.isEdit = NO;
    [self changeEditStatus];
    UIBarButtonItem *rightItem = [[UIBarButtonItem alloc] initWithTitle:@"编辑" style:(UIBarButtonItemStyleDone) target:self action:@selector(handleRightItem:)];
    [rightItem setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:kFont(14),NSFontAttributeName,kApp333Color,NSForegroundColorAttributeName, nil] forState:(UIControlStateNormal)];
    [rightItem setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:kFont(14),NSFontAttributeName,kApp333Color,NSForegroundColorAttributeName, nil] forState:(UIControlStateHighlighted)];
    self.navigationItem.rightBarButtonItem = rightItem;
    
    [_totalBalanceBtn setTitle:@"去结算" forState:(UIControlStateNormal)];
    _totalBalanceBtn.backgroundColor = kAppMainColor;
    _totalBalanceBtn.titleLabel.font = kFont(16);
    [_totalBalanceBtn setTitleColor:kAppWhiteColor forState:(UIControlStateNormal)];
    _totalBalanceBtn.clipsToBounds = YES;
    _totalBalanceBtn.layer.cornerRadius = 5;
    _totalBalanceBtn.layer.borderColor = kAppMainColor.CGColor;

}
-(void)changeEditStatus {

    if (_isEdit) {
        _totalMoneyLabel.hidden = YES;
        [_allSelectBtn changeTitle:[NSString stringWithFormat:@"全选"]];
    }else{
        _totalMoneyLabel.hidden = NO;
    }
}
// 点击确认button跳转到确认订单界面
- (void)goToFirmOrderVC {
    [_idsArr removeAllObjects];
    _totalBalanceBtn.userInteractionEnabled = NO;
    for (int i = 0; i<_cellDataArr.count; i++) {
        BGShopModel *model = _cellDataArr[i];
        if (model.selectState) {
            [self.idsArr addObject:model.cart_id];
        }
    }
    if (![Tool arrayIsNotEmpty:_idsArr]) {
        [WHIndicatorView toast:@"请先勾选商品"];
        _totalBalanceBtn.userInteractionEnabled = YES;
        return;
    }
    NSString *idsStr = _idsArr[0];
    for (int i = 1; i<_idsArr.count; i++) {
        idsStr = [NSString stringWithFormat:@"%@,%@",idsStr,_idsArr[i]];
    }
    if (_isEdit) {
        [ProgressHUDHelper showLoading];
        NSMutableDictionary *param = [[NSMutableDictionary alloc] init];
       
        
        [param setObject:idsStr forKey:@"ids"];
        __weak __typeof(self) weakSelf = self;
        [BGShopApi deleteGoodsFromCart:param succ:^(NSDictionary *response) {
            DLog(@"\n>>>[deleteGoodsFromCart success]:%@",response);
            weakSelf.totalBalanceBtn.userInteractionEnabled = YES;
            weakSelf.isAllSelect = NO;
            [weakSelf handleDoneItem];
            [weakSelf loadData];
            
        } failure:^(NSDictionary *response) {
            DLog(@"\n>>>[deleteGoodsFromCart failure]:%@",response);
            weakSelf.totalBalanceBtn.userInteractionEnabled = YES;
        }];

    }else{
        self.totalBalanceBtn.userInteractionEnabled = YES;
        BGFirmOrderViewController *firmVC = BGFirmOrderViewController.new;
        firmVC.preNav = self.navigationController;
        firmVC.cartIds = idsStr;
        [self.navigationController pushViewController:firmVC animated:YES];
    }
    
    
}
#pragma mark  -   加载数据   -
- (void)loadData{
    
    [ProgressHUDHelper showLoading];
    [self.cellDataArr removeAllObjects];
    __weak __typeof(self) weakSelf = self;
    NSMutableDictionary *param = [NSMutableDictionary dictionary];
    [BGShopApi getCartGoodsList:param succ:^(NSDictionary *response) {
//        DLog(@"\n>>>[getCartGoodsList success]:%@",response[@"data"][@"storelist"][0][@"goodslist"]);
        [weakSelf.cellDataArr removeAllObjects];
        weakSelf.cellDataArr = [BGShopModel mj_objectArrayWithKeyValuesArray:BGdictSetObjectIsNil(response[@"result"])];
        [weakSelf.tableView reloadData];
        [weakSelf totalPrice];

    } failure:^(NSDictionary *response) {
        DLog(@"\n>>>[getCartGoodsList failure]:%@",response);
    }];
    
}


#pragma  mark  -  TableViewDelegate   -
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return _cellDataArr.count;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    BGShoppingCartCell *cell = [tableView dequeueReusableCellWithIdentifier:@"BGShoppingCartCell" forIndexPath:indexPath];
    if (![Tool arrayIsNotEmpty:_cellDataArr]) {
        return UITableViewCell.new;
    }
     BGShopModel *model = self.cellDataArr[indexPath.row];
    if (_cellDataArr.count > 0) {
        [cell updataWithCellArray:model];
    }
    
    
    
    // 商品数量改变的block回调
     __weak __typeof(self) weakSelf = self;
    cell.numChangeBtnClicked = ^(NSString *currentNum) {
        
        [ProgressHUDHelper showLoading];
        NSMutableDictionary *param = [[NSMutableDictionary alloc] init];
        [param setObject:model.cart_id forKey:@"cart_id"];
        [param setObject:currentNum forKey:@"num"];
        [BGShopApi updateGoodsNum:param succ:^(NSDictionary *response) {
            DLog(@"\n>>>[updateGoodsNum success]:%@",response);
            model.num = currentNum;
            [weakSelf totalPrice];
            
        } failure:^(NSDictionary *response) {
            DLog(@"\n>>>[updateGoodsNum failure]:%@",response);
        }];
    };
    
    cell.singleSelectClicked = ^(){
        
        model.selectState = !model.selectState;
        
        [weakSelf.tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationNone];
        
        [weakSelf totalPrice];
        
    };
    
    
    [cell setLayoutMargins:UIEdgeInsetsZero];
    [cell setSeparatorInset:UIEdgeInsetsZero];
    
    return cell;
}
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    return YES;
}
- (NSString *)tableView:(UITableView *)tableView titleForDeleteConfirmationButtonForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return @"删除";
}
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        
        self.alert = [JCAlertController alertWithTitle:@"提示" message:@"确定要删除吗?"];
        
        [_alert addButtonWithTitle:@"取消" type:JCButtonTypeCancel clicked:^{
            
        }];
        
        __weak __typeof(self) weakSelf = self;
        
        [_alert addButtonWithTitle:@"删除" type:JCButtonTypeWarning clicked:^{
            
            BGShopModel *model = weakSelf.cellDataArr[indexPath.row];
           
            [ProgressHUDHelper showLoading];
            NSMutableDictionary *param = [[NSMutableDictionary alloc] init];
            [param setObject:model.cart_id forKey:@"ids"];
            [BGShopApi deleteGoodsFromCart:param succ:^(NSDictionary *response) {
                DLog(@"\n>>>[deleteGoodsFromCart success]:%@",response);
                weakSelf.isAllSelect = NO;
                [weakSelf.allSelectBtn changeImage:[UIImage imageNamed:@"shopping_cart_default"]];
                [weakSelf loadData];

            } failure:^(NSDictionary *response) {
                DLog(@"\n>>>[deleteGoodsFromCart failure]:%@",response);
            }];

        }];
        
        [self presentViewController:_alert animated:YES completion:nil];
       
        
    }
    
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 120;
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
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
    
    BGShopModel *model = _cellDataArr[indexPath.row];
    BGShopDetailViewController *detailVC = BGShopDetailViewController.new;
    detailVC.url = BGWebGoodDetail(model.goods_id);
    detailVC.goodsid = model.goods_id;
//    detailVC.navigationItem.title = model.name;
    [self.navigationController pushViewController:detailVC animated:YES];
//    CATransition*transition=[CATransition animation];
//    transition.duration=1.0f;
//    transition.type=@"rippleEffect";
//    transition.subtype=@"fromTop";
//    [self.navigationController.view.layer addAnimation:transition forKey:kCATransition];
//    [self.navigationController pushViewController:detailVC animated:NO];
    
}

// 点击全选button的响应事件
- (void)setAllSelectAction:(BGImageBtn *)sender {

    _isAllSelect = !_isAllSelect;
    

    for (int i=0; i<_cellDataArr.count; i++) {
        BGShopModel *model = [_cellDataArr objectAtIndex:i];
        model.selectState = _isAllSelect;
    }
    
    [self.tableView reloadData];
    [self totalPrice];
}

#pragma mark -- 计算价格
-(void)totalPrice {
    if ([Tool arrayIsNotEmpty:_cellDataArr]) {
        [self.noneView removeFromSuperview];
    }else{
       [self.tableView addSubview:self.noneView];
    }
    float allPrice = 0.0;

    int selectedNum = 0;

    int allGoodsNum = 0;

    for ( int i =0; i<_cellDataArr.count; i++)
    {
        BGShopModel *model = [_cellDataArr objectAtIndex:i];
        // 全部商品的个数
        allGoodsNum = allGoodsNum + model.num.intValue;

        if (model.selectState)
        {
            allPrice = allPrice + model.num.intValue * model.price.doubleValue;
            selectedNum = selectedNum + model.num.intValue;
        }
    }
    
    // 创建一个属性字符串
    NSMutableAttributedString *attributedStr = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"合计：¥%.2f",allPrice]];
    //设置属性
    // ¥
    [attributedStr setAttributes:@{NSFontAttributeName:kFont(14),NSForegroundColorAttributeName:kApp333Color} range:NSMakeRange(0, 3)];
    [attributedStr setAttributes:@{NSFontAttributeName:kFont(15),NSForegroundColorAttributeName:UIColorFromRGB(0xFF3542)} range:NSMakeRange(3, attributedStr.length-3)];

    _totalMoneyLabel.attributedText = attributedStr;

    if (selectedNum == 0) {
        [_allSelectBtn changeTitle:[NSString stringWithFormat:@"全选"]];
    }else{
        if (!_isEdit) {
            [_allSelectBtn changeTitle:[NSString stringWithFormat:@"全选(%d)",selectedNum]];
        }
    }

    if ((selectedNum == allGoodsNum) && selectedNum > 0) {
        [_allSelectBtn changeImage:[UIImage imageNamed:@"shopping_cart_selected"]];
        _isAllSelect = YES;
    } else {
        [_allSelectBtn changeImage:[UIImage imageNamed:@"shopping_cart_default"]];
        _isAllSelect = NO;
    }
    

    allPrice = 0.0;
    selectedNum = 0;
    allGoodsNum = 0;
}
-(void)MyCartRefreshAction{
    self.isAllSelect = NO;
    [self.allSelectBtn changeImage:[UIImage imageNamed:@"shopping_cart_default"]];
    [self loadData];
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
