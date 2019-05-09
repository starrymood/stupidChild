//
//  SHZCountryViewController.m
//  shahaizic
//
//  Created by 姜昊 on 2018/1/30.
//  Copyright © 2018年 姜昊. All rights reserved.
//

#import "SHZCountryViewController.h"
#import "SHZCountryTableViewCell.h"

@interface SHZCountryViewController ()
<UITableViewDelegate, UITableViewDataSource>
{
    NSArray *countryAry;
    NSArray *indexAry;
}
@property (weak, nonatomic) IBOutlet UITableView *countryTV;

@end

@implementation SHZCountryViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    countryAry = [NSArray array];
    indexAry = [NSArray array];

    // Do any additional setup after loading the view from its nib.
    NSBundle *mainBundle = [NSBundle mainBundle];
    [self.countryTV registerNib:[UINib nibWithNibName:@"SHZCountryTableViewCell" bundle:mainBundle] forCellReuseIdentifier:@"SHZCountryTableID"];
    self.countryTV.estimatedRowHeight = 45;
    self.countryTV.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.countryTV.sectionIndexColor = kAppMainColor;
    self.navigationItem.title = @"选择国家区号";
    //读取plist
    [self getDataFromPlist];
    
    
}

- (void)getDataFromPlist{
    NSString *plistPath = [[NSBundle mainBundle] pathForResource:@"CountryPhone" ofType:@"plist"];
    NSMutableDictionary *dataDic = [[NSMutableDictionary alloc]initWithContentsOfFile:plistPath];
    countryAry = dataDic[@"data"];
    indexAry = dataDic[@"index"];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - UITableView

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return indexAry.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return [[countryAry objectAtIndex:section] count];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 45;
}

#pragma mark 设置组标题
- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    return [indexAry objectAtIndex:section];
}

#pragma mark 右侧索引
-(NSArray *)sectionIndexTitlesForTableView:(UITableView *)tableView
{
    return indexAry;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    SHZCountryTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"SHZCountryTableID" forIndexPath:indexPath];
//    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    cell.countryDic = countryAry[indexPath.section][indexPath.row];
    [cell layoutSubviews];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        if (self.countryBlock != nil) {
            self.countryBlock(countryAry[indexPath.section][indexPath.row]);
        }
        [self.navigationController popViewControllerAnimated:YES];
    });
}

- (void)countryCellDic:(CountryBlock)block {
    self.countryBlock = block;
}

@end
