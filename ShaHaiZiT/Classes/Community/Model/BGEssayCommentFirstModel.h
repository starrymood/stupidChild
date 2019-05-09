//
//  BGEssayCommentFirstModel.h
//  shzTravelC
//
//  Created by biao on 2018/7/31.
//  Copyright © 2018年 biao. All rights reserved.
//

#import "BGBaseModel.h"

@interface BGEssayCommentFirstModel : BGBaseModel

@property (nonatomic, copy) NSString *ID;
@property (nonatomic, copy) NSString *post_id;
@property (nonatomic, copy) NSString *face;
@property (nonatomic, copy) NSString *create_time;
@property (nonatomic, copy) NSString *member_id;
@property (nonatomic, copy) NSString *type;
@property (nonatomic, copy) NSString *reply_member_id;
@property (nonatomic, copy) NSString *is_review_like;
@property (nonatomic, copy) NSString *review_like_count;
@property (nonatomic, strong) NSArray *children_review;
@property (nonatomic, copy) NSString *reply_comment_id;
@property(nonatomic,copy) NSString *children_review_count;
@property (nonatomic, copy) NSString *nickname;
@property(nonatomic,copy) NSString *review_body;


@end
