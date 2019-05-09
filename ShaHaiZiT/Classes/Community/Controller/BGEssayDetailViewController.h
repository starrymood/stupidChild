//
//  BGEssayDetailViewController.h
//  shzTravelC
//
//  Created by biao on 2018/7/27.
//  Copyright © 2018年 biao. All rights reserved.
//

#import "BGBaseViewController.h"

typedef void(^refreshEditBlock)(void);
@interface BGEssayDetailViewController : BGBaseViewController

@property (nonatomic, copy) NSString *postID;
@property (nonatomic, copy) refreshEditBlock refreshEditBlock;

@end
