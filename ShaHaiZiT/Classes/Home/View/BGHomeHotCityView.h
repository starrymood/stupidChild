//
//  BGHomeHotCityView.h
//  ShaHaiZiT
//
//  Created by biao on 2019/4/14.
//  Copyright © 2019 biao. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface BGHomeHotCityView : UIView

- (void)updataWithCellArray:(NSArray *)dataArr;

@property (nonatomic,copy) void(^selectCityTapClick)(NSString *region_id);

@end

NS_ASSUME_NONNULL_END
