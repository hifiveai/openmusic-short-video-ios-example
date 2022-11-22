//
//   DVECoreActionServiceProtocol.h
//   NLEEditor
//
//   Created  by bytedance on 2021/4/25.
//   Copyright © 2021 ByteDance Ltd. All rights reserved.
//

#import "DVECoreProtocol.h"

@class NLEEditor_OC;

NS_ASSUME_NONNULL_BEGIN

@protocol DVECoreActionNotifyProtocol <NSObject>

- (void)undoRedoWillClikeByUser;

- (void)undoRedoClikedByUser;

@end


@protocol DVECoreActionServiceProtocol <DVECoreProtocol>

@property (nonatomic, assign) BOOL canUndo;

@property (nonatomic, assign) BOOL canRedo;

@property (nonatomic, assign) BOOL isNeedHideUnReDo;

- (void)refreshUndoRedo;

- (BOOL)excuteUndo;

- (BOOL)excuteRedo;

- (void)notifyUndoRedoClikedByUser;

- (void)notifyUndoRedoWillClikeByUser;

- (void)addUndoRedoListener:(id<DVECoreActionNotifyProtocol>)listener;

- (void)removeUndoRedoListener:(id<DVECoreActionNotifyProtocol>)listener;

- (void)clearUndoRedoListener;


- (void)commitNLE:(BOOL)commit completion:(void (^ _Nullable)(NSError *_Nullable error))completion;

- (void)commitNLE:(BOOL)commit message:(NSString*)message completion:(void (^ _Nullable)(NSError *_Nullable error))completion;

- (void)commitNLE:(BOOL)commit;

- (void)commitNLE:(BOOL)commit message:(NSString*)message;

- (void)commitNLEWithoutNotify:(BOOL)commit;

@end

NS_ASSUME_NONNULL_END
