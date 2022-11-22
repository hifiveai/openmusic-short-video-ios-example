//
//   VEResourceModel.m
//   TTVideoEditorDemo
//
//   Created  by bytedance on 2021/5/14.
//   Copyright © 2021 ByteDance Ltd. All rights reserved.
//
    

#import "VEResourceModel.h"
#import "CKEditorHeader.h"

@implementation VEResourceCategoryModel

@synthesize models;
@synthesize name;
@synthesize order;
@synthesize categoryId;



@end

@implementation VEResourceModel

@synthesize imageURL;
@synthesize name;
@synthesize sourcePath;
@synthesize assetImage;
@synthesize identifier;
@synthesize stickerType;
@synthesize alignType;
@synthesize color;
@synthesize overlap;
@synthesize style;
@synthesize typeSettingKind;
@synthesize textTemplateDeps;
@synthesize resourceTag;
@synthesize canvasType;
@synthesize mask;

///资源状态
- (DVEResourceModelStatus)status
{
    return DVEResourceModelStatusDefault;
}


@end


@implementation VETextTemplateDepResourceModel
@synthesize path;
@synthesize resourceId;
@end
