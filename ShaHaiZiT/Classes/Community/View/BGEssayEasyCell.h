//
//  BGEssayEasyCell.h
//  ShaHaiZiT
//
//  Created by biao on 2018/11/25.
//  Copyright © 2018 biao. All rights reserved.
//

#import <UIKit/UIKit.h>

@class BGEssayCommentFirstModel;
NS_ASSUME_NONNULL_BEGIN

@interface BGEssayEasyCell : UITableViewCell

- (void)updataWithCellArray:(BGEssayCommentFirstModel *)model;

@end

NS_ASSUME_NONNULL_END
