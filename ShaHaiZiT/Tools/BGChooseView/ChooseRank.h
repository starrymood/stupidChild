//
//  ChooseRank.h
//  LvjFarm
//
//  Created by 张仁昊 on 16/4/20.
//  Copyright © 2016年 _____ZXHY_____. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BGAjustNumButton.h"

@protocol ChooseRankDelegate <NSObject>
@required
-(void)selectBtn:(UIButton *)btn;

@end

@interface ChooseRank : UIView
@property(nonatomic,strong)UIView *btnView;


@property(nonatomic,assign)id<ChooseRankDelegate> delegate;

@property (nonatomic,strong) BGAjustNumButton *numBtn;

-(instancetype)initWithTitleArr:(NSArray *)titleArr andFrame:(CGRect)frame;


@end


