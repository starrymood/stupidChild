//
//  RCDCustomerServiceViewController.m
//  RCloudMessage
//
//  Created by litao on 16/2/23.
//  Copyright © 2016年 RongCloud. All rights reserved.
//

#import "RCDCustomerServiceViewController.h"
#import "RCDCSAnnounceView.h"
#import "RCDCSEvaluateView.h"
#import "RCDCSEvaluateModel.h"
#import "IQKeyboardManager.h"
#import <RongIMKit/RongIMKit.h>

@interface RCDCustomerServiceViewController ()<RCDCSAnnounceViewDelegate,RCDCSEvaluateViewDelegate>
//＊＊＊＊＊＊＊＊＊应用自定义评价界面开始1＊＊＊＊＊＊＊＊＊＊＊＊＊
@property (nonatomic, strong)NSString *commentId;
@property (nonatomic)RCCustomerServiceStatus serviceStatus;
@property (nonatomic)BOOL quitAfterComment;
//＊＊＊＊＊＊＊＊＊应用自定义评价界面结束1＊＊＊＊＊＊＊＊＊＊＊＊＊

@property (nonatomic,copy) NSString *announceClickUrl;

@property (nonatomic,strong) RCDCSEvaluateView *evaluateView;
//key为星级；value为RCDCSEvaluateModel对象
@property (nonatomic,strong)NSMutableDictionary *evaStarDic;
@property (nonatomic,strong) RCDCSAnnounceView *announceView;
@end

@implementation RCDCustomerServiceViewController
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
  // Do any additional setup after loading the view.
  
  self.evaStarDic = [NSMutableDictionary dictionary];
  [RCIM sharedRCIM].globalMessageAvatarStyle      = RC_USER_AVATAR_CYCLE;
  [[RCIMClient sharedRCIMClient] getHumanEvaluateCustomerServiceConfig:^(NSDictionary *evaConfig) {
    NSArray *array = [evaConfig valueForKey:@"evaConfig"];
      dispatch_async(dispatch_get_main_queue(), ^{
          if (array) {
              for (NSDictionary *dic in array) {
                  RCDCSEvaluateModel *model = [RCDCSEvaluateModel modelWithDictionary:dic];
                  [self.evaStarDic setObject:model forKey:[NSString stringWithFormat:@"%d",model.score]];
              }
          }
      });
  }];
}

-(void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self createNavLeftBarButtonItem];
    self.navigationItem.rightBarButtonItems = nil;
}

- (void)didReceiveMemoryWarning {
  [super didReceiveMemoryWarning];
  // Dispose of any resources that can be recreated.
}

//客服VC左按键注册的selector是customerServiceLeftCurrentViewController，
//这个函数是基类的函数，他会根据当前服务时间来决定是否弹出评价，根据服务的类型来决定弹出评价类型。
//弹出评价的函数是commentCustomerServiceAndQuit，应用可以根据这个函数内的注释来自定义评价界面。
//等待用户评价结束后调用如下函数离开当前VC。
- (void)clickLeftBarButtonItem:(id)sender {
    [super customerServiceLeftCurrentViewController];
}

//评价客服，并离开当前会话
//如果您需要自定义客服评价界面，请把本函数注释掉，并打开“应用自定义评价界面开始1/2”到“应用自定义评价界面结束”部分的代码，然后根据您的需求进行修改。
//如果您需要去掉客服评价界面，请把本函数注释掉，并打开下面“应用去掉评价界面开始”到“应用去掉评价界面结束”部分的代码，然后根据您的需求进行修改。
//- (void)commentCustomerServiceWithStatus:(RCCustomerServiceStatus)serviceStatus
//                               commentId:(NSString *)commentId
//                        quitAfterComment:(BOOL)isQuit {
//  [super commentCustomerServiceWithStatus:serviceStatus
//                                commentId:commentId
//                         quitAfterComment:isQuit];
//}

//＊＊＊＊＊＊＊＊＊应用去掉评价界面开始＊＊＊＊＊＊＊＊＊＊＊＊＊
//-
//(void)commentCustomerServiceWithStatus:(RCCustomerServiceStatus)serviceStatus
//commentId:(NSString *)commentId quitAfterComment:(BOOL)isQuit {
//    if (isQuit) {
//        [super customerServiceLeftCurrentViewController];;
//    }
//}
//＊＊＊＊＊＊＊＊＊应用去掉评价界面结束＊＊＊＊＊＊＊＊＊＊＊＊＊

