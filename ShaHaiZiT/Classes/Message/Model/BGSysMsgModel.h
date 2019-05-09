//
//  BGSysMsgModel.h
//  shzTravelS
//
//  Created by 孙林茂 on 2018/5/30.
//  Copyright © 2018年 biao. All rights reserved.
//

#import "BGBaseModel.h"

@interface BGSysMsgModel : BGBaseModel

@property (nonatomic, copy) NSString *ID;
@property (nonatomic, copy) NSString *is_read;
@property (nonatomic, copy) NSString *title;
@property (nonatomic, copy) NSString *create_time;
@property (nonatomic, copy) NSString *is_receive;

@property(nonatomic,copy) NSString *state;
@property(nonatomic,copy) NSString *activity_subtitle;
@property(nonatomic,copy) NSString *service_name;
@property(nonatomic,copy) NSString *service_id;

@property(nonatomic,copy) NSString *nickname;
@property(nonatomic,copy) NSString *face;
@property(nonatomic,copy) NSString *uname;
@property(nonatomic,copy) NSString *type;
@property(nonatomic,copy) NSString *content;
@property(nonatomic,copy) NSString *member_id;
@property(nonatomic,copy) NSString *post_type;
@property(nonatomic,copy) NSString *post_id;
@property(nonatomic,copy) NSString *review_id;
@property(nonatomic,copy) NSString *picture;

@end
