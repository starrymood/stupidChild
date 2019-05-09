//
//  BGSystemMsgCell.h
//  shzTravelC
//
//  Created by 孙林茂 on 2018/5/8.
//  Copyright © 2018年 biao. All rights reserved.
//

#import <UIKit/UIKit.h>
@class BGSysMsgModel;
@interface BGSystemMsgCell : UITableViewCell

-(void)updataWithCellArray:(BGSysMsgModel *)model;

@end
