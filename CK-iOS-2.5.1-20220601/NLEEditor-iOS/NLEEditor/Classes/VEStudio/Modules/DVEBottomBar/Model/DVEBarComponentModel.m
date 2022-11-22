//
//   DVEBarComponentModel.m
//   NLEEditor
//
//   Created  by bytedance on 2021/5/27.
//   Copyright © 2021 ByteDance Ltd. All rights reserved.
//
    

#import "DVEBarComponentModel.h"

@implementation DVEBarComponentViewModel

@synthesize localAssetImage = _localAssetImage;

@synthesize imageURL = _imageURL;

@synthesize title = _title;

- (instancetype)initWithImage:(UIImage *)image url:(NSURL *)url title:(NSString *)title
{
    if (self = [super init]) {
        _localAssetImage = image;
        _imageURL = url;
        _title = title;
    }
    return self;
}

- (NSString *)description
{
    return [NSString stringWithFormat:@"asset:%@ url:%@ title:%@", self.localAssetImage,self.imageURL,self.title];
}

@end

@implementation DVEBarComponentModel

@synthesize clickActionName;

@synthesize componentType;

@synthesize parent;

@synthesize subComponents;

@synthesize viewModel;

@synthesize componentGroup;

@synthesize currentSubGroup;

@synthesize statusActionName;

- (NSString *)description
{
    return [NSString stringWithFormat:@"parent:%ld componentType:%ld action:%@", (long)self.parent.componentType,(long)self.componentType,self.clickActionName];
}

@end
