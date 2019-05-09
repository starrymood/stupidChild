//
//  BGWaterFallLayout.h
//  shzTravelC
//
//  Created by 孙林茂 on 2018/5/8.
//  Copyright © 2018年 biao. All rights reserved.
//

#import <UIKit/UIKit.h>

@class BGWaterFallLayout;

@protocol  BGWaterFallLayoutDelegate<NSObject>

@required
/**
 * 每个item的高度
 */
- (CGFloat)waterFallLayout:(BGWaterFallLayout *)waterFallLayout heightForItemAtIndexPath:(NSUInteger)indexPath itemWidth:(CGFloat)itemWidth;

@optional
/**
 * 有多少列
 */
- (NSUInteger)columnCountInWaterFallLayout:(BGWaterFallLayout *)waterFallLayout;

/**
 * 每列之间的间距
 */
- (CGFloat)columnMarginInWaterFallLayout:(BGWaterFallLayout *)waterFallLayout;

/**
 * 每行之间的间距
 */
- (CGFloat)rowMarginInWaterFallLayout:(BGWaterFallLayout *)waterFallLayout;

/**
 * 每个item的内边距
 */
- (UIEdgeInsets)edgeInsetdInWaterFallLayout:(BGWaterFallLayout *)waterFallLayout;


@end
@interface BGWaterFallLayout : UICollectionViewLayout
/** 代理 */
@property (nonatomic, weak) id<BGWaterFallLayoutDelegate> delegate;

@end
