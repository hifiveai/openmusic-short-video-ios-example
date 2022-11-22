//
//  DVEReportUtil.m
//  NLEEditor
//
//  Created by bytedance on 2021/7/14.
//

#import "DVEReportUtils.h"
#import "DVEBarComponentProtocol.h"
#import "DVELoggerImpl.h"
#import "DVEEditorEventProtocol.h"
#import "DVEServiceLocator.h"
#import <DVETrackKit/NLEModel_OC+NLE.h>
#import <DVETrackKit/NLETrack_OC+NLE.h>
#import <DVETrackKit/NLESegment_OC+NLE.h>
#import <DVETrackKit/NLETrackSlot_OC+NLE.h>
#import <NLEPlatform/NLETrackSlot+iOS.h>

NSString * const DVEVideoEditToolsClick = @"video_edit_tools_click";
NSString * const DVEVideoEditToolsCutClick = @"video_edit_tools_cut_click";

@interface DVEReportUtils()

@property (nonatomic, weak) DVEVCContext *vcContext;
@property (nonatomic, weak) id<DVECoreCanvasProtocol> canvasEditor;
@property (nonatomic, weak) id<DVECoreExportServiceProtocol> exportService;
@property (nonatomic, weak) id<DVENLEEditorProtocol> nleEditor;

@end

@implementation DVEReportUtils

DVEAutoInject(self.vcContext.serviceProvider, canvasEditor, DVECoreCanvasProtocol)
DVEAutoInject(self.vcContext.serviceProvider, exportService, DVECoreExportServiceProtocol)
DVEAutoInject(self.vcContext.serviceProvider, nleEditor, DVENLEEditorProtocol)

+ (instancetype)reportUtilWithVCConext:(DVEVCContext *)vcContext
{
    return [[DVEReportUtils alloc] initWithVCContext:vcContext];
}

+ (void)logEvent:(NSString *)serviceName params:(NSDictionary *)params
{
    if ([DVELoggerProtocol() respondsToSelector:@selector(logEvent:params:)]) {
        [DVELoggerProtocol() logEvent:serviceName params:params];
    }
}

