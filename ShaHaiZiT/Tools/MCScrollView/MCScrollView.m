//
//  MCScrollView.m
//  YTScrollViewDemo
//
//  Created by TonyAng on 2017/7/26.
//  Copyright © 2017年 TonyAng. All rights reserved.
//

#import "MCScrollView.h"
#import "UIImageView+AFNetworking.h"
#import <UIImageView+WebCache.h>
#import "ImagesList.h"

#define UISCREENWIDTH  self.bounds.size.width   //宽度
#define UISCREENHEIGHT  self.bounds.size.height //高度

#define HIGHT self.bounds.origin.y //由于_pageControl是添加进父视图的,所以实际位置要参考,滚动视图的y坐标

static NSUInteger currentImage;//记录中间图片的下标

@interface MCScrollView()
{
    //基本的三个视图
    UIImageView * _leftImageView;
    UIImageView * _centerImageView;
    UIImageView * _rightImageView;
    
    NSMutableArray *_imageWidthArray;
    NSMutableArray *_imageHeightArray;
    NSArray *_tagPageArray;
    
    CGFloat _scrollContentW;
    CGFloat _leftScrollH;
    CGFloat _centerScrollH;
    CGFloat _rightScrollH;
    CGFloat _currentOffSet;
    CGPoint _origin;
    
    NSUInteger realImage;
    
    BOOL isFirst;
}

@property (retain,nonatomic,readonly) UIImageView * leftImageView;
@property (retain,nonatomic,readonly) UIImageView * centerImageView;
@property (retain,nonatomic,readonly) UIImageView * rightImageView;
@property (nonatomic, strong) UILabel *pageOneLabel;
@property (nonatomic, strong) UILabel *pageCenterLabel;
@property (nonatomic, strong) UILabel *pageLastLabel;

@end

@implementation MCScrollView
-(UILabel *)pageOneLabel{
    if (!_pageOneLabel) {
        self.pageOneLabel = [[UILabel alloc] initWithFrame:CGRectMake(SCREEN_WIDTH-100, _leftImageView.y+_leftImageView.height-35, 90, 25)];
        _pageOneLabel.textAlignment = NSTextAlignmentRight;
        _pageOneLabel.font = kFont(15);
        _pageOneLabel.textColor = kAppWhiteColor;
        _pageOneLabel.text = [NSString stringWithFormat:@"1/%lu",(unsigned long)_imageNameArray.count];
    }
    return _pageOneLabel;
}
-(UILabel *)pageCenterLabel{
    if (!_pageCenterLabel) {
        self.pageCenterLabel = [[UILabel alloc] initWithFrame:CGRectMake(SCREEN_WIDTH-100, _centerImageView.y+_centerImageView.height-35, 90, 25)];
        _pageCenterLabel.textAlignment = NSTextAlignmentRight;
        _pageCenterLabel.font = kFont(15);
        _pageCenterLabel.textColor = kAppWhiteColor;
        _pageCenterLabel.text = [NSString stringWithFormat:@"2/%lu",(unsigned long)_imageNameArray.count];
    }
    return _pageCenterLabel;
}
-(UILabel *)pageLastLabel{
    if (!_pageLastLabel) {
        self.pageLastLabel = [[UILabel alloc] initWithFrame:CGRectMake(SCREEN_WIDTH-100, _rightImageView.y+_rightImageView.height-35, 90, 25)];
        _pageLastLabel.textAlignment = NSTextAlignmentRight;
        _pageLastLabel.font = kFont(15);
        _pageLastLabel.textColor = kAppWhiteColor;
        _pageLastLabel.text = [NSString stringWithFormat:@"%lu/%lu",(unsigned long)_imageNameArray.count,(unsigned long)_imageNameArray.count];
    }
    return _pageLastLabel;
}
#pragma mark - 自由指定广告所占的frame
- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.bounces = NO;
        
        self.showsHorizontalScrollIndicator = NO;
        self.showsVerticalScrollIndicator = NO;
        self.pagingEnabled = YES;
//        self.contentOffset = CGPointMake(UISCREENWIDTH, 0);
        self.contentSize = CGSizeMake(UISCREENWIDTH * 3, UISCREENHEIGHT);
        self.delegate = self;
        
        _origin = self.origin;
        
        _currentOffSet = 0;
        _currentPage = 1;
        _leftImageView = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, UISCREENWIDTH, UISCREENHEIGHT)];
        [self addSubview:_leftImageView];
        _centerImageView = [[UIImageView alloc]initWithFrame:CGRectMake(UISCREENWIDTH, 0, UISCREENWIDTH, UISCREENHEIGHT)];
        [self addSubview:_centerImageView];
        _rightImageView = [[UIImageView alloc]initWithFrame:CGRectMake(UISCREENWIDTH*2, 0, UISCREENWIDTH, UISCREENHEIGHT)];
        [self addSubview:_rightImageView];
        
    }
    return self;
}

/**
 *  重写set
 */
