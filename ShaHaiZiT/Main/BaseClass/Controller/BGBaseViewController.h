//
//  BGBaseViewController.h
//  shzTravelC
//
//  Created by 孙林茂 on 2018/5/4.
//  Copyright © 2018年 biao. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "NetworkErrorView.h"
#import "MBProgressHUD.h"

typedef void (^ShareFinishBlock)(void);//无返回值,无入参的block,应用在大多数位置

@interface BGBaseViewController : UIViewController<UIGestureRecognizerDelegate,reloadDataButtonSelectionDelegate>

@property(nonatomic,strong)ShareFinishBlock refreshBlock;
@property(nonatomic,strong)NetworkErrorView *noNetWork;     //没有网络


//隐藏没有数据界面
-(void)hideNodateView;
//显示没有网络的界面
-(void)shownoNetWorkViewWithType:(int)type;
- (void)keyboarkHidden;
@end
