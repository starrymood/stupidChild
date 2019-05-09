//
//  BGPayWayView.m
//  shzTravelC
//
//  Created by 孙林茂 on 2018/5/11.
//  Copyright © 2018年 biao. All rights reserved.
//

#import "BGPayWayView.h"
@interface BGPayWayView()

@property (weak, nonatomic) IBOutlet UIImageView *unionpayImg;
@property (weak, nonatomic) IBOutlet UIButton *unionpayBtn;

@end
@implementation BGPayWayView

- (instancetype)initWithFrame:(CGRect)frame {
    
    if (self = [super initWithFrame:frame]) {
        
        NSBundle *bundle = [NSBundle bundleForClass:[self class]];
        
        NSArray *viewArray =  [bundle loadNibNamed:@"BGPayWayView" owner:self options:nil];
        
        self = viewArray[0];
        
        self.frame = frame;
        
        
    }
    return  self;
}
- (IBAction)btnUnionPayClicked:(UIButton *)sender {
    [WHIndicatorView toast:@"暂不支持银联支付"];
}


@end
