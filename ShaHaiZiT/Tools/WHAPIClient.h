//
//  WHAPIClient.h
//  wehomec
//
//  Created by spikedeng on 2017/3/7.
//  Copyright © 2017年 JiangHao. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface WHAPIClient : NSObject

+ (NSURLSessionDataTask *)GET:(NSString *)url param:(NSMutableDictionary *)param tokenType:(int)type succ:(processSuccResp)succBlock failure:(processfailedResp)failedBlock;//1:token  3:noToken

+ (NSURLSessionDataTask *)POST:(NSString *)url
                         param:(NSMutableDictionary *)param
                     tokenType:(int)type //1:token 2:refreshToken  3:noToken
                          succ:(processSuccResp)succBlock
                       failure:(processfailedResp)failedBlock;



@end
