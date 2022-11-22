//
//  DVEVCContextExternalInjectProtocol.h
//  NLEEditor
//
//  Created by bytedance on 2021/5/19.
//

#import <Foundation/Foundation.h>
#if ENABLE_SUBTITLERECOGNIZE
#import "DVESubtitleNetServiceProtocol.h"
#import "DVETextReaderServiceProtocol.h"
#endif
#import "DVELoggerProtocol.h"
#import "DVEResourcePickerProtocol.h"
#import "DVEResourceLoaderProtocol.h"
#import "DVEEditorEventProtocol.h"

NS_ASSUME_NONNULL_BEGIN

// 实现该协议所注入的对象的生命周期与编辑页 VC 绑定
@protocol DVEVCContextExternalInjectProtocol <NSObject>

@optional

#if ENABLE_SUBTITLERECOGNIZE
/// 语音转字幕网络能力
- (id<DVESubtitleNetServiceProtocol>)provideSubtitleNetService;

/// 文本朗读能力
- (id<DVETextReaderServiceProtocol>)provideTextReaderService;
#endif

/// 日志能力
- (id<DVELoggerProtocol>)provideDVELogger;

/// 相册选择能力
- (id<DVEResourcePickerProtocol>)provideResourcePicker;

/// 资源加载能力
- (id<DVEResourceLoaderProtocol>)provideResourceLoader;

/// 事件和转换能力
- (id<DVEEditorEventProtocol>)provideEditorEvent;
@end

NS_ASSUME_NONNULL_END
