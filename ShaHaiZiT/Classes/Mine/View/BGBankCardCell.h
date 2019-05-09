//
//  BGBankCardCell.h
//  shzTravelC
//
//  Created by 孙林茂 on 2018/5/12.
//  Copyright © 2018年 biao. All rights reserved.
//

#import <UIKit/UIKit.h>
@class BGMyBankCardModel;
@interface BGBankCardCell : UITableViewCell
- (void)updataWithCellArray:(BGMyBankCardModel *)model;

@end
