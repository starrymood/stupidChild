//
//  BGShopInfoBaseCell.h
//  shzTravelC
//
//  Created by 孙林茂 on 2018/5/11.
//  Copyright © 2018年 biao. All rights reserved.
//

#import <UIKit/UIKit.h>

@class BGShopModel;
@interface BGShopInfoBaseCell : UITableViewCell
@property (nonatomic,copy) void(^afterSaleBtnClick)(NSString *itemId , NSString *num);
-(void)updataWithCellArray:(BGShopModel *)model orderStatus:(int)status;

@end
