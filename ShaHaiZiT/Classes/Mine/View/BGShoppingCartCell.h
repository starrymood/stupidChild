//
//  BGShoppingCartCell.h
//  LLMall
//
//  Created by biao on 2016/11/8.
//  Copyright © 2016年 ZZLL. All rights reserved.
//

#import <UIKit/UIKit.h>

@class BGShopModel;
@interface BGShoppingCartCell : UITableViewCell
- (void)updataWithCellArray:(BGShopModel *)model;

@property (nonatomic,copy) void(^singleSelectClicked)(void);
@property (nonatomic,copy) void(^numChangeBtnClicked)(NSString *currentNum);  // 数量改变的回调
@property (weak, nonatomic) IBOutlet UIButton *isSelectBtn; // 单选button

@end