-(void)setImageItemArray:(NSArray *)imageItemArray{
    if (_imageItemArray == nil) {
        _imageItemArray = [NSArray array];
    }
    _imageItemArray = imageItemArray;
    
    _imageWidthArray = [NSMutableArray array];
    _imageHeightArray = [NSMutableArray array];
    _imageNameArray = [NSMutableArray array];
    
    for (NSDictionary *dic in _imageItemArray) {
        ImagesList *imageModel = [ImagesList mj_objectWithKeyValues:dic];
        _scrollContentW += [imageModel.width floatValue];
        
        [_imageNameArray addObject:imageModel.url];
        [_imageWidthArray addObject:imageModel.width];
        [_imageHeightArray addObject:imageModel.height];
    }
    
    realImage = currentImage = 0;
    [self getImageFirst];
    
}


-(void)getImageData
{
    
    _leftScrollH = [self getImageHWithImgW:_imageWidthArray[(currentImage-1)%_imageNameArray.count] imgH:_imageHeightArray[(currentImage-1)%_imageNameArray.count]];
    
    _centerScrollH = [self getImageHWithImgW:_imageWidthArray[currentImage%_imageNameArray.count] imgH:_imageHeightArray[currentImage%_imageNameArray.count]];
    
    _rightScrollH = [self getImageHWithImgW:_imageWidthArray[(currentImage+1)%_imageNameArray.count] imgH:_imageHeightArray[(currentImage+1)%_imageNameArray.count]];
    
    [_leftImageView sd_setImageWithURL:[NSURL URLWithString:_imageNameArray[(currentImage-1)%_imageNameArray.count]]];
    
    self.currentPage = currentImage+1;
    [_centerImageView addSubview:self.pageCenterLabel];
    self.pageCenterLabel.text = [NSString stringWithFormat:@"%lu/%lu",(unsigned long)(currentImage+1),(unsigned long)_imageNameArray.count];
    self.pageCenterLabel.y = _centerImageView.y+_centerImageView.height-35;
    [_centerImageView sd_setImageWithURL:[NSURL URLWithString:_imageNameArray[currentImage%_imageNameArray.count]]];
    
    [_rightImageView sd_setImageWithURL:[NSURL URLWithString:_imageNameArray[(currentImage+1)%_imageNameArray.count]]];
}

-(void)getImageFirst{
    _centerScrollH = [self getImageHWithImgW:_imageWidthArray[0] imgH:_imageHeightArray[0]];
    if (_imageWidthArray.count>1) {
        _rightScrollH = [self getImageHWithImgW:_imageWidthArray[1] imgH:_imageHeightArray[1]];
    }
    _leftImageView.size = CGSizeMake(SCREEN_WIDTH, UISCREENHEIGHT);
    [_leftImageView addSubview:self.pageOneLabel];
    self.currentPage = 1;
    [_leftImageView sd_setImageWithURL:[NSURL URLWithString:_imageNameArray[0]] placeholderImage:[UIImage imageNamed:@"img_placeholder"] completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
    }];
    if (_imageNameArray.count>2) {
        [_centerImageView sd_setImageWithURL:[NSURL URLWithString:_imageNameArray[1]] placeholderImage:[UIImage imageNamed:@"img_placeholder"] completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
        }];
    }
    
    currentImage = 1;
}

-(void)getImageLast{
    [_rightImageView addSubview:self.pageLastLabel];
    self.currentPage = _imageNameArray.count;
    _centerScrollH = [self getImageHWithImgW:_imageWidthArray[_imageNameArray.count-1] imgH:_imageHeightArray[_imageNameArray.count-1]];
    
    _leftScrollH = [self getImageHWithImgW:_imageWidthArray[_imageNameArray.count-2] imgH:_imageHeightArray[_imageNameArray.count-2]];
    
    [_centerImageView sd_setImageWithURL:[NSURL URLWithString:_imageNameArray[_imageNameArray.count-2]]];
    
    [_rightImageView sd_setImageWithURL:[NSURL URLWithString:_imageNameArray[_imageNameArray.count-1]]];
    
    currentImage = _imageNameArray.count-2;
}

-(void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
    _currentOffSet = scrollView.contentOffset.x;
    if (self.imageNameArray.count == 2) {
        self.contentSize = CGSizeMake(SCREEN_WIDTH*2, self.size.height);
    }else{
        self.contentSize = CGSizeMake(SCREEN_WIDTH*3, self.size.height);
    }
}

/**
 *  控制图片（scrollview）的缩放
 */
