//
//  Constants.h
//  shzTravelC
//
//  Created by 孙林茂 on 2018/5/4.
//  Copyright © 2018年 biao. All rights reserved.
//

#ifndef Constants_h
#define Constants_h

/********************************************************************
 *
 *  屏幕&尺寸
 *
 ********************************************************************/
/**
 iphone 4s    3.5寸 {{0, 0}, {320, 480}}      640*960
 iphone 5     4.0寸 {{0, 0}, {320, 568}}      640*1136
 iphone 6     4.7寸 {{0, 0}, {375, 667}}      750*1334
 iphone 6P    5.5寸 {{0, 0}, {414, 736}}      1080*1920
 iphone X     5.8寸 {{0, 0}, {375, 812}}      1125*2436
 */

#define noNetWorkImage              @"no_data_no_network"   //没有网络的图片
#define noNetWorkmessage            @"咦，网络好像飞走了"
#define serviceUnavailable          @"服务异常，请稍后再试"
#define noOrderMessage              @"亲，您还没有订单哟~"

#define SCREEN_WIDTH            ([UIScreen mainScreen].bounds.size.width)
#define SCREEN_HEIGHT           ([UIScreen mainScreen].bounds.size.height)
/// iPhoneX  iPhoneXS  iPhoneXS Max  iPhoneXR 机型判断
#define IS_iPhoneX ([UIScreen instancesRespondToSelector:@selector(currentMode)] ? ((NSInteger)(([[UIScreen mainScreen] currentMode].size.height/[[UIScreen mainScreen] currentMode].size.width)*100) == 216) : NO)
#define SizeScale               (IS_iPhoneX ? 1 :1)
#define kFont(value)            [UIFont systemFontOfSize:value * SizeScale]
#define SafeAreaTopHeight       (IS_iPhoneX ? 88.0f : 64.0f)
#define SafeAreaBottomHeight    (IS_iPhoneX ? 34.0f : 0)
#define kStatusBarH             (IS_iPhoneX ? 44.0f : 20.0f)
#define kTabBarH                49.0f
#define kNavigationBarH         44.0f

#define IS_iPhone5              (SCREEN_WIDTH == 320)
/********************************************************************
 *
 *  常用颜色值
 *
 ********************************************************************/


#define UIColorFromRGB(rgbValue) [UIColor colorWithRed:((float)((rgbValue & 0xFF0000) >> 16))/255.0 green:((float)((rgbValue & 0xFF00) >> 8))/255.0 blue:((float)(rgbValue & 0xFF))/255.0 alpha:1.0]

// app主色调
#define kAppMainColor         UIColorFromRGB(0x17E6A1)
// 默认背景色
#define kAppBgColor           UIColorFromRGB(0xf5f9fc)

#define kAppTabBarItemColor   UIColorFromRGB(0xb2bdc5)
#define kAppWhiteColor        UIColorFromRGB(0xffffff)         //白色字体
#define kAppClearColor        [UIColor clearColor]

#define kAppTableViewBgColor  UIColorFromRGB(0xEEEEEE)         //tableView背景颜色

#define kApp333Color          UIColorFromRGB(0x333333)         //333
#define kApp666Color          UIColorFromRGB(0x666666)         //666
#define kApp999Color          UIColorFromRGB(0x999999)         //999
#define kAppDefaultLabelColor UIColorFromRGB(0x2F2F2F)         //2F2F2F
#define kAppRedColor          UIColorFromRGB(0xFF0000)         //红色
#define kAppDotLineColor      UIColorFromRGB(0xDDDDDD)         //虚线颜色
#define kAppGreyBGColor       UIColorFromRGB(0xf3f3f3)        //页面背景颜色
#define kAppLineBGColor       UIColorFromRGB(0xededed)        //1px分隔线
#define kAppTipBGColor        UIColorFromRGB(0x363636)         //提示消息字体颜色
#define kAppBlackColor        UIColorFromRGB(0x000000)         //黑色


/********************************************************************
 *
 *  打印日志
 *
 ********************************************************************/

#ifdef DEBUG
#   define DLog(fmt, ...) NSLog((@"%s [Line %d] " fmt), __PRETTY_FUNCTION__, __LINE__, ##__VA_ARGS__);
#else
#   define DLog(...)
#endif

#ifdef DEBUG
#   define ULog(fmt, ...)  { UIAlertView *alert = [[UIAlertView alloc] initWithTitle:[NSString stringWithFormat:@"%s\n [Line %d] ", __PRETTY_FUNCTION__, __LINE__] message:[NSString stringWithFormat:fmt, ##__VA_ARGS__]  delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil]; [alert show]; }
#else
#   define ULog(...)
#endif

