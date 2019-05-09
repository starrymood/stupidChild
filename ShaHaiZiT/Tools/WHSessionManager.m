//
//  WHSessionManager.m
//  wehomec
//
//  Created by Lion on 17/2/15.
//  Copyright © 2017年 JiangHao. All rights reserved.
//

#import "WHSessionManager.h"

@implementation WHSessionManager

static WHSessionManager *sharedManager = nil;
+(WHSessionManager *)sharedManager:(NSString *)token {
    
    static dispatch_once_t oncePredicate;
    dispatch_once(&oncePredicate, ^{
        sharedManager = [self manager];
        sharedManager.responseSerializer = [AFHTTPResponseSerializer serializer];
        [sharedManager.requestSerializer  setValue:@"application/json" forHTTPHeaderField:@"Accept"];
        sharedManager.responseSerializer.acceptableContentTypes = [NSSet setWithObjects:@"text/plain",@"application/json",@"text/html",nil];
        [sharedManager.requestSerializer willChangeValueForKey:@"timeoutInterval"];
        [sharedManager.requestSerializer setTimeoutInterval:10.0f];
        [sharedManager.requestSerializer didChangeValueForKey:@"timeoutInterval"];
        [NSURLSessionConfiguration defaultSessionConfiguration].HTTPMaximumConnectionsPerHost = 4;
        [sharedManager.operationQueue setMaxConcurrentOperationCount:4];
        //        [sharedManager.requestSerializer setHTTPShouldHandleCookies:NO];
    });
    if ([token isEqualToString:@"needJson"]) {
        // 一行代码传json数据
        sharedManager.requestSerializer = [AFJSONRequestSerializer serializer];
    }else{
        sharedManager.requestSerializer = [AFHTTPRequestSerializer serializer];
    }
    [sharedManager.requestSerializer clearAuthorizationHeader];
    if (![token isEqualToString:@"noToken"]) {
        [sharedManager.requestSerializer setAuthorizationHeaderFieldWithUsername:@"" password:BGGetUserDefaultObjectForKey(@"Token")];
    }
    return sharedManager;
    
}
/* 设置Cookie
 - (void)setCookieWithDomain:(NSString*)domainValue
 sessionName:(NSString *)name
 sessionValue:(NSString *)value
 expiresDate:(NSDate *)date{
 NSURL *url = [NSURL URLWithString:domainValue];
 NSString *domain = [url host];
 if ([Tool isEmpty:domain]) {
 return;
 }
 //创建字典存储cookie的属性值
 NSMutableDictionary *cookieProperties = [NSMutableDictionary dictionary];
 //设置cookie名
 [cookieProperties setObject:name forKey:NSHTTPCookieName];
 //设置cookie值
 [cookieProperties setObject:value forKey:NSHTTPCookieValue];
 //设置cookie域名
 [cookieProperties setObject:domain forKey:NSHTTPCookieDomain];
 //设置cookie路径 一般写"/"
 [cookieProperties setObject:@"/" forKey:NSHTTPCookiePath];
 //设置cookie版本, 默认写0
 [cookieProperties setObject:@"0" forKey:NSHTTPCookieVersion];
 //设置cookie过期时间
 if (date) {
 [cookieProperties setObject:date forKey:NSHTTPCookieExpires];
 }else{
 [cookieProperties setObject:[NSDate dateWithTimeIntervalSince1970:([[NSDate date] timeIntervalSince1970]+365*24*3600)] forKey:NSHTTPCookieExpires];
 }
 [[NSUserDefaults standardUserDefaults] setObject:cookieProperties forKey:@"app_cookice"];
 //删除原cookie, 如果存在的话
 NSArray * arrayCookies = [[NSHTTPCookieStorage sharedHTTPCookieStorage] cookies];
 for (NSHTTPCookie * cookice in arrayCookies) {
 if ([cookice.domain rangeOfString:domain].length>0) {
 [[NSHTTPCookieStorage sharedHTTPCookieStorage] deleteCookie:cookice];
 }
 }
 //使用字典初始化新的cookie
 NSHTTPCookie *newcookie = [NSHTTPCookie cookieWithProperties:cookieProperties];
 //使用cookie管理器 存储cookie
 [[NSHTTPCookieStorage sharedHTTPCookieStorage] setCookie:newcookie];
 }
 */
@end
