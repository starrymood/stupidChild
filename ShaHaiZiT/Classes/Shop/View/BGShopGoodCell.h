//
//  BGShopGoodCell.h
//  ShaHaiZiT
//
//  Created by biao on 2019/4/19.
//  Copyright © 2019 biao. All rights reserved.
//

#import <UIKit/UIKit.h>

@class BGShopShowModel;
NS_ASSUME_NONNULL_BEGIN

@interface BGShopGoodCell : UICollectionViewCell

- (void)updataWithCellArray:(BGShopShowModel *)model;

@end

NS_ASSUME_NONNULL_END
