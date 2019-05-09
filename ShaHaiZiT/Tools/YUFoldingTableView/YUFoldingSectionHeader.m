//
//  YUFoldingSectionHeader.m
//  YUFoldingTableView
//
//  Created by administrator on 16/8/24.
//  Copyright © 2016年 timelywind. All rights reserved.
//

#import "YUFoldingSectionHeader.h"

@interface YUFoldingSectionHeader ()

@property (nonatomic, strong) UILabel  *titleLabel;

@property (nonatomic, assign) YUFoldingSectionHeaderArrowPosition  arrowPosition;
@property (nonatomic, assign) YUFoldingSectionState  sectionState;
@property (nonatomic, strong) UITapGestureRecognizer  *tapGesture;

@property (nonatomic, assign) NSInteger sectionIndex;

@end

@implementation YUFoldingSectionHeader

- (instancetype)initWithReuseIdentifier:(NSString *)reuseIdentifier
{
    if (self = [super initWithReuseIdentifier:reuseIdentifier]) {
        
        [self setupSubviews];
        
    }
    return self;
}

- (void)awakeFromNib
{
    [super awakeFromNib];
    
    [self setupSubviews];
    
}

// 创建子视图
- (void)setupSubviews
{
    _autoHiddenSeperatorLine = NO;
    _arrowPosition = YUFoldingSectionHeaderArrowPositionRight;
    
    [self.contentView addSubview:self.titleLabel];
    [self.contentView addSubview:self.arrowImageView];
    [self.contentView addGestureRecognizer:self.tapGesture];
}

- (void)configWithBackgroundColor:(UIColor *)backgroundColor
                      titleString:(NSString *)titleString
                       titleColor:(UIColor *)titleColor
                        titleFont:(UIFont *)titleFont
                descriptionString:(NSString *)descriptionString
                 descriptionColor:(UIColor *)descriptionColor
                  descriptionFont:(UIFont *)descriptionFont
                       arrowImage:(UIImage *)arrowImage
                    arrowPosition:(YUFoldingSectionHeaderArrowPosition)arrowPosition
                     sectionState:(YUFoldingSectionState)sectionState
                     sectionIndex:(NSInteger)sectionIndex
{
    _sectionIndex = sectionIndex;
    [self.contentView setBackgroundColor:backgroundColor];
    
    self.titleLabel.text = titleString;
    self.titleLabel.textColor = titleColor;
    self.titleLabel.font = titleFont;
    
    self.arrowImageView.image = arrowImage;
    self.arrowPosition = arrowPosition;
    self.sectionState = sectionState;
    
    if (sectionState == YUFoldingSectionStateShow) {
        self.arrowImageView.hidden = NO;
    } else {
        self.arrowImageView.hidden = YES;
    }
    
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    CGFloat labelWidth = self.frame.size.width-18-2-18;
    CGFloat labelHeight = 22;
    CGRect arrowRect = CGRectMake(18, (self.frame.size.height - 16)/2, 2, 16);
    CGRect titleRect = CGRectMake(20, (self.frame.size.height - 22)/2, labelWidth, labelHeight);
    [self.titleLabel setFrame:titleRect];
    [self.arrowImageView setFrame:arrowRect];
}


// MARK: -----------------------  event


- (void)onTapped:(UITapGestureRecognizer *)gesture
{
    if (_tapDelegate && [_tapDelegate respondsToSelector:@selector(yuFoldingSectionHeaderTappedAtIndex:)]) {
        self.sectionState = [NSNumber numberWithBool:(![NSNumber numberWithInteger:self.sectionState].boolValue)].integerValue;
        [_tapDelegate yuFoldingSectionHeaderTappedAtIndex:_sectionIndex];
    }
}

// MARK: -----------------------  getter

- (UILabel *)titleLabel
{
    if (!_titleLabel) {
        _titleLabel = [[UILabel alloc]initWithFrame:CGRectZero];
        _titleLabel.backgroundColor = [UIColor clearColor];
        _titleLabel.textAlignment = NSTextAlignmentCenter;
    }
    return _titleLabel;
}

- (UIImageView *)arrowImageView
{
    if (!_arrowImageView) {
        _arrowImageView = [[UIImageView alloc]initWithFrame:CGRectZero];
        _arrowImageView.backgroundColor = [UIColor clearColor];
        _arrowImageView.contentMode = UIViewContentModeScaleAspectFit;
    }
    return _arrowImageView;
}


- (UITapGestureRecognizer *)tapGesture
{
    if (!_tapGesture) {
        _tapGesture = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(onTapped:)];
    }
    return _tapGesture;
}


@end
