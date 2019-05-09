//
//  BGPayDefaultView.m
//  ShaHaiZiT
//
//  Created by biao on 2018/11/28.
//  Copyright © 2018 biao. All rights reserved.
//

#import "BGPayDefaultView.h"
#import "BGOrderListModel.h"
#import "BGPurseApi.h"
#import "BGOrderDetailModel.h"

@interface BGPayDefaultView()
@property (weak, nonatomic) IBOutlet UILabel *staticTwoLabel;
@property (weak, nonatomic) IBOutlet UILabel *staticOneLabel;
@property (weak, nonatomic) IBOutlet UILabel *timeLabel;
@property (weak, nonatomic) IBOutlet UILabel *balanceLabel;
@property (weak, nonatomic) IBOutlet UILabel *payTipLabel;
@property (weak, nonatomic) IBOutlet UIButton *payBalanceBtn;
@property (weak, nonatomic) IBOutlet UIButton *payAlipayBtn;
@property (weak, nonatomic) IBOutlet UIButton *payWechatBtn;
@property (weak, nonatomic) IBOutlet UIButton *payUnionBtn;
@property (weak, nonatomic) IBOutlet UIButton *sureBtn;

@property (weak, nonatomic) IBOutlet UIImageView *imgBalanceImgView;
@property (weak, nonatomic) IBOutlet UIImageView *imgAlipayImgView;
@property (weak, nonatomic) IBOutlet UIImageView *imgWechatImgView;
@property(nonatomic,weak) NSTimer *countDownTimer;
@property(nonatomic,assign) NSInteger timeDifference;
@property(nonatomic,copy) NSString *order_numberStr;
@property(nonatomic,copy) NSString *payTypeStr;

@end
@implementation BGPayDefaultView


