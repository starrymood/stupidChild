//
//  BGMessageTypeCell.h
//  ShaHaiZiT
//
//  Created by biao on 2018/11/23.
//  Copyright © 2018 biao. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN
@class BGSysMsgModel;
@interface BGMessageTypeCell : UITableViewCell

-(void)updataWithCellArray:(BGSysMsgModel *)model;
@property (nonatomic,copy) void(^userHomepageBtnClicked)(void);
@property (nonatomic,copy) void(^communityEssayBtnClicked)(void);
@property (nonatomic,copy) void(^communityCommentBtnClicked)(void);

@end

NS_ASSUME_NONNULL_END
