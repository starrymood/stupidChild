//
//  BGOrderWaitTipCell.m
//  shzTravelC
//
//  Created by 孙林茂 on 2018/5/11.
//  Copyright © 2018年 biao. All rights reserved.
//

#import "BGOrderWaitTipCell.h"

@interface BGOrderWaitTipCell()
@property (weak, nonatomic) IBOutlet UILabel *countDownLabel;
@property (weak, nonatomic) IBOutlet UIView *cancelView;
@property (weak, nonatomic) IBOutlet UIView *countDownView;
@property(nonatomic,weak) NSTimer *countDownTimer;
@property (nonatomic, assign) NSInteger timeDifference;
@property (weak, nonatomic) IBOutlet UILabel *cancelReasonLabel;

@end
@implementation BGOrderWaitTipCell

- (void)updataWithCellArray:(NSInteger)timeDifference{
    [self removeTimer];
    if (timeDifference>1 && timeDifference<86400) {
        self.countDownView.hidden = NO;
        self.cancelView.hidden = YES;
        _timeDifference = timeDifference;
        _countDownTimer = [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(countDownAction) userInfo:nil repeats:YES];
        NSString *str_minute = [NSString stringWithFormat:@"%02ld",(timeDifference/60)];
        NSString *str_second = [NSString stringWithFormat:@"%02ld",timeDifference%60];
        NSString *format_time = [NSString stringWithFormat:@"%@分钟%@秒",str_minute,str_second];
        self.countDownLabel.text = format_time;
    }else{
        if (timeDifference == 999999) {
            self.cancelReasonLabel.text = @"交易关闭";
        }else{
            self.cancelReasonLabel.text = @"订单因超时已自动取消";
        }
        self.countDownView.hidden = YES;
        self.cancelView.hidden = NO;
        
    }
    
}

-(void)countDownAction{
    
    _timeDifference--;
    
    //重新计算 时/分/秒
    
    NSString *str_minute = [NSString stringWithFormat:@"%02ld",(_timeDifference/60)];
    
    NSString *str_second = [NSString stringWithFormat:@"%02ld",_timeDifference%60];
    
    NSString *format_time = [NSString stringWithFormat:@"%@分钟%@秒",str_minute,str_second];
    //修改倒计时标签及显示内容
    self.countDownLabel.text = format_time;
    
    
    if(_timeDifference==0){
        
        [self removeTimer];
        self.countDownView.hidden = YES;
        self.cancelView.hidden = NO;
        if (self.timeOverClicked) {
            self.timeOverClicked();
        }
    }
    
}

-(void)removeTimer{
    if (_countDownTimer) {
        [_countDownTimer invalidate];
        //把定时器清空
        _countDownTimer = nil;
    }
}

@end
