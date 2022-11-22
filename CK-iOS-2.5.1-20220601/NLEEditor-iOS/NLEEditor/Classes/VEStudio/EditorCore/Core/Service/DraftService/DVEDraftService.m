//
//   DVEDraftService.m
//   NLEEditor
//
//   Created  by bytedance on 2021/4/28.
//   Copyright © 2021 ByteDance Ltd. All rights reserved.
//
    

#import "DVEDraftService.h"
#import <DVETrackKit/NLEModel_OC+NLE.h>
#import <NLEPlatform/NLEStyleText+iOS.h>
#import <NLEPlatform/NLESegmentInfoSticker+iOS.h>
#import <TTVideoEditor/IESMMCanvasSource.h>
#import <TTVideoEditor/VEEditorSession.h>
#import <TTVideoEditor/VEEditorSession+Effect.h>
#import <TTVideoEditor/VEVideoAnimation.h>
#import "NSDictionary+DVE.h"
#import "DVEVCContext.h"
#import "NSArray+RGBA.h"
#import "DVETextParm.h"
#import "DVECustomerHUD.h"
#import "DVEMacros.h"
#import "NSString+VEIEPath.h"
#import "DVEDataStore.h"
#import "NSString+DVEToPinYin.h"
#import "NSString+VEToImage.h"
#import "NSString+VEIEPath.h"
#import "DVEDraftModel.h"
#import "DVELoggerImpl.h"
#import "DVEGlobalExternalInjectProtocol.h"
#import "DVEServiceLocator.h"

@interface DVEDraftService()

@property (nonatomic, strong) DVEDataStore *store;

@property (nonatomic, weak) id<DVENLEEditorProtocol> nleEditor;
@property (nonatomic, weak) id<DVENLEInterfaceProtocol> nle;

@end

@implementation DVEDraftService

DVEAutoInject(self.vcContext.serviceProvider, nleEditor, DVENLEEditorProtocol)
DVEAutoInject(self.vcContext.serviceProvider, nle, DVENLEInterfaceProtocol)

@synthesize vcContext;
@synthesize draftModel = _draftModel;
@synthesize draftRootPath = _draftRootPath;

- (instancetype)initWithContext:(DVEVCContext *)context
{
    if (self = [super init]) {
        self.vcContext = context;
        id<DVEGlobalExternalInjectProtocol> config = DVEOptionalInline(DVEGlobalServiceProvider(), DVEGlobalExternalInjectProtocol);
        if ([config respondsToSelector:@selector(draftFolderPath)]) {
            _draftRootPath = [config draftFolderPath];
        } else {
            _draftRootPath = [NSHomeDirectory() stringByAppendingPathComponent:@"Documents/DVEEditorDraft"];
        }
    }
    
    return self;
}

- (void)setDraftModel:(DVEDraftModel *)draftModel
{
    _draftModel = draftModel;
    self.nle.draftFolder = [self.draftRootPath stringByAppendingPathComponent:self.draftModel.draftID];
}

- (void)createDraftModel
{
    DVEDraftModel *model = [DVEDraftModel new];
    model.draftID = [NSString VEUUIDString];
    [self createModelCacheFolder:model];
    self.draftModel = model;
}

- (void)createModelCacheFolder:(DVEDraftModel *)draftModel
{
    NSString *draftPath = [self draftPathForModel:draftModel];
    if (![[NSFileManager defaultManager] fileExistsAtPath:draftPath]) {
        NSError* error;
        [[NSFileManager defaultManager] createDirectoryAtPath:draftPath
                                  withIntermediateDirectories:YES
                                                   attributes:nil
                                                        error:&error];
        if (error) {
            DVELogError(@"create directory fail: %@", draftPath);
        }
    }
}

- (void)deleteModelCacheFolder:(DVEDraftModel *)draftModel
{
    NSString *draftPath = [self draftPathForModel:draftModel];
    NSError *error = nil;
    if(![NSFileManager.defaultManager removeItemAtPath:draftPath error:&error]){
        if (error) {
            DVELogError(@"delete directory fail: %@", draftPath);
        }
    }
}

- (NSString *)draftPathForModel:(DVEDraftModel *)draftModel
{
    return [self.draftRootPath stringByAppendingPathComponent:draftModel.draftID];
}

- (NSString *)currentDraftPath
{
    return [self draftPathForModel:self.draftModel];
}

- (DVEDataStore *)store
{
    if (!_store) {
        _store = [DVEDataStore shareDataStore];
    }
    
    return _store;
}

