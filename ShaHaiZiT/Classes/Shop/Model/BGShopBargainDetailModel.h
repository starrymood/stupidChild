//
//  BGShopBargainDetailModel.h
//  ShaHaiZiT
//
//  Created by biao on 2019/1/19.
//  Copyright © 2019 biao. All rights reserved.
//

#import "BGBaseModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface BGShopBargainDetailModel : BGBaseModel

@property(nonatomic,copy) NSString *goods_description;
@property(nonatomic,copy) NSString *reduce_money;
@property(nonatomic,copy) NSString *duration_time;
@property(nonatomic,copy) NSArray *reduce_info;
@property(nonatomic,copy) NSString *good_image;
@property(nonatomic,copy) NSString *good_price;
@property(nonatomic,copy) NSString *number;
@property(nonatomic,copy) NSString *share_url;
@property(nonatomic,copy) NSString *good_name;


@end

NS_ASSUME_NONNULL_END
