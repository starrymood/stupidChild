//
//  BGShopCategoryModel.h
//  shzTravelC
//
//  Created by 孙林茂 on 2018/5/10.
//  Copyright © 2018年 biao. All rights reserved.
//

#import "BGBaseModel.h"

@interface BGShopCategoryModel : BGBaseModel

@property (nonatomic, copy) NSString *ID;

@property (nonatomic, copy) NSString *name;

@property (nonatomic, copy) NSString *main_pic;

@property(nonatomic,copy) NSString *goods_price;
@property(nonatomic,copy) NSString *goods_id;
@property(nonatomic,copy) NSString *goods_picture;

@end
