//
//  BGShopBargainDetailViewController.m
//  ShaHaiZiT
//
//  Created by biao on 2019/1/19.
//  Copyright © 2019 biao. All rights reserved.
//

#import "BGShopBargainDetailViewController.h"
#import "BGShopApi.h"
#import <UMShare/UMShare.h>
#import <UShareUI/UShareUI.h>
#import "BGShopBargainDetailModel.h"
#import <UIImageView+WebCache.h>
#import "BGShopBargainUserModel.h"

@interface BGShopBargainDetailViewController ()
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *contentCenterY;
@property (weak, nonatomic) IBOutlet UIView *contentView;
@property (weak, nonatomic) IBOutlet UIImageView *goodImgView;
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UILabel *priceLabel;
@property (weak, nonatomic) IBOutlet UILabel *numLabel;
@property (weak, nonatomic) IBOutlet UILabel *hourLabel;
@property (weak, nonatomic) IBOutlet UILabel *minuteLabel;
@property (weak, nonatomic) IBOutlet UILabel *secondLabel;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *progressViewWidth;
@property (weak, nonatomic) IBOutlet UILabel *progressLabel;
@property (weak, nonatomic) IBOutlet UIButton *shareToFriendsBtn;
@property(nonatomic,weak) NSTimer *countDownTimer;
@property(nonatomic,assign) NSInteger timeDifference;

@end

@implementation BGShopBargainDetailViewController

-(void)viewDidDisappear:(BOOL)animated{
    [super viewDidDisappear:animated];
     [self removeTimer];
    
}

