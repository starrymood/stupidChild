//
//  StringHelper.h
//  ZTRong
//
//  Created by 李婷 on 15/5/12.
//  Copyright © 2017年 JiangHao. All rights reserved.
//  MD5加密的工具类

#import <Foundation/Foundation.h>
#import <CommonCrypto/CommonDigest.h>
#include <CommonCrypto/CommonCryptor.h>

@interface StringHelper : NSObject

/**
 *  字典转字符串
 *
 *  @param dic 需转化的字典
 *
 *  @return 转化好的字符串
 */
+ (NSString*)dictionaryToJson:(NSDictionary *)dic;

/**
 *  数组转字符串
 *
 *  @param arr 需转化的数组
 *
 *  @return 转化好的字符串
 */
+ (NSString*)arrToJson:(NSArray *)arr;

/**
 *  字典转化为用MD5加密过的字符串
 *
 *  @param dic 需转化的字典
 *
 *  @return 加密过的字符串
 */
+ (NSString *)dicSortAndMD5:(NSDictionary *)dic;

/**
 *  des加密
 *
 *  @param clearText 需要加密的内容
 *  @param key       密钥
 *
 *  @return 加密后的字符串
 */
+(NSString *) encryptUseDES:(NSString *)clearText key:(NSString *)key;

+ (NSString *)safeStringValue:(NSString *)value;
+(NSString*)ObjectTojsonString:(id)object;
@end
