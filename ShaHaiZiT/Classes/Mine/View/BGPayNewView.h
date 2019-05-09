//
//  BGPayNewView.h
//  ShaHaiZiT
//
//  Created by biao on 2018/11/27.
//  Copyright © 2018 biao. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface BGPayNewView : UIView
@property (weak, nonatomic) IBOutlet UIButton *payCancelBtn;
@property (weak, nonatomic) IBOutlet UILabel *payOrderTypeLabel;
@property (weak, nonatomic) IBOutlet UILabel *payTypeLabel;
@property (weak, nonatomic) IBOutlet UIButton *payPayBtn;
@property (weak, nonatomic) IBOutlet UIButton *paySelectBtn;

@end

NS_ASSUME_NONNULL_END
