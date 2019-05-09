//
//  BGFoodLocationDetailModel.h
//  ShaHaiZiT
//
//  Created by biao on 2019/4/15.
//  Copyright © 2019 biao. All rights reserved.
//

#import "BGBaseModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface BGFoodLocationDetailModel : BGBaseModel

@property(nonatomic,copy) NSString *address;

@property(nonatomic,copy) NSString *title;

@property(nonatomic,copy) NSString *content;

@property(nonatomic,copy) NSArray *banner_picture;

@end

NS_ASSUME_NONNULL_END
