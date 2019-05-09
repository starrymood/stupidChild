//
//  BGEssayDetailOwnerSmallView.m
//  shzTravelC
//
//  Created by biao on 2018/8/14.
//  Copyright © 2018年 biao. All rights reserved.
//

#import "BGEssayDetailOwnerSmallView.h"

@implementation BGEssayDetailOwnerSmallView

- (instancetype)initWithFrame:(CGRect)frame {
    
    if (self = [super initWithFrame:frame]) {
        
        NSBundle *bundle = [NSBundle bundleForClass:[self class]];
        
        NSArray *viewArray =  [bundle loadNibNamed:@"BGEssayDetailOwnerSmallView" owner:self options:nil];
        
        self = viewArray[0];
        
        self.frame = frame;
        
    }
    return  self;
}


@end
