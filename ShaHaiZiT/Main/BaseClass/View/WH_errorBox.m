//
//  WH_errorBox.m
//  wehomec
//
//  Created by Lion on 17/2/20.
//  Copyright © 2017年 JiangHao. All rights reserved.
//

#import "WH_errorBox.h"

@implementation WH_errorBox

-(id)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor =[UIColor blackColor];
        self.alpha =0.6;
        self.layer.masksToBounds  = YES;
        self.layer.cornerRadius=3;
        
        errorLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 10, SCREEN_WIDTH-160, 30)];
        errorLabel.textAlignment = NSTextAlignmentCenter;
        errorLabel.backgroundColor = [UIColor clearColor];
        errorLabel.lineBreakMode = NSLineBreakByWordWrapping;
        errorLabel.numberOfLines = 0;
        errorLabel.textColor = [UIColor whiteColor];
        errorLabel.font = [UIFont boldSystemFontOfSize:15];
        [self addSubview:errorLabel];
        
        
    }
    return self;
}

- (id)initWithFrame:(CGRect)frame superController:(UIViewController*)superController{
    self = [self initWithFrame:frame];
    if (self) {
        
        
        for(WH_errorBox *view in superController.navigationController.view.subviews)
        {
            if([view isKindOfClass:[WH_errorBox class]])
            {
                [view.timeSlice invalidate];
                [view removeFromSuperview];
                break;
            }
        }
        
        
    }
    return self;
    
}

- (id)initWithFrame:(CGRect)frame superView:(UIView*)view{
    self = [self initWithFrame:frame];
    if (self && view.subviews.count > 0) {
        for(UIView *subview in view.subviews)
        {
            if([subview isKindOfClass:[WH_errorBox class]])
            {
                WH_errorBox * box = (WH_errorBox*)subview;
                [box.timeSlice invalidate];
                [box removeFromSuperview];
                break;
            }
        }
    }
    return self;
    
}

- (void)setLabeldescribe:(UILabel *)labelStr
{
    CGSize size1 = [labelStr sizeThatFits:CGSizeMake(SCREEN_WIDTH-160, FLT_MAX)];
    self.frame = CGRectMake(self.frame.origin.x, self.frame.origin.y, SCREEN_WIDTH - self.frame.origin.x*2, size1.height + 20);
    labelStr.frame = CGRectMake( 10, 10, SCREEN_WIDTH-160, size1.height);
    
    CAKeyframeAnimation* animation = [CAKeyframeAnimation animationWithKeyPath:@"transform"];
    animation.duration = 0.3;
    
    NSMutableArray *values = [NSMutableArray array];
    [values addObject:[NSValue valueWithCATransform3D:CATransform3DMakeScale(0.9, 0.9, 1.0)]];
    [values addObject:[NSValue valueWithCATransform3D:CATransform3DMakeScale(1.1, 1.1, 1.0)]];
    // [values addObject:[NSValue valueWithCATransform3D:CATransform3DMakeScale(0.9, 0.9, 1.0)]];
    [values addObject:[NSValue valueWithCATransform3D:CATransform3DMakeScale(1.0, 1.0, 1.0)]];
    animation.values = values;
    [self.layer addAnimation:animation forKey:nil];
    
}


- (void)setErrorText:(NSString *)str
{
    errorLabel.text = str;
    if (str==nil || str.length == 0) {
        errorLabel.hidden = YES;
    }else {
        [self setLabeldescribe:errorLabel];
    }
    self.timeSlice = [NSTimer scheduledTimerWithTimeInterval:2.0f target:self selector:@selector(delayRemove:) userInfo:nil repeats:NO];
}

- (void)delayRemove:(id)sender
{
    
    CAKeyframeAnimation* animation = [CAKeyframeAnimation animationWithKeyPath:@"transform"];
    animation.duration = 0.3;
    NSMutableArray *values = [NSMutableArray array];
    [values addObject:[NSValue valueWithCATransform3D:CATransform3DMakeScale(1, 1, 1.0)]];
    [values addObject:[NSValue valueWithCATransform3D:CATransform3DMakeScale(1.2, 1.2, 1.0)]];
    [values addObject:[NSValue valueWithCATransform3D:CATransform3DMakeScale(1.1, 1.1, 1.0)]];
    [values addObject:[NSValue valueWithCATransform3D:CATransform3DMakeScale(1, 1, 1.0)]];
    [values addObject:[NSValue valueWithCATransform3D:CATransform3DMakeScale(0.9, 0.9, 1.0)]];
    [values addObject:[NSValue valueWithCATransform3D:CATransform3DMakeScale(0.8, 0.8, 1.0)]];
    animation.values = values;
    [self.layer addAnimation:animation forKey:nil];
    self.frame =CGRectMake(0, 0, 0, 0);
    [self performSelector:@selector(removeFromSuperview) withObject:nil afterDelay:0.4];
}

-(void)dealloc{
    if(self.timeSlice){
        [self.timeSlice invalidate];
    }
}


@end
