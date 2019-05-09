//
//  BGLineSpotViewController.m
//  ShaHaiZiT
//
//  Created by biao on 2018/11/29.
//  Copyright © 2018 biao. All rights reserved.
//

#import "BGLineSpotViewController.h"
#import "BGAirApi.h"
#import <SDCycleScrollView.h>

@interface BGLineSpotViewController ()
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *contentCenterY;
@property (weak, nonatomic) IBOutlet SDCycleScrollView *cycleScrollView;
@property (weak, nonatomic) IBOutlet UITextView *oneTextView;
@property (weak, nonatomic) IBOutlet UITextView *twoTextView;
@property (weak, nonatomic) IBOutlet UITextView *threeTextView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *oneViewHeight;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *twoViewHeight;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *threeViewHeight;
@property (weak, nonatomic) IBOutlet UIView *tipView;

@end

@implementation BGLineSpotViewController

- (void)viewDidLoad {
    [super viewDidLoad];
   
    self.view.backgroundColor = kAppBgColor;
    [self loadData];
}
-(void)loadData{
    
    NSMutableDictionary *param = [[NSMutableDictionary alloc] init];
    if (![Tool isBlankString:_spot_id]) {
        [param setObject:_spot_id forKey:@"spot_id"];
    }
    [ProgressHUDHelper showLoading];
    __block typeof(self) weakSelf = self;
    [BGAirApi getSpotInfoByID:param succ:^(NSDictionary *response) {
        DLog(@"\n>>>[getSpotInfoByID sucess]:%@",response);
        [self hideNodateView];
        [self updateSubViewsWithData:BGdictSetObjectIsNil(response[@"result"])];

    } failure:^(NSDictionary *response) {
        DLog(@"\n>>>[getSpotInfoByID failure]:%@",response);
        [self shownoNetWorkViewWithType:0];
        [self setRefreshBlock:^{
            [weakSelf loadData];
        }];
    }];
}
-(void)updateSubViewsWithData:(NSDictionary *)dataDic{
    
     NSString *spot_content = BGdictSetObjectIsNil(dataDic[@"spot_content"]);
     NSString *spot_cost = BGdictSetObjectIsNil(dataDic[@"spot_cost"]);
     NSArray *spot_pictures = BGdictSetObjectIsNil(dataDic[@"spot_pictures"]);
     NSString *spot_tips = BGdictSetObjectIsNil(dataDic[@"spot_tips"]);
    
//    self.cycleScrollView.bannerImageViewContentMode = UIViewContentModeScaleAspectFit;
    self.cycleScrollView.pageControlAliment = SDCycleScrollViewPageContolAlimentCenter;
    self.cycleScrollView.backgroundColor = kAppBgColor;
    self.cycleScrollView.imageURLStringsGroup = spot_pictures;
    
    self.oneTextView.text = spot_content;
    self.oneViewHeight.constant = [self heightForString:self.oneTextView andWidth:SCREEN_WIDTH-12*2]+46;
    self.twoTextView.text = spot_cost;
    self.twoViewHeight.constant = [self heightForString:self.twoTextView andWidth:SCREEN_WIDTH-12*2]+46;
    self.threeTextView.text = spot_tips;
    self.threeViewHeight.constant = [self heightForString:self.threeTextView andWidth:SCREEN_WIDTH-12*2]+46;
    [self changeViewFrame];
}

-(void)changeViewFrame{
    self.contentCenterY.constant = (_tipView.y+_tipView.height-SCREEN_HEIGHT+SafeAreaTopHeight+SafeAreaBottomHeight+self.oneViewHeight.constant+self.twoViewHeight.constant+self.threeViewHeight.constant-60*3+55)*0.5;
    [UIView animateWithDuration:.2 animations:^{
        [self.view layoutIfNeeded];
    }];
}
- (float)heightForString:(UITextView *)textView andWidth:(float)width{
    CGSize sizeToFit = [textView sizeThatFits:CGSizeMake(width, MAXFLOAT)];
    return sizeToFit.height;
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
