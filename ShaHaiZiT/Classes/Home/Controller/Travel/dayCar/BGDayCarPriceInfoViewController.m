//
//  BGDayCarPriceInfoViewController.m
//  shzTravelC
//
//  Created by biao on 2018/8/23.
//  Copyright © 2018年 biao. All rights reserved.
//

#import "BGDayCarPriceInfoViewController.h"
#import "BGAirApi.h"
#import "BGAirPriceInfoModel.h"
#import "BGDayCarInputViewController.h"
#import <JCAlertController.h>
#import "BGAirPriceCommentModel.h"
#import <UIImageView+WebCache.h>
#import "BGCommunityApi.h"
#import "BGTravelCommentListViewController.h"
#import "BGChatViewController.h"

@interface BGDayCarPriceInfoViewController ()<UIWebViewDelegate>
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *contentCenterY;
@property (weak, nonatomic) IBOutlet UILabel *titleeLabel;
@property (weak, nonatomic) IBOutlet UIImageView *carImgView;
@property (weak, nonatomic) IBOutlet UILabel *carNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *peopleNumLabel;
@property (weak, nonatomic) IBOutlet UILabel *carPriceLabel;
@property (weak, nonatomic) IBOutlet UIView *serviceView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *serviceViewHeight;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *remarkViewHeight;
@property (weak, nonatomic) IBOutlet UIButton *nextBtn;
@property (weak, nonatomic) IBOutlet UILabel *serviceTimeLabel;
@property (weak, nonatomic) IBOutlet UILabel *serviceMileageLabel;
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
@property (weak, nonatomic) IBOutlet UIWebView *remarkWebView;

@end

@implementation BGDayCarPriceInfoViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self loadSubViews];
    [self loadData];
}
-(void)loadSubViews {
    
    self.navigationItem.title = @"产品详情";
    self.view.backgroundColor = kAppBgColor;
    self.navigationItem.rightBarButtonItem = [UIBarButtonItem itemWithImage:@"hotline_right" highImage:@"hotline_right" target:self action:@selector(clickedHotlineAction)];
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
    self.titleeLabel.text = [NSString stringWithFormat:@"%@%@包车",model.country_name,model.region_name];
    @weakify(self);
    [[self.nextBtn rac_signalForControlEvents:(UIControlEventTouchUpInside)] subscribeNext:^(__kindof UIControl * _Nullable x) {
        @strongify(self);
        // 点击button的响应事件
        BGDayCarInputViewController *inputVC = BGDayCarInputViewController.new;
        inputVC.product_id = self.product_id;
        inputVC.fModel = self.fModel;
        [self.navigationController pushViewController:inputVC animated:YES];
        
    }];
    if ([Tool arrayIsNotEmpty:model.car_pictures]) {
        [self.carImgView sd_setImageWithURL:[NSURL URLWithString:model.car_pictures[0]]];
//        self.carImgView.contentMode = UIViewContentModeScaleAspectFit;
    }
    self.carNameLabel.text = model.model_name;
   self.peopleNumLabel.text = [NSString stringWithFormat:@"%@人%@行李",model.passenger_number,model.baggage_number];
    self.carPriceLabel.text = [NSString stringWithFormat:@"¥%.2f", model.product_price.doubleValue];
    self.serviceTimeLabel.text = [NSString stringWithFormat:@"%@小时",model.service_duration];
    self.serviceMileageLabel.text = [NSString stringWithFormat:@"%@公里", model.service_mileage];
    self.unsubscribeLabel.text = model.unsubscribe_title;
    
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
    [_commentNumBtn setTitle:[NSString stringWithFormat:@"%@条评价 >",model.review_count] forState:(UIControlStateNormal)];
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
    [_remarkWebView loadHTMLString:[Tool attributeByWeb:model.product_content width:SCREEN_WIDTH-20 scale:SCREEN_WIDTH*0.96] baseURL:nil];
    _remarkWebView.delegate = self;
    [self changeViewFrame];
}
-(void)changeViewFrame{
    self.contentCenterY.constant = (_nextBtn.y+self.nextBtnTop.constant-140+_nextBtn.height-SCREEN_HEIGHT+SafeAreaTopHeight+SafeAreaBottomHeight+55+self.serviceViewHeight.constant+self.remarkViewHeight.constant-100-2000)*0.5;
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
    [alert addButtonWithTitle:@"确定" type:JCButtonTypeNormal clicked:^{
        
    }];
    [self presentViewController:alert animated:YES completion:nil];
}
-(void)webViewDidFinishLoad:(UIWebView *)webView{
    //HTML5的高度
    NSString *htmlHeight = [webView stringByEvaluatingJavaScriptFromString:@"document.body.scrollHeight"];
    if ([htmlHeight isEqualToString:@"2000"]) {
        self.remarkViewHeight.constant = 47;
    }else{
        self.remarkViewHeight.constant = [htmlHeight floatValue];
    }
    self.contentCenterY.constant = (_nextBtn.y+_nextBtn.height-SCREEN_HEIGHT+SafeAreaTopHeight+SafeAreaBottomHeight+55+self.remarkViewHeight.constant-2000)*0.5;
    
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
