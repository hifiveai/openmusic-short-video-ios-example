//
//  VENLEEditorServiceContainer.m
//  TTVideoEditorDemo
//
//  Created by bytedance on 2021/5/23.
//  Copyright © 2021 bytedance. All rights reserved.
//

#import "VENLEEditorServiceContainer.h"
#import "VELogger.h"
#import "VEResourcePicker.h"
#import "VEResourceLoader.h"
#import "VEEditorEventImp.h"

@interface VENLEEditorServiceContainer()

@property (nonatomic, strong) id<DVELoggerProtocol> logger;
@property (nonatomic, strong) id<DVEResourcePickerProtocol> resourcePicker;
@property (nonatomic, strong) id<DVEResourceLoaderProtocol> resourceLoader;
@property (nonatomic, strong) id<DVEEditorEventProtocol> paramConfig;

@end

@implementation VENLEEditorServiceContainer

- (id<DVELoggerProtocol>)provideDVELogger
{
    if (!_logger) {
        _logger = [[VELogger alloc] init];
    }
    return _logger;
}

- (id<DVEResourceLoaderProtocol>)provideResourceLoader
{
    if (!_resourceLoader) {
        _resourceLoader = [[VEResourceLoader alloc] init];
    }
    return _resourceLoader;
}

//- (id<DVEResourcePickerProtocol>)provideResourcePicker {
//    if (!_resourcePicker) {
//        _resourcePicker = [[VEResourcePicker alloc] init];
//    }
//    return _resourcePicker;
//}


- (id<DVEEditorEventProtocol>)provideEditorEvent
{
    if (!_paramConfig) {
        _paramConfig = [[VEEditorEventImp alloc] init];
    }
    return _paramConfig;
}

@end

