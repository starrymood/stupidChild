//
//  BGShopCatView.h
//  ShaHaiZiT
//
//  Created by biao on 2019/4/19.
//  Copyright © 2019 biao. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface BGShopCatView : UIView

- (void)updataWithCellArray:(NSArray *)dataArr;

@property (nonatomic,copy) void(^selectCatTapClick)(NSString *cat_id);

@end

NS_ASSUME_NONNULL_END
