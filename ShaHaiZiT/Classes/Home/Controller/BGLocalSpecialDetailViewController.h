//
//  BGLocalSpecialDetailViewController.h
//  ShaHaiZiT
//
//  Created by biao on 2019/3/27.
//  Copyright © 2019 biao. All rights reserved.
//

#import "BGBaseViewController.h"

@class BGLocalSpecialModel;
NS_ASSUME_NONNULL_BEGIN

@interface BGLocalSpecialDetailViewController : BGBaseViewController

@property(nonatomic,copy) NSString *typeID;

@property(nonatomic,strong) BGLocalSpecialModel *specialModel;

@end

NS_ASSUME_NONNULL_END
