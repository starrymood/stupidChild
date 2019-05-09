//
//  BGDouYinCell.h
//  ShaHaiZiT
//
//  Created by biao on 2019/1/20.
//  Copyright © 2019 biao. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BGEssayDetailModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface BGDouYinCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UIButton *publishBtn;
@property (weak, nonatomic) IBOutlet UIButton *searchBtn;
@property (weak, nonatomic) IBOutlet UIButton *messageBtn;
@property (weak, nonatomic) IBOutlet UIButton *shareBtn;

@property (nonatomic,copy) void(^headImgViewClicked)(void);
- (void)updataWithCellArray:(BGEssayDetailModel *)model pic:(NSString *)pic;

@end

NS_ASSUME_NONNULL_END
