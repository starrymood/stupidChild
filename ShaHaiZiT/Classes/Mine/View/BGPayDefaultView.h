//
//  BGPayDefaultView.h
//  ShaHaiZiT
//
//  Created by biao on 2018/11/28.
//  Copyright © 2018 biao. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN
@class BGOrderListModel;
@class BGOrderDetailModel;
@interface BGPayDefaultView : UIView

@property (weak, nonatomic) IBOutlet UIButton *payCancelBtn;

@property (nonatomic,copy) void(^sureBtnClick)(NSString *payType);
-(instancetype)initWithFrame:(CGRect)frame dataDic:(NSDictionary *)dataDic;
-(instancetype)initWithFrame:(CGRect)frame dataModel:(BGOrderListModel *)model;
-(instancetype)initWithFrame:(CGRect)frame dataSModel:(BGOrderDetailModel *)model;

@end

NS_ASSUME_NONNULL_END
