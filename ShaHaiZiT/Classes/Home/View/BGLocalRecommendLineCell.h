//
//  BGLocalRecommendLineCell.h
//  ShaHaiZiT
//
//  Created by biao on 2019/3/27.
//  Copyright © 2019 biao. All rights reserved.
//

#import <UIKit/UIKit.h>

@class BGAirProductModel;
NS_ASSUME_NONNULL_BEGIN

@interface BGLocalRecommendLineCell : UITableViewCell

-(void)updataWithCellArr:(BGAirProductModel *)model;

@end

NS_ASSUME_NONNULL_END
