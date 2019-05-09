//
//  BGOrderListCell.h
//  ShaHaiZiT
//
//  Created by biao on 2018/11/29.
//  Copyright © 2018 biao. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@class BGOrderListModel;
@interface BGOrderListCell : UITableViewCell

-(void)updataWithCellArray:(BGOrderListModel *)model;

@property (nonatomic,copy) void(^firstBtnClicked)(void);
@property (nonatomic,copy) void(^secondBtnClicked)(void);

@end

NS_ASSUME_NONNULL_END
