//
//  BGHotLineWaterFallCell.h
//  ShaHaiZiT
//
//  Created by biao on 2018/10/19.
//  Copyright © 2018年 biao. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@class BGAirProductModel;

@interface BGHotLineWaterFallCell : UICollectionViewCell

- (void)updataWithCellArray:(BGAirProductModel *)model;

@end

NS_ASSUME_NONNULL_END
