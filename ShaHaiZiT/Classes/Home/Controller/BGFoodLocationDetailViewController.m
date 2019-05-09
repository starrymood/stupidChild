
//
//  BGFoodLocationDetailViewController.m
//  ShaHaiZiT
//
//  Created by biao on 2019/4/15.
//  Copyright © 2019 biao. All rights reserved.
//

#import "BGFoodLocationDetailViewController.h"
#import <SDCycleScrollView.h>
#import "BGAirApi.h"
#import "BGFoodLocationDetailModel.h"

@interface BGFoodLocationDetailViewController ()<UIWebViewDelegate>
@property (weak, nonatomic) IBOutlet SDCycleScrollView *cycleScrollView;
@property (weak, nonatomic) IBOutlet UILabel *tileeLabel;
@property (weak, nonatomic) IBOutlet UILabel *addressLabel;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *scrollCenterY;
@property (weak, nonatomic) IBOutlet UIWebView *webView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *detailViewHeight;
@property (weak, nonatomic) IBOutlet UIView *detailView;

@end

@implementation BGFoodLocationDetailViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self loadSubViews];
    [self loadData];
}
-(void)loadSubViews{
    self.navigationItem.title = @"详情页";
    self.view.backgroundColor = kAppBgColor;
    
    self.cycleScrollView.pageControlAliment = SDCycleScrollViewPageContolAlimentCenter;
    self.cycleScrollView.backgroundColor = kAppWhiteColor;
}
-(void)loadData{
    [ProgressHUDHelper showLoading];
    NSMutableDictionary *param = [[NSMutableDictionary alloc] init];
    [param setObject:_landmark_id forKey:@"landmark_id"];
    __weak __typeof(self) weakSelf = self;
    [BGAirApi getFoodLocationDetail:param succ:^(NSDictionary *response) {
        DLog(@"\n>>>[getFoodLocationDetail sucess]:%@",response);
        [weakSelf hideNodateView];
        BGFoodLocationDetailModel *model = [BGFoodLocationDetailModel mj_objectWithKeyValues:BGdictSetObjectIsNil(response[@"result"])];
        [weakSelf updateSubViewsWithModel:model];
    } failure:^(NSDictionary *response) {
        DLog(@"\n>>>[getFoodLocationDetail failure]:%@",response);
        [ProgressHUDHelper removeLoading];
        [self shownoNetWorkViewWithType:0];
        [self setRefreshBlock:^{
            [weakSelf loadData];
        }];
    }];
    
}
-(void)updateSubViewsWithModel:(BGFoodLocationDetailModel *)model{
    self.cycleScrollView.imageURLStringsGroup = model.banner_picture;
    self.tileeLabel.text = model.title;
    self.addressLabel.text = [NSString stringWithFormat:@"地址：%@",model.address];
    [_webView loadHTMLString:[Tool attributeByWeb:model.content width:SCREEN_WIDTH-20 scale:SCREEN_WIDTH*0.96] baseURL:nil];
    _webView.delegate = self;
}
-(void)webViewDidFinishLoad:(UIWebView *)webView{
    //HTML5的高度
    NSString *htmlHeight = [webView stringByEvaluatingJavaScriptFromString:@"document.body.scrollHeight"];
    if ([htmlHeight isEqualToString:@"45"]) {
        self.detailViewHeight.constant = 47;
    }else{
        self.detailViewHeight.constant = [htmlHeight floatValue];
    } 
    self.scrollCenterY.constant = (_detailView.y+_detailView.height+30+self.detailViewHeight.constant-SCREEN_HEIGHT+SafeAreaTopHeight+SafeAreaBottomHeight-45)*0.5;
    [UIView animateWithDuration:.2 animations:^{
        [self.view layoutIfNeeded];
        
    } completion:^(BOOL finished) {
        
    }];
    
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