- (void)saveDraftModel:(DVEDraftModel *)model
{
    if(model == nil) return;
    NSString *json =  [self.nleEditor store];
    DVELogInfo(@"draft string : %@",json);
    
    [self saveDraftCoverIfNeedWithModel:model];
    
    NSData *jsonData = [json dataUsingEncoding:NSUTF8StringEncoding];
    NSError *error;
    NSDictionary *newJson = [NSJSONSerialization JSONObjectWithData:jsonData options:NSJSONReadingMutableContainers error:&error];
    if (!error) {
        ///app打开的时候沙盒和bundle唯一编码路径会发生变化，所以这里要带入当前草稿快照时沙盒路径字段，恢复草稿做批量替换使用
        NSMutableDictionary* newDic = [NSMutableDictionary dictionaryWithDictionary:newJson];
        [newDic setObject:NSHomeDirectory() forKey:@"appPath"];
        [newDic setObject:[[[NSBundle mainBundle] bundlePath] stringByDeletingLastPathComponent] forKey:@"bundlePath"];
        json = [newDic dve_toJsonString];
    }

    NSTimeInterval duration = [self.vcContext.playerService updateVideoDuration];
    model.date = [[NSString DVE_curDateString] substringWithRange:NSMakeRange(0, 10)];
    model.duration = duration;
    model.videoInfo = json;
    
    if (model.iconFileUrl.length == 0) {
        NSString *documentDirectory = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) firstObject];
        NSString *releativePath = [self.currentDraftPath stringByReplacingOccurrencesOfString:documentDirectory withString:@""];
        NSString *savePath = [releativePath stringByAppendingPathComponent:[model.draftID stringByAppendingString:@".jpg"]];
        NSString *writePath = [self.currentDraftPath stringByAppendingPathComponent:[savePath lastPathComponent]];
        model.iconFileUrl = savePath;
        CGSize preferredSize = [DVEAutoInline(self.vcContext.serviceProvider, DVECoreCanvasProtocol) canvasSize];
        [self.vcContext.playerService getProcessedPreviewImageAtTime:0
                                                     preferredSize:preferredSize
                                                       compeletion:^(UIImage * _Nullable image, NSTimeInterval atTime) {
            [UIImageJPEGRepresentation(image, 1) writeToFile:writePath atomically:YES];
        }];
    }
    
    [self.store addOneDarftWithModel:model];
}

- (void)saveDraftCoverIfNeedWithModel:(DVEDraftModel *)model {
    NSString *path = [[self.currentDraftPath stringByAppendingPathComponent:model.draftID] stringByAppendingString:@".jpg"];
    NLEVideoFrameModel_OC *coverModel = self.nleEditor.nleModel.coverModel;
    //将当前封面编辑的缩略图作为草稿封面
    if (coverModel.snapshot) {
        NSString *snapshotPath = [self.nle getAbsolutePathWithResource:coverModel.snapshot];
        NSError *error = nil;
        [[NSFileManager defaultManager] removeItemAtPath:path error:&error];
        [[NSFileManager defaultManager] copyItemAtPath:snapshotPath toPath:path error:&error];
        NSString *documentDirectory = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) firstObject];
        NSString *releativePath = [path stringByReplacingOccurrencesOfString:documentDirectory withString:@""];
        model.iconFileUrl = releativePath;
        if (error) {
            DVELogError(@"the snapshot of coverModel copy failed:%@ when save draftModel", error);
        }
    }
}

- (void)restoreDraftModel:(DVEDraftModel *)model
{
    if(model == nil) return;
    self.draftModel = model;
    NSString* orgJson = model.videoInfo;
    
    NSData *jsonData = [orgJson dataUsingEncoding:NSUTF8StringEncoding];
    NSError *error;
    NSDictionary *orgDic = [NSJSONSerialization JSONObjectWithData:jsonData options:NSJSONReadingMutableContainers error:&error];
    if (!error) {
        ///app打开的时候沙盒和Bundle唯一编码路径会发生变化，这里要把草稿保存时的路径替换成当前唯一编码路径再交给nle做恢复
        NSMutableDictionary* newDic = [NSMutableDictionary dictionaryWithDictionary:orgDic];
        
        NSString* lastHomePath = [orgDic objectForKey:@"appPath"];
        [newDic removeObjectForKey:@"appPath"];
        lastHomePath = [self cutHomePath:lastHomePath];
        NSString* currentHomePath = NSHomeDirectory();
        currentHomePath = [self cutHomePath:currentHomePath];

        NSString* lastBundlePath = [orgDic objectForKey:@"bundlePath"];
        [newDic removeObjectForKey:@"bundlePath"];
        lastBundlePath = [self cutHomePath:lastBundlePath];
        NSString* currentBundlePath = [[[NSBundle mainBundle] bundlePath] stringByDeletingLastPathComponent];
        currentBundlePath = [self cutHomePath:currentBundlePath];
        
        NSString* newJson = [newDic dve_toJsonString];
        
        if(lastHomePath){
            newJson = [orgJson stringByReplacingOccurrencesOfString:lastHomePath withString:currentHomePath];
        }
        if(lastBundlePath){
            newJson = [orgJson stringByReplacingOccurrencesOfString:lastBundlePath withString:currentBundlePath];
        }
        
        model.videoInfo = newJson;
    }
    
    NLEError nleError = [self.nleEditor restore:model.videoInfo];
    NSAssert(nleError == SUCCESS, @"restore NLEEditor from draft error!!!");
}

