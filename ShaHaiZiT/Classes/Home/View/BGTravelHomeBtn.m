//
//  BGTravelHomeBtn.m
//  shzTravelC
//
//  Created by biao on 2018/7/23.
//  Copyright © 2018年 biao. All rights reserved.
//

#import "BGTravelHomeBtn.h"

@implementation BGTravelHomeBtn

- (instancetype)initWithFrame:(CGRect)frame {
    
    if (self = [super initWithFrame:frame]) {
        
        NSBundle *bundle = [NSBundle bundleForClass:[self class]];
        
        NSArray *viewArray =  [bundle loadNibNamed:@"BGTravelHomeBtn" owner:self options:nil];
        
        self = viewArray[0];
        
        self.frame = frame;
        
        
    }
    return  self;
}

@end
