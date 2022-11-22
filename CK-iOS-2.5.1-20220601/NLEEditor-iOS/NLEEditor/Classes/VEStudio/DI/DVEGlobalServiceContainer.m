//
//  DVEGlobalServiceContainer.m
//  NLEEditor
//
//  Created by bytedance on 2021/9/9.
//

#import "DVEGlobalServiceContainer.h"
#import "DVEGlobalExternalInjectProtocol.h"
#import <DVETrackKit/DVECustomResourceProvider.h>

@implementation DVEGlobalServiceContainer

+ (instancetype)sharedContainer
{
    static dispatch_once_t onceToken;
    static DVEGlobalServiceContainer *globalServiceContainer = nil;
    dispatch_once(&onceToken, ^{
        globalServiceContainer = [[super alloc] init];
    });
    return globalServiceContainer;
}

@end

DVEGlobalServiceContainer* DVEGlobalContainer(void)
{
    return [DVEGlobalServiceContainer sharedContainer];
}

DVEServiceProvider* DVEGlobalServiceProvider(void)
{
    static dispatch_once_t onceToken;
    static DVEServiceProvider *globalProvider = nil;
    dispatch_once(&onceToken, ^{
        globalProvider = [[DVEServiceProvider alloc] initWithContainer:DVEGlobalContainer()];
    });
    return globalProvider;
}

void DVEGlobalServiceContainerRegister(Class serviceContainerClass)
{
    if (serviceContainerClass == nil) return;

    id<DVEGlobalExternalInjectProtocol> serviceContainer = [[serviceContainerClass alloc] init];

    if([serviceContainer conformsToProtocol:@protocol(DVEGlobalExternalInjectProtocol)]){
        [DVEGlobalContainer() registerClass:serviceContainerClass forProtocol:@protocol(DVEGlobalExternalInjectProtocol) scope:DVEInjectScopeTypeSingleton];
        
        if ([serviceContainer respondsToSelector:@selector(customResourceProvideBundle)]) {
            [[DVECustomResourceProvider shareManager] setMainBundle:[serviceContainer customResourceProvideBundle]];
        }
    }
}
