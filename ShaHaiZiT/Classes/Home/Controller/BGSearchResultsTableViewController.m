//
//  BGSearchResultsTableViewController.m
//  LLBike
//
//  Created by biao on 2017/4/11.
//  Copyright © 2017年 ZZLL. All rights reserved.
//

#import "BGSearchResultsTableViewController.h"
#import "BGSearchTipsLocationCell.h"
#import "BGAirApi.h"
#import "BGAirportCategoryModel.h"

@interface BGSearchResultsTableViewController ()
@property (nonatomic, strong) NSMutableArray *tips;
@end

@implementation BGSearchResultsTableViewController

-(NSMutableArray *)tips{
    if (!_tips) {
        self.tips = [NSMutableArray array];
    }
    return _tips;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self.tableView registerNib:[UINib nibWithNibName:@"BGSearchTipsLocationCell" bundle:nil] forCellReuseIdentifier:@"BGSearchTipsLocationCell"];
    // cell较少情况下不显示下面的分割线条
    self.tableView.tableFooterView = [UIView new];
    //添加当前类对象为一个观察者，name和object设置为nil，表示接收一切通知
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleTextChange:) name:@"searchBarDidChange" object:nil];
    
}

/**
 接收searchBar.text

 @param sender 通知
 */
-(void)handleTextChange:(NSNotification* )sender
{
    NSString *text = sender.userInfo[@"searchText"];
    [self searchTipsWithKey:text];

}

/* 输入提示回调. */
- (void)dealResultWithResponse:(NSMutableArray *)response
{
    //解析response获取提示词，具体解析见 Demo
    [self.tips removeAllObjects];

    for (int i = 0; i <response.count; i++) {
        BGAirportCategoryModel *tip = response[i];
        if (tip.region_name != nil)
        {
            [self.tips addObject:tip];
        }
    }

    [self.tableView reloadData];
    
    
}
/* 输入提示 搜索.*/
- (void)searchTipsWithKey:(NSString *)key
{
    if (key.length == 0)
    {
        return;
    }
    
    [self loadDataWithKey:key];
}
-(void)loadDataWithKey:(NSString *)key {
    NSMutableDictionary *param = [[NSMutableDictionary alloc] init];
    [param setObject:key forKey:@"name"];
    [param setObject:@(_category) forKey:@"category"];

    __block typeof(self) weakSelf = self;
    [BGAirApi searchAirCity:param category:_category succ:^(NSDictionary *response) {
        DLog(@"\n>>>[searchAirCity sucess]:%@",response);
        NSMutableArray *tempArr = [BGAirportCategoryModel mj_objectArrayWithKeyValuesArray:response[@"result"]];
        [weakSelf dealResultWithResponse:tempArr];

    } failure:^(NSDictionary *response) {
        DLog(@"\n>>>[searchAirCity failure]:%@",response);
    }];
}



#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.tips.count;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    BGSearchTipsLocationCell *cell = [tableView dequeueReusableCellWithIdentifier:@"BGSearchTipsLocationCell" forIndexPath:indexPath];
    
    BGAirportCategoryModel *tip = self.tips[indexPath.row];
    if (_category<3) {
        cell.nameLabel.text = tip.airport_name;
        cell.locationLabel.text = tip.region_name;
    }else{
        cell.nameLabel.text = tip.region_name;
        cell.locationLabel.text = tip.country_name;
    }
    
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    // 取消选中
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
     BGAirportCategoryModel *tip = self.tips[indexPath.row];
   
    // 代理传值
    if (self.didSelectLocation) {
        self.didSelectLocation(tip);
    }
   
}
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 45;
}
- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
@end
