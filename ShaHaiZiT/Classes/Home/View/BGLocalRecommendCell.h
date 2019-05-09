//
//  BGLocalRecommendCell.h
//  ShaHaiZiT
//
//  Created by biao on 2019/3/27.
//  Copyright © 2019 biao. All rights reserved.
//

#import <UIKit/UIKit.h>

@class BGLocalSpecialModel;
NS_ASSUME_NONNULL_BEGIN

@interface BGLocalRecommendCell : UICollectionViewCell

- (void)updataWithCellArray:(BGLocalSpecialModel *)model;

@end

NS_ASSUME_NONNULL_END
