//
//  BGPayNewView.m
//  ShaHaiZiT
//
//  Created by biao on 2018/11/27.
//  Copyright © 2018 biao. All rights reserved.
//

#import "BGPayNewView.h"

@implementation BGPayNewView

- (instancetype)initWithFrame:(CGRect)frame {
    
    if (self = [super initWithFrame:frame]) {
        
        NSBundle *bundle = [NSBundle bundleForClass:[self class]];
        
        NSArray *viewArray =  [bundle loadNibNamed:@"BGPayNewView" owner:self options:nil];
        
        self = viewArray[0];
        
        self.frame = frame;
        
        
    }
    return  self;
}

@end
