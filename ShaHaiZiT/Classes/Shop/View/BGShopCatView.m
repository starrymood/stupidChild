//
//  BGShopCatView.m
//  ShaHaiZiT
//
//  Created by biao on 2019/4/19.
//  Copyright © 2019 biao. All rights reserved.
//

#import "BGShopCatView.h"
#import <UIImageView+WebCache.h>
#import "BGShopCategoryModel.h"

@interface BGShopCatView()
@property (weak, nonatomic) IBOutlet UIImageView *oneImgView;
@property (weak, nonatomic) IBOutlet UIImageView *twoImgView;
@property (weak, nonatomic) IBOutlet UIImageView *threeImgView;
@property (weak, nonatomic) IBOutlet UIImageView *fourImgView;
@property (weak, nonatomic) IBOutlet UIImageView *fiveImgView;
@property(nonatomic,copy) NSArray *dataaArr;

@end
@implementation BGShopCatView

-(instancetype)initWithFrame:(CGRect)frame{
    if (self = [super initWithFrame:frame]) {
        NSBundle *bundle = [NSBundle bundleForClass:[self class]];
        
        NSArray *viewArray =  [bundle loadNibNamed:@"BGShopCatView" owner:self options:nil];
        
        self = viewArray[0];
        
        self.frame = frame;
        
        
    }
    return  self;
    
}
- (void)updataWithCellArray:(NSArray *)dataArr{
     if ([Tool arrayIsNotEmpty:dataArr] && dataArr.count>4) {
         self.dataaArr = [NSArray arrayWithArray:dataArr];
         self.userInteractionEnabled = YES;
         BGShopCategoryModel *oneModel = dataArr[0];
         [_oneImgView sd_setImageWithURL:[NSURL URLWithString:oneModel.main_pic]];
         BGShopCategoryModel *twoModel = dataArr[1];
         [_twoImgView sd_setImageWithURL:[NSURL URLWithString:twoModel.main_pic]];
         BGShopCategoryModel *threeModel = dataArr[2];
         [_threeImgView sd_setImageWithURL:[NSURL URLWithString:threeModel.main_pic]];
         BGShopCategoryModel *fourModel = dataArr[3];
         [_fourImgView sd_setImageWithURL:[NSURL URLWithString:fourModel.main_pic]];
         BGShopCategoryModel *fiveModel = dataArr[4];
         [_fiveImgView sd_setImageWithURL:[NSURL URLWithString:fiveModel.main_pic]];
         
         UITapGestureRecognizer * oneTap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(tapAction:)];
         [self.oneImgView addGestureRecognizer:oneTap];
         oneTap.view.tag = 3000;
         
         UITapGestureRecognizer * twoTap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(tapAction:)];
         [self.twoImgView addGestureRecognizer:twoTap];
         twoTap.view.tag = 3001;
         
         UITapGestureRecognizer * threeTap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(tapAction:)];
         [self.threeImgView addGestureRecognizer:threeTap];
         threeTap.view.tag = 3002;
         
         UITapGestureRecognizer * fourTap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(tapAction:)];
         [self.fourImgView addGestureRecognizer:fourTap];
         fourTap.view.tag = 3003;
         
         UITapGestureRecognizer * fiveTap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(tapAction:)];
         [self.fiveImgView addGestureRecognizer:fiveTap];
         fiveTap.view.tag = 3004;
         
     }
}
- (void)tapAction:(UITapGestureRecognizer *)tap{
    NSInteger imgTag = tap.view.tag - 3000;
    BGShopCategoryModel *model = self.dataaArr[imgTag];
    if (self.selectCatTapClick) {
        self.selectCatTapClick(model.ID);
    }
}

@end
