//
//  BGHomeHotVideoCell.h
//  ShaHaiZiT
//
//  Created by biao on 2018/11/21.
//  Copyright © 2018 biao. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@class BGHomeHotVideoModel;
@interface BGHomeHotVideoCell : UICollectionViewCell

-(void)updataWithCellArray:(BGHomeHotVideoModel *)model;

@end

NS_ASSUME_NONNULL_END
