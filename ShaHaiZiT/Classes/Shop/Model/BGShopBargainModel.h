//
//  BGShopBargainModel.h
//  ShaHaiZiT
//
//  Created by biao on 2019/1/19.
//  Copyright © 2019 biao. All rights reserved.
//

#import "BGBaseModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface BGShopBargainModel : BGBaseModel

@property(nonatomic,copy) NSString *number;
@property(nonatomic,copy) NSString *msg_id;
@property(nonatomic,copy) NSString *good_price;
@property(nonatomic,copy) NSString *norm_name;
@property(nonatomic,copy) NSString *good_image;
@property(nonatomic,copy) NSString *good_name;
@property(nonatomic,copy) NSString *reduce_id;

@end

NS_ASSUME_NONNULL_END
