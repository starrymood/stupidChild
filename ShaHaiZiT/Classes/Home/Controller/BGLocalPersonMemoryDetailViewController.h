//
//  BGLocalPersonMemoryDetailViewController.h
//  ShaHaiZiT
//
//  Created by biao on 2019/3/28.
//  Copyright © 2019 biao. All rights reserved.
//

#import "BGBaseViewController.h"

NS_ASSUME_NONNULL_BEGIN

@interface BGLocalPersonMemoryDetailViewController : BGBaseViewController

@property(nonatomic,copy) NSString *talent_id;

@property(nonatomic,strong) NSString *yearStr;

@property(nonatomic,copy) NSArray *yearArr;

@end

NS_ASSUME_NONNULL_END
