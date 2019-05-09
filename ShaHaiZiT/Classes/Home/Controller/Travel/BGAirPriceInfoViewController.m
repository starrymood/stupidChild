//
//  BGAirPriceInfoViewController.m
//  shzTravelC
//
//  Created by biao on 2018/8/20.
//  Copyright © 2018年 biao. All rights reserved.
//

#import "BGAirPriceInfoViewController.h"
#import <SDCycleScrollView.h>
#import "BGAirApi.h"
#import "BGAirPriceInfoModel.h"
#import "BGPickUpAirportViewController.h"
#import "BGDropOffAirportViewController.h"
#import <JCAlertController.h>
#import "BGAirPriceCommentModel.h"
#import <UIImageView+WebCache.h>
#import "BGCommunityApi.h"
#import "BGTravelCommentListViewController.h"
#import "BGChatViewController.h"

@interface BGAirPriceInfoViewController ()
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *contentCenterY;
@property (weak, nonatomic) IBOutlet UILabel *titleeLabel;
@property (weak, nonatomic) IBOutlet SDCycleScrollView *cycleScrollView;
@property (weak, nonatomic) IBOutlet UILabel *carNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *peopleNumLabel;
@property (weak, nonatomic) IBOutlet UILabel *carPriceLabel;
@property (weak, nonatomic) IBOutlet UIView *serviceView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *serviceViewHeight;
@property (weak, nonatomic) IBOutlet UITextView *remarkTextView;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *illustrateViewHeight;
@property (weak, nonatomic) IBOutlet UIButton *nextBtn;
@property (weak, nonatomic) IBOutlet UILabel *unsubscribeLabel;
@property (nonatomic, strong) BGAirPriceInfoModel *fModel;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *nextBtnTop;
@property (weak, nonatomic) IBOutlet UIImageView *cHeadImgView;
@property (weak, nonatomic) IBOutlet UILabel *cNickNameLabel;
@property (weak, nonatomic) IBOutlet UIImageView *cGradesImgView;
@property (weak, nonatomic) IBOutlet UITextView *cNoteView;
@property (weak, nonatomic) IBOutlet UILabel *cTimeLabel;
@property (weak, nonatomic) IBOutlet UIView *commentView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *commentViewHeight;
@property (weak, nonatomic) IBOutlet UIButton *commentNumBtn;

@end

