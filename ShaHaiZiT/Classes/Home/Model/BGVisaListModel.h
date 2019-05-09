//
//  BGVisaListModel.h
//  ShaHaiZiT
//
//  Created by biao on 2019/1/19.
//  Copyright © 2019 biao. All rights reserved.
//

#import "BGBaseModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface BGVisaListModel : BGBaseModel

@property(nonatomic,copy) NSString *review_count;
@property(nonatomic,copy) NSString *main_picture;
@property(nonatomic,copy) NSString *product_name;
@property(nonatomic,copy) NSString *ID;
@property(nonatomic,copy) NSString *product_price;
@property(nonatomic,copy) NSString *visa_name;
@property(nonatomic,copy) NSString *book_count;

@end

NS_ASSUME_NONNULL_END
