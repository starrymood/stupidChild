//
//  BGEssayCommentCell.h
//  shzTravelC
//
//  Created by biao on 2018/7/31.
//  Copyright © 2018年 biao. All rights reserved.
//

#import <UIKit/UIKit.h>

@class BGEssayCommentFirstModel;
@interface BGEssayCommentCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UIButton *userHomepageBtn;
@property (weak, nonatomic) IBOutlet UIButton *replyBtn;
@property (weak, nonatomic) IBOutlet UIButton *sAllReplyBtn;
@property (weak, nonatomic) IBOutlet UIButton *sFirstUserBtn;
@property (weak, nonatomic) IBOutlet UIButton *sSUserBtn;
@property (weak, nonatomic) IBOutlet UIButton *firstLikeBtn;

- (void)updataWithCellArray:(BGEssayCommentFirstModel *)model;

@end
