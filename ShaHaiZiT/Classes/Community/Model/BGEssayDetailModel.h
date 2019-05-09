//
//  BGEssayDetailModel.h
//  shzTravelC
//
//  Created by biao on 2018/7/27.
//  Copyright © 2018年 biao. All rights reserved.
//

#import "BGBaseModel.h"

@interface BGEssayDetailModel : BGBaseModel

@property (nonatomic, copy) NSArray *file_url;

@property (nonatomic, copy) NSString *is_collect;
@property (nonatomic, copy) NSString *is_concern;
@property (nonatomic, copy) NSString *is_like;

@property (nonatomic, copy) NSString *like_count;
@property (nonatomic, copy) NSString *collect_count;
@property (nonatomic, copy) NSString *review_count;
@property (nonatomic, copy) NSString *attention_number;

@property (nonatomic, copy) NSString *member_id;
@property (nonatomic, copy) NSString *content;
@property (nonatomic, copy) NSString *post_title;
@property (nonatomic, copy) NSString *create_time;
@property (nonatomic, copy) NSString *nickname;
@property (nonatomic, copy) NSString *logo;

@property (nonatomic, copy) NSString *type;
@property (nonatomic, copy) NSString *ID;

@property (nonatomic, copy) NSString *post_id;

@property (nonatomic, copy) NSArray *review_list;

@property (nonatomic, copy) NSString *video_image;
@property (nonatomic, copy) NSString *video_url;
@property (nonatomic, copy) NSString *video_title;
@property (nonatomic, copy) NSString *video_description;

@property (nonatomic, copy) NSString *classification_id;

@property (nonatomic, assign) BOOL isChangeToFull;

@property(nonatomic,copy) NSString *face;
@property(nonatomic,copy) NSString *category_name;

@property(nonatomic,copy) NSString *picture;



@end
