//
//  BGChatViewController.m
//  shzTravelC
//
//  Created by 孙林茂 on 2018/5/8.
//  Copyright © 2018年 biao. All rights reserved.
//

#import "BGChatViewController.h"
#import "IQKeyboardManager.h"

@implementation BGChatViewController
-(void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    [IQKeyboardManager sharedManager].enableAutoToolbar = NO;
    [[IQKeyboardManager sharedManager] setEnable:NO];
}
-(void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    [[IQKeyboardManager sharedManager] setEnable:YES];
    [IQKeyboardManager sharedManager].enableAutoToolbar = YES;
}
- (void)viewDidLoad {
    [super viewDidLoad];
    
    // 在聊天界面中点击下方工具条上的加号 可以选择发送照片 拍照 及发送位置信息的功能 如果某项功能不需要可以通过以下方法删除
    if ([self is32bit]) {
        [self.chatSessionInputBarControl.pluginBoardView removeItemAtIndex:2];
    }
    [RCIM sharedRCIM].globalMessageAvatarStyle      = RC_USER_AVATAR_CYCLE; // 聊天界面头像的形状
    if ([Tool isBlankString:self.targetId]) {
        [WHIndicatorView toast:@"参数错误"];
        [self.navigationController popViewControllerAnimated:YES];
    }
    //    self.conversationMessageCollectionView.backgroundColor = UIColor.clearColor;
    //    self.view.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@""]];
    
}

/*
 -(void)willDisplayMessageCell:(RCMessageBaseCell *)cell atIndexPath:(NSIndexPath *)indexPath{
 if ([cell isKindOfClass:[RCTextMessageCell class]]) {
 RCTextMessageCell *testMsgCell = (RCTextMessageCell *)cell;
 UILabel *textMsgLabel = (UILabel *)testMsgCell.textLabel;
 textMsgLabel.textColor = [UIColor redColor];
 }
 }
 
 // 输入框中内容发生变化的回调 inputTextView:文本输入框 range:当前操作的范围  text:插入的文本
 - (void)inputTextView:(UITextView *)inputTextView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text {
 [super inputTextView:inputTextView shouldChangeTextInRange:range replacementText:text];
 
 }
 
 // 扩展功能板的点击回调 pluginBoardView:输入扩展功能板View  tag:输入扩展功能(Item)的唯一标示
 
 - (void)pluginBoardView:(RCPluginBoardView*)pluginBoardView clickedItemWithTag:(NSInteger)tag {
 [super pluginBoardView:pluginBoardView clickedItemWithTag:tag];
 
 }
 
 // 开始录制语音消息的回调
 
 - (void)onBeginRecordEvent {
 [super onBeginRecordEvent];
 
 }
 // 点击头像
 - (void)didTapCellPortrait:(NSString *)userId {
 
 }
 
 // 长摁头像
 - (void)didLongPressCellPortrait:(NSString *)userId {
 
 }
 
 // 点击Cell中URL的回调  url:点击的URL  model:消息Cell的数据模型
 -(void)didTapUrlInMessageCell:(NSString *)url model:(RCMessageModel *)model{
 
 }
 
 // 点击Cell中电话号码的回调 phoneNumber:点击的电话号码    model:消息Cell的数据模型
 -(void)didTapPhoneNumberInMessageCell:(NSString *)phoneNumber model:(RCMessageModel *)model{
 
 }
 */


- (BOOL)is32bit
{
#if defined(__LP64__) && __LP64__
    return NO;
#else
    return YES;
#endif
}

@end
