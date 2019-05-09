//
//  BGShopSortsModel.h
//  shzTravelC
//
//  Created by biao on 2018/6/6.
//  Copyright © 2018年 biao. All rights reserved.
//

#import "BGBaseModel.h"

@interface BGShopSortsModel : BGBaseModel

@property (nonatomic, copy) NSString *ID;
@property (nonatomic, copy) NSString *name;
@property (nonatomic, copy) NSString *main_pic;

@property (nonatomic, strong) NSArray *children;
@property(nonatomic,copy) NSString *parent_id;

@end
