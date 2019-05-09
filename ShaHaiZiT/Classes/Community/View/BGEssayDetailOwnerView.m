//
//  BGEssayDetailOwnerView.m
//  shzTravelC
//
//  Created by biao on 2018/7/27.
//  Copyright © 2018年 biao. All rights reserved.
//

#import "BGEssayDetailOwnerView.h"

@implementation BGEssayDetailOwnerView

- (instancetype)initWithFrame:(CGRect)frame {
    
    if (self = [super initWithFrame:frame]) {
        
        NSBundle *bundle = [NSBundle bundleForClass:[self class]];
        
        NSArray *viewArray =  [bundle loadNibNamed:@"BGEssayDetailOwnerView" owner:self options:nil];
        
        self = viewArray[0];
        
        self.frame = frame;
        
    }
    return  self;
}

@end
