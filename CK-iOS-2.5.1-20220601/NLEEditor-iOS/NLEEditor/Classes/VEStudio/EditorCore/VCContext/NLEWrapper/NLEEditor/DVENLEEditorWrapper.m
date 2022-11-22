//
//  DVENLEEditorWrapper.m
//  NLEEditor
//
//  Created by bytedance on 2021/9/16.
//

#import "DVENLEEditorWrapper.h"
#import <NLEPlatform/NLEEditor+iOS.h>

@interface DVENLEEditorWrapper ()

@property (nonatomic, weak) NLEEditor_OC *nleEditor;

@end

@implementation DVENLEEditorWrapper

- (instancetype)initWithNLEEditor:(NLEEditor_OC *)nleEditor
{
    self = [super init];
    if (self) {
        _nleEditor = nleEditor;
    }
    return self;
}

#pragma mark - DVENLEEditorProtocol

- (void)addDelegate:(id<NLEEditorDelegate>)delegate
{
    [self.nleEditor addDelegate:delegate];
}

- (void)removeDelegate:(id<NLEEditorDelegate>)delegate
{
    [self.nleEditor removeDelegate:delegate];
}

- (void)addListener:(id<NLEEditor_iOSListenerProtocol>)listener
{
    [self.nleEditor addListener:listener];
}

- (BOOL)undo
{
    return [self.nleEditor undo];
}

- (BOOL)redo
{
    return [self.nleEditor redo];
}

- (BOOL)canUndo
{
    return [self.nleEditor canUndo];
}

- (BOOL)canRedo
{
    return [self.nleEditor canRedo];
}

- (void)commit
{
    [self commit:nil];
}

- (void)commit:(void (^ _Nullable)(NSError *_Nullable error))completion
{
    id<NLEEditorCommitContextProtocol> context = [self.nleEditor commit];
    [self.nleEditor doRender:context completion:^(NSError * _Nonnull renderError) {
        if ([NSThread isMainThread]) {
            !completion ?: completion(renderError);
        } else {
            dispatch_async(dispatch_get_main_queue(), ^{
                !completion ?: completion(renderError);
            });
        }
    }];
}

- (BOOL)done
{
    return [self.nleEditor done];
}

- (BOOL)done:(NSString*)message
{
    return [self.nleEditor done:message];
}

- (NSString *)store
{
    return [self.nleEditor store];
}

- (NLEError)restore:(NSString *)jsonString
{
    return [self.nleEditor restore:jsonString];
}

- (NLEModel_OC *)nleModel
{
    return [self.nleEditor model];
}

- (void)setNleModel:(NLEModel_OC *)nleModel
{
    self.nleEditor.model = nleModel;
}

- (NLEBranch_OC*)branch
{
    return [self.nleEditor branch];
}

@end
