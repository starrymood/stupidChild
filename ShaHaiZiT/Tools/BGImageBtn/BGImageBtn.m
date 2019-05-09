//
//  BGImageBtn.m
//  LLMall
//
//  Created by biao on 2016/11/19.
//  Copyright © 2016年 ZZLL. All rights reserved.
//

#import "BGImageBtn.h"

@implementation BGImageBtn
@synthesize lb_title,image;

//先创建，后布局
- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        
        lb_title = [[UILabel alloc] initWithFrame:CGRectZero];
        lb_title.numberOfLines = 1;
        lb_title.font = [UIFont systemFontOfSize:14.f];
        lb_title.textColor = kApp333Color;
        [self addSubview:lb_title];
        
        image = [[UIImageView alloc] initWithFrame:CGRectZero];
        
//        image.backgroundColor = [UIColor lightGrayColor];
        [self addSubview:image];
    }
    return self;
}
// 只更改图片
-(void)changeImage:(UIImage *)Image {
    [image setImage:Image];
    
}
// 只更改title
-(void)changeTitle:(NSString *)title {
    lb_title.text = title;
    CGSize size = [lb_title.text sizeWithAttributes:@{NSFontAttributeName:[UIFont systemFontOfSize:14.f]}];
    //假设lb_title与图片、按钮边缘间隔都是10,图片大小30*30
    if (size.width>self.width-5*2-15-5) {
        size.width = self.width-5*2-15-5;
    }
    lb_title.frame = CGRectMake(image.width+image.x+5, 0, size.width,self.frame.size.height);
}
//更改title内容时可重新布局
-(void)resetdata:(NSString *)title :(UIImage *)Image
{
    lb_title.text = title;
    CGSize size = [lb_title.text sizeWithAttributes:@{NSFontAttributeName:[UIFont systemFontOfSize:14.f]}];
    //假设lb_title与图片、按钮边缘间隔都是10,图片大小30*30
    if (size.width>self.width-5*2-15-5) {
        size.width = self.width-5*2-15-5;
    }
    image.frame = CGRectMake(5,(self.frame.size.height-20)/2,15,15);
    [image setImage:Image];
    lb_title.frame = CGRectMake(image.width+image.x+5, 0, size.width,self.frame.size.height );
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
