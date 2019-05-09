//
//  BGPostCommentCell.h
//  shzTravelC
//
//  Created by biao on 2018/6/27.
//  Copyright © 2018年 biao. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface BGPostCommentCell : UITableViewCell

@property (nonatomic,copy) void(^uploadImgClicked)(void);
@property (nonatomic,copy) void(^delImgClicked)(NSInteger tag);

- (void)updataWithCellArray:(NSDictionary *)dic picArr:(NSMutableArray *)picArr contentStr:(NSString *)contentStr;

@property (nonatomic,copy) void(^textViewDone)(NSString *text);

@end
