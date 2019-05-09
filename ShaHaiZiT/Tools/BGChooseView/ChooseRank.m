//
//  ChooseRank.m
//  LvjFarm
//
//  Created by 张仁昊 on 16/4/20.
//  Copyright © 2016年 _____ZXHY_____. All rights reserved.
//

#import "ChooseRank.h"
#import "BGShopCategoryModel.h"

@interface ChooseRank()
@property(nonatomic,strong)UIButton *selectBtn;

@property(nonatomic,strong)UIView *packView;
@property(nonatomic,copy) NSArray *cellDataArr;

@end
@implementation ChooseRank


-(instancetype)initWithTitleArr:(NSArray *)titleArr andFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if (self) {

        self.frame = frame;
        if ([Tool arrayIsNotEmpty:titleArr]) {
            self.cellDataArr = [NSArray arrayWithArray:titleArr];
            [self rankView];
        }else{
            [self addNumView];
        }
       
    }
    return self;
}

-(void)addNumView{
    
    self.packView = [[UIView alloc] initWithFrame:self.frame];
    self.packView.y = 0;
    
    UILabel *line = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, 0.5)];
    line.backgroundColor = kAppLineBGColor;
    [self.packView addSubview:line];
    
    UILabel *titleLB = [[UILabel alloc] initWithFrame:CGRectMake(20, 12, 70, 25)];
    titleLB.text = @"购买数量";
    titleLB.font = kFont(13);
    titleLB.textColor = kApp666Color;
    [self.packView addSubview:titleLB];
    
    _numBtn = [[BGAjustNumButton alloc] init];
    [_numBtn setFrame:CGRectMake(SCREEN_WIDTH-20-100, 12, 100, 25)];
    _numBtn.currentNum = @"1";
    _numBtn.lineColor = [UIColor lightGrayColor];
    [self.packView addSubview:_numBtn];
    
    [self addSubview:self.packView];
}
-(void)rankView{
    
    self.packView = [[UIView alloc] initWithFrame:self.frame];
    self.packView.y = 0;
    
    UILabel *line = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, 0.5)];
    line.backgroundColor = kAppLineBGColor;
    [self.packView addSubview:line];
    
    self.btnView = [[UIView alloc] initWithFrame:CGRectMake(0,0, SCREEN_WIDTH, 40)];
    [self.packView addSubview:self.btnView];
    
    int count = 0;
    float btnWidth = 0;
    float viewHeight = 0;
    
    for (int i = 0; i < self.cellDataArr.count; i++) {
        BGShopCategoryModel *model = _cellDataArr[i];
        NSString *btnName = model.name;
        
        UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
        [btn setBackgroundColor:[UIColor whiteColor]];
        [btn setTitleColor:kApp666Color forState:UIControlStateNormal];
        [btn setTitleColor:kAppWhiteColor forState:UIControlStateSelected];

        btn.layer.borderWidth = 0.5;
        btn.layer.borderColor = kAppMainColor.CGColor;

        btn.titleLabel.font = kFont(13);
        [btn setTitle:btnName forState:UIControlStateNormal];
        [btn addTarget:self action:@selector(btnClick:) forControlEvents:UIControlEventTouchUpInside];
        
        
        btn.layer.masksToBounds = YES;
        
        NSDictionary *dict = [NSDictionary dictionaryWithObject:kFont(13) forKey:NSFontAttributeName];
        CGSize btnSize = [btnName sizeWithAttributes:dict];
        
        btn.width = btnSize.width + 30;
        btn.height = btnSize.height + 16;
        btn.layer.cornerRadius = 12;
        
        if (i==0)
        {
            btn.x = 20;
            btnWidth += CGRectGetMaxX(btn.frame);
        }
        else{
            btnWidth += CGRectGetMaxX(btn.frame)+20;
            if (btnWidth > SCREEN_WIDTH) {
                count++;
                btn.x = 20;
                btnWidth = CGRectGetMaxX(btn.frame);
            }
            else{
                
                btn.x += btnWidth - btn.width;
            }
        }
        btn.y += count * (btn.height+10)+10;
        
        viewHeight = CGRectGetMaxY(btn.frame)+10;
        
        [self.btnView addSubview:btn];
        
        btn.tag = 10000+i;
 
    }
    self.btnView.height = viewHeight;
    self.packView.height = self.btnView.height;

    self.height = self.packView.height;
    
    [self addSubview:self.packView];
}


-(void)btnClick:(UIButton *)btn{
    
    
    if (![self.selectBtn isEqual:btn]) {
        
        self.selectBtn.backgroundColor = [UIColor whiteColor];
        self.selectBtn.selected = NO;
        btn.backgroundColor = kAppMainColor;
        btn.selected = YES;
        self.selectBtn = btn;
    }
    else{
        [btn setBackgroundColor:[UIColor whiteColor]];
        btn.selected = NO;
        self.selectBtn = nil;
    }
   
    if ([self.delegate respondsToSelector:@selector(selectBtn:)]) {
        
        [self.delegate selectBtn:self.selectBtn];
    }
}


@end







