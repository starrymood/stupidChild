//
//  MCScrollView.h
//  YTScrollViewDemo
//
//  Created by TonyAng on 2017/7/26.
//  Copyright © 2017年 TonyAng. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol MCScrollViewDelegate <NSObject>

@optional
-(void)MCScrollViewDidScroll:(UIScrollView *)scrollView viewHeight:(CGFloat)height;

-(void)MCScrollViewDidEndDecelerating:(UIScrollView *)scrollView;

@end

@interface MCScrollView : UIScrollView<UIScrollViewDelegate>

@property (retain,nonatomic) NSMutableArray * imageNameArray;
@property (retain,nonatomic) NSArray * imageItemArray;

@property (assign,nonatomic) CGFloat scrollLastH;

@property (weak,nonatomic) id<MCScrollViewDelegate> mcDelegate;

@property (nonatomic, assign) NSUInteger currentPage;

@end
