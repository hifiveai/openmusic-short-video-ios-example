//
//  DVETextBar.h
//  TTVideoEditorDemo
//
//  Created by bytedance on 2020/12/20
//  Copyright © 2020 bytedance. All rights reserved.
//

#import "DVEBaseBar.h"

NS_ASSUME_NONNULL_BEGIN


@interface DVEEffectColorModel :NSObject

@property (nonatomic, strong) NSArray *textColor;
@property (nonatomic, strong) NSArray *outlineColor;
@property (nonatomic, strong) NSArray *backgroundColor;
@property (nonatomic, strong) NSArray *shadowColor;

@end

@interface DVETextBar : DVEBaseBar

@property (nonatomic,copy) NSString* segmentId;

@property (nonatomic, assign) BOOL isMainEdit;

//封面编辑文字面板的分类目前和主编辑页面的不一致，需要调整
- (void)updateTextCategoryWithNames:(NSArray<NSString *> *)names;

@end

NS_ASSUME_NONNULL_END
