//
//  BGAirRightCell.h
//  shzTravelC
//
//  Created by biao on 2018/8/20.
//  Copyright © 2018年 biao. All rights reserved.
//

#import <UIKit/UIKit.h>

@class BGAirportCategoryModel;

@interface BGAirRightCell : UICollectionViewCell

- (void)updataWithCellArray:(BGAirportCategoryModel *)model isCar:(BOOL)isCar;

@end
