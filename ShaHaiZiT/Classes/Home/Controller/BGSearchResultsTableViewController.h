//
//  BGSearchResultsTableViewController.h
//  LLBike
//
//  Created by biao on 2017/4/11.
//  Copyright © 2017年 ZZLL. All rights reserved.
//

#import <UIKit/UIKit.h>
@class BGAirportCategoryModel;
@interface BGSearchResultsTableViewController : UITableViewController
/** 选中cell时调用此Block  */
@property (nonatomic, copy) void(^didSelectLocation)(BGAirportCategoryModel *model);

@property (nonatomic, assign) NSInteger category;

@end