/********************************************************************
 *
 *  系统相关
 *
 ********************************************************************/
#define BGImage(imgName) [UIImage imageNamed:imgName]
#define BGRootViewController [UIApplication sharedApplication].keyWindow.rootViewController
#define BGWindow [UIApplication sharedApplication].keyWindow
#define BGdictSetObjectIsNil(value) [Tool dictSetObjectIsNil:value]
#define APPDELEGATE ((AppDelegate *)([[UIApplication sharedApplication] delegate]))
#define kBGAPIPOSTUploadFile         @"uploadfile"                          //文件上传
#define  htmlUrl                APPDELEGATE.httpURL
#define  htmlImgUrl             APPDELEGATE.httpImgURL
#define  htmlH5Url              APPDELEGATE.httpH5URL

//开发
#define  HtmlUrldev         @"http://api.user.shahaizi.cn/"
//#define  HtmlUrldev         @"http://user.api.shahaizhi.com/"
//#define  HtmlImgUrldev      @"https://oss.shahaizi.net/"
#define  HtmlH5Urldev       @"http://www.shahaizi.tech/"

//正式
#define  HtmlUrlprd         @"http://api.user.shahaizi.cn/"
//#define  HtmlImgUrlprd      @"https://oss.shahaizi.cn/"
#define  HtmlH5Urlprd       @"http://www.shahaizi.tech/"

// h5 路径
#define BGWebMainHtml  [NSString stringWithFormat:@"%@html/",htmlH5Url]
#define BGWebGoodDetail(appendix)  [NSString stringWithFormat:@"%@html/goods_detail.html?goodid=%@",htmlH5Url,appendix]
#define BGWebPages(appendix)  [NSString stringWithFormat:@"%@dist/pages/%@",htmlH5Url,appendix]
#define BGWebActivityHtml(appendix)  [NSString stringWithFormat:@"%@activity_share/activity_share.html?id=%@",htmlH5Url,appendix]

/********************************************************************
 *
 *  NSUserDefaults对象存储
 *
 ********************************************************************/

/**
 *  the saving objects      存储对象
 */
#define BGSetUserDefaultObjectForKey(__VALUE__,__KEY__) \
{\
[[NSUserDefaults standardUserDefaults] setObject:__VALUE__ forKey:__KEY__];\
[[NSUserDefaults standardUserDefaults] synchronize];\
}

/**
 *  get the saved objects       获得存储的对象
 */
#define BGGetUserDefaultObjectForKey(__KEY__)  [[NSUserDefaults standardUserDefaults] objectForKey:__KEY__]

/**
 *  delete objects      删除对象
 */
#define BGRemoveUserDefaultObjectForKey(__KEY__) \
{\
[[NSUserDefaults standardUserDefaults] removeObjectForKey:__KEY__];\
[[NSUserDefaults standardUserDefaults] synchronize];\
}


#define HistoryCity @"HistoryCity"

/********************************************************************
 *
 *  http请求
 *
 ********************************************************************/
#define BGAPIGet(appendix)  [NSString stringWithFormat:@"%@%@",htmlUrl,appendix]
#define BGAPIPost(appendix) [NSString stringWithFormat:@"%@%@",htmlUrl,appendix]
#define BGImageUrl(urlAppendix) [NSURL URLWithString:[NSString stringWithFormat:@"%@%@",htmlImgUrl, urlAppendix]]

/********************************************************************
 *
 *  账号相关
 *
 ********************************************************************/
//微信 第三方登录 和分享

/** App id */
#define APP_ID @"1361942674"

//正式
#define WECHAT_AppIDprd            @"wx444bb74a6d803478"
#define WECHAT_Appsecretprd        @"336027558d4d7274dd33a6d04f375de8"

// QQ 第三方登录和分享
#define QQ_AppIDprd                @"1106980891"
#define QQ_AppKeyprd               @"u7RkX4rG9XZxBbd9"

// 新浪 第三方分享
#define Sina_AppIDprd                @"2695656281"
#define Sina_AppKeyprd               @"c45c1c7feb3bfc2c2b1da20cd3594a19"

//极光推送

#define JPUSH_APPKEY               @"f33675352d0f85cb754fa4b7"

//友盟
#define UMENG_APPKEY               @"5b21f9ccf29d982b39000120"

// 融云 bmdehs6pbrfqs
#define RongCloud_Service   @"service"
#if DEBUG
#define RongCloud_AppKey    @"0vnjpoad069rz"
#else
#define RongCloud_AppKey    @"0vnjpoad069rz"
#endif


//支付宝AlipayURLScheme
#define ALIPAY_URLSCHEME           @"alipaySHZBiaoC"



#endif /* Constants_h */
