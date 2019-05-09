//
//  BGDateSingleViewController.h
//  ShaHaiZiT
//
//  Created by biao on 2019/5/8.
//  Copyright © 2019 biao. All rights reserved.
//

#import "BGBaseViewController.h"

NS_ASSUME_NONNULL_BEGIN
typedef void(^refreshEditBlock)(NSString *timeStampStr);
@interface BGDateSingleViewController : BGBaseViewController

@property (nonatomic, copy) refreshEditBlock refreshEditBlock;
@end

NS_ASSUME_NONNULL_END
