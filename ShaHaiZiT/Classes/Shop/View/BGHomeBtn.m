//
//  BGHomeBtn.m
//  shzTravelC
//
//  Created by biao on 2018/6/6.
//  Copyright © 2018年 biao. All rights reserved.
//

#import "BGHomeBtn.h"

@implementation BGHomeBtn

- (instancetype)initWithFrame:(CGRect)frame {
    
    if (self = [super initWithFrame:frame]) {
        
        NSBundle *bundle = [NSBundle bundleForClass:[self class]];
        
        NSArray *viewArray =  [bundle loadNibNamed:@"BGHomeBtn" owner:self options:nil];
        
        self = viewArray[0];
        
        self.frame = frame;
        
        
    }
    return  self;
}

@end
