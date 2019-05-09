//
//  BGCommunityApi.m
//  shzTravelC
//
//  Created by biao on 2018/7/23.
//  Copyright © 2018年 biao. All rights reserved.
//

#import "BGCommunityApi.h"
#import "BGSystemApi.h"

#define BGCommunityPost(appendix) [NSString stringWithFormat:@"api/user/post/%@",appendix]
#define BGConcernPost(appendix) [NSString stringWithFormat:@"api/user/concern/%@",appendix]
#define BGLikePost(appendix) [NSString stringWithFormat:@"api/user/like/%@",appendix]
#define BGCommentPost(appendix) [NSString stringWithFormat:@"api/user/review/%@",appendix]
#define BGHomeGet(appendix) [NSString stringWithFormat:@"api/user/home/%@",appendix]
#define BGVideoGet(appendix) [NSString stringWithFormat:@"api/user/video/%@",appendix]

@implementation BGCommunityApi

/**
 获取社区分类列表
 */
+ (void)getTypeList:(NSMutableDictionary *)param succ:(processSuccResp)succBlock failure:(processfailedResp)failedBlock{
    
    [WHAPIClient GET:BGCommunityPost(@"get-list") param:param tokenType:3 succ:^(NSDictionary *response) {
        if (succBlock) {
            succBlock(response);
        }
    } failure:^(NSDictionary *response) {
        if (failedBlock) {
            failedBlock(response);
        }
    }];
}

/**
 获取社区发布分类列表
 */
+ (void)getPublishTypeList:(NSMutableDictionary *)param succ:(processSuccResp)succBlock failure:(processfailedResp)failedBlock{
    
    [WHAPIClient GET:BGCommunityPost(@"get-classification-list") param:param tokenType:3 succ:^(NSDictionary *response) {
        if (succBlock) {
            succBlock(response);
        }
    } failure:^(NSDictionary *response) {
        if (failedBlock) {
            failedBlock(response);
        }
    }];
}

/**
 获取帖子列表
 */
+ (void)getPostList:(NSMutableDictionary *)param succ:(processSuccResp)succBlock failure:(processfailedResp)failedBlock{
    
    int tokenType = 3;
    if ([Tool isLogin]) {
        tokenType = 1;
    }
    
    [WHAPIClient POST:BGCommunityPost(@"get-home-post-page") param:param tokenType:tokenType succ:^(NSDictionary *response) {
        if (succBlock) {
            succBlock(response);
        }
    } failure:^(NSDictionary *response) {
        if (failedBlock) {
            failedBlock(response);
        }
    }];
}

/**
 获取我的粉丝列表
 */
+ (void)getMyFansList:(NSMutableDictionary *)param succ:(processSuccResp)succBlock failure:(processfailedResp)failedBlock{
    
    [WHAPIClient GET:BGConcernPost(@"get-my-fans") param:param tokenType:1 succ:^(NSDictionary *response) {
        if (succBlock) {
            succBlock(response);
        }
    } failure:^(NSDictionary *response) {
        if (failedBlock) {
            failedBlock(response);
        }
    }];
}

/**
 获取我的关注列表
 */
+ (void)getMyConcernList:(NSMutableDictionary *)param succ:(processSuccResp)succBlock failure:(processfailedResp)failedBlock{
    
    [WHAPIClient GET:BGConcernPost(@"get-my-concern") param:param tokenType:1 succ:^(NSDictionary *response) {
        if (succBlock) {
            succBlock(response);
        }
    } failure:^(NSDictionary *response) {
        if (failedBlock) {
            failedBlock(response);
        }
    }];
}

/**
 关注或取消关注
 */
+ (void)modifyConcernStatus:(NSMutableDictionary *)param succ:(processSuccResp)succBlock failure:(processfailedResp)failedBlock{
    
    [WHAPIClient POST:BGConcernPost(@"add-concern") param:param tokenType:1 succ:^(NSDictionary *response) {
        if (succBlock) {
            succBlock(response);
        }
        [BGSystemApi getUserInfo:nil succ:^(NSDictionary *response) {
            
        } failure:^(NSDictionary *response) {
            
        }];
    } failure:^(NSDictionary *response) {
        if (failedBlock) {
            failedBlock(response);
        }
    }];
}

/**
 点赞或取消点赞
 */
+ (void)modifyLikeStatus:(NSMutableDictionary *)param succ:(processSuccResp)succBlock failure:(processfailedResp)failedBlock{
    
    [WHAPIClient POST:BGLikePost(@"add-or-cancel-member-like") param:param tokenType:1 succ:^(NSDictionary *response) {
        if (succBlock) {
            succBlock(response);
        }
    } failure:^(NSDictionary *response) {
        if (failedBlock) {
            failedBlock(response);
        }
    }];
}
/**
 获取其他用户信息
 */
