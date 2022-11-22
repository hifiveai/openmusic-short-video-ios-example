//
//  DVEDraftModel.h
//  TTVideoEditorDemo
//
//  Created by bytedance on 2021/2/28.
//  Copyright © 2021 bytedance. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface DVEDraftModel : NSObject

@property (nonatomic, copy) NSString *iconFileUrl;
@property (nonatomic, assign) NSTimeInterval duration;
@property (nonatomic, copy) NSString *date;
@property (nonatomic, copy) NSString *videoInfo;
@property (nonatomic, copy) NSString *videoDataInfo;
@property (nonatomic, copy) NSString *draftID;

@end

NS_ASSUME_NONNULL_END
