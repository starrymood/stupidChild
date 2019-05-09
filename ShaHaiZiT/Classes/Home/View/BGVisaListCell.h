//
//  BGVisaListCell.h
//  ShaHaiZiT
//
//  Created by biao on 2019/1/19.
//  Copyright © 2019 biao. All rights reserved.
//

#import <UIKit/UIKit.h>

@class BGVisaListModel;
NS_ASSUME_NONNULL_BEGIN

@interface BGVisaListCell : UITableViewCell

- (void)updataWithCellArray:(BGVisaListModel *)model;

@end

NS_ASSUME_NONNULL_END
