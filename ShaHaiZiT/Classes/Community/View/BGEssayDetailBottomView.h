//
//  BGEssayDetailBottomView.h
//  shzTravelC
//
//  Created by biao on 2018/7/30.
//  Copyright © 2018年 biao. All rights reserved.
//

#import <UIKit/UIKit.h>

@class BGEssayDetailModel;
@interface BGEssayDetailBottomView : UIView

@property (weak, nonatomic) IBOutlet UIButton *commentBtn;

-(void)updataWithModel:(BGEssayDetailModel *)model;
-(void)updataColorWithModel:(BGEssayDetailModel *)model;

@end
