//
//  WHAPIClient.m
//  wehomec
//
//  Created by spikedeng on 2017/3/7.
//  Copyright © 2017年 JiangHao. All rights reserved.
//

#import "WHAPIClient.h"

@implementation WHAPIClient

+ (NSURLSessionDataTask *)GET:(NSString *)url param:(NSMutableDictionary *)param tokenType:(int)type succ:(processSuccResp)succBlock failure:(processfailedResp)failedBlock {
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
    
    NSString *URL = BGAPIGet(url);
    if ([url rangeOfString:@"https://www.csno"].location != NSNotFound || [url rangeOfString:@"?imageInfo"].location != NSNotFound) {
        URL = url;
    }
    WHSessionManager *manager;
    if (type == 1) {
        if (BGGetUserDefaultObjectForKey(@"Token")) {
            manager = [WHSessionManager sharedManager:BGGetUserDefaultObjectForKey(@"Token")];
        } else {
            manager = [WHSessionManager sharedManager:@"noToken"];
        }
    }else{
        manager = [WHSessionManager sharedManager:@"noToken"];
    }
    NSMutableDictionary* parametersMutable = [NSMutableDictionary dictionaryWithDictionary:param];
    
    NSURLSessionDataTask *task = [manager GET:URL parameters:parametersMutable progress:^(NSProgress * _Nonnull downloadProgress) {
        
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        
        [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
        NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:responseObject
                                                             options:NSJSONReadingMutableContainers
                                                               error:nil];
        NSNumber *statusNumber = dict[@"code"];
        if ([url rangeOfString:@"?imageInfo"].location != NSNotFound) {
            succBlock(dict);
            [ProgressHUDHelper removeLoading];
            return ;
        }
        if(statusNumber.integerValue != 200 && failedBlock != nil ){
            if (statusNumber.integerValue<4003 && statusNumber.integerValue>3999) {
                [Tool logoutRongCloudAction];
            }
            failedBlock(dict);
            [ProgressHUDHelper removeLoading];
            NSString *msgStr = dict[@"msg"];
            if (statusNumber.integerValue == 300) {
                return ;
            }
            if (![Tool isBlankString:msgStr]) {
                if ([url containsString:@"get-rong-cloud-info"]) {
                    
                }else{
                    [WHIndicatorView toast:msgStr];
                }
                
            }else{
                if ([url rangeOfString:@"https://www.csno"].location != NSNotFound) {
                }else{
                    [WHIndicatorView toast:@"服务器访问失败"];
                }
            }
        }else if(succBlock){
            succBlock(dict);
            [ProgressHUDHelper removeLoading];
        }
        
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        
        [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
        if ([url containsString:@"get-rong-cloud-info"] || ([url rangeOfString:@"https://www.csno"].location != NSNotFound)) {
            
        }else{
            [WHIndicatorView toast:@"服务器访问失败"];
        }
        [ProgressHUDHelper removeLoading];
        if (failedBlock) {
            failedBlock(nil);
        }
    }];
    return task;
}


+ (NSURLSessionDataTask *)POST:(NSString *)url
                         param:(NSMutableDictionary *)param
                     tokenType:(int)type
                          succ:(processSuccResp)succBlock
                       failure:(processfailedResp)failedBlock {
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
    NSString *URL = BGAPIPost(url);
    
    WHSessionManager *manager = [[WHSessionManager alloc] init];
    switch (type) {
        case 1: {
            if (BGGetUserDefaultObjectForKey(@"Token")) {
                manager = [WHSessionManager sharedManager:BGGetUserDefaultObjectForKey(@"Token")];
            } else {
                manager = [WHSessionManager sharedManager:@"noToken"];
            }
        }
            break;
        case 2: {
            if (BGGetUserDefaultObjectForKey(@"RefreshToken")) {
                manager = [WHSessionManager sharedManager:BGGetUserDefaultObjectForKey(@"RefreshToken")];
            } else {
                manager = [WHSessionManager sharedManager:@"noToken"];
            }
        }
            break;
        case 3: {
            manager = [WHSessionManager sharedManager:@"noToken"];
        }
            break;
        case 4: {
            if (BGGetUserDefaultObjectForKey(@"Token")) {
                manager = [WHSessionManager sharedManager:@"needJson"];
            } else {
                manager = [WHSessionManager sharedManager:@"noToken"];
            }
        }
            break;
        default:
            break;
    }
    
    NSMutableDictionary* parametersMutable = [NSMutableDictionary dictionaryWithDictionary:param];
    NSURLSessionDataTask *task = [manager POST:URL parameters:parametersMutable progress:^(NSProgress * _Nonnull uploadProgress) {
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
        NSDictionary *dict;
        if ([responseObject isKindOfClass:[NSDictionary class]]) {
             dict = [NSDictionary dictionaryWithDictionary:responseObject];
        }else{
            dict = [NSJSONSerialization JSONObjectWithData:responseObject
                                                   options:NSJSONReadingMutableContainers
                                                     error:nil];
        }
        
        NSNumber *statusNumber = dict[@"code"];
        if(statusNumber.integerValue != 200 && failedBlock != nil ){
            if (statusNumber.integerValue<4003 && statusNumber.integerValue>3999) {
                [Tool logoutRongCloudAction];
            }
            failedBlock(dict);
            [ProgressHUDHelper removeLoading];
            NSString *msgStr = dict[@"msg"];
            if (![Tool isBlankString:msgStr]) {
                [WHIndicatorView toast:msgStr];
            }else{
                [WHIndicatorView toast:@"服务器访问失败"];
            }
        }else if(succBlock){
            succBlock(dict);
            [ProgressHUDHelper removeLoading];
        }
        
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        
        [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
        [ProgressHUDHelper removeLoading];
        if (failedBlock) {
            failedBlock(error.userInfo);
        }
    }];
    return task;
}

@end
