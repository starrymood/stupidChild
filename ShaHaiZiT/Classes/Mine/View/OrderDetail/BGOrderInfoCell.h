//
//  BGOrderInfoCell.h
//  shzTravelC
//
//  Created by 孙林茂 on 2018/5/11.
//  Copyright © 2018年 biao. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface BGOrderInfoCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UILabel *goodsCouponLabel;

- (void)updataWithCellArray:(NSDictionary *)dic isPay:(BOOL)isPay;


@end