-(void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    CGFloat offset = scrollView.contentOffset.x;
    CGFloat offsetValue = offset - _currentOffSet;
    CGFloat offsetX = 0.0;
    if (self.imageNameArray.count == 2) {
        _leftScrollH = [self getImageHWithImgW:_imageWidthArray[0] imgH:_imageHeightArray[0]];
        _rightScrollH = [self getImageHWithImgW:_imageWidthArray[1] imgH:_imageHeightArray[1]];
    }
    
    if (offsetValue > 0) {//左滑
        if (self.imageNameArray.count == 2) {
            
            offsetX = offsetValue;
            CGFloat value = _leftScrollH - _rightScrollH;
            CGFloat scale = value/SCREEN_WIDTH;//单位位移下的缩放的距离
            if (value > 0) {//缩小
                self.size = CGSizeMake(SCREEN_WIDTH, _leftScrollH-scale*offsetX);
            }else if (value < 0){//放大
                self.size = CGSizeMake(SCREEN_WIDTH, _leftScrollH-scale*offsetX);
            }
        }else{
            offsetX = offsetValue;
            CGFloat value = _centerScrollH - _rightScrollH;
            CGFloat scale = value/SCREEN_WIDTH;//单位位移下的缩放的距离
            if (value > 0) {//缩小
                self.size = CGSizeMake(SCREEN_WIDTH, _centerScrollH-scale*offsetX);
            }else if (value < 0){//放大
                self.size = CGSizeMake(SCREEN_WIDTH, _centerScrollH-scale*offsetX);
            }
        }
        
    }else if (offsetValue < 0){//右滑
        if (self.imageNameArray.count == 2) {
            offsetX = _currentOffSet - offset;
            CGFloat value = _rightScrollH - _leftScrollH;
            CGFloat scale = value/SCREEN_WIDTH;
            if (value > 0) {//缩小
                self.size = CGSizeMake(SCREEN_WIDTH, _rightScrollH-scale*offsetX);
            }else if (value < 0){//放大
                self.size = CGSizeMake(SCREEN_WIDTH, _rightScrollH-scale*offsetX);
            }
        }else{
            offsetX = _currentOffSet - offset;
            CGFloat value = _centerScrollH - _leftScrollH;
            CGFloat scale = value/SCREEN_WIDTH;
            if (value > 0) {//缩小
                self.size = CGSizeMake(SCREEN_WIDTH, _centerScrollH-scale*offsetX);
            }else if (value < 0){//放大
                self.size = CGSizeMake(SCREEN_WIDTH, _centerScrollH-scale*offsetX);
            }
        }
        
    }else{
        return;
    }
    
    if (self.imageNameArray.count == 2) {
        [_centerImageView removeFromSuperview];
        [_rightImageView removeFromSuperview];
        
        _rightImageView = [[UIImageView alloc]initWithFrame:CGRectMake(UISCREENWIDTH, 0, UISCREENWIDTH, UISCREENHEIGHT)];
        [self addSubview:_rightImageView];
        self.contentSize = CGSizeMake(SCREEN_WIDTH * 2, self.size.height);
        
        [_rightImageView sd_setImageWithURL:[NSURL URLWithString:_imageNameArray[1]] placeholderImage:[UIImage imageNamed:@"img_placeholder"] completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
        }];
        _leftImageView.size =_rightImageView.size = CGSizeMake(SCREEN_WIDTH, UISCREENHEIGHT);
    }else{
        self.contentSize = CGSizeMake(SCREEN_WIDTH * 3, self.size.height);
        _leftImageView.size = _centerImageView.size = _rightImageView.size = CGSizeMake(SCREEN_WIDTH, UISCREENHEIGHT);
    }
    
    
    if ([self.mcDelegate respondsToSelector:@selector(MCScrollViewDidScroll:viewHeight:)]) {
        [self.mcDelegate MCScrollViewDidScroll:scrollView viewHeight:UISCREENHEIGHT];
    }
}

#pragma mark - 图片停止时,调用该函数使得滚动视图复用
- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
//    NSLog(@"***********左----->%lf 中-----> %lf 右-----> %lf",_leftScrollH,_centerScrollH,_rightScrollH);
//    NSLog(@"self.size------>%f",self.size.height);
    scrollView.userInteractionEnabled = YES;
    
    if (self.contentOffset.x == 0){
        realImage = currentImage - 1;
    }else if (self.contentOffset.x == SCREEN_WIDTH*2){
        realImage = currentImage + 1;
    }else{
        if (self.imageNameArray.count == 2) {
            [_rightImageView addSubview:self.pageLastLabel];
            self.currentPage = _imageNameArray.count;
        }
        realImage = currentImage;
    }
    
    if (realImage == 0){
        [self getImageFirst];
        return;
    }
    if (realImage == _imageNameArray.count-1) {
        if (self.imageNameArray.count != 2) {
            [self getImageLast];
        }
        return;
    }
    
    if (self.contentOffset.x == 0){
        currentImage = (currentImage-1)%_imageNameArray.count;
    }else if(self.contentOffset.x == SCREEN_WIDTH * 2){
        currentImage = (currentImage+1)%_imageNameArray.count;
    }else if(realImage == 1 || realImage == _imageNameArray.count-2){
        
    }else{
        return;
    }
    
    [self getImageData];
    
    self.contentOffset = CGPointMake(SCREEN_WIDTH, 0);
    
    if ([self.mcDelegate respondsToSelector:@selector(MCScrollViewDidEndDecelerating:)]) {
        [self.mcDelegate MCScrollViewDidEndDecelerating:scrollView];
    }
}


-(void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{
    if (decelerate) {
        scrollView.userInteractionEnabled = NO;
    }
}


-(CGFloat)getImageHWithImgW:(NSString *)imgW imgH:(NSString *)imgH{
    CGFloat width = [imgW floatValue];
    CGFloat height = [imgH floatValue];
    
    return SCREEN_WIDTH/width * height;
}


@end
