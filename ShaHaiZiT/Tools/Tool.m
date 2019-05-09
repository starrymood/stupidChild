//
//  Tool.m
//  shzTravelC
//
//  Created by 孙林茂 on 2018/5/4.
//  Copyright © 2018年 biao. All rights reserved.
//

#import "Tool.h"
#import "BGAppDelegateHelper.h"
#import <RongIMKit/RongIMKit.h>

static BOOL hasNetWork=YES;
@implementation Tool
//初始化服务器状态
+(void)initHtmlRoot{
#ifdef DEBUG
    APPDELEGATE.httpURL = HtmlUrldev;
//    APPDELEGATE.httpImgURL = HtmlImgUrldev;
    APPDELEGATE.httpH5URL = HtmlH5Urldev;
#else
    APPDELEGATE.httpURL = HtmlUrlprd;
//    APPDELEGATE.httpImgURL = HtmlImgUrlprd;
    APPDELEGATE.httpH5URL = HtmlH5Urlprd;
#endif
}

+(BOOL)hasNetWork{
    
    [[AFNetworkReachabilityManager sharedManager] startMonitoring];
    
    // 检测网络连接的单例,网络变化时的回调方法
    [[AFNetworkReachabilityManager sharedManager] setReachabilityStatusChangeBlock:^(AFNetworkReachabilityStatus status) {
        //        NSLog(@"AFNetworkReachabilityManager   %zi", status);
        
        switch (status) {
            case AFNetworkReachabilityStatusUnknown:
                hasNetWork=NO;
                break;
            case AFNetworkReachabilityStatusNotReachable:
                hasNetWork=NO;
                break;
            case AFNetworkReachabilityStatusReachableViaWWAN:
                hasNetWork=YES;
                break;
            case AFNetworkReachabilityStatusReachableViaWiFi:
                hasNetWork=YES;
                break;
                
                
            default:
                break;
        }
    }];
    
    
    return hasNetWork;
}
/// 是否是电话号码(简单判断)
+ (BOOL)isMobile:(NSString *)phoneNum {
    //手机号以13， 15，18开头，八个 \d 数字字符
    NSString *phoneRegex = @"^1[34578]\\d{9}$";
    NSPredicate *phoneTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@",phoneRegex];
    return [phoneTest evaluateWithObject:phoneNum];
}
#pragma mark -   小数位取舍
+(NSString*)decimalStrWith:(double)sec positin:(NSInteger)position RoundingMode:(NSRoundingMode)modle
{
    NSDecimalNumberHandler* roundingBehavior = [NSDecimalNumberHandler decimalNumberHandlerWithRoundingMode:modle scale:position raiseOnExactness:NO raiseOnOverflow:NO raiseOnUnderflow:NO raiseOnDivideByZero:YES];
    NSDecimalNumber *ouncesDecimal;
    NSDecimalNumber *roundedOunces;
    
    ouncesDecimal = [[NSDecimalNumber alloc] initWithFloat:sec];
    roundedOunces = [ouncesDecimal decimalNumberByRoundingAccordingToBehavior:roundingBehavior];
    
    return [NSString stringWithFormat:@"%@",roundedOunces];
}
#pragma mark- 根据时间戳返回 星期几
+ (NSString *)getWeekDayFordate:(long long)data
{
    NSArray *weekday = [NSArray arrayWithObjects: [NSNull null], @"周日", @"周一", @"周二", @"周三", @"周四", @"周五", @"周六", nil];
    NSDate *newDate = [NSDate dateWithTimeIntervalSince1970:data];
    NSCalendar *calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
    NSDateComponents *components = [calendar components:NSCalendarUnitWeekday fromDate:newDate];
    NSString *weekStr = [weekday objectAtIndex:components.weekday];
    return weekStr;
}
#pragma mark- 日期格式

+ (NSString *)timeString:(NSString *)formatTime withFormatte:(NSString *)format {
    
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateStyle:NSDateFormatterMediumStyle];
    [formatter setTimeStyle:NSDateFormatterShortStyle];
    [formatter setDateFormat:format]; //(@"YYYY-MM-dd hh:mm:ss") ----------设置你想要的格式,hh与HH的区别:分别表示12小时制,24小时制
