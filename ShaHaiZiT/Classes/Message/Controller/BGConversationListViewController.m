//
//  BGConversationListViewController.m
//  shzTravelC
//
//  Created by 孙林茂 on 2018/5/8.
//  Copyright © 2018年 biao. All rights reserved.
//

#import "BGConversationListViewController.h"
#import "BGChatViewController.h"
#import "UITabBar+badge.h"
#import "RCDCustomerServiceViewController.h"

@interface BGConversationListViewController ()


@end

@implementation BGConversationListViewController
-(instancetype)init{
    self = [super init];
    if (self) {
        //设置需要显示哪些类型的会话
        [self setDisplayConversationTypes:@[@(ConversationType_PRIVATE),@(ConversationType_CUSTOMERSERVICE)]];
        [RCIM sharedRCIM].globalConversationAvatarStyle = RC_USER_AVATAR_CYCLE; // 列表页头像的形状，设置成圆形
//        [RCIM sharedRCIM].globalMessageAvatarStyle      = RC_USER_AVATAR_CYCLE; // 聊天界面头像的形状
        [self setupEmptyConversationView];
        //    [RCIM sharedRCIM].globalConversationze// 列表页头像的大小，默认是46*46
        //    [RCIM sharedRCIM].globalMessagePortraitSize // 聊天界面头像的大小默认是40*40
    }
    return self;
}

- (void)setupEmptyConversationView {
    
    UIView *emptyView = [[UIView alloc] initWithFrame:self.view.bounds];
    emptyView.backgroundColor = kAppBgColor;
    UIImageView *noneImgView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"no_chat_message"]];
    noneImgView.frame = CGRectMake(SCREEN_WIDTH*0.4, SafeAreaTopHeight+60, SCREEN_WIDTH*0.2, SCREEN_WIDTH*0.2*0.88);
    [emptyView addSubview:noneImgView];
    UILabel *showMsgLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, noneImgView.frame.origin.y+noneImgView.frame.size.height+50, SCREEN_WIDTH-20, 20)];
    showMsgLabel.textAlignment = NSTextAlignmentCenter;
    [showMsgLabel setTextColor:kAppTipBGColor];
    showMsgLabel.font = kFont(14);
    showMsgLabel.text = @"亲，您还没有聊天记录哟~";
    [emptyView addSubview:showMsgLabel];
    
    self.emptyConversationView = emptyView;
    
}
- (void)viewDidLoad {
    [super viewDidLoad];
    self.conversationListTableView.tableFooterView = UIView.new;
    self.navigationItem.title = @"消息中心";
    self.edgesForExtendedLayout = UIRectEdgeNone;
    // cell背景颜色
    //    self.cellBackgroundColor = UIColor.yellowColor;
}
/*
 // cell将要显示
 -(void)willDisplayConversationTableCell:(RCConversationBaseCell *)cell atIndexPath:(NSIndexPath *)indexPath{
 RCConversationModel *model = self.conversationListDataSource[indexPath.row];
 if (model.conversationType == ConversationType_PRIVATE) {
 RCConversationCell *conversationCell = (RCConversationCell *)cell;
 //        conversationCell.conversationTitle.text = @"biaoo";
 conversationCell.conversationTitle.textColor = UIColor.blueColor;
 
 }
 }
 -(void)gotoConverstionView {
 BGChatViewController *conversationVC = [[BGChatViewController alloc]init];
 conversationVC.conversationType = ConversationType_PRIVATE;
 conversationVC.targetId = model.targetId;
 conversationVC.title = @"想显示的会话标题";
 [self.navigationController pushViewController:conversationVC animated:YES];
 }
 // 点击Cell头像的回调
 - (void)didTapCellPortrait:(RCConversationModel *)model {
 
 }
 
 // 长按Cell头像的回调
 - (void)didLongPressCellPortrait:(RCConversationModel *)model {
 
 }
 */

//重写RCConversationListViewController的onSelectedTableRow事件
- (void)onSelectedTableRow:(RCConversationModelType)conversationModelType
         conversationModel:(RCConversationModel *)model
               atIndexPath:(NSIndexPath *)indexPath {
    if (model.conversationType == ConversationType_CUSTOMERSERVICE) {
        if ([RCIMClient sharedRCIMClient].getConnectionStatus != 0) {
            [WHIndicatorView toast:@"融云连接失败,请重新登录账号!"];
            [Tool logoutRongCloudAction];
            return;
        }
        RCDCustomerServiceViewController *chatService = [[RCDCustomerServiceViewController alloc] init];
        chatService.conversationType = ConversationType_CUSTOMERSERVICE;
        chatService.targetId = model.targetId;//通过“客服管理后台 - 坐席管理 - 技能组”，对应为技能组列表中的技能组 ID。
        chatService.title = model.conversationTitle;
        RCCustomerServiceInfo *csInfo = [[RCCustomerServiceInfo alloc] init];
        csInfo.userId = [RCIMClient sharedRCIMClient].currentUserInfo.userId;
        csInfo.nickName = BGGetUserDefaultObjectForKey(@"UserNickname");
        csInfo.portraitUrl = [RCIMClient sharedRCIMClient].currentUserInfo.portraitUri;
        csInfo.referrer = @"客户端";
        chatService.csInfo = csInfo; //用户的详细信息，此数据用于上传用户信息到客服后台，数据的 nickName 和 portraitUrl 必须填写。
        [self.navigationController pushViewController :chatService animated:YES];
    }else{
        BGChatViewController *conversationVC = [[BGChatViewController alloc]init];
        conversationVC.conversationType = ConversationType_PRIVATE;
        conversationVC.targetId = model.targetId;
        conversationVC.title = model.conversationTitle;
        [self.navigationController pushViewController:conversationVC animated:YES];
    }
   
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
@end
