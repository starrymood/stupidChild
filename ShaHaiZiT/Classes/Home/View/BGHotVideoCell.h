//
//  BGHotVideoCell.h
//  shzTravelC
//
//  Created by biao on 2018/7/23.
//  Copyright © 2018年 biao. All rights reserved.
//

#import <UIKit/UIKit.h>

@class BGHomeHotVideoModel;
@interface BGHotVideoCell : UICollectionViewCell

-(void)updataWithCellArray:(BGHomeHotVideoModel *)model isFood:(BOOL)isFood;

@end
