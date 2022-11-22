//
//   DVEUIFactory.m
//   NLEEditor
//
//   Created  by bytedance on 2021/5/24.
//   Copyright © 2021 ByteDance Ltd. All rights reserved.
//
    

#import "DVEUIFactory.h"
#import "DVEViewController.h"
#import "DVEDraftViewController.h"

@implementation DVEUIFactory

#pragma mark - EditPage

+ (UIViewController *)createDVEViewController
{
    return [[DVEViewController alloc] init];
}

+ (UIViewController *)createDVEViewControllerWithResources:(NSArray<id<DVEResourcePickerModel>> *)resources
                                             injectService:(id<DVEVCContextExternalInjectProtocol>)injectService
{
    return [DVEViewController vcWithResources:resources injectService:injectService];
}

+ (UIViewController *)createDVEViewControllerWithDraft:(DVEDraftModel *)draft
                                         injectService:(id<DVEVCContextExternalInjectProtocol>)injectService
{
    return [[DVEViewController alloc] initWithDraftModel:draft injectService:injectService];
}

+ (UIViewController *)createDVEViewControllerWithNLEModelString:(NSString *)nleModelString draftFolder:(NSString *)draftFolder injectService:(id<DVEVCContextExternalInjectProtocol>)injectService {
    DVEViewController *vc = [[DVEViewController alloc] initWithModelString:nleModelString draftFolder:draftFolder injectService:injectService];
    return vc;
}

#pragma mark - DraftPage

+ (UIViewController *)createDVEDraftViewControllerWithInjectService:(id<DVEVCContextExternalInjectProtocol>)injectService
{
    DVEDraftViewController *vc = [[DVEDraftViewController alloc] init];
    vc.serviceInjectContainer = injectService;
    return vc;
}

@end
