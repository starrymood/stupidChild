//
//  BGReceiveAddressCell.h
//  shzTravelC
//
//  Created by 孙林茂 on 2018/5/12.
//  Copyright © 2018年 biao. All rights reserved.
//

#import <UIKit/UIKit.h>
@class BGAddressModel;
@interface BGReceiveAddressCell : UITableViewCell
@property (nonatomic,copy) void(^deleteCellClicked)(void); // 删除button的回调
@property (nonatomic,copy) void(^setDefaultCellClicked)(void); // 设为默认button的回调
@property (nonatomic,copy) void(^editCellClicked)(void); // 编辑button的回调

-(void)updataWithCellArray:(BGAddressModel *)model;

@end
