//
//  StringHelper.m
//  ZTRong
//
//  Created by 李婷 on 15/5/12.
//  Copyright © 2017年 JiangHao. All rights reserved.
//

#import "StringHelper.h"

@implementation StringHelper


+(NSString *)exchangeListToJson:(NSArray *)arr{
    
     NSMutableString *jsonString = [[NSMutableString alloc] initWithString:@"["];
    for(int i=0;i<arr.count;i++){
        NSDictionary *dic= [arr objectAtIndex:i];
        
        NSString *string;
        
        string  = [NSString stringWithFormat:
                   @"{\"goodsId\":\"%@\",\"exchangeCount\":\"%@\",\"commodityId\":\"%@\"},",[dic objectForKey:@"goodsId"],[dic objectForKey:@"exchangeCount"],[dic objectForKey:@"commodityId"]];
        
        [jsonString appendString:string];
        
        NSUInteger location = [jsonString length]-1;
        
        NSRange range       = NSMakeRange(location, 1);
        
        // 4. 将末尾逗号换成结束的]}
        [jsonString replaceCharactersInRange:range withString:@"]"];
    }
    
    
    
    return jsonString  ;
}

//+(NSString *)shortmapToJson :(NSDictionary *)map{
//    
//    NSMutableArray *allKeys= [NSMutableArray arrayWithArray:[map allKeys]];
//    
//    //比较排序
//    for (int i = 0; i < [allKeys count]; i ++)
//    {
//        for (int j = i + 1; j < [allKeys count]; j ++)
//        {
//            NSString  *firstOne=[NSString stringWithFormat:@"%@",[allKeys objectAtIndex:i]];
//            NSString  *secondOne=[NSString stringWithFormat:@"%@",[allKeys objectAtIndex:j]];
//            
//            int result = [firstOne compare:secondOne];
//            if (result == 1)
//            {
//                [allKeys exchangeObjectAtIndex:i withObjectAtIndex:j];
//            }
//        }
//        
//    }
//
//    
//     NSString *combineStr = @"";
//    
//    
//    for (int i = 0; i < allKeys.count; i++) {
//        NSString *key=  allKeys[i];
//        
//        NSObject *ob =[map objectForKey:key];
//        
//        NSString *s =@"";
//        
//        if(ob){
//            if([ob isKindOfClass:[NSArray class]]){
//                if([key isEqualToString:@"exchangeList"]){
//                    s= [self exchangeListToJson:(NSArray *)ob];
//                }else{
//                    s= [self arrToJson:(NSArray *)ob];
//                }
//            }else if([ob isKindOfClass:[NSString class]]){
//                s= (NSString *)ob;
//            }else if([ob isKindOfClass:[NSDictionary class]]){
//                s= [self dictionaryToJson:(NSDictionary *)ob];
//            }
//        }
//        
//        
//        
//        
//        if (     s.length >0   || [key isEqualToString:@"ids"]  ) {
//            
//            combineStr = [NSString stringWithFormat:@"%@%@%@=%@",combineStr,(i != 0 && combineStr.length) ? @"&":@"",key,s];
//        }
//    }
//
//    
//    
//    return combineStr;
//    
//}

+ (NSString*)dictionaryToJson:(NSDictionary *)dic
{
    NSError *parseError = nil;
    
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:dic options:NSJSONWritingPrettyPrinted error:&parseError];
    
    return [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
}

+ (NSString*)arrToJson:(NSArray *)arr{
    NSError *parseError = nil;
    NSData *jsonData =[NSJSONSerialization dataWithJSONObject:arr options:NSJSONWritingPrettyPrinted  error:&parseError];
    return [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
}


+(NSString*)ObjectTojsonString:(id)object
{
    NSString *jsonString = [[NSString alloc]init];
    NSError *error;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:object
                                                      options:NSJSONWritingPrettyPrinted
                                                        error:&error];
    if (! jsonData) {
//        NSLog(@"error: %@", error);
    } else {
        jsonString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
    }
    NSMutableString *mutStr = [NSMutableString stringWithString:jsonString];
    NSRange range = {0,jsonString.length};
    [mutStr replaceOccurrencesOfString:@" "withString:@""options:NSLiteralSearch range:range];
    NSRange range2 = {0,mutStr.length};
    [mutStr replaceOccurrencesOfString:@"\n"withString:@""options:NSLiteralSearch range:range2];
    NSRange range3 = {0,mutStr.length};
    [mutStr replaceOccurrencesOfString:@"\\"withString:@""options:NSLiteralSearch range:range3];
    return mutStr;
}

