//
//  BGWebViewController.h
//  shahaizic
//
//  Created by 孙林茂 on 2018/4/10.
//  Copyright © 2018年 樱兰网络. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface BGWebViewController : UIViewController

@property (nonatomic, copy) NSString * url;

@property (nonatomic, assign) BOOL isShowActivityShare;

@property (nonatomic, copy) NSString *subTitleStr;

@property (nonatomic, copy) NSString *activityTitleStr;

@property (nonatomic, copy) NSString *service_name;

@property (nonatomic, copy) NSString *service_id;

@end