- (void)viewDidLoad {
    [super viewDidLoad];
   
    [self loadSubViews];
    [self loadData];
}
- (void)loadSubViews {
    
    self.navigationItem.title = @"砍价免费拿";
    self.view.backgroundColor = kAppBgColor;
}
-(void)loadData {
    
    [ProgressHUDHelper showLoading];
    __weak typeof(self) weakSelf = self;
    NSMutableDictionary *param = [NSMutableDictionary dictionary];
    [param setObject:_reduce_id forKey:@"reduce_id"];
    [param setObject:_msg_id forKey:@"msg_id"];
    
    [BGShopApi getBargainDetail:param succ:^(NSDictionary *response) {
        DLog(@"\n>>>[getBargainDetail sucess]:%@",response);
        [weakSelf hideNodateView];        
        weakSelf.navigationItem.rightBarButtonItem = [UIBarButtonItem itemWithImage:@"product_details_share_icon" highImage:@"travel_share_green" target:self action:@selector(clickedShareItem:)];
        BGShopBargainDetailModel *model = [BGShopBargainDetailModel mj_objectWithKeyValues:BGdictSetObjectIsNil(response[@"result"])];
        [weakSelf updateSubViewsWithModel:model];
    } failure:^(NSDictionary *response) {
        DLog(@"\n>>>[getBargainDetail failure]:%@",response);
        [ProgressHUDHelper removeLoading];
        [self shownoNetWorkViewWithType:0];
        [self setRefreshBlock:^{
            [weakSelf loadData];
        }];
    }];
}
-(void)updateSubViewsWithModel:(BGShopBargainDetailModel *)model{

        if (model.duration_time.integerValue <1) {
        [WHIndicatorView toast:@"该商品砍价已过期"];
        [self.navigationController popViewControllerAnimated:YES];
        return;
    }
    [self.goodImgView sd_setImageWithURL:[NSURL URLWithString:model.good_image] placeholderImage:BGImage(@"img_placeholder")];
    self.nameLabel.text = model.good_name;
    self.priceLabel.text = [NSString stringWithFormat:@"价值¥%@",model.good_price];
    self.numLabel.text = [NSString stringWithFormat:@"%@人已获得",model.number];
    self.timeDifference = model.duration_time.integerValue;
    [self startTimeAction];
    
    self.progressLabel.text = [NSString stringWithFormat:@"已砍%@元，还剩%.2f元",model.reduce_money,(model.good_price.doubleValue-model.reduce_money.doubleValue)];
    self.progressViewWidth.constant = (SCREEN_WIDTH-46*2)*model.reduce_money.doubleValue/model.good_price.doubleValue;
    self.shareToFriendsBtn.userInteractionEnabled = YES;
    [self createViewWithArr:model.reduce_info];
    @weakify(self);
    [[self.shareToFriendsBtn rac_signalForControlEvents:(UIControlEventTouchUpInside)] subscribeNext:^(__kindof UIControl * _Nullable x) {
        @strongify(self);
        // 点击button的响应事件
        [UMSocialUIManager setPreDefinePlatforms:@[@(UMSocialPlatformType_WechatSession),@(UMSocialPlatformType_WechatTimeLine),@(UMSocialPlatformType_QQ),@(UMSocialPlatformType_Qzone),@(UMSocialPlatformType_Sina)]];
        [UMSocialUIManager showShareMenuViewInWindowWithPlatformSelectionBlock:^(UMSocialPlatformType platformType, NSDictionary *userInfo) {
            // 根据获取的platformType确定所选平台进行下一步操作
            NSData *imgData = [NSData dataWithContentsOfURL:[NSURL URLWithString:model.good_image]];
            UIImage *shareImg = [UIImage imageWithData:imgData];
            [self doShareTitle:model.good_name description:model.goods_description image:shareImg url:model.share_url shareType:(platformType)];
        }];
    }];
}
-(void)createViewWithArr:(NSArray *)arr{
    
    NSMutableArray *dataArr = [BGShopBargainUserModel mj_objectArrayWithKeyValuesArray:arr];
    UIView *bigView = [[UIView alloc] initWithFrame:CGRectMake(26, _shareToFriendsBtn.y+_shareToFriendsBtn.height+80, SCREEN_WIDTH-26*2, 19+15+13+1+25+52*dataArr.count)];
    self.contentCenterY.constant = (bigView.y+bigView.height-SCREEN_HEIGHT+SafeAreaTopHeight+SafeAreaBottomHeight+55)*0.5;
    [UIView animateWithDuration:.2 animations:^{
        [self.view layoutIfNeeded];
    }];
    
    bigView.clipsToBounds = YES;
    bigView.layer.borderColor = UIColorFromRGB(0xFF3C5D).CGColor;
    bigView.layer.borderWidth = 1.0;
    bigView.layer.cornerRadius = 13;
    bigView.backgroundColor = kAppWhiteColor;
    [self.contentView addSubview:bigView];
    UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(15, 19, bigView.width-30, 15)];
    titleLabel.text = @"砍价帮";
    titleLabel.textColor = kApp333Color;
    titleLabel.font = kFont(15);
    titleLabel.textAlignment = NSTextAlignmentCenter;
    [bigView addSubview:titleLabel];
    
    UIView *lineView = [[UIView alloc] initWithFrame:CGRectMake(13, 47, bigView.width-13*2, 1)];
    lineView.backgroundColor = UIColorFromRGB(0xFF3C5D);
    [bigView addSubview:lineView];
    
    for (int i = 0; i<dataArr.count; i++) {
        BGShopBargainUserModel *model = dataArr[i];
        UIView *userView = UIView.new;
        userView.frame = CGRectMake(0, lineView.y+lineView.height+25+i*52, bigView.width, 52);
        userView.backgroundColor = kAppClearColor;
        [bigView addSubview:userView];
        
        UIImageView *headImgView = [[UIImageView alloc] initWithFrame:CGRectMake(20, 0, 30, 30)];
        headImgView.clipsToBounds = YES;
        headImgView.layer.cornerRadius = 15;
        [headImgView sd_setImageWithURL:[NSURL URLWithString:model.face] placeholderImage:BGImage(@"img_placeholder")];
        [userView addSubview:headImgView];
        
        UILabel *nickNameLabel = UILabel.new;
        nickNameLabel.frame = CGRectMake(50+5, 8, userView.width-20-30-5-33-75-15, 14);
        nickNameLabel.textColor = kApp333Color;
        nickNameLabel.textAlignment = NSTextAlignmentLeft;
        nickNameLabel.font = kFont(13);
        nickNameLabel.text = model.member_name;
        [userView addSubview:nickNameLabel];
        
        UILabel *moneyLabel = UILabel.new;
        moneyLabel.frame = CGRectMake(userView.width-33-75, 9, 75, 12);
        moneyLabel.textColor = UIColorFromRGB(0xFF3C5D);
        moneyLabel.textAlignment = NSTextAlignmentRight;
        moneyLabel.font = kFont(12);
        moneyLabel.text = [NSString stringWithFormat:@"砍掉%@元",model.reduce_money];
        [userView addSubview:moneyLabel];
    }
    
    
    
}
-(void)startTimeAction{
    if (_timeDifference>1) {
        _countDownTimer = [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(countDownAction) userInfo:nil repeats:YES];
        self.hourLabel.text = [NSString stringWithFormat:@"%02ld",(_timeDifference/3600)];
        self.minuteLabel.text = [NSString stringWithFormat:@"%02ld",((_timeDifference-self.hourLabel.text.integerValue*3600)/60)];
        self.secondLabel.text = [NSString stringWithFormat:@"%02ld",_timeDifference%60];
     
    }else{
         [self removeTimer];
        [WHIndicatorView toast:@"该商品砍价已过期"];
        [self.navigationController popViewControllerAnimated:YES];
    }
}
-(void)countDownAction{
    
    _timeDifference--;
    
    //重新计算 时/分/秒
    
    self.hourLabel.text = [NSString stringWithFormat:@"%02ld",(_timeDifference/3600)];
    self.minuteLabel.text = [NSString stringWithFormat:@"%02ld",((_timeDifference-self.hourLabel.text.integerValue*3600)/60)];
    self.secondLabel.text = [NSString stringWithFormat:@"%02ld",_timeDifference%60];
    
    
    //当倒计时到0时做需要的操作，比如验证码过期不能提交
    if(_timeDifference==0){
         [self removeTimer];
        [WHIndicatorView toast:@"该商品砍价已过期"];
        [self.navigationController popViewControllerAnimated:YES];
    }
    
}

