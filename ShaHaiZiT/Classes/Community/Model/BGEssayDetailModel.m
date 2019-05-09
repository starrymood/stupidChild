
//
//  BGEssayDetailModel.m
//  shzTravelC
//
//  Created by biao on 2018/7/27.
//  Copyright © 2018年 biao. All rights reserved.
//

#import "BGEssayDetailModel.h"

@implementation BGEssayDetailModel
+(NSDictionary *)mj_replacedKeyFromPropertyName{
    return @{@"ID":@"id",
             @"collect_count":@[@"collection_count",@"collect_count"],
             @"is_collect":@[@"is_collection",@"is_collect"]};
}

@end
