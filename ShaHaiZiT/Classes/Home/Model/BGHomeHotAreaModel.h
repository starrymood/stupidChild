//
//  BGHomeHotAreaModel.h
//  ShaHaiZiT
//
//  Created by biao on 2018/11/21.
//  Copyright © 2018 biao. All rights reserved.
//

#import "BGBaseModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface BGHomeHotAreaModel : BGBaseModel

@property(nonatomic,copy) NSString *recommendation;
@property(nonatomic,copy) NSString *picture;
@property(nonatomic,copy) NSString *region_id;
@property(nonatomic,copy) NSString *region_name;

@end

NS_ASSUME_NONNULL_END
