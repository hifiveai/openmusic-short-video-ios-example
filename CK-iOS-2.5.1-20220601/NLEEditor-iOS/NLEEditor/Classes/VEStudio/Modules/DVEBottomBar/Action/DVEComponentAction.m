//
//   DVEComponentAction.m
//   NLEEditor
//
//   Created  by bytedance on 2021/5/26.
//   Copyright © 2021 ByteDance Ltd. All rights reserved.
//
    

#import "DVEComponentAction.h"
#import "DVEComponentAction+Private.h"

#define AnimationDuration (0.2f)
#define DVEComponentActionViewTag (82634)

@interface DVEComponentAction()

///剪辑上下文
@property (nonatomic, weak) DVEVCContext *vcContext;
///Bar依附VC
@property (nonatomic, weak) DVEViewController *parentVC;

@property (nonatomic, weak, readwrite) id<DVECoreVideoProtocol> videoEditor;
@property (nonatomic, weak, readwrite) id<DVECoreAudioProtocol> audioEditor;
@property (nonatomic, weak, readwrite) id<DVECoreTextProtocol> textEditor;
@property (nonatomic, weak, readwrite) id<DVECoreTextTemplateProtocol> textTemplateEditor;
@property (nonatomic, weak, readwrite) id<DVECoreEffectProtocol> effectEditor;
@property (nonatomic, weak, readwrite) id<DVECoreFilterProtocol> filterEditor;
@property (nonatomic, weak, readwrite) id<DVECoreStickerProtocol> stickerEditor;
@property (nonatomic, weak, readwrite) id<DVECoreRegulateProtocol> regulateEditor;
@property (nonatomic, weak, readwrite) id<DVECoreSlotProtocol> slotEditor;
@property (nonatomic, weak, readwrite) id<DVECoreImportServiceProtocol> importService;
@property (nonatomic, weak, readwrite) id<DVEResourcePickerProtocol> resourcePicker;
@property (nonatomic, weak, readwrite) id<DVENLEEditorProtocol> nleEditor;

@end

@implementation DVEComponentAction

DVEAutoInject(self.vcContext.serviceProvider, videoEditor, DVECoreVideoProtocol)
DVEAutoInject(self.vcContext.serviceProvider, audioEditor, DVECoreAudioProtocol)
DVEAutoInject(self.vcContext.serviceProvider, textEditor, DVECoreTextProtocol)
DVEAutoInject(self.vcContext.serviceProvider, textTemplateEditor, DVECoreTextTemplateProtocol)
DVEAutoInject(self.vcContext.serviceProvider, effectEditor, DVECoreEffectProtocol)
DVEAutoInject(self.vcContext.serviceProvider, filterEditor, DVECoreFilterProtocol)
DVEAutoInject(self.vcContext.serviceProvider, stickerEditor, DVECoreStickerProtocol)
DVEAutoInject(self.vcContext.serviceProvider, regulateEditor, DVECoreRegulateProtocol)
DVEAutoInject(self.vcContext.serviceProvider, slotEditor, DVECoreSlotProtocol)
DVEAutoInject(self.vcContext.serviceProvider, importService, DVECoreImportServiceProtocol)
DVEAutoInject(self.vcContext.serviceProvider, nleEditor, DVENLEEditorProtocol)

DVEOptionalInject(self.vcContext.serviceProvider, resourcePicker, DVEResourcePickerProtocol)

+ (instancetype)shareManager
{
    static DVEComponentAction * _instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _instance = [[super allocWithZone:nil] init];
    });
    return _instance;
}

+ (id)allocWithZone:(NSZone *)zone
{
    return [self shareManager];
}

- (id)copyWithZone:(NSZone *)zone
{
    return [[self class] shareManager];
}

- (id)mutableCopyWithZone:(NSZone *)zone
{
    return [[self class] shareManager];
}

- (instancetype)init
{
    if (self = [super init]) {
    }
    return self;
}

- (void)setupParentVC:(DVEViewController *)parentVC context:(DVEVCContext *)context
{
    self.parentVC = parentVC;
    self.vcContext = context;
}

- (void)actionNotFound:(NSObject*)obj
{
    NSLog(@"%@ actionNotFound",obj.description);
}

- (void)openSubComponent:(id<DVEBarComponentProtocol>)component
{
    [[DVEComponentViewManager sharedManager] showComponent:component animation:NO];
}

- (void)openParentComponent:(id<DVEBarComponentProtocol>)component
{
    if (component.parent) {
        [[DVEComponentViewManager sharedManager] popToParentComponent:NO];
    }
}

- (void)showActionView:(DVEBaseBar *)barView
{
    barView.tag = DVEComponentActionViewTag;
    barView.vcContext = self.vcContext;
    barView.parentVC = self.parentVC;
    [barView showInView:self.parentVC.view animation:NO];
}

- (void)dismissCurrentActionView
{
    UIView *view = [self.parentVC.view viewWithTag:DVEComponentActionViewTag];
    if ([view isKindOfClass:[DVEBaseBar class]]) {
        [((DVEBaseBar *)view) dismiss:YES];
    }
}

- (id)callMethod:(NSString*)method withArgument:(NSArray*)arguments
{
    id res = nil;
    SEL sel = NSSelectorFromString(method);
    NSMethodSignature* signature = [[self class] instanceMethodSignatureForSelector:sel];
    if (signature != nil) {
        NSInvocation* invocation =  [NSInvocation invocationWithMethodSignature:signature];
        //设置方法调用者
        invocation.target = self;
         //注意：这里的方法名一定要与方法签名类中的方法一致
        invocation.selector = sel;
        
        
        NSUInteger argsCount = signature.numberOfArguments - 2;
            
        NSUInteger arrCount = arguments.count;
        //获取最小值
        NSUInteger count = MIN(argsCount, arrCount);
        

        for (int i = 0; i<count; i++) {
            id arg = arguments[i];
            
            if ([arg isKindOfClass:[NSNull class]]) arg = nil;
            //这里的Index要从2开始，以为0跟1已经被占据了，分别是self（target）,selector(_cmd),即使方法的参数为空的时候,此处也应该加2
            [invocation setArgument:&arg atIndex: i + 2 ];
            
        }
        
        [invocation invoke];
        
        if (signature.methodReturnLength != 0) {
            [invocation getReturnValue:&res];
        }
    }else{
        [self actionNotFound:arguments];
    }
    return res;
}


@end
