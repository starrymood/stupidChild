//
//  BGOrderDetailCell.h
//  shzTravelC
//
//  Created by 孙林茂 on 2018/5/10.
//  Copyright © 2018年 biao. All rights reserved.
//

#import <UIKit/UIKit.h>
@class BGOrderModel;
//typedef NS_ENUM(NSInteger, Order_Type) {
//    Order_Pay = 1,        // 待付款
//    Order_Send,           // 待发货
//    Order_Receive,        // 待收货
//    Order_Finish,         // 已完成
//    Order_Service,        // 售后
//    Order_All,            // 全部
//};

@interface BGOrderDetailCell : UITableViewCell

//-(void)updataWithCellArray:(BGOrderModel *)model Order_Type:(Order_Type)type;
-(void)updataWithCellArray:(BGOrderModel *)model;
@property (nonatomic,copy) void(^afterSaleBtnClick)(NSString *itemId , NSString *num);
@property (nonatomic,copy) void(^firstBtnClicked)(void);
@property (nonatomic,copy) void(^sureBtnClicked)(void);
@property (nonatomic,copy) void(^didSelectRowClicked)(void);
@end
