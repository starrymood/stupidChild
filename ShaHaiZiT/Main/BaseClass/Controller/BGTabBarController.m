//
//  BGTabBarController.m
//  shzTravelC
//
//  Created by 孙林茂 on 2018/5/4.
//  Copyright © 2018年 biao. All rights reserved.
//

#import "BGTabBarController.h"
#import "BGNavigationViewController.h"
#import "BGHomeViewController.h"
#import "BGCommunityViewController.h"
#import "BGMineViewController.h"
#import "BGPromotionNewViewController.h"
#import "RCDCustomerServiceViewController.h"
#import "BGConversationListViewController.h"
#import "BGShopViewController.h"

@interface BGTabBarController ()

@property (nonatomic, strong) BGNavigationViewController *homeNav;

@end

@implementation BGTabBarController

+(void)initialize{
    NSMutableDictionary *attrs = [NSMutableDictionary dictionary];
    attrs[NSForegroundColorAttributeName] = kApp333Color;
    
    NSMutableDictionary *selectedAttrs = [NSMutableDictionary dictionary];
    selectedAttrs[NSFontAttributeName] = attrs[NSFontAttributeName];
    selectedAttrs[NSForegroundColorAttributeName] = kAppMainColor;
    
    UITabBarItem *item = [UITabBarItem appearance];
    [item setTitleTextAttributes:attrs forState:UIControlStateNormal];
    [item setTitleTextAttributes:selectedAttrs forState:UIControlStateSelected];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setupChildVc:[[BGHomeViewController alloc] init] title:@"首页" image:@"tab_icon_home_default" selectedImage:@"tab_icon_home_selected" color:UIColorFromRGB(0x63ea73) tag:0];
    [self setupChildVc:[[BGCommunityViewController alloc] init] title:@"社区" image:@"tab_icon_community_default" selectedImage:@"tab_icon_community_selected" color:UIColorFromRGB(0xff9955) tag:1];
    [self setupChildVc:[[BGShopViewController alloc] init] title:@"商城" image:@"tab_icon_shop_default" selectedImage:@"tab_icon_shop_selected" color:UIColorFromRGB(0xd0a4fc) tag:2];
    [self setupChildVc:[[BGPromotionNewViewController alloc] init] title:@"活动" image:@"tab_icon_promotion_default" selectedImage:@"tab_icon_promotion_selected" color:UIColorFromRGB(0xf3516d) tag:3];
    [self setupChildVc:[[BGMineViewController alloc] init] title:@"我的" image:@"tab_icon_my_default" selectedImage:@"tab_icon_my_selected" color:UIColorFromRGB(0x13e9e5) tag:4];
    
    self.tabBar.backgroundColor = kAppWhiteColor;
    self.tabBar.barTintColor    = kAppWhiteColor;
    [[UITabBar appearance] setTranslucent:NO];
//    UIView *line = [[UIView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, 1)];
//    line.backgroundColor = kAppTableViewBgColor;
//    [self.tabBar addSubview:line];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(selectIndexHome) name:@"SELECTINDEXHOME" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(selectIndexMessage:) name:@"SELECTINDEXMESSAGE" object:nil];
//    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(selectIndexSystemMessage) name:@"selectIndexSystemMessage" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(selectIndexRongCloudMessage) name:@"selectIndexRongCloudMessage" object:nil];
}
-(void)setupChildVc:(UIViewController *)vc title:(NSString *)title image:(NSString *)image selectedImage:(NSString *)selectedImage color:(UIColor *)color tag:(NSInteger)tag{
    //    vc.navigationItem.title = title;
    vc.tabBarItem.title = title;
    vc.tabBarItem.tag = tag;
    NSMutableDictionary *selectedAttrs = [NSMutableDictionary dictionary];
    selectedAttrs[NSForegroundColorAttributeName] = color;
    [vc.tabBarItem setTitleTextAttributes:selectedAttrs forState:UIControlStateSelected];
    vc.tabBarItem.image = [BGImage(image) imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    vc.tabBarItem.selectedImage = [BGImage(selectedImage) imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    vc.tabBarItem.imageInsets = UIEdgeInsetsMake(0, 0, 0, 0);
    vc.tabBarItem.titlePositionAdjustment = UIOffsetMake(0, -3);
    if (tag == 0) {
        self.homeNav = [[BGNavigationViewController alloc] initWithRootViewController:vc];
        [self addChildViewController:_homeNav];
    }else{
        BGNavigationViewController *nav = [[BGNavigationViewController alloc] initWithRootViewController:vc];
        [self addChildViewController:nav];
    }
}
-(void)selectIndexHome{
    _homeNav.tabBarController.selectedIndex = 0;
}
-(void)selectIndexMessage:(NSNotification *)no{
    if ([RCIMClient sharedRCIMClient].getConnectionStatus != 0) {
        [WHIndicatorView toast:@"融云连接失败,请重新登录账号!"];
        [Tool logoutRongCloudAction];
        return;
    }
    NSDictionary *dic = [NSDictionary dictionaryWithDictionary:[no object]];
    _homeNav.tabBarController.selectedIndex = 0;
    BGConversationListViewController *listVC = [[BGConversationListViewController alloc] init];
    [self.homeNav pushViewController:listVC animated:NO];
    
    RCDCustomerServiceViewController *chatService = [[RCDCustomerServiceViewController alloc] init];
    chatService.conversationType = ConversationType_CUSTOMERSERVICE;
    chatService.targetId = [NSString stringWithFormat:@"%@",BGdictSetObjectIsNil(dic[@"serviceID"])];//通过“客服管理后台 - 坐席管理 - 技能组”，对应为技能组列表中的技能组 ID。
    chatService.title = [NSString stringWithFormat:@"%@",BGdictSetObjectIsNil(dic[@"serviceName"])];
    RCCustomerServiceInfo *csInfo = [[RCCustomerServiceInfo alloc] init];
    csInfo.userId = [RCIMClient sharedRCIMClient].currentUserInfo.userId;
    csInfo.nickName = BGGetUserDefaultObjectForKey(@"UserNickname");
    csInfo.portraitUrl = [RCIMClient sharedRCIMClient].currentUserInfo.portraitUri;
    csInfo.referrer = @"客户端";
    chatService.csInfo = csInfo; //用户的详细信息，此数据用于上传用户信息到客服后台，数据的 nickName 和 portraitUrl 必须填写。
    [_homeNav pushViewController :chatService animated:NO];
}
//-(void)selectIndexSystemMessage{
//    
//    _homeNav.tabBarController.selectedIndex = 0;
//    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
//        BGMessageViewController *messageVC = BGMessageViewController.new;
//        [self.homeNav pushViewController:messageVC animated:YES];
//        [[NSNotificationCenter defaultCenter] postNotificationName:@"MsgListRefreshNotification" object:nil];
//    });
//}
-(void)selectIndexRongCloudMessage{
    _homeNav.tabBarController.selectedIndex = 0;
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        BGConversationListViewController *listVC = [[BGConversationListViewController alloc] init];
        [self.homeNav pushViewController:listVC animated:YES];
//         [[NSNotificationCenter defaultCenter] postNotificationName:@"MsgListRefreshNotification" object:nil];
    });
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