//    NSTimeZone* timeZone = [NSTimeZone timeZoneWithName:@"Asia/Beijing"];
    NSTimeZone *timeZone = [NSTimeZone systemTimeZone];
    [formatter setTimeZone:timeZone];
    NSDate* date = [formatter dateFromString:formatTime]; //------------将字符串按formatter转成nsdate
    
    //时间转时间戳的方法:
    
    long timeSp = [[NSNumber numberWithDouble:[date timeIntervalSince1970]] doubleValue];
    //    NSLog(@"将某个时间转化成 时间戳&&&&&&&timeSp:%ld",(long)timeSp*1000); //时间戳的值
    
    return [NSString stringWithFormat:@"%ld",timeSp];
}

+(NSString *)dateFormatter:(double)time dateFormatter:(NSString *)formatterStr
{
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:formatterStr];
    NSDate * Date = [NSDate dateWithTimeIntervalSince1970:time];
    
    //formatter
    return [formatter stringFromDate:Date];
}
+ (UIViewController *)topViewController {
    UIViewController *resultVC;
    resultVC = [self _topViewController:[[UIApplication sharedApplication].keyWindow rootViewController]];
    while (resultVC.presentedViewController) {
        resultVC = [self _topViewController:resultVC.presentedViewController];
    }
    return resultVC;
}
#pragma mark- 获取当前屏幕显示的viewcontroller
+ (UIViewController *)getCurrentVC {
    UIViewController *resultVC;
    resultVC = [self _topViewController:[[UIApplication sharedApplication].keyWindow rootViewController]];
    while (resultVC.presentedViewController) {
        resultVC = [self _topViewController:resultVC.presentedViewController];
    }
    return resultVC;
}
+ (UIViewController *)_topViewController:(UIViewController *)vc {
    if ([vc isKindOfClass:[UINavigationController class]]) {
        return [self _topViewController:[(UINavigationController *)vc topViewController]];
    } else if ([vc isKindOfClass:[UITabBarController class]]) {
        return [self _topViewController:[(UITabBarController *)vc selectedViewController]];
    } else {
        return vc;
    }
    return nil;
}

+ (UIViewController *)getTopViewController {
    AppDelegate *appdelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
    UIViewController *rootViewController = appdelegate.window.rootViewController;
    return rootViewController;
}

#pragma mark- 判断数组是否为空
+ (BOOL)arrayIsNotEmpty:(NSArray *)listArr
{
    if (![listArr isKindOfClass:[NSNull class]] && [listArr isKindOfClass:[NSArray class]] && listArr && [listArr count] > 0)
    {
        return YES;
    }
    return NO;
}
#pragma mark- 判断字符串是否为空
+ (BOOL)isBlankString:(NSString *)string
{
    NSString *str = [NSString stringWithFormat:@"%@",string];
    if (str == nil || str == NULL || [str  isEqual: @"(null)"] || [str  isEqual: @"null"] || str.length == 0 || [str isKindOfClass:[NSNull class]]) {
        return YES;
    }
    
    return NO;
}

+ (BOOL)isEmpty:(NSString *)str
{
    if (!str) {
        return true;
    } else {
        NSCharacterSet *set = [NSCharacterSet whitespaceAndNewlineCharacterSet];
        NSString *trimedString = [str stringByTrimmingCharactersInSet:set];
        if ([trimedString length] == 0) {
            return true;
        } else {
            return false;
        }
    }
}