- (instancetype)initWithVCContext:(DVEVCContext *)vcContext
{
    self = [self init];
    if (self) {
        _vcContext = vcContext;
    }
    return self;
}
/// 主视频的时长
- (NSInteger)videodurationSeconds
{
    if (self.vcContext) {
        double dur = CMTimeGetSeconds(self.vcContext.mediaContext.duration);
        NSInteger duration = (NSInteger)(dur);
        return duration;
    }
    return 0;
}
/// 获取主视频片段的数量
- (NSInteger)videoCount
{
    if (self.vcContext) {
        NLETrack_OC *mainTrack = [self.nleEditor.nleModel nle_getMainVideoTrack];
        return mainTrack.slots.count;
    }
    return 0;
}
/// 主视频和画中画各个片段的速度
- (NSString *)cutSpeed
{
    if (self.vcContext) {
        NSMutableArray<NSString *> *mainCutSpeedArray = [[NSMutableArray alloc] init];
        NSMutableArray<NSString *> *pipCutSpeedArray = [[NSMutableArray alloc] init];
        NSArray<NLETrack_OC *> *tracks = [self.nleEditor.nleModel getTracks];
        for (NLETrack_OC *track in tracks) {
            if (!track.isMainTrack && track.extraTrackType == NLETrackVIDEO) {
                for (NLETrackSlot_OC *slot in track.slots) {
                    [pipCutSpeedArray addObject:[NSString stringWithFormat:@"%.1lf", slot.nle_speed]];
                }
            } else if (track.isMainTrack) {
                for (NLETrackSlot_OC *slot in track.slots) {
                    [mainCutSpeedArray addObject:[NSString stringWithFormat:@"%.1lf", slot.nle_speed]];
                }
            }
        }
        NSString *mainCutSpeed = [mainCutSpeedArray componentsJoinedByString:@","];
        NSString *pipCutSpeed = [pipCutSpeedArray componentsJoinedByString:@","];
        if (mainCutSpeedArray.count == 0 && pipCutSpeedArray.count == 0) {
            return @"none";
        } else if (mainCutSpeedArray.count > 0 && pipCutSpeedArray.count == 0) {
            return [NSString stringWithFormat:@"%@&none", mainCutSpeed];
        } else if (mainCutSpeedArray.count == 0 && pipCutSpeedArray.count > 0) {
            return [NSString stringWithFormat:@"none&%@", pipCutSpeed];
        } else if (mainCutSpeedArray.count > 0 && pipCutSpeedArray.count > 0) {
            return [NSString stringWithFormat:@"%@&%@", mainCutSpeed, pipCutSpeed];
        }
    }
    return @"none";
}
/// 是否倒放
- (NSString *)isCutReverse
{
    if (self.vcContext) {
        NSString *mainCutReverse = @"no";
        NSString *pipCutReverse = @"no";
        NSArray<NLETrack_OC *> *tracks = [self.nleEditor.nleModel getTracks];
        for (NLETrack_OC *track in tracks) {
            if (!track.isMainTrack && track.extraTrackType == NLETrackVIDEO) {
                for (NLETrackSlot_OC *slot in track.slots) {
                    if ([slot.segment getType] == NLEResourceTypeVideo) {
                        NLESegmentVideo_OC *segmentVideo = (NLESegmentVideo_OC *)slot.segment;
                        if (segmentVideo.rewind) {
                            pipCutReverse = @"yes";
                        }
                    }
                }
            } else if (track.isMainTrack) {
                for (NLETrackSlot_OC *slot in track.slots) {
                    if ([slot.segment getType] == NLEResourceTypeVideo) {
                        NLESegmentVideo_OC *segmentVideo = (NLESegmentVideo_OC *)slot.segment;
                        if (segmentVideo.rewind) {
                            mainCutReverse = @"yes";
                        }
                    }
                }
            }
        }
        return [NSString stringWithFormat:@"%@&%@", mainCutReverse, pipCutReverse];
    }
    return @"no&no";
}
/// 是否旋转
- (NSString *)isRotate
{
    if (self.vcContext) {
        NSString *result = @"no";
        NSArray<NLETrack_OC *> *tracks = [self.nleEditor.nleModel getTracks];
        for (NLETrack_OC *track in tracks) {
            for (NLETrackSlot_OC *slot in track.slots) {
                if (slot.rotation != 0) {
                    result = @"yes";
                }
            }
        }
        return result;
    }
    return @"no";
}
/// 文本数量
- (NSInteger)textCount
{
    if (self.vcContext) {
        NSInteger count = 0;
        NSArray<NLETrack_OC *> *tracks = [self.nleEditor.nleModel getTracks];
        for (NLETrack_OC *track in tracks) {
            if (track.extraTrackType == NLETrackSTICKER && track.nle_extraResourceType == NLEResourceTypeTextSticker) {
                for (NLETrackSlot_OC *slot in track.slots) {
                    if ([slot.segment getType] == NLEResourceTypeTextSticker) {
                        count++;
                    }
                }
            }
        }
        return count;
    }
    return 0;
}
/// 贴纸数量
- (NSInteger)stickerCount
{
    if (self.vcContext) {
        NSInteger count = 0;
        NSArray<NLETrack_OC *> *tracks = [self.nleEditor.nleModel getTracks];
        for (NLETrack_OC *track in tracks) {
            if (track.extraTrackType == NLETrackSTICKER) {
                for (NLETrackSlot_OC *slot in track.slots) {
                    if ([slot.segment getType] == NLEResourceTypeSticker) {
                        count++;
                    }
                }
            }
        }
        return count;
    }
    return 0;
}
/// 贴纸id
- (NSString *)stickerIds
{
    if (self.vcContext) {
        NSMutableArray<NSString *> *stickerIdArray = [[NSMutableArray alloc] init];
        NSArray<NLETrack_OC *> *tracks = [self.nleEditor.nleModel getTracks];
        for (NLETrack_OC *track in tracks) {
            if (track.extraTrackType == NLETrackSTICKER) {
                for (NLETrackSlot_OC *slot in track.slots) {
                    if ([slot.segment getType] == NLEResourceTypeSticker) {
                        NLEResourceNode_OC *resSticker = [slot.segment getResNode];
                        [stickerIdArray addObject:resSticker.resourceId];
                    }
                }
            }
        }
        if (stickerIdArray.count > 0) {
            NSString *result = [stickerIdArray componentsJoinedByString:@","];
            return result;
        } else {
            return @"none";
        }
    
    }
    return @"none";
}
/// 音乐数量
- (NSInteger)musicCount
{
    if (self.vcContext) {
        NSInteger count = 0;
        NSArray<NLETrack_OC *> *tracks = [self.nleEditor.nleModel getTracks];
        for (NLETrack_OC *track in tracks) {
            if (track.extraTrackType == NLETrackAUDIO) {
                for (NLETrackSlot_OC *slot in track.slots) {
                    if ([slot.segment getType] == NLEResourceTypeAudio) {
                        count++;
                    }
                }
            }
        }
        return count;
    }
    return 0;
}
/// 音乐名称
- (NSString *)musicNames
{
    if (self.vcContext) {
        NSMutableArray<NSString *> *musicNameArray = [[NSMutableArray alloc] init];
        NSArray<NLETrack_OC *> *tracks = [self.nleEditor.nleModel getTracks];
        for (NLETrack_OC *track in tracks) {
            if (track.extraTrackType == NLETrackAUDIO) {
                for (NLETrackSlot_OC *slot in track.slots) {
                    if ([slot.segment getType] == NLEResourceTypeAudio) {
                        [musicNameArray addObject:[slot.segment getResNode].resourceName];
                    }
                }
            }
        }
        if (musicNameArray.count > 0) {
            NSString *result = [musicNameArray componentsJoinedByString:@","];
            return result;
        } else {
            return @"none";
        }
    }
    return @"none";
}
/// 导出分辨率
- (NSInteger)resolutionRate
{
    if (self.vcContext) {
        return self.exportService.exportResolution;
    }
    return 0;
}
/// 帧率
- (DVEExportFPS)frameRate
{
    if (self.vcContext) {
        return self.exportService.expotFps;
    }
    return 0;
}
/// 画布尺寸
- (NSString *)canvasScale
{
    if (self.vcContext) {
        NSString *result = @"";
        switch (self.canvasEditor.ratio) {
            case DVECanvasRatio9_16:
                result = @"9:16";
                break;
            case DVECanvasRatio3_4:
                result = @"3:4";
                break;
            case DVECanvasRatio1_1:
                result = @"1:1";
                break;
            case DVECanvasRatio4_3:
                result = @"4:3";
                break;
            case DVECanvasRatio16_9:
                result = @"16:9";
                break;
            default:
                result = [NSString stringWithFormat:@"原始-%.0f:%.0f", self.canvasEditor.canvasSize.width, self.canvasEditor.canvasSize.height];
                break;
        }
        return result;
    }
    return @"";
}
/// 横竖屏
- (NSString *)screen
{
    if (self.vcContext) {
        NSString *result = @"";
        switch (self.canvasEditor.ratio) {
            case DVECanvasRatio9_16:
            case DVECanvasRatio3_4:
            case DVECanvasRatio1_1:
                result = @"vertical_screen";
                break;
            case DVECanvasRatio4_3:
            case DVECanvasRatio16_9:
                result = @"horizontal_screen";
                break;
            default:
                if (self.canvasEditor.canvasSize.height >= self.canvasEditor.canvasSize.width) {
                    result = @"vertical_screen";
                } else {
                    result = @"horizontal_screen";
                }
                break;
        }
        return result;
    }
    return @"";
}
/// 所有特效id
- (NSString *)effectIds
{
    if (self.vcContext) {
        NSString *result = @"";
        NSMutableArray <NSString *> *effectIdArray = [[NSMutableArray alloc] init];
        NLEModel_OC *model = self.nleEditor.nleModel;
        for (NLETrack_OC *track in [model getTracks]) {
            if ([track getTrackType] == NLETrackEFFECT) {
                for(NLETrackSlot_OC *slot in track.slots){///目前全局特效只有一个插槽
                    NLESegmentEffect_OC* segEffect = (NLESegmentEffect_OC *)slot.segment;
                    NLEResourceNode_OC *resEffect = segEffect.effectSDKEffect;
                    [effectIdArray addObject:resEffect.resourceId];
                }
            }else if([track getTrackType] == NLETrackVIDEO){
                for(NLETrackSlot_OC* slot in [track getEffect]){
                    NLESegment_OC* segment = [slot segment];
                    if([segment isKindOfClass:[NLESegmentEffect_OC class]]){
                        NLESegmentEffect_OC *segEffect = (NLESegmentEffect_OC*)segment;
                        NLEResourceNode_OC *resEffect = segEffect.effectSDKEffect;
                        [effectIdArray addObject:resEffect.resourceId];
                    }
                }
            }
        }
        if (effectIdArray.count > 0) {
            result = [effectIdArray componentsJoinedByString:@","];
            return result;
        } else {
            return @"none";
        }
    }
    return @"none";
}
/// 所有滤镜id
- (NSString *)filterIds
{
    if (self.vcContext) {
        NSString *result = @"";
        NSMutableArray<NSString *> *filterIdArray = [[NSMutableArray alloc] init];
        NSArray<NLETrack_OC *> *tracks = [self.nleEditor.nleModel getTracks];
        for (NLETrack_OC *track in tracks) {
            //全局滤镜
            if ([track getTrackType] == NLETrackFILTER && track.nle_extraResourceType == NLEResourceTypeFilter) {
                for (NLETrackSlot_OC *globalFilterSlot in track.slots) {
                    NLESegmentFilter_OC *segFilter = (NLESegmentFilter_OC *)globalFilterSlot.segment;
                    NLEResourceNode_OC *resFilter = [segFilter getResNode];
                    if (!resFilter) {
                        resFilter = [globalFilterSlot getFilter].firstObject.segmentFilter.effectSDKFilter;
                    }
                    if (resFilter) {
                        [filterIdArray addObject:resFilter.resourceId];
                    }
                }
            } else {
                //局部滤镜
                for (NLETrackSlot_OC *slot in track.slots) {
                    NSArray<NLEFilter_OC *> *filterArray = [slot getFilter];
                    if ([slot.segment getResNode].resourceType == NLEResourceTypeVideo && filterArray.count > 0) {
                        NLESegmentFilter_OC *segFilter = filterArray.firstObject.segmentFilter;
                        NLEResourceNode_OC *resFilter = [segFilter getResNode];
                        [filterIdArray addObject:resFilter.resourceId];
                    }
                }
            }
        }
        result = [filterIdArray componentsJoinedByString:@","];
        return result;
    }
    return @"none";
}

