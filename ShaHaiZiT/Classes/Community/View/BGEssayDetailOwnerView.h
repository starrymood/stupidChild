//
//  BGEssayDetailOwnerView.h
//  shzTravelC
//
//  Created by biao on 2018/7/27.
//  Copyright © 2018年 biao. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface BGEssayDetailOwnerView : UIView
@property (weak, nonatomic) IBOutlet UIImageView *headImgView;
@property (weak, nonatomic) IBOutlet UILabel *nickNameLabel;
@property (weak, nonatomic) IBOutlet UIButton *enterHomepageBtn;
@property (weak, nonatomic) IBOutlet UIButton *concernBtn;
@property (weak, nonatomic) IBOutlet UILabel *contentLabel;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *contentLabelHeight;
@property (weak, nonatomic) IBOutlet UILabel *commentNumLabel;
@property (weak, nonatomic) IBOutlet UIButton *commentListBtn;
@property (weak, nonatomic) IBOutlet UILabel *createTimeLabel;

@end
