//
//  BGRecommendView.m
//  ShaHaiZiT
//
//  Created by biao on 2019/1/26.
//  Copyright © 2019 biao. All rights reserved.
//

#import "BGRecommendView.h"

@implementation BGRecommendView

- (instancetype)initWithFrame:(CGRect)frame {
    
    if (self = [super initWithFrame:frame]) {
        
        NSBundle *bundle = [NSBundle bundleForClass:[self class]];
        
        NSArray *viewArray =  [bundle loadNibNamed:@"BGRecommendView" owner:self options:nil];
        
        self = viewArray[0];
        
        self.frame = frame;
        self.layer.cornerRadius = 10.0;
        
    }
    return  self;
}

@end
