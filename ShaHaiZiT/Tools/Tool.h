//
//  Tool.h
//  shzTravelC
//
//  Created by 孙林茂 on 2018/5/4.
//  Copyright © 2018年 biao. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AFNetworking.h"

@interface Tool : NSObject

typedef void (^processSuccResp)(NSDictionary *response); // 请求成功回调
typedef void (^processfailedResp)(NSDictionary *response); //  请求失败回调

//初始化服务器状态
+(void)initHtmlRoot;

//当前是否有网络
+(BOOL)hasNetWork;

// 是否是电话号码(简单判断)
+ (BOOL)isMobile:(NSString *)phoneNum;

// 根据时间戳返回 星期几
+ (NSString *)getWeekDayFordate:(long long)data;

// 根据日期格式返回时间戳
+ (NSString *)timeString:(NSString *)time withFormatte:(NSString *)formatte;

// 根据时间戳返回给定日期格式
+(NSString *)dateFormatter:(double)time dateFormatter:(NSString *)formatterStr;

// 小数位取舍
+(NSString*)decimalStrWith:(double)sec positin:(NSInteger)position RoundingMode:(NSRoundingMode)modle;

//获取当前最顶层的ViewController
+(UIViewController *)topViewController;

//获取当前屏幕显示的viewcontroller
+(UIViewController *)getCurrentVC;

//判断数组是否为空
+ (BOOL)arrayIsNotEmpty:(NSArray *)listArr;
//判断字符串为空
+ (BOOL)isBlankString:(NSString *)string;
//判断字典value为空
+ (id)dictSetObjectIsNil:(id)value;
//判断内容为空格
+ (BOOL)isEmpty:(NSString *)str;
//判断字典是否包含对应的key值
+ (BOOL)dictContainsObject:(NSDictionary *)dic forKey:(id)key;

// 是否登录
+ (BOOL)isLogin;

// 判断是否是身份证号
+ (BOOL)judgeIdentityStringValid:(NSString *)identityString;

// 画虚线
+ (void)drawDashLine:(UIView *)lineView lineLength:(int)lineLength lineSpacing:(int)lineSpacing lineColor:(UIColor *)lineColor;

// 修正图片方向
+ (UIImage *)fixOrientation:(UIImage *)image;

/**
 显示当前文字需要几行
 
 @param width 给定一个宽度
 @return 返回行数
 */
+ (NSInteger)needLinesWithWidth:(CGFloat)width text:(NSString *)text;
+(NSString *)attributeByWeb:(NSString *)str width:(CGFloat)width scale:(CGFloat)scale;
+ (UIImage *)screenShotWithVC:(UIViewController *)vc;
// 退出登录清除数据
+ (void)logoutRongCloudAction;
+ (BOOL)isBlankDictionary:(NSDictionary *)dic;
+ (CGSize)textSizeWithText:(NSString *)text
                      Font:(UIFont*)font
                limitWidth:(CGFloat)maxWidth;

@end
