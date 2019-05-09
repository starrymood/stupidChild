//
//  BGCommunityApi.h
//  shzTravelC
//
//  Created by biao on 2018/7/23.
//  Copyright © 2018年 biao. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface BGCommunityApi : NSObject

/**
 获取社区分类列表
 */
+ (void)getTypeList:(NSMutableDictionary *)param succ:(processSuccResp)succBlock failure:(processfailedResp)failedBlock;

/**
 获取社区发布分类列表
 */
+ (void)getPublishTypeList:(NSMutableDictionary *)param succ:(processSuccResp)succBlock failure:(processfailedResp)failedBlock;

/**
 获取帖子列表
 */
+ (void)getPostList:(NSMutableDictionary *)param succ:(processSuccResp)succBlock failure:(processfailedResp)failedBlock;

/**
 获取我的粉丝列表
 */
+ (void)getMyFansList:(NSMutableDictionary *)param succ:(processSuccResp)succBlock failure:(processfailedResp)failedBlock;

/**
 获取我的关注列表
 */
+ (void)getMyConcernList:(NSMutableDictionary *)param succ:(processSuccResp)succBlock failure:(processfailedResp)failedBlock;

/**
 关注或取消关注
 */
+ (void)modifyConcernStatus:(NSMutableDictionary *)param succ:(processSuccResp)succBlock failure:(processfailedResp)failedBlock;

/**
 点赞或取消点赞
 */
+ (void)modifyLikeStatus:(NSMutableDictionary *)param succ:(processSuccResp)succBlock failure:(processfailedResp)failedBlock;

/**
 获取其他用户信息
 */
+ (void)getOtherUserInfo:(NSMutableDictionary *)param succ:(processSuccResp)succBlock failure:(processfailedResp)failedBlock;

/**
 获取其他用户帖子列表
 */
+ (void)getOtherUserPostList:(NSMutableDictionary *)param succ:(processSuccResp)succBlock failure:(processfailedResp)failedBlock;

/**
 获取用户发布的帖子
 */
+ (void)getMyPublishPost:(NSMutableDictionary *)param succ:(processSuccResp)succBlock failure:(processfailedResp)failedBlock;

/**
 检索会员的信息
 */
+ (void)getSearchMemberInfo:(NSMutableDictionary *)param succ:(processSuccResp)succBlock failure:(processfailedResp)failedBlock;

/**
 获取帖子详情
 */
+ (void)getEssayDetail:(NSMutableDictionary *)param succ:(processSuccResp)succBlock failure:(processfailedResp)failedBlock;

/**
 获取编辑帖子详情
 */
+ (void)getEditEssayDetail:(NSMutableDictionary *)param succ:(processSuccResp)succBlock failure:(processfailedResp)failedBlock;

/**
 举报用户帖子
 */
+ (void)reportEssayAction:(NSMutableDictionary *)param succ:(processSuccResp)succBlock failure:(processfailedResp)failedBlock;

/**
 屏蔽用户帖子
 */
+ (void)shieldEssayAction:(NSMutableDictionary *)param succ:(processSuccResp)succBlock failure:(processfailedResp)failedBlock;

/**
 获取帖子评论列表
 */
+ (void)getCommentList:(NSMutableDictionary *)param succ:(processSuccResp)succBlock failure:(processfailedResp)failedBlock;

/**
 获取视频帖子评论列表
 */
+ (void)getVideoCommentList:(NSMutableDictionary *)param succ:(processSuccResp)succBlock failure:(processfailedResp)failedBlock;

/**
 获取某一个评论的详细信息
 */
+ (void)getOneCommentDetail:(NSMutableDictionary *)param type:(int)type succ:(processSuccResp)succBlock failure:(processfailedResp)failedBlock;

/**
 给评论点赞
 */
+ (void)likeThisComment:(NSMutableDictionary *)param succ:(processSuccResp)succBlock failure:(processfailedResp)failedBlock;

/**
 添加评论
 */
+ (void)AddComment:(NSMutableDictionary *)param succ:(processSuccResp)succBlock failure:(processfailedResp)failedBlock;

/**
 首页most数据
 */
+ (void)getHomepageData:(NSMutableDictionary *)param succ:(processSuccResp)succBlock failure:(processfailedResp)failedBlock;

/**
 首页line数据
 */
+ (void)getHomepageLineData:(NSMutableDictionary *)param succ:(processSuccResp)succBlock failure:(processfailedResp)failedBlock;

/**
 获取视频列表
 */
+ (void)getVideoList:(NSMutableDictionary *)param succ:(processSuccResp)succBlock failure:(processfailedResp)failedBlock;


/**
 获取视频详情
 */
+ (void)getVideoDetail:(NSMutableDictionary *)param succ:(processSuccResp)succBlock failure:(processfailedResp)failedBlock;

/**
 用户编辑帖子
 */
+ (void)publishEditPost:(NSMutableDictionary *)param succ:(processSuccResp)succBlock failure:(processfailedResp)failedBlock;

/**
 用户删除帖子
 */
+ (void)publishDeletePost:(NSMutableDictionary *)param succ:(processSuccResp)succBlock failure:(processfailedResp)failedBlock;

@end
