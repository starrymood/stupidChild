//
//  BGBirthdayPickView.h
//  shahaizic
//
//  Created by 孙林茂 on 2018/4/5.
//  Copyright © 2018年 樱兰网络. All rights reserved.
//

#import <UIKit/UIKit.h>
@protocol BGBirthDateDelegate <NSObject>
@optional

- (void)canaleCallBack;

- (void)confrmCallBack:(NSInteger)Year month:(NSInteger)month day:(NSInteger)day;

@end

@interface BGBirthdayPickView : UIView
@property (nonatomic, assign) int yearNum;

@property (nonatomic,weak) id<BGBirthDateDelegate> delegate;

- (id)initWithDelegate:(id<BGBirthDateDelegate>)delegate year:(NSUInteger)year month:(NSUInteger)month day:(NSUInteger)day;

@end
