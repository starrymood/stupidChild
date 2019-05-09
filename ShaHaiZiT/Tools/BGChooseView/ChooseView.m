//
//  ChooseView.m
//  LvjFarm
//
//  Created by 张仁昊 on 16/4/14.
//  Copyright © 2016年 _____ZXHY_____. All rights reserved.
//

#import "ChooseView.h"

@interface ChooseView ()

//规格分类
@property(nonatomic,strong)NSArray *rankArr;

@end

@implementation ChooseView

@synthesize whiteView,headImage,LB_detail,LB_line,LB_price,LB_stock,mainscrollview,cancelBtn,buyBtn,stockBtn;

-(instancetype)initWithFrame:(CGRect)frame{
    
    self = [super initWithFrame:frame];
    
    if (self) {
        
        self.backgroundColor = [UIColor clearColor];

        [self creatUI];

    }
    return self;
}



-(void)creatUI{
    
    //装载商品信息的视图
    whiteView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT-280-SafeAreaBottomHeight)];
    whiteView.backgroundColor = [UIColor whiteColor];
    [self addSubview:whiteView];
    
    //商品图片
    headImage = [[UIImageView alloc] initWithFrame:CGRectMake(20, -10, 90, 90)];
    headImage.image = [UIImage imageNamed:@"img_placeholder"];
    headImage.layer.cornerRadius = 4;
    headImage.layer.borderColor = kAppLineBGColor.CGColor;
    headImage.layer.borderWidth = 1;
    [headImage.layer setMasksToBounds:YES];
    [whiteView addSubview:headImage];
    
    cancelBtn= [UIButton buttonWithType:UIButtonTypeCustom];
    cancelBtn.frame = CGRectMake(SCREEN_WIDTH-40, 10, 25, 25);
    [cancelBtn setImage:BGImage(@"sharing_courtesy_close") forState:0];
    [whiteView addSubview:cancelBtn];
    
    
    //商品价格
    LB_price = [[UILabel alloc] initWithFrame:CGRectMake(CGRectGetMaxX(headImage.frame)+20, 10, 150, 20)];
    LB_price.text = @"¥";
    LB_price.textColor = kAppRedColor;
    LB_price.font = [UIFont fontWithName:@"Arial" size:16];
    [whiteView addSubview:LB_price];
    //商品库存
    LB_stock = [[UILabel alloc] initWithFrame:CGRectMake(CGRectGetMaxX(headImage.frame)+20, CGRectGetMaxY(LB_price.frame), 160, 20)];
    LB_stock.text = @"库存0件";
    LB_stock.textColor = kApp666Color;
    LB_stock.font = [UIFont systemFontOfSize:13];
    [whiteView addSubview:LB_stock];
    
    
    //用户所选择商品的尺码和颜色
    LB_detail = [[UILabel alloc] initWithFrame:CGRectMake(CGRectGetMaxX(headImage.frame)+20, CGRectGetMaxY(LB_stock.frame), SCREEN_WIDTH-CGRectGetMaxX(headImage.frame)-20-20, 20)];
    LB_detail.text = @"请选择商品规格";
    LB_detail.numberOfLines = 0;
    LB_detail.textColor = kApp666Color;
    LB_detail.font = [UIFont systemFontOfSize:13];
    if (IS_iPhone5) {
        LB_detail.width = 100;
        LB_detail.font = [UIFont systemFontOfSize:11];
    }
    [whiteView addSubview:LB_detail];
    //分界线
    LB_line = [[UILabel alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(headImage.frame)+10, SCREEN_WIDTH, 0.5)];
    LB_line.backgroundColor = [UIColor whiteColor];
    [whiteView addSubview:LB_line];
    
    //立即购买按钮
    buyBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    buyBtn.frame = CGRectMake(0,  whiteView.height-40, whiteView.width, 40);
    [buyBtn setBackgroundColor:kAppMainColor];
    [buyBtn setTitleColor:[UIColor whiteColor] forState:0];
    buyBtn.titleLabel.font = [UIFont systemFontOfSize:15];
    [buyBtn setTitle:@"确定" forState:0];
    [whiteView addSubview:buyBtn];
    
    //库存不足按钮
    stockBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    stockBtn.frame = CGRectMake(0,  whiteView.height-40, SCREEN_WIDTH, 40);
    [stockBtn setBackgroundColor:[UIColor lightGrayColor]];
    [stockBtn setTitleColor:[UIColor blackColor] forState:0];
    stockBtn.titleLabel.font = [UIFont systemFontOfSize:15];
    [stockBtn setTitle:@"库存不足" forState:0];
    [whiteView addSubview:stockBtn];
    //默认隐藏
    stockBtn.hidden = YES;
    
    //有的商品尺码和颜色分类特别多 所以用UIScrollView 分类过多显示不全的时候可滑动查看
    mainscrollview = [[UIScrollView alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(headImage.frame)+10, SCREEN_WIDTH, whiteView.height-CGRectGetMaxY(headImage.frame)+10-60)];
    mainscrollview.backgroundColor = [UIColor clearColor];
    mainscrollview.contentSize = CGSizeMake(0, 200);
    mainscrollview.showsHorizontalScrollIndicator = NO;
    mainscrollview.showsVerticalScrollIndicator = NO;
    [whiteView addSubview:mainscrollview];

}




@end








