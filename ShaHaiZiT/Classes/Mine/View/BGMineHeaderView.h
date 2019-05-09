//
//  BGMineHeaderView.h
//  shzTravelC
//
//  Created by biao on 2018/7/18.
//  Copyright © 2018年 biao. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface BGMineHeaderView : UIView
@property (weak, nonatomic) IBOutlet UILabel *loginLabel;
@property (weak, nonatomic) IBOutlet UIButton *loginBtn;
@property (weak, nonatomic) IBOutlet UIView *clearView;
@property (weak, nonatomic) IBOutlet UIImageView *headImgView;
@property (weak, nonatomic) IBOutlet UILabel *mineNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *shzIdLabel;
@property (weak, nonatomic) IBOutlet UILabel *mineAutographLabel;
@property (weak, nonatomic) IBOutlet UILabel *concernLabel;
@property (weak, nonatomic) IBOutlet UILabel *fansLabel;
@property (weak, nonatomic) IBOutlet UILabel *collectedLabel;
@property (weak, nonatomic) IBOutlet UILabel *likeLabel;

@property (nonatomic,copy) void(^headImgBtnClick)(void);
@property (nonatomic,copy) void(^attentionBtnClick)(void);
@property (nonatomic,copy) void(^fansBtnClick)(void);


@end
