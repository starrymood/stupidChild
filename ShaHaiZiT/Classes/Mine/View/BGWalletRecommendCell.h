//
//  BGWalletRecommendCell.h
//  ShaHaiZiT
//
//  Created by biao on 2019/1/11.
//  Copyright © 2019 biao. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@class BGWalletDetailModel;
@interface BGWalletRecommendCell : UITableViewCell

-(void)updataWithAwardArray:(BGWalletDetailModel *)model;

@end

NS_ASSUME_NONNULL_END
