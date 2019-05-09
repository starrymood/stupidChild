//
//  BGPostCommentView.h
//  shzTravelC
//
//  Created by biao on 2018/6/27.
//  Copyright © 2018年 biao. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface BGPostCommentView : UIView

@property (nonatomic,copy) void(^starOneClicked)(NSString *star);
@property (nonatomic,copy) void(^starTwoClicked)(NSString *star);
@property (nonatomic,copy) void(^starThreeClicked)(NSString *star);
@property (nonatomic,copy) void(^publishBtnClicked)(UIButton *sender);

@end
