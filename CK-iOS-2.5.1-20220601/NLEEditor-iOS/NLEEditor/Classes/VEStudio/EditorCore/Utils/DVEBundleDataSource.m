//
//  DVEBundleDataSource.m
//  NLEEditor
//
//  Created by bytedance on 2021/4/9.
//

#import "DVEBundleDataSource.h"
#import <NLEPlatform/NLEResourceNode+iOS.h>
#import <TTVideoEditor/HTSVideoData+CacheDirPath.h>


@interface DVEBundleDataSource()

@property (nonatomic, weak) DVEVCContext *vcContext;

@end

@implementation DVEBundleDataSource

- (instancetype)initWithVEVCContext:(DVEVCContext *)vcContext
{
    self = [super init];
    if (self) {
        _vcContext = vcContext;
    }
    return self;
}

#pragma mark - NLEBundleDataSource

- (NSString *)resourcePathForNode:(NLEResourceNode_OC *)resourceNode
{
    if (resourceNode.resourceFile.length == 0) {
        return nil;
    }
    // for path begin with /var
    NSURL *url = [NSURL URLWithString:resourceNode.resourceFile];
    if (url && url.isFileURL) {
        return url.path;
    }
    
    // for path begin with /var
    if ([resourceNode.resourceFile containsString:@"/Data/Application"]) {
        return url.path;
    }
    
    NSArray *draftPaths = @[[HTSVideoData cacheDirPath],
                            [[NSBundle mainBundle] pathForResource:@"music" ofType:@"bundle"],
                            [[NSBundle mainBundle] pathForResource:@"sound" ofType:@"bundle"]];
    for (NSString *draftPath in draftPaths) {
        NSString *path = [NSString stringWithFormat:@"%@/%@", draftPath, resourceNode.resourceFile];
        
        if ([[NSFileManager defaultManager] fileExistsAtPath:path]) {
            return path;
        }
    }
    
    return resourceNode.resourceFile;
}



@end
