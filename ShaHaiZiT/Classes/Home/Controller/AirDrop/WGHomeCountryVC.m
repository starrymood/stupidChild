//
//  WGHomeCountryVC.m
//  ShaHaiZiT
//
//  Created by DY on 2019/5/9.
//  Copyright © 2019 biao. All rights reserved.
//  国内

#import "WGHomeCountryVC.h"
#import "BGAirApi.h"
#import "WGCityModel.h"

@interface WGHomeCountryVC () <UITableViewDelegate, UITableViewDataSource>

@property(nonatomic,strong) UITableView * tableView;
@property(nonatomic,strong) NSMutableArray *dataArr;
@property(nonatomic,strong) NSMutableArray *hotDataArr;
@property(nonatomic,strong) NSMutableArray *firstWordArr;
@property(nonatomic,strong) NSMutableDictionary *alphaWordDic;


@end

@implementation WGHomeCountryVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.view.backgroundColor = kAppBgColor;
    [self loadData];
}

- (void)initUI {
    self.tableView = [[UITableView alloc] initWithFrame:CGRectZero style:(UITableViewStylePlain)];
    _tableView.dataSource = self;
    _tableView.delegate =self;
    _tableView.backgroundColor = kAppBgColor;
    _tableView.estimatedSectionFooterHeight = 0;
    _tableView.estimatedSectionHeaderHeight =0;
    _tableView.estimatedRowHeight = 46;
    _tableView.sectionIndexBackgroundColor = [UIColor clearColor];
    [self.view addSubview:_tableView];
    [_tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.view);
    }];
}


- (void)loadData {
    
    NSArray *historyArr = [[NSUserDefaults standardUserDefaults] objectForKey:HistoryCity];
    if (historyArr.count > 0) {
        [self.alphaWordDic setObject:historyArr forKey:@"历史"];
    }
    
    [self loadHotCityData];
    [self loadCityList];
}

- (void)loadHotCityData {
    [ProgressHUDHelper showLoading];
    NSMutableDictionary *param = [[NSMutableDictionary alloc] init];
    [param setObject:@"cn" forKey:@"country_code"];
    __weak __typeof(self) weakSelf = self;
    [BGAirApi getAirFlyHotCityListsDetail:param Succ:^(NSDictionary *response) {
        DLog(@"\n>>>[getFoodLocationDetail sucess]:%@",response);
        [weakSelf hideNodateView];
        weakSelf.hotDataArr = [WGCityModel mj_keyValuesArrayWithObjectArray:response[@"result"]];
        [weakSelf.alphaWordDic setObject:weakSelf.hotDataArr forKey:@"热门"];
        [weakSelf.tableView reloadData];
    } failure:^(NSDictionary *response) {
        DLog(@"\n>>>[getFoodLocationDetail failure]:%@",response);
        [ProgressHUDHelper removeLoading];
        [self shownoNetWorkViewWithType:0];
        [self setRefreshBlock:^{
            [weakSelf loadData];
        }];
    }];
}

- (void)loadCityList {
    [ProgressHUDHelper showLoading];
    NSMutableDictionary *param = [[NSMutableDictionary alloc] init];
    [param setObject:@"cn" forKey:@"country_code"];
    __weak __typeof(self) weakSelf = self;
    [BGAirApi getAirFlyCityListsDetail:param Succ:^(NSDictionary *response) {
        DLog(@"\n>>>[getFoodLocationDetail sucess]:%@",response);
        weakSelf.dataArr = [WGCityModel mj_keyValuesArrayWithObjectArray:response[@"result"]];
        
        [weakSelf hideNodateView];
    } failure:^(NSDictionary *response) {
        DLog(@"\n>>>[getFoodLocationDetail failure]:%@",response);
        [ProgressHUDHelper removeLoading];
        [self shownoNetWorkViewWithType:0];
        [self setRefreshBlock:^{
            [weakSelf loadData];
        }];
    }];
}

#pragma Mark private
- (void)seperateDifferentCityForAlphaWith:(NSMutableArray <WGCityModel *> *)arr {
    
    [arr enumerateObjectsUsingBlock:^(WGCityModel * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        NSString *firstWord = [obj.city_en substringToIndex:1];
        [firstWord uppercaseString];
        if (![self.firstWordArr containsObject:firstWord]) {
            [self.firstWordArr addObject:firstWord];
        }
    }];
}

#pragma Mark lazy
- (NSMutableArray *)dataArr {
    if (!_dataArr) {
        _dataArr = [NSMutableArray array];
    }
    return _dataArr;
}

- (NSMutableArray *)firstWordArr {
    if (!_firstWordArr) {
        _firstWordArr = [NSMutableArray array];
    }
    return _firstWordArr;
}

- (NSMutableDictionary *)alphaWordDic {
    if (!_alphaWordDic) {
        _alphaWordDic = [NSMutableDictionary dictionary];
    }
    return _alphaWordDic;
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
