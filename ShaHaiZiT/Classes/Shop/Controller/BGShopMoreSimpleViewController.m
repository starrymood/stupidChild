//
//  BGShopMoreSimpleViewController.m
//  ShaHaiZiT
//
//  Created by biao on 2019/1/12.
//  Copyright © 2019 biao. All rights reserved.
//

#import "BGShopMoreSimpleViewController.h"
#import "BGShopListViewController.h"
#import "BGShopApi.h"
#import "BGShopSortsModel.h"
#import "BGHomeBtn.h"
#import <UIImageView+WebCache.h>

@interface BGShopMoreSimpleViewController ()

@property (nonatomic,strong) NSMutableArray *leftDataArr;

@end

@implementation BGShopMoreSimpleViewController
-(NSMutableArray *)leftDataArr{
    if (!_leftDataArr) {
        self.leftDataArr = [NSMutableArray array];
    }
    return _leftDataArr;
}
-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    self.navigationController.navigationBarHidden = NO;
}
- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self loadSubViews];
        
    [self loadLeftData];
}
-(void)loadSubViews {
    
    self.navigationItem.title = @"更多分类";
    self.view.backgroundColor = kAppBgColor;
    
}
-(void)loadLeftData {
    
    [ProgressHUDHelper showLoading];
    NSMutableDictionary *param = [NSMutableDictionary dictionary];
    __weak __typeof(self) weakSelf = self;
    [BGShopApi getGoodsSort:param succ:^(NSDictionary *response) {
        DLog(@"\n>>>[getGoodsSortA sucess]:%@",response);
        [weakSelf hideNodateView];
        weakSelf.leftDataArr = [BGShopSortsModel mj_objectArrayWithKeyValuesArray:response[@"result"]];
        [weakSelf createSortBtn];
    } failure:^(NSDictionary *response) {
        DLog(@"\n>>>[getGoodsSortA failure]:%@",response);
        [ProgressHUDHelper removeLoading];
        [weakSelf shownoNetWorkViewWithType:0];
        [weakSelf setRefreshBlock:^{
            [weakSelf loadLeftData];
        }];
    }];
    
}
-(void)createSortBtn{
    
    UIView *bgView = UIView.new;
    bgView.backgroundColor = kAppWhiteColor;
    bgView.frame = CGRectMake(0, SafeAreaTopHeight+6, SCREEN_WIDTH, SCREEN_HEIGHT-SafeAreaTopHeight-6);
    [self.view addSubview:bgView];
    
    CGFloat spaceWidth = SCREEN_WIDTH*0.1;
    CGFloat btnWidth = (SCREEN_WIDTH-spaceWidth*4)/3.0;
    for (int i = 0; i < _leftDataArr.count; i++) {
        BGShopSortsModel *model = _leftDataArr[i];
        BGHomeBtn *itemBtn = [[BGHomeBtn alloc] initWithFrame:CGRectMake(spaceWidth+i%3*(spaceWidth+btnWidth), 15+i/3* (btnWidth+10+20), btnWidth, btnWidth+10)];
        [itemBtn.btnImgView sd_setImageWithURL:[NSURL URLWithString:model.main_pic]];
        itemBtn.btnTitleLabel.text = model.name;

        itemBtn.tag = 100+i;
        [itemBtn addTarget:self action:@selector(itemBtnClicked:) forControlEvents:UIControlEventTouchUpInside];
        [bgView addSubview:itemBtn];
    }
}
- (void)itemBtnClicked:(UIButton *)sender {
    
    BGShopSortsModel *model = _leftDataArr[sender.tag-100];
    BGShopListViewController *shopListVC = BGShopListViewController.new;
    shopListVC.cat_id = model.ID;
    [self.navigationController pushViewController:shopListVC animated:YES];
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
