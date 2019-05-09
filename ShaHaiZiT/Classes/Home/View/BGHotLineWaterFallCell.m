//
//  BGHotLineWaterFallCell.m
//  ShaHaiZiT
//
//  Created by biao on 2018/10/19.
//  Copyright © 2018年 biao. All rights reserved.
//

#import "BGHotLineWaterFallCell.h"
#import "BGAirProductModel.h"
#import "UIImageView+WebCache.h"

@interface BGHotLineWaterFallCell()
@property (weak, nonatomic) IBOutlet UIImageView *imgView;
@property (weak, nonatomic) IBOutlet UILabel *titleeLabel;
@property (weak, nonatomic) IBOutlet UILabel *detailTitleLabel;
@property (weak, nonatomic) IBOutlet UILabel *priceLabel;
@property (weak, nonatomic) IBOutlet UILabel *orderNumLabel;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *imgBottomDistance;


@end
@implementation BGHotLineWaterFallCell

- (void)updataWithCellArray:(BGAirProductModel *)model{
    NSInteger lineNum = [self needLinesWithWidth:(self.width-16) text:model.product_introduction];
    switch (lineNum) {
        case 1:
            self.imgBottomDistance.constant = 85;
            self.detailTitleLabel.numberOfLines = 1;
            break;
        case 2:
            self.imgBottomDistance.constant = 96;
            self.detailTitleLabel.numberOfLines = 2;
            break;
            
        default:
            self.imgBottomDistance.constant = 109;
            self.detailTitleLabel.numberOfLines = 3;
            break;
    }
    
    [self.imgView sd_setImageWithURL:[NSURL URLWithString:model.main_picture] placeholderImage:BGImage(@"img_placeholder")];
    self.titleeLabel.text = model.product_name;
    self.detailTitleLabel.text = model.product_introduction;
    self.priceLabel.text = model.product_price;
//    NSMutableAttributedString *attributedBookStr = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"已预订%@次",model.book_count]];
//    [attributedBookStr setAttributes:@{NSFontAttributeName:kFont(9),NSForegroundColorAttributeName:kApp999Color} range:NSMakeRange(0, attributedBookStr.length-2)];
//    [attributedBookStr setAttributes:@{NSFontAttributeName:kFont(9),NSForegroundColorAttributeName:UIColorFromRGB(0xFF4848)} range:NSMakeRange(3, attributedBookStr.length-4)];
//    
//    self.orderNumLabel.attributedText = attributedBookStr;
    
}


- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}
/**
 显示当前文字需要几行
 
 @param width 给定一个宽度
 @return 返回行数
 */
- (NSInteger)needLinesWithWidth:(CGFloat)width text:(NSString *)text{
    //创建一个labe
    UILabel * label = [[UILabel alloc]init];
    //font和当前label保持一致
    label.font = kFont(10);
    NSInteger sum = 0;
    //总行数受换行符影响，所以这里计算总行数，需要用换行符分隔这段文字，然后计算每段文字的行数，相加即是总行数。
    NSArray * splitText = [text componentsSeparatedByString:@"\n"];
    for (NSString * sText in splitText) {
        label.text = sText;
        //获取这段文字一行需要的size
        CGSize textSize = [label systemLayoutSizeFittingSize:CGSizeZero];
        //size.width/所需要的width 向上取整就是这段文字占的行数
        NSInteger lines = ceilf(textSize.width/width);
        //当是0的时候，说明这是换行，需要按一行算。
        lines = lines == 0?1:lines;
        sum += lines;
    }
    return sum;
}
@end
