//
//  BGPromotionNewModel.h
//  shzTravelC
//
//  Created by biao on 2018/9/13.
//  Copyright © 2018年 biao. All rights reserved.
//

#import "BGBaseModel.h"

@interface BGPromotionNewModel : BGBaseModel

@property (nonatomic, copy) NSString *ID;
@property (nonatomic, copy) NSString *activityTitle;
@property (nonatomic, copy) NSString *mainPicture;
@property (nonatomic, copy) NSString *activitySubtitle;
@property (nonatomic, copy) NSString *startTime;
@property (nonatomic, copy) NSString *endTime;
@property (nonatomic, copy) NSString *serviceId;
@property (nonatomic, copy) NSString *serviceName;

@property(nonatomic,copy) NSString *activity_subtitle;
@property(nonatomic,copy) NSString *start_time;
@property(nonatomic,copy) NSString *end_time;
@property(nonatomic,copy) NSString *activity_title;
@property(nonatomic,copy) NSString *main_picture;

@end
