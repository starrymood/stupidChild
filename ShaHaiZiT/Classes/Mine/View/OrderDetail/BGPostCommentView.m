//
//  BGPostCommentView.m
//  shzTravelC
//
//  Created by biao on 2018/6/27.
//  Copyright © 2018年 biao. All rights reserved.
//

#import "BGPostCommentView.h"
#import "XHStarRateView.h"
@interface BGPostCommentView()

@end
@implementation BGPostCommentView

- (instancetype)initWithFrame:(CGRect)frame {
    
    if (self = [super initWithFrame:frame]) {
        
        NSBundle *bundle = [NSBundle bundleForClass:[self class]];
        
        NSArray *viewArray =  [bundle loadNibNamed:@"BGPostCommentView" owner:self options:nil];
        
        self = viewArray[0];
        
        [self setLayout];
        
        
        self.frame = frame;
        
        
    }
    return  self;
}
-(void)setLayout{
    XHStarRateView *starRateView1 = [[XHStarRateView alloc] initWithFrame:CGRectMake(85, 55, 200, 30) isT:NO finish:^(CGFloat currentScore) {
        if (self.starOneClicked) {
            self.starOneClicked([NSString stringWithFormat:@"%d",(int)currentScore]);
        }
    }];

    XHStarRateView *starRateView2 = [[XHStarRateView alloc] initWithFrame:CGRectMake(85, 97, 200, 30) isT:NO finish:^(CGFloat currentScore) {
        if (self.starTwoClicked) {
            self.starTwoClicked([NSString stringWithFormat:@"%d",(int)currentScore]);
        }
    }];
    XHStarRateView *starRateView3 = [[XHStarRateView alloc] initWithFrame:CGRectMake(85, 139, 200, 30) isT:NO finish:^(CGFloat currentScore) {
        if (self.starThreeClicked) {
            self.starThreeClicked([NSString stringWithFormat:@"%d",(int)currentScore]);
        }
    }];
    [self addSubview:starRateView1];
    [self addSubview:starRateView2];
    [self addSubview:starRateView3];
}
- (IBAction)btnPublishClicked:(UIButton *)sender {
    if (self.publishBtnClicked) {
        self.publishBtnClicked(sender);
    }
}

@end
