//
//  BGMyCollectionCell.h
//  shzTravelC
//
//  Created by 孙林茂 on 2018/5/11.
//  Copyright © 2018年 biao. All rights reserved.
//

#import <UIKit/UIKit.h>
@class BGShopShowModel;

@interface BGMyCollectionCell : UITableViewCell

@property (nonatomic,copy) void(^deleteCellClicked)(void); // 删除button的回调

@property (nonatomic,copy) void(^addToCartCellClicked)(void); // 加入购物车button的回调

-(void)updataWithCellArray:(BGShopShowModel *)model;

@end
