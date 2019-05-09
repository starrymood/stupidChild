//
//  BGOrderShopInfoCell.h
//  shzTravelC
//
//  Created by 孙林茂 on 2018/5/11.
//  Copyright © 2018年 biao. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface BGOrderShopInfoCell : UITableViewCell
@property (nonatomic,copy) void(^afterSaleBtnClick)(NSString *itemId , NSString *num);
- (void)updataWithCellArray:(NSArray *)arr orderStatus:(int)status;

@end