@implementation BGAirPriceInfoViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self loadSubViews];
    [self loadData];
}
-(void)loadSubViews {
    
    self.navigationItem.title = @"产品详情";
    self.view.backgroundColor = kAppBgColor;

    self.navigationItem.rightBarButtonItem = [UIBarButtonItem itemWithImage:@"hotline_right" highImage:@"hotline_right" target:self action:@selector(clickedHotlineAction)];
    self.cycleScrollView.pageControlAliment = SDCycleScrollViewPageContolAlimentCenter;
    self.cycleScrollView.currentPageDotImage = BGImage(@"pageControlCurrentDot");
    self.cycleScrollView.pageDotImage = BGImage(@"pageControlDot");
    self.cycleScrollView.backgroundColor = kAppBgColor;
//    self.cycleScrollView.bannerImageViewContentMode = UIViewContentModeScaleAspectFit;
    self.cycleScrollView.backgroundColor = kAppBgColor;
    [self changeViewFrame];
}
-(void)clickedHotlineAction{
    if (![Tool isLogin]) {
        [WHIndicatorView toast:@"请先登录!"];
        [BGAppDelegateHelper showLoginViewController];
        return;
    }
    BGChatViewController *conversationVC = [[BGChatViewController alloc]init];
    conversationVC.conversationType = ConversationType_PRIVATE;
    
    conversationVC.targetId = [NSString stringWithFormat:@"%@",_fModel.service_id];
    conversationVC.title = [NSString stringWithFormat:@"%@",_fModel.service_name];
    [self.navigationController pushViewController:conversationVC animated:YES];
}
-(void)loadData{
    [ProgressHUDHelper showLoading];
    NSMutableDictionary *param = [[NSMutableDictionary alloc] init];
    [param setObject:_product_id forKey:@"product_id"];
    __weak __typeof(self) weakSelf = self;
    [BGAirApi getCarInfoById:param succ:^(NSDictionary *response) {
        DLog(@"\n>>>[getCarInfoById sucess]:%@",response);
        [weakSelf hideNodateView];
        BGAirPriceInfoModel *model = [BGAirPriceInfoModel mj_objectWithKeyValues:BGdictSetObjectIsNil(response[@"result"])];
        weakSelf.fModel = model;
        [weakSelf updateSubViewsWithModel:model];
    } failure:^(NSDictionary *response) {
        DLog(@"\n>>>[getCarInfoById failure]:%@",response);
        [ProgressHUDHelper removeLoading];
        [self shownoNetWorkViewWithType:0];
        [self setRefreshBlock:^{
            [weakSelf loadData];
        }];
    }];
    
}
-(void)updateSubViewsWithModel:(BGAirPriceInfoModel *)model{

    @weakify(self);
    [[self.nextBtn rac_signalForControlEvents:(UIControlEventTouchUpInside)] subscribeNext:^(__kindof UIControl * _Nullable x) {
        @strongify(self);
        // 点击button的响应事件
        if (self.category == 1) {
            BGPickUpAirportViewController *pickVC = BGPickUpAirportViewController.new;
            pickVC.product_id = self.product_id;
            pickVC.fModel = self.fModel;
            [self.navigationController pushViewController:pickVC animated:YES];
        }else{
            BGDropOffAirportViewController *dropVC = BGDropOffAirportViewController.new;
            dropVC.product_id = self.product_id;
            dropVC.fModel = self.fModel;
            [self.navigationController pushViewController:dropVC animated:YES];
        }
    }];
    self.titleeLabel.text = [NSString stringWithFormat:@"%@%@%@",model.country_name,model.region_name,model.airport_name];
    self.cycleScrollView.imageURLStringsGroup = model.car_pictures;
    self.carNameLabel.text = model.model_name;
    self.peopleNumLabel.text = [NSString stringWithFormat:@"%@人%@行李",model.passenger_number,model.baggage_number];
    self.carPriceLabel.text = [NSString stringWithFormat:@"¥%.2f", model.product_price.doubleValue];
    
    self.serviceViewHeight.constant =39+model.service_configuration.count/3*(39+24);
    
    for (int i = 0; i<model.service_configuration.count; i++) {
        UILabel *lab = UILabel.new;
        CGFloat spaceWidth = SCREEN_WIDTH*0.072;
        CGFloat btnWidth = (SCREEN_WIDTH-spaceWidth*4)/3.0;
        lab.frame = CGRectMake(spaceWidth+i%3*(90+spaceWidth), i/3*(39+24), btnWidth, 39);
        lab.textColor = kApp999Color;
        lab.backgroundColor = UIColorFromRGB(0xEEEEEE);
        lab.clipsToBounds = YES;
        lab.layer.cornerRadius = lab.height*0.5;
        lab.font = kFont(14);
        lab.textAlignment = NSTextAlignmentCenter;
        NSString *nameStr = [NSString stringWithFormat:@"%@",[model.service_configuration[i] objectForKey:@"name"]];
        lab.text = nameStr;
        NSString *isShowStr = [NSString stringWithFormat:@"%@",[model.service_configuration[i] objectForKey:@"is_show"]];
        if(isShowStr.intValue == 1){
            lab.textColor = kAppMainColor;
            lab.font = [UIFont boldSystemFontOfSize:14];
            lab.backgroundColor = kAppWhiteColor;
        }
        [self.serviceView addSubview:lab];
    }
    _commentNumBtn.contentHorizontalAlignment = UIControlContentHorizontalAlignmentRight;
    [_commentNumBtn setTitle:[NSString stringWithFormat:@"%@条评论 >",model.review_count] forState:(UIControlStateNormal)];
    [[_commentNumBtn rac_signalForControlEvents:(UIControlEventTouchUpInside)] subscribeNext:^(__kindof UIControl * _Nullable x) {
        @strongify(self);
        // 点击button的响应事件
        BGTravelCommentListViewController *listVC = BGTravelCommentListViewController.new;
        listVC.product_id = self.product_id;
        [self.navigationController pushViewController:listVC animated:YES];
    }];
    if ([Tool arrayIsNotEmpty:model.review_list]) {
        BGAirPriceCommentModel *cModel = [BGAirPriceCommentModel mj_objectWithKeyValues:model.review_list[0]];
        [_cHeadImgView sd_setImageWithURL:[NSURL URLWithString:cModel.face] placeholderImage:BGImage(@"defaultUserIcon")];
        _cNickNameLabel.text = cModel.nickname;
        
        _cTimeLabel.text = [Tool dateFormatter:cModel.create_time.doubleValue dateFormatter:@"yyyy.MM.dd"];
        NSArray *starNameArr = @[@"comment_star_one",@"comment_star_two",@"comment_star_three",@"comment_star_four",@"comment_star_five"];
        if (starNameArr.count>cModel.satisfaction_level.intValue-1) {
            [_cGradesImgView setImage:BGImage(starNameArr[cModel.satisfaction_level.intValue-1])];
        }
        _cNoteView.text = cModel.content;
        
        self.commentViewHeight.constant = [self heightForString:self.cNoteView andWidth:SCREEN_WIDTH-42]+49+36;
        self.nextBtnTop.constant = self.commentViewHeight.constant+6+29;
    }else{
        [self.commentView removeFromSuperview];
        self.nextBtnTop.constant = 54;
    }
    if ([Tool isBlankString:model.remark]) {
        model.remark = @"无特殊说明";
    }
    _remarkTextView.text = model.remark;
    self.illustrateViewHeight.constant = [self heightForString:self.remarkTextView andWidth:SCREEN_WIDTH-30];
    self.unsubscribeLabel.text = model.unsubscribe_title;
    [self changeViewFrame];
}
-(void)changeViewFrame{
    self.contentCenterY.constant = (_nextBtn.y+self.nextBtnTop.constant-140+_nextBtn.height-SCREEN_HEIGHT+SafeAreaTopHeight+SafeAreaBottomHeight+55+self.serviceViewHeight.constant+self.illustrateViewHeight.constant-100-21)*0.5;
    [UIView animateWithDuration:.2 animations:^{
        [self.view layoutIfNeeded];
    }];
}
- (float)heightForString:(UITextView *)textView andWidth:(float)width{
    CGSize sizeToFit = [textView sizeThatFits:CGSizeMake(width, MAXFLOAT)];
    return sizeToFit.height;
}
- (IBAction)btnServicePolicyClicked:(UIButton *)sender {

    CGFloat width = [JCAlertStyle shareStyle].alertView.width;
    UIWebView *webView = [[UIWebView alloc] initWithFrame:CGRectMake(0, 0, width, SCREEN_HEIGHT*0.6)];
    webView.backgroundColor = kAppWhiteColor;
    [webView loadHTMLString:[Tool attributeByWeb:_fModel.unsubscribe_content width:width scale:width*0.96] baseURL:nil];
    JCAlertController *alert = [JCAlertController alertWithTitle:@"退订政策" contentView:webView];
    JCAlertStyle *style = [JCAlertStyle shareStyle];
    style.background.canDismiss = YES;
    style.title.backgroundColor = kAppMainColor;
    [alert addButtonWithTitle:@"确定" type:JCButtonTypeNormal clicked:^{
        
    }];
    [self presentViewController:alert animated:YES completion:nil];
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
