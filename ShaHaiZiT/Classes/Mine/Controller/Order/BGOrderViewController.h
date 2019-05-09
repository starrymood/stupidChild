//
//  BGOrderViewController.h
//  ShaHaiZiT
//
//  Created by biao on 2018/11/20.
//  Copyright © 2018 biao. All rights reserved.
//

#import "BGBaseViewController.h"

NS_ASSUME_NONNULL_BEGIN

@interface BGOrderViewController : BGBaseViewController

@property (nonatomic, assign) NSInteger ninaDefaultPage;

-(void)changeDefaultPageWithPage:(NSInteger)pageNum;

@property (nonatomic, assign) NSInteger jumpNum;

@property (nonatomic, assign) BOOL isJump;

@end

NS_ASSUME_NONNULL_END
