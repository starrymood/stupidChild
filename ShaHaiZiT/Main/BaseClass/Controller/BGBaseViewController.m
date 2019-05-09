//
//  BGBaseViewController.m
//  shzTravelC
//
//  Created by 孙林茂 on 2018/5/4.
//  Copyright © 2018年 biao. All rights reserved.
//

#import "BGBaseViewController.h"
#import "BGWalletPayResultViewController.h"
#import "BGWalletSubmitSuccessViewController.h"

@interface BGBaseViewController ()

@end

@implementation BGBaseViewController
-(void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    [self.view resignFirstResponder];
    [self keyboarkHidden];
    
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = kAppWhiteColor;
    
    if (@available(iOS 11.0,*)) {
        UIScrollView.appearance.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
    }else{
        self.automaticallyAdjustsScrollViewInsets = NO;
    }
    [self addGestureRecognizer];
    
    [self addRightSwipeBackGestureToUpViewController];
}
- (void)keyboarkHidden {
    [[[UIApplication sharedApplication] keyWindow] endEditing:YES];
}
- (void)addGestureRecognizer
{
    UITapGestureRecognizer *tapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleGestureFrom:)];
    tapRecognizer.delegate = self;
    [self.view addGestureRecognizer:tapRecognizer];
}

#pragma mark - GestureRecognizer
-(void)handleGestureFrom:(UIGestureRecognizer *)recognizer
{
    [self.view endEditing:YES];
}


//防止手势冲突
- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch {
    NSString *classname=[NSString stringWithFormat:@"%@",[touch.view class]]  ;
//        NSLog(@"classname:%@",classname);
    
         UIViewController *topmostVC = [Tool topViewController];
    if ([touch.view isKindOfClass:[UITableView class]]){
        return YES;

    }
    
    if ([touch.view isKindOfClass:[UITableViewCell class]]){
        return NO;
    }
    
    
    if ([classname isEqualToString:@"UITableViewCellContentView"] || [classname isEqualToString:@"UIWebBrowserView"]){
        return NO;
    }
if ([topmostVC isKindOfClass:[BGWalletSubmitSuccessViewController class]] || [topmostVC isKindOfClass:[BGWalletPayResultViewController class]]){
            return NO;
        }
    
    UIView *supView =touch.view.superview;
    if(supView){
        
        NSString *classname1=[NSString stringWithFormat:@"%@",[supView class]]  ;
//                NSLog(@"classname1:%@",classname1);
        
        if ([classname1 isEqualToString:@"UITableViewCellContentView"] || [classname1 isEqualToString:@"BGShopCell"] || [classname1 isEqualToString:@"BGSaleCollectCell"] || [classname1 isEqualToString:@"SDCollectionViewCell"] || [classname1 isEqualToString:@"FSCalendarCell"] || [classname1 isEqualToString:@"BGStrategyCell"] || [classname1 isEqualToString:@"BGHotVideoCell"] || [classname1 isEqualToString:@"HXPhotoSubViewCell"] || [classname1 isEqualToString:@"BGAirRightCell"] || [classname1 isEqualToString:@"BGAirProductCell"] || [classname1 isEqualToString:@"BGHotLineWaterFallCell"] || [classname1 isEqualToString:@"BGHomeHotVideoCell"] || [classname1 isEqualToString:@"BGCouponManagerListCell"] | [classname1 isEqualToString:@"BGLocalRecommendCell"] | [classname1 isEqualToString:@"BGShopGoodCell"]){
            return NO;
        }
        
        UIView *supView2 = supView.superview;
        
        if (supView2) {
            NSString *classname2=[NSString stringWithFormat:@"%@",[supView2 class]]  ;
//                        NSLog(@"classname2:%@",classname2);
            
            if ([classname2 isEqualToString:@"UITableViewCellContentView"]){
                return NO;
            }
        }
        
        
    }
    
    return YES;
    
}

#pragma make nodate
-(void)refreshNoNetView{
    if(self.refreshBlock){
        self.refreshBlock();
    }
}

//显示没有网络的界面
-(void)shownoNetWorkViewWithType:(int)type
{
    if (!self.noNetWork) {
        [self.noNetWork removeFromSuperview];
        self.noNetWork = nil;
        switch (type) {
            case 0://界面全屏
                self.noNetWork = [[NetworkErrorView alloc]initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT)];
                
                break;
            case 1://界面不含头部64
                self.noNetWork = [[NetworkErrorView alloc]initWithFrame:CGRectMake(0, 64, SCREEN_WIDTH, SCREEN_HEIGHT-kNavigationBarH)];
                
                break;
            case 2://界面不含头部64尾部49
                if (self. navigationController.viewControllers.count > 1) {
                    self.noNetWork = [[NetworkErrorView alloc]initWithFrame:CGRectMake(0, 64, SCREEN_WIDTH, SCREEN_HEIGHT-kNavigationBarH)];
                }else{
                    self.noNetWork = [[NetworkErrorView alloc]initWithFrame:CGRectMake(0, 64, SCREEN_WIDTH, SCREEN_HEIGHT-kNavigationBarH-kTabBarH)];
                }
                
                break;
            default:
                break;
        }
        self.noNetWork.prompImgView.image = [UIImage imageNamed:noNetWorkImage];
        //        self.noNetWork.prompLabel.text = noNetWorkmessage;
        self.noNetWork.delegate = self;
        
        [self.view addSubview: self.noNetWork];
    }
    
}


-(void)hideNodateView{
    [self.noNetWork removeFromSuperview];
    self.noNetWork = nil;
    
}



- (void)reloadDataButtonSelected:(id)sender networkErrorView:(UIView *)view
{
    // [self.wb reload];
    [self refreshNoNetView];
    
}


- (void)addRightSwipeBackGestureToUpViewController {
    self.navigationController.interactivePopGestureRecognizer.delegate = (id)self;
}

- (void)removeRightSwipeBackGestureToUpViewController {
    self.navigationController.interactivePopGestureRecognizer.delegate = nil;
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
