//
//  BGShopBargainUserModel.h
//  ShaHaiZiT
//
//  Created by biao on 2019/1/19.
//  Copyright © 2019 biao. All rights reserved.
//

#import "BGBaseModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface BGShopBargainUserModel : BGBaseModel

@property(nonatomic,copy) NSString *member_name;

@property(nonatomic,copy) NSString *face;

@property(nonatomic,copy) NSString *reduce_money;

@end

NS_ASSUME_NONNULL_END
