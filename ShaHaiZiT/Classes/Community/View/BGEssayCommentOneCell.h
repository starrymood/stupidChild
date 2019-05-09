//
//  BGEssayCommentOneCell.h
//  shzTravelC
//
//  Created by biao on 2018/8/1.
//  Copyright © 2018年 biao. All rights reserved.
//

#import <UIKit/UIKit.h>

@class BGEssayCommentSModel;
@interface BGEssayCommentOneCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UIButton *sFirstUserBtn;
@property (weak, nonatomic) IBOutlet UIButton *sSUserBtn;

- (void)updataWithCellArray:(BGEssayCommentSModel *)model;


@end
