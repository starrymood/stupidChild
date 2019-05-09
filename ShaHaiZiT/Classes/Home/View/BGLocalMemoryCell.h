//
//  BGLocalMemoryCell.h
//  ShaHaiZiT
//
//  Created by biao on 2019/3/28.
//  Copyright © 2019 biao. All rights reserved.
//

#import <UIKit/UIKit.h>

@class BGLocalPersonModel;
NS_ASSUME_NONNULL_BEGIN

@interface BGLocalMemoryCell : UITableViewCell

-(void)updataWithCellArr:(BGLocalPersonModel *)model;

@end

NS_ASSUME_NONNULL_END
