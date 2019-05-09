//
//  BGCollectionStoreCell.h
//  shzTravelC
//
//  Created by biao on 2018/7/26.
//  Copyright © 2018年 biao. All rights reserved.
//

#import <UIKit/UIKit.h>

@class BGCollectionStoreModel;
@interface BGCollectionStoreCell : UITableViewCell

@property (nonatomic,copy) void(^enterStoreCellClicked)(void);

@property (nonatomic,copy) void(^cancelCollectCellClicked)(void);

-(void)updataWithCellArray:(BGCollectionStoreModel *)model;

@end
