//
//  ChooseView.h
//  LvjFarm
//
//  Created by 张仁昊 on 16/4/14.
//  Copyright © 2016年 _____ZXHY_____. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ChooseView : UIView


@property(nonatomic,strong)UIView *whiteView;

@property(nonatomic,strong)UIImageView *headImage;

@property(nonatomic,strong)UILabel *LB_price;
@property(nonatomic,strong)UILabel *LB_stock;
@property(nonatomic,strong)UILabel *LB_detail;
@property(nonatomic,strong)UILabel *LB_line;


@property(nonatomic,copy)NSString *price;
@property(nonatomic,copy)NSString *stock;
@property(nonatomic,copy)NSString *detail;

@property(nonatomic,strong)UIScrollView *mainscrollview;


@property(nonatomic,strong)UIButton *cancelBtn;
@property(nonatomic,strong)UIButton *buyBtn;
@property(nonatomic,strong)UIButton *stockBtn;

@property(nonatomic,assign) int typeCount;

@property(nonatomic,strong)UIButton *selectBtn;



-(instancetype)initWithFrame:(CGRect)frame;


@end