+ (void)getOtherUserInfo:(NSMutableDictionary *)param succ:(processSuccResp)succBlock failure:(processfailedResp)failedBlock{
    
    [WHAPIClient GET:BGCommunityPost(@"get-other-member-info") param:param tokenType:1 succ:^(NSDictionary *response) {
        if (succBlock) {
            succBlock(response);
        }
    } failure:^(NSDictionary *response) {
        if (failedBlock) {
            failedBlock(response);
        }
    }];
}

/**
 获取其他用户帖子列表
 */
+ (void)getOtherUserPostList:(NSMutableDictionary *)param succ:(processSuccResp)succBlock failure:(processfailedResp)failedBlock{
    
    [WHAPIClient GET:BGCommunityPost(@"get-other-member-post") param:param tokenType:3 succ:^(NSDictionary *response) {
        if (succBlock) {
            succBlock(response);
        }
    } failure:^(NSDictionary *response) {
        if (failedBlock) {
            failedBlock(response);
        }
    }];
}

/**
 获取用户发布的帖子
 */
+ (void)getMyPublishPost:(NSMutableDictionary *)param succ:(processSuccResp)succBlock failure:(processfailedResp)failedBlock{
    
    [WHAPIClient GET:BGCommunityPost(@"get-member-post-list") param:param tokenType:1 succ:^(NSDictionary *response) {
        if (succBlock) {
            succBlock(response);
        }
    } failure:^(NSDictionary *response) {
        if (failedBlock) {
            failedBlock(response);
        }
    }];
}

/**
 检索会员的信息
 */
+ (void)getSearchMemberInfo:(NSMutableDictionary *)param succ:(processSuccResp)succBlock failure:(processfailedResp)failedBlock{
    
    [WHAPIClient POST:BGCommunityPost(@"get-member-info-page") param:param tokenType:3 succ:^(NSDictionary *response) {
        if (succBlock) {
            succBlock(response);
        }
    } failure:^(NSDictionary *response) {
        if (failedBlock) {
            failedBlock(response);
        }
    }];
}

/**
 获取帖子详情
 */
+ (void)getEssayDetail:(NSMutableDictionary *)param succ:(processSuccResp)succBlock failure:(processfailedResp)failedBlock{
    
    int tokenType = 3;
    if ([Tool isLogin]) {
        tokenType = 1;
    }
    
    [WHAPIClient GET:BGCommunityPost(@"get-post-detail") param:param tokenType:tokenType succ:^(NSDictionary *response) {
        if (succBlock) {
            succBlock(response);
        }
    } failure:^(NSDictionary *response) {
        if (failedBlock) {
            failedBlock(response);
        }
    }];
}

/**
 获取编辑帖子详情
 */
+ (void)getEditEssayDetail:(NSMutableDictionary *)param succ:(processSuccResp)succBlock failure:(processfailedResp)failedBlock{
    
    [WHAPIClient GET:BGCommunityPost(@"get-my-post-detail") param:param tokenType:1 succ:^(NSDictionary *response) {
        if (succBlock) {
            succBlock(response);
        }
    } failure:^(NSDictionary *response) {
        if (failedBlock) {
            failedBlock(response);
        }
    }];
}

/**
 举报用户帖子
 */
+ (void)reportEssayAction:(NSMutableDictionary *)param succ:(processSuccResp)succBlock failure:(processfailedResp)failedBlock{
    
    [WHAPIClient POST:BGCommunityPost(@"report-post") param:param tokenType:1 succ:^(NSDictionary *response) {
        if (succBlock) {
            succBlock(response);
        }
    } failure:^(NSDictionary *response) {
        if (failedBlock) {
            failedBlock(response);
        }
    }];
}

/**
 屏蔽用户帖子
 */
+ (void)shieldEssayAction:(NSMutableDictionary *)param succ:(processSuccResp)succBlock failure:(processfailedResp)failedBlock{
    
    [WHAPIClient POST:BGCommunityPost(@"member-shield-post") param:param tokenType:1 succ:^(NSDictionary *response) {
        if (succBlock) {
            succBlock(response);
        }
    } failure:^(NSDictionary *response) {
        if (failedBlock) {
            failedBlock(response);
        }
    }];
}

/**
 获取帖子评论列表
 */
+ (void)getCommentList:(NSMutableDictionary *)param succ:(processSuccResp)succBlock failure:(processfailedResp)failedBlock{
    
    [WHAPIClient GET:BGCommentPost(@"get-review-page") param:param tokenType:1 succ:^(NSDictionary *response) {
        if (succBlock) {
            succBlock(response);
        }
    } failure:^(NSDictionary *response) {
        if (failedBlock) {
            failedBlock(response);
        }
    }];
}

/**
 获取视频帖子评论列表
 */
+ (void)getVideoCommentList:(NSMutableDictionary *)param succ:(processSuccResp)succBlock failure:(processfailedResp)failedBlock{
    
//    int tokenType = 3;
//    if ([Tool isLogin]) {
//        tokenType = 1;
//    }
    
    [WHAPIClient GET:BGCommentPost(@"get-video-review-page") param:param tokenType:1 succ:^(NSDictionary *response) {
        if (succBlock) {
            succBlock(response);
        }
    } failure:^(NSDictionary *response) {
        if (failedBlock) {
            failedBlock(response);
        }
    }];
}