//＊＊＊＊＊＊＊＊＊应用自定义评价界面开始2＊＊＊＊＊＊＊＊＊＊＊＊＊
-
(void)commentCustomerServiceWithStatus:(RCCustomerServiceStatus)serviceStatus
commentId:(NSString *)commentId quitAfterComment:(BOOL)isQuit {
    if (self.evaStarDic.count == 0) {
        [super commentCustomerServiceWithStatus:serviceStatus commentId:commentId quitAfterComment:isQuit];
        return;
    }
    self.serviceStatus = serviceStatus;
    self.commentId = commentId;
    self.quitAfterComment = isQuit;
    if (serviceStatus == 0) {
        [super customerServiceLeftCurrentViewController];;
    } else if (serviceStatus == 1) {
        //人工评价结果
      [self.evaluateView show];
    } else if (serviceStatus == 2) {
        //机器人评价结果
        UIAlertView *alert = [[UIAlertView alloc]
        initWithTitle:@"请评价我们的机器人服务"
        message:@"如果您满意就按是，不满意就按否" delegate:self
        cancelButtonTitle:@"是" otherButtonTitles:@"否", nil];
        [alert show];
    }
}
- (void)alertView:(UIAlertView *)alertView
clickedButtonAtIndex:(NSInteger)buttonIndex {
    //(1)调用evaluateCustomerService将评价结果传给融云sdk。
    if (self.serviceStatus == RCCustomerService_RobotService)
    {//机器人评价结果
        if (buttonIndex == 0) {
            [[RCIMClient sharedRCIMClient]
            evaluateCustomerService:self.targetId knownledgeId:self.commentId
            robotValue:YES suggest:nil];
        } else if (buttonIndex == 1) {
            [[RCIMClient sharedRCIMClient]
            evaluateCustomerService:self.targetId knownledgeId:self.commentId
            robotValue:NO suggest:nil];
        }
    }
    //(2)离开当前客服VC
    if (self.quitAfterComment) {
        [super customerServiceLeftCurrentViewController];;
    }
}

//＊＊＊＊＊＊＊＊＊应用自定义客服通告＊＊＊＊＊＊＊＊＊＊＊＊＊

- (void)announceViewWillShow:(NSString *)announceMsg announceClickUrl:(NSString *)announceClickUrl{
  self.announceClickUrl = announceClickUrl;
  
  self.announceView.content.text = announceMsg;
  if (announceClickUrl.length == 0) {
    self.announceView.hiddenArrowIcon = YES;
  }
}

#pragma mark -- RCDCSAnnounceViewDelegate
- (void)didTapViewAction{
  if (self.announceClickUrl.length > 0) {
    [RCKitUtility openURLInSafariViewOrWebView:self.announceClickUrl base:self];
  }
}
//＊＊＊＊＊＊＊＊＊应用自定义客服通告＊＊＊＊＊＊＊＊＊＊＊＊＊

#pragma mark -- RCDCSEvaluateViewDelegate

- (void)didSubmitEvaluate:(RCCSResolveStatus)solveStatus star:(int)star tagString:(NSString *)tagString suggest:(NSString *)suggest{
  [[RCIMClient sharedRCIMClient] evaluateCustomerService:self.targetId dialogId:nil starValue:star suggest:suggest resolveStatus:solveStatus tagText:tagString extra:nil];
  if (self.quitAfterComment) {
    [super customerServiceLeftCurrentViewController];;
  }
}

- (void)dismissEvaluateView{
  [self.evaluateView hide];
  if (self.quitAfterComment) {
    [super customerServiceLeftCurrentViewController];;
  }
}

- (RCDCSEvaluateView *)evaluateView{
  if (!_evaluateView) {
    _evaluateView = [[RCDCSEvaluateView alloc] initWithEvaStarDic:self.evaStarDic];
    _evaluateView.delegate = self;
  }
  return _evaluateView;
}

- (RCDCSAnnounceView *)announceView{
  if (!_announceView) {
    CGRect rect = self.conversationMessageCollectionView.frame;
    rect.origin.y += 44;
    rect.size.height -= 44;
    self.conversationMessageCollectionView.frame = rect;
    _announceView = [[RCDCSAnnounceView alloc] initWithFrame:CGRectMake(0,rect.origin.y-44, self.view.frame.size.width,44)];
    _announceView.delegate = self;
    [self.view addSubview:_announceView];
  }
  return _announceView;
}

#pragma mark Navigation Setting
- (void) createNavLeftBarButtonItem {
    UIButton *button = [[UIButton alloc] init];
    [button setImage:[UIImage imageNamed:@"btn_back_black"] forState:UIControlStateNormal];
    [button setImage:[UIImage imageNamed:@"btn_back_green"] forState:UIControlStateHighlighted];
    button.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
    
    
    @weakify(self);
    [[button rac_signalForControlEvents:(UIControlEventTouchUpInside)] subscribeNext:^(__kindof UIControl * _Nullable x) {
        @strongify(self);
        // 点击button的响应事件
        [self.navigationController popViewControllerAnimated:YES];
    }];
    button.bounds = CGRectMake(0, 0, 70, 30);
    button.contentEdgeInsets = UIEdgeInsetsMake(0, 0, 0, 0);
    button.titleLabel.font = [UIFont systemFontOfSize:15];
    UIBarButtonItem *leftButton = [[UIBarButtonItem alloc] initWithCustomView:button];
    [self.navigationItem setLeftBarButtonItem:leftButton];
}

@end
