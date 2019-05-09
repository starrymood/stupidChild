//
//  BGAttentionCell.h
//  shzTravelC
//
//  Created by biao on 2018/7/19.
//  Copyright © 2018年 biao. All rights reserved.
//

#import <UIKit/UIKit.h>
@class BGAttentionModel;

@interface BGAttentionCell : UITableViewCell

-(void)updataWithArray:(BGAttentionModel *)model listType:(int)listType;

@property (nonatomic,copy) void(^concernClicked)(UIButton *sender); // 关注utton的回调

@end
