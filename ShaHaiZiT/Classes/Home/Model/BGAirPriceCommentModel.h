//
//  BGAirPriceCommentModel.h
//  shzTravelC
//
//  Created by biao on 2018/8/28.
//  Copyright © 2018年 biao. All rights reserved.
//

#import "BGBaseModel.h"

@interface BGAirPriceCommentModel : BGBaseModel

@property (nonatomic, copy) NSString *ID;
@property (nonatomic, copy) NSString *is_like;
@property (nonatomic, copy) NSString *content;
@property (nonatomic, copy) NSString *nickname;
@property (nonatomic, copy) NSString *face;
@property (nonatomic, copy) NSString *satisfaction_level;
@property (nonatomic, copy) NSString *like_number;
@property (nonatomic, copy) NSString *create_time;
@property (nonatomic, copy) NSArray *picture;

@end