+ (NSString *)dicSortAndMD5:(NSDictionary *)dic{
    
    //取得所有KEY值
    NSMutableArray *allKeys= [NSMutableArray arrayWithArray:[dic allKeys]];
    
    //比较排序
    for (int i = 0; i < [allKeys count]; i ++)
    {
        for (int j = i + 1; j < [allKeys count]; j ++)
        {
            NSString  *firstOne=[NSString stringWithFormat:@"%@",[allKeys objectAtIndex:i]];
            NSString  *secondOne=[NSString stringWithFormat:@"%@",[allKeys objectAtIndex:j]];
            
            int result = [firstOne compare:secondOne];
            if (result == 1)
            {
                [allKeys exchangeObjectAtIndex:i withObjectAtIndex:j];
            }
        }
        
    }
    
    //KEY、VALUE组成字符串
    NSString *combineStr = @"";
    
    for (int i = 0; i < allKeys.count; i++) {
        NSString *key=  allKeys[i];
        
        NSObject *ob =[dic objectForKey:key];
        
        NSString *s =@"";
        
        if(ob){
            if([ob isKindOfClass:[NSArray class]]){  //数组不参与签名  2015-09-07 
//                if([key isEqualToString:@"exchangeList"]){
//                    s= [self exchangeListToJson:(NSArray *)ob];
//                }else{
//                    s= [self arrToJson:(NSArray *)ob];
//                }
            }else if([ob isKindOfClass:[NSString class]]){
                s= (NSString *)ob;
            }else if([ob isKindOfClass:[NSDictionary class]]){
                s= [self dictionaryToJson:(NSDictionary *)ob];
            }
        }
        
        
        
        
        if (     s.length >0   || [key isEqualToString:@"ids"]  ) {

            combineStr = [NSString stringWithFormat:@"%@%@%@=%@",combineStr,(i != 0 && combineStr.length) ? @"&":@"",key,s];
        }
    }
    
    combineStr = [combineStr stringByAppendingString:@"&key=51e4dc1269013ccd8f257164a79f465a"];
    return [[self createMD5:combineStr] lowercaseString];
    
}
+(NSString*) md5:(NSString*) str
{
    const char *cStr = [str UTF8String];
    unsigned char result[CC_MD5_DIGEST_LENGTH];
    CC_MD5( cStr, (CC_LONG)strlen(cStr), result );
    
    NSMutableString *hash = [NSMutableString string];
    for(int i=0;i<CC_MD5_DIGEST_LENGTH;i++)
    {
        [hash appendFormat:@"%02X",result[i]];
    }
    return [hash lowercaseString];
}
+ (NSString *)createMD5:(NSString *)signString
{
    const char*cStr =[signString UTF8String];
    unsigned char result[16];
    CC_MD5(cStr, (CC_LONG)strlen(cStr), result);
    return[NSString stringWithFormat:
           @"%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X",
           result[0], result[1], result[2], result[3],
           result[4], result[5], result[6], result[7],
           result[8], result[9], result[10], result[11],
           result[12], result[13], result[14], result[15]
           ];
}

+(NSString *) encryptUseDES:(NSString *)clearText key:(NSString *)key
{
    NSData *data = [clearText dataUsingEncoding:NSUTF8StringEncoding allowLossyConversion:YES];
    unsigned char buffer[1024];
    memset(buffer, 0, sizeof(char));
    size_t numBytesEncrypted = 0;
    
    CCCryptorStatus cryptStatus = CCCrypt(kCCEncrypt,
                                          kCCAlgorithmDES,
                                          kCCOptionPKCS7Padding| kCCOptionECBMode,
                                          [key UTF8String],
                                          kCCKeySizeDES,
                                          nil,
                                          [data bytes],
                                          [data length],
                                          buffer,
                                          1024,
                                          &numBytesEncrypted);
    
    NSString* plainText = nil;
    if (cryptStatus == kCCSuccess) {
        NSData *data = [NSData dataWithBytes:buffer length:(NSUInteger)numBytesEncrypted];
        plainText = [self stringWithHexBytes2:data];
        
        //        plainText = [GTMBase64 stringByEncodingData:dataTemp];
    }else{
//        NSLog(@"DES加密失败");
    }
    return plainText;
}

//nsdata转成16进制字符串
+ (NSString*)stringWithHexBytes2:(NSData *)sender {
    static const char hexdigits[] = "0123456789ABCDEF";
    const size_t numBytes = [sender length];
    const unsigned char* bytes = [sender bytes];
    char *strbuf = (char *)malloc(numBytes * 2 + 1);
    char *hex = strbuf;
    NSString *hexBytes = nil;
    
    for (int i = 0; i<numBytes; ++i) {
        const unsigned char c = *bytes++;
        *hex++ = hexdigits[(c >> 4) & 0xF];
        *hex++ = hexdigits[(c ) & 0xF];
    }
    
    *hex = 0;
    hexBytes = [NSString stringWithUTF8String:strbuf];
    
    free(strbuf);
    return hexBytes;
}

+ (NSString *)safeStringValue:(NSString *)value {
    return  [Tool isBlankString:value] ? @"" : value;
}

@end
