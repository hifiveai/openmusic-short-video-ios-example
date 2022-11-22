//
//  DVECaptionModel.h
//  NLEEditor
//
//  Created by bytedance on 2021/5/18.
//

#import <Foundation/Foundation.h>
#import "DVEBaseApiModel.h"

@class DVESubtitleSentenceModel, DVESubtitleQueryModel;

@interface DVESubtitleCommitModel : DVEBaseApiModel

@property (nonatomic, strong) DVESubtitleQueryModel *videoCaption;

@end

@interface DVESubtitleQueryModel : MTLModel<MTLJSONSerializing>

@property (nonatomic, strong) NSString *captionId;
@property (nonatomic, assign) NSInteger code;
@property (nonatomic, strong) NSString *message;
@property (nonatomic, copy) NSArray<DVESubtitleSentenceModel *> *captions;

@end


@interface DVESubtitleSentenceModel : MTLModel<MTLJSONSerializing, NSCopying>

@property (nonatomic, strong) NSString *text;                           //文本信息
@property (nonatomic, assign) CGFloat startTime;                        //起始时间
@property (nonatomic, assign) CGFloat endTime;                          //结束时间
@property (nonatomic, copy) NSArray<DVESubtitleSentenceModel *> *words;    //词粒度信息

@end
