//
//  WHSessionManager.h
//  wehomec
//
//  Created by Lion on 17/2/15.
//  Copyright © 2017年 JiangHao. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface WHSessionManager : AFHTTPSessionManager

+(WHSessionManager *)sharedManager:(NSString *)token;


@end
