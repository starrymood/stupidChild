//
//  BGPostCommentCell.m
//  shzTravelC
//
//  Created by biao on 2018/6/27.
//  Copyright © 2018年 biao. All rights reserved.
//

#import "BGPostCommentCell.h"
#import "BGShopModel.h"
#import <UIImageView+WebCache.h>
#import <UIButton+WebCache.h>

@interface BGPostCommentCell()<UITextViewDelegate>
@property (weak, nonatomic) IBOutlet UIImageView *goodsImgView;
@property (weak, nonatomic) IBOutlet UILabel *goodsNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *goodsSpecsLabel;
@property (weak, nonatomic) IBOutlet UILabel *goodsPriceLabel;
@property (weak, nonatomic) IBOutlet UITextView *textView;
@property (weak, nonatomic) IBOutlet UIButton *imgBtn1;
@property (weak, nonatomic) IBOutlet UIButton *imgBtn2;
@property (weak, nonatomic) IBOutlet UIButton *imgBtn3;
@property (weak, nonatomic) IBOutlet UIButton *delBtn1;
@property (weak, nonatomic) IBOutlet UIButton *delBtn2;
@property (weak, nonatomic) IBOutlet UIButton *delBtn3;

@property (nonatomic, strong) UILabel *placeholderLabel;

@end
@implementation BGPostCommentCell


- (void)updataWithCellArray:(NSDictionary *)dic picArr:(NSMutableArray *)picArr contentStr:(NSString *)contentStr{
    BGShopModel *model = [BGShopModel mj_objectWithKeyValues:dic];
     [self.goodsImgView sd_setImageWithURL:[NSURL URLWithString:model.goods_picture] placeholderImage:BGImage(@"img_placeholder")];
      self.goodsNameLabel.text = model.name;
    self.goodsSpecsLabel.text = model.norm_name;
    self.goodsPriceLabel.text = [NSString stringWithFormat:@"¥ %.2f",model.price.doubleValue];
    if ([Tool isBlankString:contentStr]) {
        self.textView.text = @"";
    }else{
        self.textView.text = contentStr;
        [_placeholderLabel setHidden:YES];
    }
    
    _textView.delegate = self;
    switch (picArr.count) {
        case 0:{
            [_imgBtn1 setBackgroundImage:BGImage(@"comment_picture") forState:(UIControlStateNormal)];
            [_imgBtn2 setBackgroundImage:BGImage(@"comment_picture") forState:(UIControlStateNormal)];
            [_imgBtn3 setBackgroundImage:BGImage(@"comment_picture") forState:(UIControlStateNormal)];
            _imgBtn1.hidden = NO;
            _imgBtn2.hidden = YES;
            _imgBtn3.hidden = YES;
            _imgBtn1.userInteractionEnabled = YES;
            _imgBtn2.userInteractionEnabled = YES;
            _imgBtn3.userInteractionEnabled = YES;
            _delBtn1.hidden = YES;
            _delBtn2.hidden = YES;
            _delBtn3.hidden = YES;
        }
            break;
        case 1:{
            [_imgBtn1 sd_setBackgroundImageWithURL:[NSURL URLWithString:picArr[0]] forState:(UIControlStateNormal) placeholderImage:BGImage(@"comment_picture")];
            [_imgBtn2 setBackgroundImage:BGImage(@"comment_picture") forState:(UIControlStateNormal)];
            [_imgBtn3 setBackgroundImage:BGImage(@"comment_picture") forState:(UIControlStateNormal)];
            _imgBtn1.hidden = NO;
            _imgBtn2.hidden = NO;
            _imgBtn3.hidden = YES;
            _imgBtn1.userInteractionEnabled = NO;
            _imgBtn2.userInteractionEnabled = YES;
            _imgBtn3.userInteractionEnabled = YES;
            _delBtn1.hidden = NO;
            _delBtn2.hidden = YES;
            _delBtn3.hidden = YES;
        }
            break;
        case 2:{
            [_imgBtn1 sd_setBackgroundImageWithURL:[NSURL URLWithString:picArr[0]] forState:(UIControlStateNormal) placeholderImage:BGImage(@"comment_picture")];
            [_imgBtn2 sd_setBackgroundImageWithURL:[NSURL URLWithString:picArr[1]] forState:(UIControlStateNormal) placeholderImage:BGImage(@"comment_picture")];
            [_imgBtn3 setBackgroundImage:BGImage(@"comment_picture") forState:(UIControlStateNormal)];
            _imgBtn1.hidden = NO;
            _imgBtn2.hidden = NO;
            _imgBtn3.hidden = NO;
            _imgBtn1.userInteractionEnabled = NO;
            _imgBtn2.userInteractionEnabled = NO;
            _imgBtn3.userInteractionEnabled = YES;
            _delBtn1.hidden = NO;
            _delBtn2.hidden = NO;
            _delBtn3.hidden = YES;
        }
            break;
        case 3:{
            [_imgBtn1 sd_setBackgroundImageWithURL:[NSURL URLWithString:picArr[0]] forState:(UIControlStateNormal) placeholderImage:BGImage(@"comment_picture")];
            [_imgBtn2 sd_setBackgroundImageWithURL:[NSURL URLWithString:picArr[1]] forState:(UIControlStateNormal) placeholderImage:BGImage(@"comment_picture")];
            [_imgBtn3 sd_setBackgroundImageWithURL:[NSURL URLWithString:picArr[2]] forState:(UIControlStateNormal) placeholderImage:BGImage(@"comment_picture")];
            _imgBtn1.hidden = NO;
            _imgBtn2.hidden = NO;
            _imgBtn3.hidden = NO;
            _imgBtn1.userInteractionEnabled = NO;
            _imgBtn2.userInteractionEnabled = NO;
            _imgBtn3.userInteractionEnabled = NO;
            _delBtn1.hidden = NO;
            _delBtn2.hidden = NO;
            _delBtn3.hidden = NO;
        }
            break;
            
        default:
            break;
    }
}

- (void)awakeFromNib {
    [super awakeFromNib];

    self.placeholderLabel = [[UILabel alloc] initWithFrame:CGRectMake(3, 3, SCREEN_WIDTH-20-6, 44)];
    _placeholderLabel.enabled = NO;
    _placeholderLabel.text = @"亲，您对这个商品还满意么？\n您的评价会帮助我们选择更好的产品哦~";
    _placeholderLabel.numberOfLines = 0;
    _placeholderLabel.font = kFont(13);
    _placeholderLabel.textColor = kApp999Color;
    [_textView addSubview:_placeholderLabel];
}
#pragma mark - UITextView -
-(void)textViewDidChange:(UITextView *)textView
{
    if ([textView.text length] == 0) {
        [_placeholderLabel setHidden:NO];
    }else{
        [_placeholderLabel setHidden:YES];
    }
    [self wordLimit: textView];
}
-(BOOL)wordLimit:(UITextView *)text {
    
    if (text.text.length > 300) {
        [WHIndicatorView toast:@"请输入小于300个文字"];
        NSString *s = [text.text substringToIndex:300];
        text.text = s;
    }
    return nil;
}
-(void)textViewDidEndEditing:(UITextView *)textView{
    if (self.textViewDone) {
        self.textViewDone(textView.text);
    }
}
- (IBAction)btnUploadImgClicked:(UIButton *)sender {
    if (self.uploadImgClicked) {
        self.uploadImgClicked();
    }
}
- (IBAction)btnDelImgClicked:(UIButton *)sender {
    if (self.delImgClicked) {
        self.delImgClicked(sender.tag-110);
    }
}


- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
