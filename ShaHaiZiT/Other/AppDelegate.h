//
//  AppDelegate.h
//  ShaHaiZiT
//
//  Created by biao on 2018/10/10.
//  Copyright © 2018年 biao. All rights reserved.
//

#import <UIKit/UIKit.h>
@class BGTabBarController;

@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;
@property (nonatomic, strong) BGTabBarController *tabBarVC;
@property (strong,nonatomic) NSString *httpURL;     //服务器地址
//@property (strong,nonatomic) NSString *httpImgURL;  //图片地址
@property (nonatomic, strong) NSString *httpH5URL;  //H5地址
- (void)loginRongCloudWithToken:(NSString *)token;

@end

