//
//  BGShopShowModel.h
//  shzTravelC
//
//  Created by 孙林茂 on 2018/5/10.
//  Copyright © 2018年 biao. All rights reserved.
//

#import "BGBaseModel.h"

@interface BGShopShowModel : BGBaseModel

@property (nonatomic, copy) NSString *ID;    // 商品id

@property (nonatomic, copy) NSString *name;        // 商品名称

@property (nonatomic, copy) NSString *original;   // 商品缩略图

@property (nonatomic, copy) NSString *price;       // 商品价格

@property (nonatomic, copy) NSString *store_name;  // 显示自营或为空

@property (nonatomic, copy) NSString *brand_name;  // 商品品牌

@property (nonatomic, copy) NSString *tag_name;   // 特价商品或显示其它

@property (nonatomic, copy) NSString *goods_description;

@property(nonatomic,copy) NSString *aspect_ratio;

@property(nonatomic,copy) NSString *goods_id;

@end
