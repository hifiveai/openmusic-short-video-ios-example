//
//  DVEAlbumTemplateModel.h
//  VideoTemplate
//
//  Created by bytedance on 2021/4/20.
//

#import <Foundation/Foundation.h>
#import "DVEAlbumCutSameFragmentModel.h"
#import "DVEAlbumBaseModel.h"
#import <CoreGraphics/CoreGraphics.h>

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSUInteger, DVEAlbumTemplateItemStatus) {
    DVEAlbumTemplateItemStatusOnline = 1,             // 上线
    DVEAlbumTemplateItemStatusOffline = 2,            // 下架
    DVEAlbumTemplateItemStatusDeleted = 3,            // 删除
    DVEAlbumTemplateItemStatusBanned = 4,             // 封禁
    DVEAlbumTemplateItemStatusPreReview = 5,          // 审核前
    DVEAlbumTemplateItemStatusHomepageReviewing = 6,  // 审核后划为主页可见，运营平台暂未审核
    DVEAlbumTemplateItemStatusFeedReviewing = 7,      // 审核后feed流可见，运营平台暂未审核
    DVEAlbumTemplateItemStatusUnknown = 99,           // 未知状态
};

#pragma mark - DVEAlbumTemplateAuthor
@interface DVEAlbumTemplateAuthor : DVEAlbumBaseModel

@property (nonatomic, assign) NSInteger uid;

@property (nonatomic, copy) NSString *name;

@property (nonatomic, copy) NSString *avatarUrl;

@end

#pragma mark - DVEAlbumTemplateVideoInfo
@interface DVEAlbumTemplateVideoInfo : DVEAlbumBaseModel

/// 视频URL
@property (nonatomic, copy) NSString *url;

@end

#pragma mark - DVEAlbumTemplateCoverModel
@interface DVEAlbumTemplateCoverModel : DVEAlbumBaseModel

/// 封面链接
@property (nonatomic, copy) NSString *url;

@property (nonatomic, assign) CGFloat width;

@property (nonatomic, assign) CGFloat height;

@end

#pragma mark - DVEAlbumTemplateLimit
@interface DVEAlbumTemplateLimit : DVEAlbumBaseModel

@property (nonatomic, copy) NSString *sdkVersionMin;

@property (nonatomic, copy) NSArray<NSString *> *platform;

@end

#pragma mark - DVEAlbumCutSameTemplateModel
// 上传模板时的信息
@interface DVEAlbumCutSameTemplateModel : DVEAlbumBaseModel

@property (nonatomic, copy) NSArray<DVEAlbumCutSameFragmentModel *> *fragments;

@property (nonatomic, copy) NSString *alignMode;

@end

#pragma mark - DVEAlbumTemplateModel
@interface DVEAlbumTemplateModel : DVEAlbumBaseModel

/// 模板id
@property (nonatomic, assign) NSInteger templateID;

/// 模板短标题
@property (nonatomic, copy) NSString *shortTitle;

/// 模版常规标题
@property (nonatomic, copy) NSString *title;

/// 作者信息,可选，PGC内容没有这个字段
@property (nonatomic, strong) DVEAlbumTemplateAuthor *author;

/// 业务方自定义counter信息
@property (nonatomic, copy) NSDictionary *counterData;

/// 封面信息
@property (nonatomic, strong) DVEAlbumTemplateCoverModel *cover;

/// 原视频信息
@property (nonatomic, strong) DVEAlbumTemplateVideoInfo *originVideoInfo;

/// 播放信息(转码后)
@property (nonatomic, strong) DVEAlbumTemplateVideoInfo *videoInfo;

/// 模板上传时的限制
@property (nonatomic, strong) DVEAlbumTemplateLimit *limit;

/// 模板创建时间
@property (nonatomic, assign) NSInteger createTime;

/// 视频时长
@property (nonatomic, assign) NSInteger duration;

/// 客户端上传模板时的信息
@property (nonatomic, copy) NSString *extra;

/// extra转模型
@property (nonatomic, copy) DVEAlbumCutSameTemplateModel *extraModel;

/// 模板分段数
@property (nonatomic, assign) NSInteger fragmentCount;

/// 模板使用人数
@property (nonatomic, assign) NSUInteger usageAmount;

/// 模板like人数
@property (nonatomic, assign) NSUInteger likeAmount;

/// 模板md5
@property (nonatomic, copy) NSString *md5;

/// 模板状态，1.上线， 2.下架
@property (nonatomic, assign) DVEAlbumTemplateItemStatus status;

/// 模板标签
@property (nonatomic, copy) NSString *templateTags;

/// 模板下载链接
@property (nonatomic, copy) NSString *templateUrl;

/// 提示信息
@property (nonatomic, copy) NSString *hintLabel;

@end

NS_ASSUME_NONNULL_END