#pragma mark- 判断字典是否包含对应的key值
+ (BOOL)dictContainsObject:(NSDictionary *)dic forKey:(id)key
{
    if([[dic allKeys] containsObject:key])
    {
        return YES;
    }else{
        return NO;
    }
}
//判断字典value为空
+ (id)dictSetObjectIsNil:(id)value
{
    if (!value) {
        return @"";
    }else{
        if ([value isEqual:[NSNull null]]) {
            return @"";
        }else{
            return value;
        }
        
    }
}
// 是否登录
+ (BOOL)isLogin{
    if (BGGetUserDefaultObjectForKey(@"Token")) {
        return YES;
    }else{
        return NO;
    }
}
#pragma mark --- 判断身份证号
+ (BOOL)judgeIdentityStringValid:(NSString *)identityString {
    
    if (identityString.length != 18) return NO;
    // 正则表达式判断基本 身份证号是否满足格式
    NSString *regex = @"^[1-9]\\d{5}[1-9]\\d{3}((0\\d)|(1[0-2]))(([0|1|2]\\d)|3[0-1])\\d{3}([0-9]|X)$";
    //  NSString *regex = @"^(^[1-9]\\d{7}((0\\d)|(1[0-2]))(([0|1|2]\\d)|3[0-1])\\d{3}$)|(^[1-9]\\d{5}[1-9]\\d{3}((0\\d)|(1[0-2]))(([0|1|2]\\d)|3[0-1])((\\d{4})|\\d{3}[Xx])$)$";
    NSPredicate *identityStringPredicate = [NSPredicate predicateWithFormat:@"SELF MATCHES %@",regex];
    //如果通过该验证，说明身份证格式正确，但准确性还需计算
    if(![identityStringPredicate evaluateWithObject:identityString]) return NO;
    
    //** 开始进行校验 *//
    
    //将前17位加权因子保存在数组里
    NSArray *idCardWiArray = @[@"7", @"9", @"10", @"5", @"8", @"4", @"2", @"1", @"6", @"3", @"7", @"9", @"10", @"5", @"8", @"4", @"2"];
    
    //这是除以11后，可能产生的11位余数、验证码，也保存成数组
    NSArray *idCardYArray = @[@"1", @"0", @"10", @"9", @"8", @"7", @"6", @"5", @"4", @"3", @"2"];
    
    //用来保存前17位各自乖以加权因子后的总和
    NSInteger idCardWiSum = 0;
    for(int i = 0;i < 17;i++) {
        NSInteger subStrIndex = [[identityString substringWithRange:NSMakeRange(i, 1)] integerValue];
        NSInteger idCardWiIndex = [[idCardWiArray objectAtIndex:i] integerValue];
        idCardWiSum+= subStrIndex * idCardWiIndex;
    }
    
    //计算出校验码所在数组的位置
    NSInteger idCardMod=idCardWiSum%11;
    //得到最后一位身份证号码
    NSString *idCardLast= [identityString substringWithRange:NSMakeRange(17, 1)];
    //如果等于2，则说明校验码是10，身份证号码最后一位应该是X
    if(idCardMod==2) {
        if(![idCardLast isEqualToString:@"X"]||[idCardLast isEqualToString:@"x"]) {
            return NO;
        }
    }
    else{
        //用计算出的验证码与最后一位身份证号码匹配，如果一致，说明通过，否则是无效的身份证号码
        if(![idCardLast isEqualToString: [idCardYArray objectAtIndex:idCardMod]]) {
            return NO;
        }
    }
    return YES;
}
/**
 ** lineView:       需要绘制成虚线的view
 ** lineLength:     虚线的宽度
 ** lineSpacing:    虚线的间距
 ** lineColor:      虚线的颜色
 **/
+ (void)drawDashLine:(UIView *)lineView lineLength:(int)lineLength lineSpacing:(int)lineSpacing lineColor:(UIColor *)lineColor
{
    CAShapeLayer *shapeLayer = [CAShapeLayer layer];
    [shapeLayer setBounds:lineView.bounds];
    [shapeLayer setPosition:CGPointMake(CGRectGetWidth(lineView.frame) / 2, CGRectGetHeight(lineView.frame))];
    [shapeLayer setFillColor:[UIColor clearColor].CGColor];
    
    //  设置虚线颜色为blackColor
    [shapeLayer setStrokeColor:lineColor.CGColor];
    
    //  设置虚线宽度
    [shapeLayer setLineWidth:CGRectGetHeight(lineView.frame)];
    [shapeLayer setLineJoin:kCALineJoinRound];
    
    //  设置线宽，线间距
    [shapeLayer setLineDashPattern:[NSArray arrayWithObjects:[NSNumber numberWithInt:lineLength], [NSNumber numberWithInt:lineSpacing], nil]];
    
    //  设置路径
    CGMutablePathRef path = CGPathCreateMutable();
    CGPathMoveToPoint(path, NULL, 0, 0);
    CGPathAddLineToPoint(path, NULL, CGRectGetWidth(lineView.frame), 0);
    
    [shapeLayer setPath:path];
    CGPathRelease(path);
    
    //  把绘制好的虚线添加上来
    [lineView.layer addSublayer:shapeLayer];
}

