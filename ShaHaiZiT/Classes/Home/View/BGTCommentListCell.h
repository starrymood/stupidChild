//
//  BGTCommentListCell.h
//  shzTravelC
//
//  Created by biao on 2018/8/28.
//  Copyright © 2018年 biao. All rights reserved.
//

#import <UIKit/UIKit.h>

@class BGAirPriceCommentModel;
@interface BGTCommentListCell : UITableViewCell

- (void)updataWithCellArray:(BGAirPriceCommentModel *)model;

@end
