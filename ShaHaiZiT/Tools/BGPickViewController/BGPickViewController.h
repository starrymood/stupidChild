//
//  BGPickViewController.h
//  LLMall
//
//  Created by biao on 2016/11/18.
//  Copyright © 2016年 ZZLL. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol pickViewDelegate <NSObject>
@optional
- (void) getTextStr:(NSString *)text;
- (void) getTextStr:(NSString *)text index:(NSInteger)index;
@end

@interface BGPickViewController : UIViewController<UIPickerViewDataSource,UIPickerViewDelegate>

@property (nonatomic, unsafe_unretained) id<pickViewDelegate> delegate;
@property (nonatomic, weak) IBOutlet UIPickerView *pickView;
@property (nonatomic, strong) NSMutableArray *arry;
@property (nonatomic, strong) NSString *chooseText;
@property (nonatomic, weak) IBOutlet UIView *TEST;
@end
