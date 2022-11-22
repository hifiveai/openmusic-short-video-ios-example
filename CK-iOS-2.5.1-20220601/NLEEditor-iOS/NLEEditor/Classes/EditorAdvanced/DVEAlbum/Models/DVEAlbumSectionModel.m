//
//  DVEAlbumSectionModel.m
//  CameraClient
//
//  Created by bytedance on 2020/7/16.
//

#import "DVEAlbumSectionModel.h"
  
@implementation DVEAlbumSectionModel

- (instancetype)init
{
    self = [super init];
    if (self) {
        _identifier = NSStringFromClass([self class]);
    }
    return self;
}

- (void)setTitle:(NSString *)title
{
    _title = title;
    _identifier = [NSString stringWithFormat:@"%@_%@", @(_resourceType), _title];
}

- (void)setResourceType:(DVEAlbumGetResourceType)resourceType
{
    _resourceType = resourceType;
    _identifier = [NSString stringWithFormat:@"%@_%@", @(_resourceType), _title];
}

- (nonnull id<NSObject>)diffIdentifier
{
    return _identifier;
}

- (BOOL)isEqualToDiffableObject:(DVEAlbumSectionModel *)object
{
    if (self.assetsModels == nil) {
        return [self.identifier isEqualToString:object.identifier];
    }
    return [self.assetsModels isEqualToArray:object.assetsModels];
}

@end
