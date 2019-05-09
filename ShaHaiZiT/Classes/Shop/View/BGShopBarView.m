//
//  BGShopBarView.m
//  shzTravelC
//
//  Created by 孙林茂 on 2018/5/10.
//  Copyright © 2018年 biao. All rights reserved.
//

#import "BGShopBarView.h"

@implementation BGShopBarView

@synthesize bt_addBasket,bt_buyNow,bt_collection,bt_service,bt_shop;
-(instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        bt_service= [UIButton buttonWithType:UIButtonTypeCustom];
        bt_service.frame = CGRectMake(0, 0,51, self.frame.size.height);
        [bt_service setImage:BGImage(@"home_shopBar_shop") forState:0];
        [self addSubview:bt_service];
        
        bt_shop= [UIButton buttonWithType:UIButtonTypeCustom];
        [bt_shop setBackgroundImage:BGImage(@"home_shopBar_service") forState:0];
        bt_shop.frame = CGRectMake(bt_service.frame.size.width+bt_service.frame.origin.x, 0,53, self.frame.size.height);
        [self addSubview:bt_shop];
        
        
        bt_collection= [UIButton buttonWithType:UIButtonTypeCustom];
        bt_collection.frame = CGRectMake(bt_shop.frame.size.width+bt_shop.frame.origin.x, 0,52, self.frame.size.height);
        [bt_collection setBackgroundImage:BGImage(@"home_shopBar_collection") forState:0];
//        [bt_collection setBackgroundImage:BGImage(@"home_shopBar_collectioned") forState:UIControlStateSelected];
        [self addSubview:bt_collection];
        
        
        CGFloat btnWidth = (SCREEN_WIDTH-bt_collection.frame.size.width-bt_collection.frame.origin.x)*0.5;
        bt_addBasket= [UIButton buttonWithType:UIButtonTypeCustom];
        bt_addBasket.frame = CGRectMake(bt_collection.frame.size.width+bt_collection.frame.origin.x, 0,btnWidth, self.frame.size.height);
        [bt_addBasket setTitle:@"加入购物车" forState:(UIControlStateNormal)];
        [bt_addBasket.titleLabel setFont:kFont(14)];
        [bt_addBasket.titleLabel setTextColor:kAppWhiteColor];
        [bt_addBasket setBackgroundImage:BGImage(@"home_shopBar_add") forState:0];
        [self addSubview:bt_addBasket];
        
        bt_buyNow= [UIButton buttonWithType:UIButtonTypeCustom];
        [bt_buyNow setTitle:@"立即购买" forState:(UIControlStateNormal)];
        [bt_buyNow.titleLabel setFont:kFont(14)];
        [bt_buyNow.titleLabel setTextColor:kAppWhiteColor];
        [bt_buyNow setBackgroundImage:BGImage(@"home_shopBar_buy") forState:0];
        bt_buyNow.frame = CGRectMake(bt_addBasket.frame.size.width+bt_addBasket.frame.origin.x, 0,self.frame.size.width-(bt_addBasket.frame.size.width+bt_addBasket.frame.origin.x), self.frame.size.height);
        [self addSubview:bt_buyNow];
        
        
    }
    return self;
}

@end