/**
 获取某一个评论的详细信息
 */
+ (void)getOneCommentDetail:(NSMutableDictionary *)param type:(int)type succ:(processSuccResp)succBlock failure:(processfailedResp)failedBlock{
    
     NSString *url = (type==2) ? BGCommentPost(@"get-video-review-detail") : BGCommentPost(@"get-review-detail");
    
    [WHAPIClient GET:url param:param tokenType:1 succ:^(NSDictionary *response) {
        if (succBlock) {
            succBlock(response);
        }
    } failure:^(NSDictionary *response) {
        if (failedBlock) {
            failedBlock(response);
        }
    }];
}

/**
 给评论点赞
 */
+ (void)likeThisComment:(NSMutableDictionary *)param succ:(processSuccResp)succBlock failure:(processfailedResp)failedBlock{
    
    [WHAPIClient POST:BGLikePost(@"add-or-cancel-review-like") param:param tokenType:1 succ:^(NSDictionary *response) {
        if (succBlock) {
            succBlock(response);
        }
    } failure:^(NSDictionary *response) {
        if (failedBlock) {
            failedBlock(response);
        }
    }];
}

/**
 添加评论
 */
+ (void)AddComment:(NSMutableDictionary *)param succ:(processSuccResp)succBlock failure:(processfailedResp)failedBlock{
    
    [WHAPIClient POST:BGCommentPost(@"add-review") param:param tokenType:4 succ:^(NSDictionary *response) {
        if (succBlock) {
            succBlock(response);
        }
    } failure:^(NSDictionary *response) {
        if (failedBlock) {
            failedBlock(response);
        }
    }];
}

/**
 首页most数据
 */
+ (void)getHomepageData:(NSMutableDictionary *)param succ:(processSuccResp)succBlock failure:(processfailedResp)failedBlock{
    
    [WHAPIClient GET:BGHomeGet(@"get-banner-video-country") param:param tokenType:3 succ:^(NSDictionary *response) {
        if (succBlock) {
            succBlock(response);
        }
    } failure:^(NSDictionary *response) {
        if (failedBlock) {
            failedBlock(response);
        }
    }];
}

/**
 首页line数据
 */
+ (void)getHomepageLineData:(NSMutableDictionary *)param succ:(processSuccResp)succBlock failure:(processfailedResp)failedBlock{
    
    [WHAPIClient GET:BGHomeGet(@"get-home-route-page") param:param tokenType:3 succ:^(NSDictionary *response) {
        if (succBlock) {
            succBlock(response);
        }
    } failure:^(NSDictionary *response) {
        if (failedBlock) {
            failedBlock(response);
        }
    }];
}

/**
 获取视频列表
 */
+ (void)getVideoList:(NSMutableDictionary *)param succ:(processSuccResp)succBlock failure:(processfailedResp)failedBlock{
    
    [WHAPIClient GET:BGVideoGet(@"get-video-page") param:param tokenType:3 succ:^(NSDictionary *response) {
        if (succBlock) {
            succBlock(response);
        }
    } failure:^(NSDictionary *response) {
        if (failedBlock) {
            failedBlock(response);
        }
    }];
}

/**
 获取视频详情
 */
+ (void)getVideoDetail:(NSMutableDictionary *)param succ:(processSuccResp)succBlock failure:(processfailedResp)failedBlock{
    
    int tokenType = 3;
    if ([Tool isLogin]) {
        tokenType = 1;
    }
    
    [WHAPIClient GET:BGVideoGet(@"get-video-detail") param:param tokenType:tokenType succ:^(NSDictionary *response) {
        if (succBlock) {
            succBlock(response);
        }
    } failure:^(NSDictionary *response) {
        if (failedBlock) {
            failedBlock(response);
        }
    }];
}

/**
 用户编辑帖子
 */
+ (void)publishEditPost:(NSMutableDictionary *)param succ:(processSuccResp)succBlock failure:(processfailedResp)failedBlock{
    
    [WHAPIClient POST:BGCommunityPost(@"add-or-edit-post") param:param tokenType:4 succ:^(NSDictionary *response) {
        if (succBlock) {
            succBlock(response);
        }
    } failure:^(NSDictionary *response) {
        if (failedBlock) {
            failedBlock(response);
        }
    }];
}

/**
 用户删除帖子
 */
+ (void)publishDeletePost:(NSMutableDictionary *)param succ:(processSuccResp)succBlock failure:(processfailedResp)failedBlock{
    
    [WHAPIClient POST:BGCommunityPost(@"delete-post") param:param tokenType:1 succ:^(NSDictionary *response) {
        if (succBlock) {
            succBlock(response);
        }
    } failure:^(NSDictionary *response) {
        if (failedBlock) {
            failedBlock(response);
        }
    }];
}

@end
