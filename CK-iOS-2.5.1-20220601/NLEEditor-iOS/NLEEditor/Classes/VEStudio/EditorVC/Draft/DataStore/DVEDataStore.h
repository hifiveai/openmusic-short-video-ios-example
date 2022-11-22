//
//  DVEDataStore.h
//  TTVideoEditorDemo
//
//  Created by bytedance on 2021/2/28.
//  Copyright © 2021 bytedance. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN
@class DVEDraftModel;
@interface DVEDataStore : NSObject

+ (instancetype)shareDataStore;

- (NSArray <DVEDraftModel *>*)getAllDrafts;

- (void)addOneDarftWithModel:(DVEDraftModel *)draft;

- (void)removeOneDraftModel:(DVEDraftModel *)draft;

@end

NS_ASSUME_NONNULL_END
