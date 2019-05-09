//
//  BGHomeHotVideoModel.h
//  shzTravelC
//
//  Created by biao on 2018/8/1.
//  Copyright © 2018年 biao. All rights reserved.
//

#import "BGBaseModel.h"

@interface BGHomeHotVideoModel : BGBaseModel

@property (nonatomic, copy) NSString *ID;
@property (nonatomic, copy) NSString *video_url;
@property (nonatomic, copy) NSString *video_image;

@property(nonatomic,copy) NSString *video_id;
@property (nonatomic, copy) NSString *video_title;
@property (nonatomic, copy) NSString *collect_count;
@property (nonatomic, copy) NSString *like_count;
@property (nonatomic, copy) NSString *watch_number;
@property(nonatomic,copy) NSString *country_name;
@property(nonatomic,copy) NSString *talent_tag;
@property(nonatomic,copy) NSString *talent_name;
@property(nonatomic,copy) NSString *talent_english_name;
@property(nonatomic,copy) NSString *talent_cover_picture;

@property(nonatomic,copy) NSString *title;
@property(nonatomic,copy) NSString *cover_picture;
@property(nonatomic,copy) NSString *region_name;

@end
