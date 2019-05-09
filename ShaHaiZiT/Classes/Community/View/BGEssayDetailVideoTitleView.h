//
//  BGEssayDetailVideoTitleView.h
//  shzTravelC
//
//  Created by biao on 2018/8/14.
//  Copyright © 2018年 biao. All rights reserved.
//

#import <UIKit/UIKit.h>

@class BGEssayDetailModel;
@interface BGEssayDetailVideoTitleView : UIView
@property (weak, nonatomic) IBOutlet UIButton *backBtn;
@property (weak, nonatomic) IBOutlet UIButton *enterHomepageBtn;
@property (weak, nonatomic) IBOutlet UIButton *concernBtn;
@property (weak, nonatomic) IBOutlet UIButton *shareBtn;

-(void)updataWithModel:(BGEssayDetailModel *)model;

@end
