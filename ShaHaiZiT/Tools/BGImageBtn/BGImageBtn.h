//
//  BGImageBtn.h
//  LLMall
//
//  Created by biao on 2016/11/19.
//  Copyright © 2016年 ZZLL. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface BGImageBtn : UIButton
@property(nonatomic, retain)UIImageView *image;
@property(nonatomic, retain)UILabel *lb_title;
// 只更改图片
-(void)changeImage:(UIImage *)Image;
// 只更改title
-(void)changeTitle:(NSString *)title;
- (id)initWithFrame:(CGRect)frame;
-(void)resetdata:(NSString *)title :(UIImage *)Image;
@end
