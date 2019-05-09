//
//  BGMyActivityViewController.m
//  ShaHaiZiT
//
//  Created by biao on 2018/11/23.
//  Copyright © 2018 biao. All rights reserved.
//

#import "BGMyActivityViewController.h"
#import "BGPromotionPastListViewController.h"

@interface BGMyActivityViewController ()

@end

@implementation BGMyActivityViewController

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    self.navigationController.navigationBarHidden = NO;
    
}
- (void)viewDidLoad {
    [super viewDidLoad];
   
    self.navigationItem.title = @"我的活动";
    self.view.backgroundColor = kAppBgColor;
}
- (IBAction)btnIngClicked:(UIButton *)sender {
    BGPromotionPastListViewController *listVC = BGPromotionPastListViewController.new;
    listVC.navigationItem.title = @"报名的活动";
    listVC.type = 2;
    [self.navigationController pushViewController:listVC animated:YES];
}

- (IBAction)btnOldClicked:(UIButton *)sender {
    BGPromotionPastListViewController *listVC = BGPromotionPastListViewController.new;
    listVC.navigationItem.title = @"参与过的活动";
    listVC.type = 3;
    [self.navigationController pushViewController:listVC animated:YES];
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
