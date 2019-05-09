//
//  BGVisaListCell.m
//  ShaHaiZiT
//
//  Created by biao on 2019/1/19.
//  Copyright © 2019 biao. All rights reserved.
//

#import "BGVisaListCell.h"
#import "BGVisaListModel.h"
#import <UIImageView+WebCache.h>

@interface BGVisaListCell()
@property (weak, nonatomic) IBOutlet UIImageView *imgView;
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UILabel *priceLabel;
@property (weak, nonatomic) IBOutlet UILabel *numLabel;

@end
@implementation BGVisaListCell


- (void)updataWithCellArray:(BGVisaListModel *)model{
    [self.imgView sd_setImageWithURL:[NSURL URLWithString:model.main_picture] placeholderImage:BGImage(@"img_placeholder")];
    self.priceLabel.text = model.product_price;
//    self.numLabel.text = [NSString stringWithFormat:@"月售%@  评价%@",model.book_count,model.review_count];
    
    NSMutableAttributedString *attributedStr = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"%@%@",model.visa_name,model.product_name]];
    [attributedStr setAttributes:@{NSFontAttributeName:kFont(15),NSForegroundColorAttributeName:kApp333Color} range:NSMakeRange(0, attributedStr.length)];
    [attributedStr setAttributes:@{NSFontAttributeName:kFont(16),NSForegroundColorAttributeName:kAppMainColor} range:NSMakeRange(0, model.visa_name.length)];
    
    self.nameLabel.attributedText = attributedStr;
    
}

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
