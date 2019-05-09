//
//  BGMyBankCardModel.h
//  shzTravelS
//
//  Created by 孙林茂 on 2018/5/28.
//  Copyright © 2018年 biao. All rights reserved.
//

#import "BGBaseModel.h"

@interface BGMyBankCardModel : BGBaseModel


@property (nonatomic, copy) NSString *background_url;
@property (nonatomic, copy) NSString *bank_number;
@property (nonatomic, copy) NSString *ID;
@property(nonatomic,copy) NSString *name;
@property(nonatomic,copy) NSString *is_default;

@end
