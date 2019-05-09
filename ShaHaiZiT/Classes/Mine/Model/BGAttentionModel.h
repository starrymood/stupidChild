//
//  BGAttentionModel.h
//  shzTravelC
//
//  Created by biao on 2018/7/19.
//  Copyright © 2018年 biao. All rights reserved.
//

#import "BGBaseModel.h"

@interface BGAttentionModel : BGBaseModel

@property (nonatomic, copy) NSString *nickname;
@property (nonatomic, copy) NSString *face;
@property (nonatomic, copy) NSString *member_id;
@property (nonatomic, copy) NSString *is_concern;

@property (nonatomic, copy) NSString *rong_cloud;
@property (nonatomic, copy) NSString *signature;
@property(nonatomic,copy) NSString *order_quantity;
@property(nonatomic,copy) NSString *color;
@property(nonatomic,copy) NSString *level_name;
@property(nonatomic,copy) NSString *rong_cloud_guide;

@end
