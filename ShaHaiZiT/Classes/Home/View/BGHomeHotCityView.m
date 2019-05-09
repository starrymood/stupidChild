//
//  BGHomeHotCityView.m
//  ShaHaiZiT
//
//  Created by biao on 2019/4/14.
//  Copyright © 2019 biao. All rights reserved.
//

#import "BGHomeHotCityView.h"
#import <UIImageView+WebCache.h>
#import "BGHomeHotAreaModel.h"

@interface BGHomeHotCityView()
@property (weak, nonatomic) IBOutlet UIImageView *oneImgView;
@property (weak, nonatomic) IBOutlet UIImageView *twoImgView;
@property (weak, nonatomic) IBOutlet UIImageView *threeImgView;
@property (weak, nonatomic) IBOutlet UIImageView *fourImgView;
@property (weak, nonatomic) IBOutlet UILabel *oneALabel;
@property (weak, nonatomic) IBOutlet UILabel *oneBLabel;
@property (weak, nonatomic) IBOutlet UILabel *twoALabel;
@property (weak, nonatomic) IBOutlet UILabel *twoBLabel;
@property (weak, nonatomic) IBOutlet UILabel *threeALabel;
@property (weak, nonatomic) IBOutlet UILabel *threeBLabel;
@property (weak, nonatomic) IBOutlet UILabel *fourALabel;
@property (weak, nonatomic) IBOutlet UILabel *fourBLabel;
@property(nonatomic,copy) NSArray *dataaArr;


@end
@implementation BGHomeHotCityView

-(instancetype)initWithFrame:(CGRect)frame{
    if (self = [super initWithFrame:frame]) {
        NSBundle *bundle = [NSBundle bundleForClass:[self class]];
        
        NSArray *viewArray =  [bundle loadNibNamed:@"BGHomeHotCityView" owner:self options:nil];
        
        self = viewArray[0];
        
        self.frame = frame;
        
        
    }
    return  self;
    
}
- (void)updataWithCellArray:(NSArray *)dataArr{
    if ([Tool arrayIsNotEmpty:dataArr]) {
        if (dataArr.count>3) {
            self.dataaArr = [NSArray arrayWithArray:dataArr];
            UITapGestureRecognizer * oneTap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(tapAction:)];
            [self.oneImgView addGestureRecognizer:oneTap];
            oneTap.view.tag = 1000;
            
            
            UITapGestureRecognizer * twoTap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(tapAction:)];
            [self.twoImgView addGestureRecognizer:twoTap];
            twoTap.view.tag = 1001;
            
            
            UITapGestureRecognizer * threeTap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(tapAction:)];
            [self.threeImgView addGestureRecognizer:threeTap];
            threeTap.view.tag = 1002;
            
            
            UITapGestureRecognizer * fourTap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(tapAction:)];
            [self.fourImgView addGestureRecognizer:fourTap];
            fourTap.view.tag = 1003;
            
            
            BGHomeHotAreaModel *oneModel = dataArr[0];
            [self.oneImgView sd_setImageWithURL:[NSURL URLWithString:oneModel.picture]];
            self.oneALabel.text = oneModel.region_name;
            self.oneBLabel.text = oneModel.recommendation;
            
            BGHomeHotAreaModel *twoModel = dataArr[1];
            [self.twoImgView sd_setImageWithURL:[NSURL URLWithString:twoModel.picture]];
            self.twoALabel.text = twoModel.region_name;
            self.twoBLabel.text = twoModel.recommendation;
            
            BGHomeHotAreaModel *threeModel = dataArr[2];
            [self.threeImgView sd_setImageWithURL:[NSURL URLWithString:threeModel.picture]];
            self.threeALabel.text = threeModel.region_name;
            self.threeBLabel.text = threeModel.recommendation;
            
            BGHomeHotAreaModel *fourModel = dataArr[3];
            [self.fourImgView sd_setImageWithURL:[NSURL URLWithString:fourModel.picture]];
            self.fourALabel.text = fourModel.region_name;
            self.fourBLabel.text = fourModel.recommendation;
        }
    }
}

- (void)tapAction:(UITapGestureRecognizer *)tap{
    NSInteger imgTag = tap.view.tag - 1000;
    BGHomeHotAreaModel *model = self.dataaArr[imgTag];
    if (self.selectCityTapClick) {
        self.selectCityTapClick(model.region_id);
    }
}

@end