-(void)updateWithData:(NSDictionary *)dataDic balanceStr:(NSString *)balanceStr{
    BOOL isCanBalance = NO;
    NSString *needPayStr;
    if ([Tool isBlankString:BGdictSetObjectIsNil(dataDic[@"need_pay_money"])]) {
        self.timeDifference = [BGdictSetObjectIsNil(dataDic[@"order_end_time"]) doubleValue] - [BGdictSetObjectIsNil(dataDic[@"order_start_time"]) doubleValue];
        needPayStr = BGdictSetObjectIsNil(dataDic[@"pay_amount"]);
    }else{
        self.timeDifference = [BGdictSetObjectIsNil(dataDic[@"last_time"]) doubleValue] - [BGdictSetObjectIsNil(dataDic[@"now_time"]) doubleValue];
        needPayStr = BGdictSetObjectIsNil(dataDic[@"need_pay_money"]);
    }
    
    [self startTimeAction];
    
    self.order_numberStr = [NSString stringWithFormat:@"%@",BGdictSetObjectIsNil(dataDic[@"order_number"])];
    
    NSMutableAttributedString *attributedStr = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"金额%.2f元",needPayStr.doubleValue]];
    [attributedStr setAttributes:@{NSFontAttributeName:kFont(14),NSForegroundColorAttributeName:kApp999Color} range:NSMakeRange(0, attributedStr.length)];
    [attributedStr setAttributes:@{NSFontAttributeName:kFont(14),NSForegroundColorAttributeName:UIColorFromRGB(0xFF5656)} range:NSMakeRange(2, attributedStr.length-3)];
    
    self.balanceLabel.attributedText = attributedStr;
    
    if (balanceStr.doubleValue - [needPayStr doubleValue] < 0 ) {
        self.payTipLabel.text = @"余额不足";
        self.payTipLabel.textColor = kApp333Color;
        self.payTypeStr = @"alipay";
        [self.imgBalanceImgView setImage:nil];
        [self.imgAlipayImgView setImage:BGImage(@"address_address_selection")];
    }else{
        isCanBalance = YES;
        self.payTypeStr = @"qianbao";
        [self.imgBalanceImgView setImage:BGImage(@"address_address_selection")];
        [self.imgAlipayImgView setImage:nil];
        self.payTipLabel.text = [NSString stringWithFormat:@"余额：¥ %@",balanceStr];
        self.payTipLabel.textColor = UIColorFromRGB(0xFF5656);
    }
     @weakify(self);
    [[self.payBalanceBtn rac_signalForControlEvents:(UIControlEventTouchUpInside)] subscribeNext:^(__kindof UIControl * _Nullable x) {
        @strongify(self);
        // 点击button的响应事件
        if (isCanBalance) {
            self.payTypeStr = @"qianbao";
            [self.imgBalanceImgView setImage:BGImage(@"address_address_selection")];
            [self.imgAlipayImgView setImage:nil];
            [self.imgWechatImgView setImage:nil];
        }else{
            [WHIndicatorView toast:@"余额不足"];
        }
    }];
    [self btnClickedAction];
}
-(void)updateWithModel:(BGOrderListModel *)model balanceStr:(NSString *)balanceStr{
    BOOL isCanBalance = NO;
    self.timeDifference = model.payment_deadline.doubleValue - model.paymemnt_start_time.doubleValue;
    [self startTimeAction];
    
    self.order_numberStr = model.order_number;
    
    NSMutableAttributedString *attributedStr = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"金额%@元",model.pay_amount]];
    [attributedStr setAttributes:@{NSFontAttributeName:kFont(14),NSForegroundColorAttributeName:kApp999Color} range:NSMakeRange(0, attributedStr.length)];
    [attributedStr setAttributes:@{NSFontAttributeName:kFont(14),NSForegroundColorAttributeName:UIColorFromRGB(0xFF5656)} range:NSMakeRange(2, attributedStr.length-3)];
    
    self.balanceLabel.attributedText = attributedStr;
    
    if (balanceStr.doubleValue - model.pay_amount.doubleValue < 0 ) {
        self.payTipLabel.text = @"余额不足";
        self.payTipLabel.textColor = kApp333Color;
        self.payTypeStr = @"alipay";
        [self.imgBalanceImgView setImage:nil];
        [self.imgAlipayImgView setImage:BGImage(@"address_address_selection")];
    }else{
        isCanBalance = YES;
        self.payTypeStr = @"qianbao";
        [self.imgBalanceImgView setImage:BGImage(@"address_address_selection")];
        [self.imgAlipayImgView setImage:nil];
        self.payTipLabel.text = [NSString stringWithFormat:@"余额：¥ %@",balanceStr];
        self.payTipLabel.textColor = UIColorFromRGB(0xFF5656);
    }
    @weakify(self);
    [[self.payBalanceBtn rac_signalForControlEvents:(UIControlEventTouchUpInside)] subscribeNext:^(__kindof UIControl * _Nullable x) {
        @strongify(self);
        // 点击button的响应事件
        if (isCanBalance) {
            self.payTypeStr = @"qianbao";
            [self.imgBalanceImgView setImage:BGImage(@"address_address_selection")];
            [self.imgAlipayImgView setImage:nil];
            [self.imgWechatImgView setImage:nil];
        }else{
            [WHIndicatorView toast:@"余额不足"];
        }
    }];
    [self btnClickedAction];
}
-(void)updateWithModelS:(BGOrderDetailModel *)model balanceStr:(NSString *)balanceStr{
    BOOL isCanBalance = NO;
    self.timeDifference = model.pay_end_time.doubleValue - model.pay_start_time.doubleValue;
    [self startTimeAction];
    
    self.order_numberStr = model.order_number;
    
    NSMutableAttributedString *attributedStr = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"金额%@元",model.pay_amount]];
    [attributedStr setAttributes:@{NSFontAttributeName:kFont(14),NSForegroundColorAttributeName:kApp999Color} range:NSMakeRange(0, attributedStr.length)];
    [attributedStr setAttributes:@{NSFontAttributeName:kFont(14),NSForegroundColorAttributeName:UIColorFromRGB(0xFF5656)} range:NSMakeRange(2, attributedStr.length-3)];
    
    self.balanceLabel.attributedText = attributedStr;
    
    if (balanceStr.doubleValue - model.pay_amount.doubleValue < 0 ) {
        self.payTipLabel.text = @"余额不足";
        self.payTipLabel.textColor = kApp333Color;
        self.payTypeStr = @"alipay";
        [self.imgBalanceImgView setImage:nil];
        [self.imgAlipayImgView setImage:BGImage(@"address_address_selection")];
    }else{
        isCanBalance = YES;
        self.payTypeStr = @"qianbao";
        [self.imgBalanceImgView setImage:BGImage(@"address_address_selection")];
        [self.imgAlipayImgView setImage:nil];
        self.payTipLabel.text = [NSString stringWithFormat:@"余额：¥ %@",balanceStr];
        self.payTipLabel.textColor = UIColorFromRGB(0xFF5656);
    }
    @weakify(self);
    [[self.payBalanceBtn rac_signalForControlEvents:(UIControlEventTouchUpInside)] subscribeNext:^(__kindof UIControl * _Nullable x) {
        @strongify(self);
        // 点击button的响应事件
        if (isCanBalance) {
            self.payTypeStr = @"qianbao";
            [self.imgBalanceImgView setImage:BGImage(@"address_address_selection")];
            [self.imgAlipayImgView setImage:nil];
            [self.imgWechatImgView setImage:nil];
        }else{
            [WHIndicatorView toast:@"余额不足"];
        }
    }];
    [self btnClickedAction];
}
-(void)btnClickedAction{
     @weakify(self);
    [[self.payAlipayBtn rac_signalForControlEvents:(UIControlEventTouchUpInside)] subscribeNext:^(__kindof UIControl * _Nullable x) {
        @strongify(self);
        // 点击button的响应事件
        self.payTypeStr = @"alipay";
        [self.imgBalanceImgView setImage:nil];
        [self.imgAlipayImgView setImage:BGImage(@"address_address_selection")];
        [self.imgWechatImgView setImage:nil];
    }];
    [[self.payWechatBtn rac_signalForControlEvents:(UIControlEventTouchUpInside)] subscribeNext:^(__kindof UIControl * _Nullable x) {
        @strongify(self);
        // 点击button的响应事件
        self.payTypeStr = @"weixin";
        [self.imgBalanceImgView setImage:nil];
        [self.imgAlipayImgView setImage:nil];
        [self.imgWechatImgView setImage:BGImage(@"address_address_selection")];
    }];
   
    [[self.payUnionBtn rac_signalForControlEvents:(UIControlEventTouchUpInside)] subscribeNext:^(__kindof UIControl * _Nullable x) {
        // 点击button的响应事件
        [WHIndicatorView toast:@"暂不支持银联支付"];
    }];
    [[self.sureBtn rac_signalForControlEvents:(UIControlEventTouchUpInside)] subscribeNext:^(__kindof UIControl * _Nullable x) {
        // 点击button的响应事件
        if (self.sureBtnClick) {
            self.sureBtnClick(self.payTypeStr);
        }
    }];
}
-(void)startTimeAction{
    if (_timeDifference>1) {
        _countDownTimer = [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(countDownAction) userInfo:nil repeats:YES];
        NSString *str_minute = [NSString stringWithFormat:@"%02ld",(_timeDifference/60)];
        NSString *str_second = [NSString stringWithFormat:@"%02ld",_timeDifference%60];
        NSString *format_time = [NSString stringWithFormat:@"%@分钟%@秒",str_minute,str_second];
        self.timeLabel.text = format_time;
        self.sureBtn.userInteractionEnabled = YES;
        [self.sureBtn setBackgroundColor:UIColorFromRGB(0xFF5656)];
        self.sureBtn.enabled = YES;
    }else{
        [self orderCancelAction];
    }
}
-(void)countDownAction{
    
    _timeDifference--;
    
    //重新计算 时/分/秒
    
    NSString *str_minute = [NSString stringWithFormat:@"%02ld",(_timeDifference/60)];
    
    NSString *str_second = [NSString stringWithFormat:@"%02ld",_timeDifference%60];
    
    NSString *format_time = [NSString stringWithFormat:@"%@分钟%@秒",str_minute,str_second];
    //修改倒计时标签及显示内容
    self.timeLabel.text = format_time;
    
    
    //当倒计时到0时做需要的操作，比如验证码过期不能提交
    if(_timeDifference==0){
        
        [self orderCancelAction];
    }
    
}