///目前唯一编码路径只是最后一段UUID码发生变化，所以只截取最后一段路径做替换
-(NSString*)cutHomePath:(NSString*)str {
    return [str lastPathComponent];
}


- (NSArray <DVEDraftModel *>*)getAllDrafts
{
    return [self.store getAllDrafts];
}

- (void)addOneDarftWithModel:(DVEDraftModel *)draft
{
    [self.store addOneDarftWithModel:draft];
}

- (void)removeOneDraftModel:(DVEDraftModel *)draft
{
    [self.store removeOneDraftModel:draft];
    [self deleteModelCacheFolder:draft];
}

- (NSString * _Nullable)copyResourceToDraft:(NSURL *)resourceURL resourceType:(NLEResourceType)resourceType
{
    if (!resourceURL) {
        return nil;
    }
    NSString *relativePath = [self folderForResourceType:resourceType];
    NSString *relativePathWithRoot = [@"/" stringByAppendingPathComponent:relativePath];
    BOOL isDir;
    BOOL isFileExist = [[NSFileManager defaultManager] fileExistsAtPath:resourceURL.path isDirectory:&isDir];
    if (!isFileExist) {
        if (!([resourceURL.path hasPrefix:relativePath] || [resourceURL.path hasPrefix:relativePathWithRoot])) {
            NSAssert(NO, @"sticker resource path is invaild!!!");
        }
        return resourceURL.relativeString;
    }
    
    NSError *error = nil;
    NSString *targetFolder = [self.currentDraftPath stringByAppendingPathComponent:relativePath];
    if (![[NSFileManager defaultManager] fileExistsAtPath:targetFolder]) {
        [[NSFileManager defaultManager] createDirectoryAtPath:targetFolder withIntermediateDirectories:YES attributes:nil error:&error];
        
        if (error) {
            DVELogError(@"create sub folder fail: %@", error);
        }
    }
    
    relativePath = [relativePath stringByAppendingPathComponent:resourceURL.absoluteString.lastPathComponent];
    NSString *destPath = [self.currentDraftPath stringByAppendingPathComponent:relativePath];
    if (![[NSFileManager defaultManager] fileExistsAtPath:destPath]) {
        [NSFileManager.defaultManager copyItemAtPath:resourceURL.path toPath:destPath error:&error];
        
        if (error) {
            DVELogError(@"copy item fail: %@ to %@", resourceURL.path, destPath);
        }
    }
    
    return relativePath;
}

- (NSString * _Nullable)convertResourceToDraftPath:(NSURL *)resourceURL resourceType:(NLEResourceType)resourceType
{
    if (!resourceURL) {
        return nil;
    }
    NSString *relativePath = [self folderForResourceType:resourceType];
    relativePath = [relativePath stringByAppendingPathComponent:resourceURL.absoluteString.lastPathComponent];
    return relativePath;
}

- (void)removeResource:(NLEResourceNode_OC *)resourceNode
{
    
}

- (NSString *)folderForResourceType:(NLEResourceType)resourceType
{
    switch (resourceType) {
        case NLEResourceTypeVideo:
        case NLEResourceTypeImage:
            return @"video";
        case NLEResourceTypeAudio:
        case NLEResourceTypeSound:
        case NLEResourceTypeRecord:
            return @"audio";
        case NLEResourceTypeEffect:
            return @"effect";
        case NLEResourceTypeFilter:
            return @"filter";
        case NLEResourceTypeAdjust:
            return @"adjust";
        case NLEResourceTypeTransition:
            return @"transition";
        case NLEResourceTypeSticker:
        case NLEResourceTypeImageSticker:
        case NLEResourceTypeInfoSticker:
            return @"sticker";
        case NLEResourceTypeTextTemplate:
            return @"text/text_template";
        case NLEResourceTypeFlower:
            return @"text/flower";
        case NLEResourceTypeMask:
            return @"mask";
        case NLEResourceTypeAnimationVideo:
            return @"animation";
        case NLEResourceTypeFont:
            return @"text/font";
        default:
            return @"";
    }
}

@end
