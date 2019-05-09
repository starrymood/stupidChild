//
//  BGHomeLineCell.h
//  shzTravelC
//
//  Created by biao on 2018/7/23.
//  Copyright © 2018年 biao. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface BGHomeLineCell : UITableViewCell

-(void)updataWithCellArr:(NSArray *)dataArr;

@property (nonatomic,copy) void(^jumpToDetailBtnClick)(NSInteger btnTag);

@end
