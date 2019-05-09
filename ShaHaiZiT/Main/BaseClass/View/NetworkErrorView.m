//
//  NetworkErrorView.m
//  
//
//
//

#import "NetworkErrorView.h"
@implementation NetworkErrorView


- (id)initWithFrame:(CGRect)frame;
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        self.backgroundColor = kAppGreyBGColor;
        self.prompImgView = [[UIImageView alloc]init];
        _prompImgView.backgroundColor = [UIColor clearColor];
        float imageSizeW = SCREEN_WIDTH*0.7;
        float imageSizeH = SCREEN_WIDTH*0.7*0.2678;

        _prompImgView.frame = CGRectMake((frame.size.width - imageSizeW)/2, frame.size.height * 0.14, imageSizeW, imageSizeH);
        [self addSubview:_prompImgView];
        
        UILabel *titleLabel = [[UILabel alloc]initWithFrame:CGRectMake(0,CGRectGetMaxY( _prompImgView.frame)+ 44 , frame.size.width, 40)];
        titleLabel.text = noNetWorkmessage;
        titleLabel.backgroundColor = [UIColor clearColor];
        titleLabel.textAlignment = NSTextAlignmentCenter;
        titleLabel.font = [UIFont systemFontOfSize:16];
        titleLabel.textColor = kApp333Color;
        titleLabel.adjustsFontSizeToFitWidth = YES;
        titleLabel.numberOfLines = 0;
        [self addSubview:titleLabel];
        
        self.prompLabel = [[UILabel alloc]initWithFrame:CGRectMake(0,CGRectGetMaxY( titleLabel.frame)+ 22 , frame.size.width, 40)];
        _prompLabel.backgroundColor = [UIColor clearColor];
        _prompLabel.textAlignment = NSTextAlignmentCenter;
        _prompLabel.font = [UIFont systemFontOfSize:15];
        _prompLabel.textColor = kApp999Color;
        _prompLabel.adjustsFontSizeToFitWidth = YES;
        _prompLabel.numberOfLines = 0;
//        [self addSubview:_prompLabel];
        
        
        self.reloadDataButton = [[UIButton alloc]initWithFrame:CGRectMake((frame.size.width - 190)/2, CGRectGetMaxY( _prompLabel.frame)+frame.size.height * 0.1, 190, 45)];
        self.reloadDataButton.layer.masksToBounds = YES;
        self.reloadDataButton.layer.cornerRadius = _reloadDataButton.frame.size.height*0.5;
        [_reloadDataButton setTitle:@"重新加载" forState:UIControlStateNormal];
        [_reloadDataButton setTitleColor:kAppWhiteColor forState:UIControlStateNormal];
        [_reloadDataButton setBackgroundImage:BGImage(@"btn_bgColor") forState:UIControlStateNormal];
        [_reloadDataButton addTarget:self action:@selector(reloadDataSeleted:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:_reloadDataButton];
        
    }
    return self;
}

- (void)reloadDataSeleted:(id)sender
{
    if(self.delegate){
        [self.delegate reloadDataButtonSelected:sender networkErrorView:self];
    }
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

@end