// 修正图片方向
+ (UIImage *)fixOrientation:(UIImage *)image
{
    if (image.imageOrientation == UIImageOrientationUp)
        return image;
    
    CGAffineTransform transform = CGAffineTransformIdentity;
    
    switch (image.imageOrientation) {
        case UIImageOrientationDown:
        case UIImageOrientationDownMirrored:
            transform = CGAffineTransformTranslate(transform, image.size.width, image.size.height);
            transform = CGAffineTransformRotate(transform, M_PI);
            break;
            
        case UIImageOrientationLeft:
        case UIImageOrientationLeftMirrored:
            transform = CGAffineTransformTranslate(transform, image.size.width, 0);
            transform = CGAffineTransformRotate(transform, M_PI_2);
            break;
            
        case UIImageOrientationRight:
        case UIImageOrientationRightMirrored:
            transform = CGAffineTransformTranslate(transform, 0, image.size.height);
            transform = CGAffineTransformRotate(transform, -M_PI_2);
            break;
        default:
            break;
    }
    
    switch (image.imageOrientation) {
        case UIImageOrientationUpMirrored:
        case UIImageOrientationDownMirrored:
            transform = CGAffineTransformTranslate(transform, image.size.width, 0);
            transform = CGAffineTransformScale(transform, -1, 1);
            break;
            
        case UIImageOrientationLeftMirrored:
        case UIImageOrientationRightMirrored:
            transform = CGAffineTransformTranslate(transform, image.size.height, 0);
            transform = CGAffineTransformScale(transform, -1, 1);
            break;
        default:
            break;
    }
    
    CGContextRef ctx = CGBitmapContextCreate(NULL, image.size.width, image.size.height,
                                             CGImageGetBitsPerComponent(image.CGImage), 0,
                                             CGImageGetColorSpace(image.CGImage),
                                             CGImageGetBitmapInfo(image.CGImage));
    CGContextConcatCTM(ctx, transform);
    switch (image.imageOrientation) {
        case UIImageOrientationLeft:
        case UIImageOrientationLeftMirrored:
        case UIImageOrientationRight:
        case UIImageOrientationRightMirrored:
            CGContextDrawImage(ctx, CGRectMake(0,0,image.size.height,image.size.width), image.CGImage);
            break;
        default:
            CGContextDrawImage(ctx, CGRectMake(0,0,image.size.width,image.size.height), image.CGImage);
            break;
    }
    CGImageRef cgimg = CGBitmapContextCreateImage(ctx);
    UIImage *img = [UIImage imageWithCGImage:cgimg];
    CGContextRelease(ctx);
    CGImageRelease(cgimg);
    return img;
}

/**
 显示当前文字需要几行
 
 @param width 给定一个宽度
 @return 返回行数
 */