+ (void)logComponentClickAction:(DVEVCContext *)vcContext event:(NSString *)event actionType:(DVEBarActionType)type;
{
    NSDictionary *dic = [[NSDictionary alloc] init];
    NSString *selectSegmentType = @"";
    if (vcContext.mediaContext.selectBlendVideoSegment){
        selectSegmentType = @"pip";
    } else {
        selectSegmentType = @"main";
    }
    id<DVEEditorEventProtocol> config = DVEOptionalInline(vcContext.serviceProvider, DVEEditorEventProtocol);
    if ([config respondsToSelector:@selector(convert:)]) {
        dic = @{
            @"action":[config convert:type] ?: @"",
            @"type":selectSegmentType ?: @""
        };
    } else {
        dic = @{
            @"action":@(type),
            @"type":selectSegmentType ?: @""
        };
    }
    [DVEReportUtils logEvent:event params:dic];
}

+ (void)logComponentClick:(DVEVCContext *)vcContext currentComponent:(id<DVEBarComponentProtocol>)currentComponent clickComponent:(id<DVEBarComponentProtocol>)clickComponent;
{
    if (currentComponent.componentType == DVEBarComponentTypeRoot) {
        [self logComponentClickAction:vcContext event:DVEVideoEditToolsClick actionType:(DVEBarActionType)clickComponent.componentType];
    } else if (currentComponent.componentType == DVEBarComponentTypeCut) {
        [self logComponentClickAction:vcContext event:DVEVideoEditToolsCutClick actionType:(DVEBarActionType)clickComponent.componentType];
    }
}

