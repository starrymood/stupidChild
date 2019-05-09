//
//  BGShopCell.h
//  shzTravelC
//
//  Created by 孙林茂 on 2018/5/8.
//  Copyright © 2018年 biao. All rights reserved.
//

#import <UIKit/UIKit.h>

@class BGShopShowModel;

@interface BGShopCell : UICollectionViewCell

- (void)updataWithCellArray:(BGShopShowModel *)model;

@end
