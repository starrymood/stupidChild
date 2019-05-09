//
//  WH_errorBox.h
//  wehomec
//
//  Created by Lion on 17/2/20.
//  Copyright © 2017年 JiangHao. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface WH_errorBox : UIView

{
    UILabel *errorLabel;
}
- (void)setErrorText:(NSString *)str;
- (id)initWithFrame:(CGRect)frame superController:(UIViewController*)superController;
- (id)initWithFrame:(CGRect)frame superView:(UIView*)view;

@property (nonatomic,strong) NSTimer *timeSlice;

@end