-(void)removeTimer{
    if (_countDownTimer) {
        [_countDownTimer invalidate];
        //把定时器清空
        _countDownTimer = nil;
    }
}

#pragma mark - clickedShareItem

- (void)clickedShareItem:(UIButton *)btn{
    [self showShareAction];
}

-(void)showShareAction {
    [UMSocialUIManager setPreDefinePlatforms:@[@(UMSocialPlatformType_WechatSession),@(UMSocialPlatformType_WechatTimeLine),@(UMSocialPlatformType_QQ),@(UMSocialPlatformType_Qzone),@(UMSocialPlatformType_Sina)]];
    [UMSocialUIManager showShareMenuViewInWindowWithPlatformSelectionBlock:^(UMSocialPlatformType platformType, NSDictionary *userInfo) {
        // 根据获取的platformType确定所选平台进行下一步操作
        NSData *imgData = [NSData dataWithContentsOfURL:[NSURL URLWithString:BGdictSetObjectIsNil(self.shareDic[@"share_image"])]];
        UIImage *shareImg = [UIImage imageWithData:imgData];
        [self doShareTitle:BGdictSetObjectIsNil(self.shareDic[@"title"]) description:BGdictSetObjectIsNil(self.shareDic[@"share_message"]) image:shareImg url:BGdictSetObjectIsNil(self.shareDic[@"share_url"]) shareType:(platformType)];
    }];
}
#pragma mark- 分享公共方法
- (void)doShareTitle:(NSString *)tieleStr
         description:(NSString *)descriptionStr
               image:(UIImage *)image
                 url:(NSString *)url
           shareType:(UMSocialPlatformType)type
{
    [ProgressHUDHelper showLoading];
    
    //创建分享消息对象
    UMSocialMessageObject *messageObject = [UMSocialMessageObject messageObject];
    
    //创建网页内容对象
    UMShareWebpageObject *shareObject = [UMShareWebpageObject shareObjectWithTitle:tieleStr descr:descriptionStr thumImage:image];
    //设置网页地址
    shareObject.webpageUrl = url;
    
    //分享消息对象设置分享内容对象
    messageObject.shareObject = shareObject;
    [ProgressHUDHelper removeLoading];
    //调用分享接口
    [[UMSocialManager defaultManager] shareToPlatform:type messageObject:messageObject currentViewController:self completion:^(id data, NSError *error) {
        if (error) {
            [WHIndicatorView toast:@"分享失败"];
        }else{
            if ([data isKindOfClass:[UMSocialShareResponse class]]) {
                [WHIndicatorView toast:@"分享成功"];
            }else{
                DLog(@"/n[share]");
                [WHIndicatorView toast:@"分享成功"];
            }
        }
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
