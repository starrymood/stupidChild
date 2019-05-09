//
//  BGOrderWaitTipCell.h
//  shzTravelC
//
//  Created by 孙林茂 on 2018/5/11.
//  Copyright © 2018年 biao. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface BGOrderWaitTipCell : UITableViewCell

- (void)updataWithCellArray:(NSInteger)timeDifference;
@property (nonatomic,copy) void(^timeOverClicked)(void);

@end
