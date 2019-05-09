//
//  BGShopBargainCell.h
//  ShaHaiZiT
//
//  Created by biao on 2019/1/19.
//  Copyright © 2019 biao. All rights reserved.
//

#import <UIKit/UIKit.h>

@class BGShopBargainModel;
NS_ASSUME_NONNULL_BEGIN

@interface BGShopBargainCell : UITableViewCell

@property (nonatomic,copy) void(^sureBtnClicked)(void);
- (void)updataWithCellArray:(BGShopBargainModel *)model;

@end

NS_ASSUME_NONNULL_END
