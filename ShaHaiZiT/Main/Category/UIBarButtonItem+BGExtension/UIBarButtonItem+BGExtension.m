//
//  UIBarButtonItem+BGExtension.m
//  LLLive
//
//  Created by biao on 2017/2/8.
//  Copyright © 2017年 ZZLL. All rights reserved.
//

#import "UIBarButtonItem+BGExtension.h"

@implementation UIBarButtonItem (BGExtension)
+ (instancetype)itemWithImage:(NSString *)image highImage:(NSString *)highImage target:(id)target action:(SEL)action
{
    UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
    [btn setImage:[UIImage imageNamed:image] forState:UIControlStateNormal];
    [btn setImage:[UIImage imageNamed:highImage] forState:UIControlStateHighlighted];
    btn.bounds = CGRectMake(0, 0, 70, 30);
    btn.contentEdgeInsets = UIEdgeInsetsZero;
    if ([image isEqualToString:@"bank_card_plus_sign"] || [image isEqualToString:@"product_details_share_icon"] || [image isEqualToString:@"address_delete_icon"] || [image isEqualToString:@"home_city_search"] || [image isEqualToString:@"hotline_right"] || [image isEqualToString:@"share_icon_small"] || [image isEqualToString:@"travel_collection_green"] || [image isEqualToString:@"travel_share_green"] || [image isEqualToString:@"mine_setting"]) {
        btn.contentHorizontalAlignment = UIControlContentHorizontalAlignmentRight;
    }else{
        btn.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
    }
    
    [btn addTarget:target action:action forControlEvents:UIControlEventTouchUpInside];
    return [[UIBarButtonItem alloc] initWithCustomView:btn];
}
@end
