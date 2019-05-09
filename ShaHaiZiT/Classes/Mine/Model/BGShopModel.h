//
//  BGShopModel.h
//  LLMall
//
//  Created by biao on 2016/12/27.
//  Copyright © 2016年 ZZLL. All rights reserved.
//

#import "BGBaseModel.h"

@interface BGShopModel : BGBaseModel

@property (nonatomic, copy) NSString *cart_id;               // 购物车id
@property (nonatomic, copy) NSString *goods_id;         // 商品id
@property (nonatomic, copy) NSString *goods_picture;    // 商品图片
@property (nonatomic, copy) NSString *name;             // 商品名称
@property (nonatomic, copy) NSString *num;              // 商品数量
@property (nonatomic, copy) NSString *norm_name;            // 商品规格
@property (nonatomic, copy) NSString *price;            // 商品价格
//@property (nonatomic, copy) NSString *image;            // 商品图片

//@property (nonatomic, copy) NSString *goods_img;        // 商品图片
//@property (nonatomic, copy) NSString *goods_name;       // 商品名称
@property(nonatomic,assign)BOOL selectState;            // 是否选中状态
@property (nonatomic, copy) NSString *item_id;
@property (nonatomic, copy) NSString *sellback_state;
//@property (nonatomic, copy) NSString *product_id;
@end
