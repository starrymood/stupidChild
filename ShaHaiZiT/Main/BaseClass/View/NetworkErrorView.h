//
//  NetworkErrorView.h
//  
//
//  没有数据和请求失败页面

#import <UIKit/UIKit.h>

@protocol reloadDataButtonSelectionDelegate <NSObject>

- (void)reloadDataButtonSelected:(id)sender networkErrorView:(UIView*)view;

@end

@interface NetworkErrorView : UIView

@property(nonatomic, weak) id <reloadDataButtonSelectionDelegate> delegate;
@property (nonatomic,strong) UILabel *prompLabel;

@property (nonatomic,strong) UIView *lineview;

@property (nonatomic,strong) UIButton *reloadDataButton;
@property (nonatomic,strong) UIImageView *prompImgView;

- (id)initWithFrame:(CGRect)frame;

@end