-(void)removeTimer{
    if (_countDownTimer) {
        [_countDownTimer invalidate];
        //把定时器清空
        _countDownTimer = nil;
    }
}
-(void)orderCancelAction{
    [self removeTimer];
    self.staticTwoLabel.hidden = YES;
    self.timeLabel.hidden = YES;
    self.balanceLabel.hidden = YES;
    self.staticOneLabel.text = @"订单因超时已自动取消";
    self.sureBtn.enabled = NO;
    [self.sureBtn setBackgroundColor:kApp999Color];
}
-(instancetype)initWithFrame:(CGRect)frame dataDic:(NSDictionary *)dataDic{
    if (self = [super initWithFrame:frame]) {
        NSBundle *bundle = [NSBundle bundleForClass:[self class]];
        
        NSArray *viewArray =  [bundle loadNibNamed:@"BGPayDefaultView" owner:self options:nil];
        
        self = viewArray[0];
        [self loadDataWithData:dataDic];

        self.frame = frame;
        
        
    }
    return  self;
    
}
-(instancetype)initWithFrame:(CGRect)frame dataModel:(BGOrderListModel *)model{
    
    if (self = [super initWithFrame:frame]) {
        NSBundle *bundle = [NSBundle bundleForClass:[self class]];
        
        NSArray *viewArray =  [bundle loadNibNamed:@"BGPayDefaultView" owner:self options:nil];
        
        self = viewArray[0];
        [self loadDataWithModel:model];
        
        self.frame = frame;
        
        
    }
    return  self;
}
-(instancetype)initWithFrame:(CGRect)frame dataSModel:(BGOrderDetailModel *)model{
    if (self = [super initWithFrame:frame]) {
        NSBundle *bundle = [NSBundle bundleForClass:[self class]];
        
        NSArray *viewArray =  [bundle loadNibNamed:@"BGPayDefaultView" owner:self options:nil];
        
        self = viewArray[0];
        [self loadDataWithModelS:model];
        
        self.frame = frame;
        
    }
    return  self;
}
-(void)loadDataWithData:(NSDictionary *)dataDic{
    
    [BGPurseApi getPurseBalance:nil succ:^(NSDictionary *response) {
        DLog(@"\n>>>[getPurseBalance success]:%@",response);
        NSString *balanceStr = BGdictSetObjectIsNil(response[@"result"][@"money"]);
        NSString *banlance = [NSString stringWithFormat:@"%.2f",balanceStr.doubleValue];
        [self updateWithData:dataDic balanceStr:banlance];
    } failure:^(NSDictionary *response) {
        DLog(@"\n>>>[getPurseBalance failure]:%@",response);
    }];
}
-(void)loadDataWithModel:(BGOrderListModel *)model{
    
    [BGPurseApi getPurseBalance:nil succ:^(NSDictionary *response) {
        DLog(@"\n>>>[getPurseBalance success]:%@",response);
        NSString *balanceStr = BGdictSetObjectIsNil(response[@"result"][@"money"]);
        NSString *banlance = [NSString stringWithFormat:@"%.2f",balanceStr.doubleValue];
        [self updateWithModel:model balanceStr:banlance];
    } failure:^(NSDictionary *response) {
        DLog(@"\n>>>[getPurseBalance failure]:%@",response);
    }];
}
-(void)loadDataWithModelS:(BGOrderDetailModel *)model{
    
    [BGPurseApi getPurseBalance:nil succ:^(NSDictionary *response) {
        DLog(@"\n>>>[getPurseBalance success]:%@",response);
        NSString *balanceStr = BGdictSetObjectIsNil(response[@"result"][@"money"]);
        NSString *banlance = [NSString stringWithFormat:@"%.2f",balanceStr.doubleValue];
        [self updateWithModelS:model balanceStr:banlance];
    } failure:^(NSDictionary *response) {
        DLog(@"\n>>>[getPurseBalance failure]:%@",response);
    }];
}


@end