+ (NSInteger)needLinesWithWidth:(CGFloat)width text:(NSString *)text{
    //创建一个labe
    UILabel * label = [[UILabel alloc]init];
    //font和当前label保持一致
    label.font = kFont(11);
    NSInteger sum = 0;
    //总行数受换行符影响，所以这里计算总行数，需要用换行符分隔这段文字，然后计算每段文字的行数，相加即是总行数。
    NSArray * splitText = [text componentsSeparatedByString:@"\n"];
    for (NSString * sText in splitText) {
        label.text = sText;
        //获取这段文字一行需要的size
        CGSize textSize = [label systemLayoutSizeFittingSize:CGSizeZero];
        //size.width/所需要的width 向上取整就是这段文字占的行数
        NSInteger lines = ceilf(textSize.width/width);
        //当是0的时候，说明这是换行，需要按一行算。
        lines = lines == 0?1:lines;
        sum += lines;
    }
    return sum;
}
+(NSString *)attributeByWeb:(NSString *)str width:(CGFloat)width scale:(CGFloat)scale{
    NSString *jsString = [NSString stringWithFormat:@ "<head> \n"
                          "<style type=\"text/css\"> \n"
                          "img {max-width:%fpx;} *{} body{width:%fpx;position:relative;margin-right:10px;word-break: break-all;word-wrap: break-word;height:auto;}\n"
                          " p{line-height:30px;} </style> \n"
                          "<script>window.onload=function(){"
                          "var imgs = document.getElementsByTagName('img');"
                          "var length = imgs.length;"
                          "var srcs = '';"
                          "for (i = 0; i < length; i++) {"
                          "var img = imgs;"
                          "srcs +='&'+img.src; }"
                          "for (i = 0; i < length; i++) {"
                          "var img = imgs;"
                          "img.onclick = function(){"
                          "window.location.href = 'ready://'+ this.src+srcs;}}"
                          "}</script>"
                          "</head> \n"
                          "<body id=content>%@</body> \n"
                          "</html>",width,scale ,str];
    return jsString;
}
+ (UIImage *)screenShotWithVC:(UIViewController *)vc
{
    // 将要被截图的view,即窗口的根控制器的view
    UIViewController *beyondVC = vc.view.window.rootViewController;
    // 背景图片 总的大小
    CGSize size = beyondVC.view.frame.size;
    // 开启上下文,使用参数之后,截出来的是原图（YES  0.0 质量高）
    UIGraphicsBeginImageContextWithOptions(size, YES, 0.0);
    // 要裁剪的矩形范围
    CGRect rect = CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT);
    //注：iOS7以后renderInContext：由drawViewHierarchyInRect：afterScreenUpdates：替代
    [beyondVC.view drawViewHierarchyInRect:rect  afterScreenUpdates:NO];
    // 从上下文中,取出UIImage
    UIImage *snapshot = UIGraphicsGetImageFromCurrentImageContext();
    // 千万记得,结束上下文(移除栈顶的基于当前位图的图形上下文)
    UIGraphicsEndImageContext();
    // 添加截取好的图片到图片数组
    if (snapshot) {
        return snapshot;
    }else{
        return nil;
    }
}
// 退出登录清除数据
+ (void)logoutRongCloudAction {
    
    BGRemoveUserDefaultObjectForKey(@"Token");
    BGRemoveUserDefaultObjectForKey(@"RCToken");
    [[RCIM sharedRCIM] logout];
    [[RCIM sharedRCIM] clearUserInfoCache];
    
    NSFileManager * fileManager = [[NSFileManager alloc]init];
    NSString *fullPath = [[NSHomeDirectory() stringByAppendingPathComponent:@"Documents"] stringByAppendingPathComponent:@"currentImage.png"];
    UIImage *savedImage = [[UIImage alloc] initWithContentsOfFile:fullPath];
    if (savedImage != nil) {
        [fileManager removeItemAtPath:fullPath error:nil];
    }
    NSString *storeFullPath = [[NSHomeDirectory() stringByAppendingPathComponent:@"Documents"] stringByAppendingPathComponent:@"storeImage.png"];
    UIImage *storeSavedImage = [[UIImage alloc] initWithContentsOfFile:storeFullPath];
    if (storeSavedImage != nil) {
        [fileManager removeItemAtPath:storeFullPath error:nil];
    }
    [BGAppDelegateHelper showLoginViewController];
}
+ (BOOL)isBlankDictionary:(NSDictionary *)dic {
    if (!dic) {
        return YES;
    }
    if ([dic isKindOfClass:[NSNull class]]) {
        return YES;
    }
    if (![dic isKindOfClass:[NSDictionary class]]) {
        return YES;
    }
    if (!dic.count) {
        return YES;
    }
    if (dic == nil) {
        return YES;
    }
    if (dic == NULL) {
        return YES;
    }
    return NO;
}
/// 计算字符串长度（一行时候）
+ (CGSize)textSizeWithText:(NSString *)text
                      Font:(UIFont*)font
                limitWidth:(CGFloat)maxWidth {
    CGSize size = [text boundingRectWithSize:CGSizeMake(MAXFLOAT, 36)options:(NSStringDrawingTruncatesLastVisibleLine | NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading)  attributes:@{ NSFontAttributeName : font} context:nil].size;
    size.width = size.width > maxWidth ? maxWidth : size.width;
    size.width = ceil(size.width);
    size.height = ceil(size.height);
    return size;
}
@end
