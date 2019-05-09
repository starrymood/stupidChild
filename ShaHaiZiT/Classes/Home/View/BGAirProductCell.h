//
//  BGAirProductCell.h
//  shzTravelC
//
//  Created by biao on 2018/8/20.
//  Copyright © 2018年 biao. All rights reserved.
//

#import <UIKit/UIKit.h>

@class BGAirProductModel;
@interface BGAirProductCell : UICollectionViewCell

- (void)updataWithCellArray:(BGAirProductModel *)model;

@end
