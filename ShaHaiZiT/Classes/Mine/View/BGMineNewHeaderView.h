//
//  BGMineNewHeaderView.h
//  ShaHaiZiT
//
//  Created by biao on 2018/12/28.
//  Copyright © 2018 biao. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface BGMineNewHeaderView : UIView

@property (weak, nonatomic) IBOutlet UIButton *editBtn;
@property (weak, nonatomic) IBOutlet UIButton *settingBtn;
@property (weak, nonatomic) IBOutlet UILabel *loginLabel;
@property (weak, nonatomic) IBOutlet UIButton *loginBtn;
@property (weak, nonatomic) IBOutlet UIView *clearView;
@property (weak, nonatomic) IBOutlet UIImageView *headImgView;
@property (weak, nonatomic) IBOutlet UILabel *mineNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *shzIdLabel;
@property (weak, nonatomic) IBOutlet UILabel *concernLabel;
@property (weak, nonatomic) IBOutlet UILabel *fansLabel;
@property (weak, nonatomic) IBOutlet UILabel *collectedLabel;
@property (weak, nonatomic) IBOutlet UILabel *likeLabel;
@property (weak, nonatomic) IBOutlet UIImageView *levelImgView;
@property (weak, nonatomic) IBOutlet UILabel *integralLabel;
@property (weak, nonatomic) IBOutlet UILabel *inviteCountLabel;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *messageBtnTop;

@property (nonatomic,copy) void(^headImgBtnClick)(void);
@property (nonatomic,copy) void(^attentionBtnClick)(void);
@property (nonatomic,copy) void(^fansBtnClick)(void);
@property (nonatomic,copy) void(^editBtnClick)(void);
@property (nonatomic,copy) void(^settingBtnClick)(void);
@property (nonatomic,copy) void(^recommendBtnClick)(void);

@end

NS_ASSUME_NONNULL_END
