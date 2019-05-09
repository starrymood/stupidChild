//
//  BGEssayCommentSModel.h
//  shzTravelC
//
//  Created by biao on 2018/7/31.
//  Copyright © 2018年 biao. All rights reserved.
//

#import "BGBaseModel.h"

@interface BGEssayCommentSModel : BGBaseModel

@property (nonatomic, copy) NSString *reply_member_id;
@property (nonatomic, copy) NSString *review_id;
@property (nonatomic, copy) NSString *review_body;
@property (nonatomic, copy) NSString *nickname;
@property(nonatomic,copy) NSString *review_like_count;
@property (nonatomic, copy) NSString *member_id;
@property (nonatomic, copy) NSString *face;
@property (nonatomic, copy) NSString *replay_nickname;
@property(nonatomic,copy) NSString *is_review_like;
@property(nonatomic,copy) NSString *create_time;
@property (nonatomic, copy) NSString *type;


@end
