//
//  BGEssayEasyCell.m
//  ShaHaiZiT
//
//  Created by biao on 2018/11/25.
//  Copyright © 2018 biao. All rights reserved.
//

#import "BGEssayEasyCell.h"
#import "BGEssayCommentFirstModel.h"

@interface BGEssayEasyCell()

@property (weak, nonatomic) IBOutlet UILabel *easyContentLabel;

@end
@implementation BGEssayEasyCell

- (void)updataWithCellArray:(BGEssayCommentFirstModel *)model{
    
    self.easyContentLabel.text = [NSString stringWithFormat:@"%@：%@",model.nickname,model.review_body];
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
