//
//  BGHotVideoListCell.h
//  shzTravelC
//
//  Created by biao on 2018/7/23.
//  Copyright © 2018年 biao. All rights reserved.
//

#import <UIKit/UIKit.h>

@class BGHomeHotVideoModel;
@interface BGHotVideoListCell : UITableViewCell

-(void)updataWithCellArray:(BGHomeHotVideoModel *)model;

@end
