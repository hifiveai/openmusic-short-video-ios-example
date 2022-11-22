//
//   DVEService.m
//   NLEEditor
//
//   Created  by ByteDance on 2021/9/27.
//   Copyright © 2021 ByteDance Ltd. All rights reserved.
//
    

#import "DVEService.h"
#import "DVEServiceInjectionLocator.h"
#import <DVETrackKit/DVECustomResourceProvider.h>
#import "NSBundle+DVE.h"

void DVEServiceInit(Class serviceContainerClass)
{
    DVEGlobalServiceContainerRegister(serviceContainerClass);
    [[DVECustomResourceProvider shareManager] registerDefaultBundle:[NSBundle dve_mainBundle]];
}