+ (void)logVideoExportClickEvent:(DVEVCContext *)vcContext
{
    DVEReportUtils *util = [DVEReportUtils reportUtilWithVCConext:vcContext];
    NSDictionary *dic= @{
        @"video_duration":@([util videodurationSeconds]),
        @"video_cnt":@([util videoCount]),
        @"cut_speed":[util cutSpeed] ?:@"",
        @"cut_reverse":[util isCutReverse] ?:@"",
        @"rotate":[util isRotate] ?:@"",
        @"text_cnt":@([util textCount]),
        @"sticker_id":[util stickerIds] ?:@"",
        @"sticker_cnt":@([util stickerCount]),
        @"music_cnt":@([util musicCount]),
        @"music_name":[util musicNames] ?:@"",
        @"resolution_rate":@([util resolutionRate]),
        @"frame_rate":@([util frameRate]),
        @"canvas_scale":[util canvasScale] ?:@"",
        @"screen":[util screen] ?:@"",
        @"effect_id":[util effectIds] ?:@"",
        @"filter_id":[util filterIds] ?:@"",
    };
    [DVEReportUtils logEvent:@"video_edit_publish_click" params:dic];
}

+ (void)logVideoExportResultEvent:(DVEVCContext *)vcContext isSuccess:(BOOL)isSuccess failCode:(NSString * _Nullable)failCode failMsg:(NSString * _Nullable)failMsg;
{
    DVEReportUtils *util = [DVEReportUtils reportUtilWithVCConext:vcContext];
    NSDictionary *dic= @{
        @"video_duration":@([util videodurationSeconds]),
        @"video_cnt":@([util videoCount]),
        @"cut_speed":[util cutSpeed] ?:@"",
        @"cut_reverse":[util isCutReverse] ?:@"",
        @"rotate":[util isRotate] ?:@"",
        @"text_cnt":@([util textCount]),
        @"sticker_id":[util stickerIds] ?:@"",
        @"sticker_cnt":@([util stickerCount]),
        @"music_cnt":@([util musicCount]),
        @"music_name":[util musicNames] ?:@"",
        @"resolution_rate":@([util resolutionRate]),
        @"frame_rate":@([util frameRate]),
        @"canvas_scale":[util canvasScale] ?:@"",
        @"screen":[util screen] ?:@"",
        @"effect_id":[util effectIds] ?:@"",
        @"filter_id":[util filterIds] ?:@"",
    };
    NSMutableDictionary *finalDic = [NSMutableDictionary dictionaryWithDictionary:dic];
    if (isSuccess) {
        [finalDic setObject:@"success" forKey:@"result"];
    } else {
        [finalDic setObject:@"fail" forKey:@"result"];
        [finalDic setObject:failCode forKey:@"fail_code"];
        [finalDic setObject:failMsg forKey:@"fail_msg"];
    }
    [DVEReportUtils logEvent:@"video_edit_publish_result" params:finalDic];
}


@end
