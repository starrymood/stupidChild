//
//  BGLocalSpecialModel.h
//  ShaHaiZiT
//
//  Created by biao on 2019/3/27.
//  Copyright © 2019 biao. All rights reserved.
//

#import "BGBaseModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface BGLocalSpecialModel : BGBaseModel

@property(nonatomic,copy) NSString *ID;
@property(nonatomic,copy) NSString *talent_id;
@property(nonatomic,copy) NSString *title;
@property(nonatomic,copy) NSArray *picture;
@property(nonatomic,copy) NSString *recommended_reason;

@end

NS_ASSUME_NONNULL_END
