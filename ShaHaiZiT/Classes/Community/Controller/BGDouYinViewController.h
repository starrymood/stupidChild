//
//  BGDouYinViewController.h
//  ShaHaiZiT
//
//  Created by biao on 2019/1/20.
//  Copyright © 2019 biao. All rights reserved.
//

#import "BGBaseViewController.h"

NS_ASSUME_NONNULL_BEGIN

typedef void(^refreshEditBlock)(void);
@interface BGDouYinViewController : BGBaseViewController

- (void)playTheIndex:(NSInteger)index;
@property(nonatomic,strong) NSArray *dataArr;
@property(nonatomic,copy) NSString *pageNum;
@property (nonatomic, copy) NSString *classification_id;

@property(nonatomic,copy) NSString *postID;
@property(nonatomic,assign) BOOL isSingle;
@property (nonatomic, copy) refreshEditBlock refreshEditBlock;

@end

NS_ASSUME_NONNULL_END
