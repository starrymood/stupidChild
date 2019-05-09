//
//  BGShopCommentModel.h
//  shzTravelC
//
//  Created by biao on 2018/6/26.
//  Copyright © 2018年 biao. All rights reserved.
//

#import "BGBaseModel.h"

@interface BGShopCommentModel : BGBaseModel

@property (nonatomic, copy) NSString *face;

@property (nonatomic, copy) NSString *nickname;

@property (nonatomic, copy) NSString *content;

@property (nonatomic, copy) NSString *create_time;

@property (nonatomic, copy) NSArray *pictures;

@end
