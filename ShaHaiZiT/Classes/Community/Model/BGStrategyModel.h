//
//  BGStrategyModel.h
//  shzTravelC
//
//  Created by biao on 2018/7/19.
//  Copyright © 2018年 biao. All rights reserved.
//

#import "BGBaseModel.h"

@interface BGStrategyModel : BGBaseModel

@property (nonatomic, copy) NSString *nickname;
@property (nonatomic, copy) NSString *postTitle;
@property (nonatomic, copy) NSString *picture;
@property (nonatomic, copy) NSString *face;
@property (nonatomic, copy) NSString *clickNumber;
@property (nonatomic, copy) NSString *ID;
@property (nonatomic, copy) NSString *type;
@property(nonatomic,copy) NSString *classificationId;
@property(nonatomic,copy) NSString *aspectRatio;

@property (nonatomic, copy) NSString *linkUrl;
@property(nonatomic,copy) NSString *bannerTitle;
@property(nonatomic,copy) NSString *bannerImages;
@property(nonatomic,copy) NSString *bannerType;

@property(nonatomic,copy) NSString *post_title;
@property(nonatomic,copy) NSString *click_number;
@property(nonatomic,copy) NSString *aspect_ratio;
@property(nonatomic,copy) NSString *file_url;
@property(nonatomic,copy) NSString *is_like;

@end
