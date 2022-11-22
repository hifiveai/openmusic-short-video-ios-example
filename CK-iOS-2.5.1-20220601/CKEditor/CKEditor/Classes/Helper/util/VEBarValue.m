//
//  VEBarValue.m
//  TTVideoEditorDemo
//
//  Created by bytedance on 2020/12/20
//  Copyright © 2020 bytedance. All rights reserved.
//

#import "VEBarValue.h"

@implementation VEBarValue

- (instancetype)init
{
    if (self = [super init]) {
        self.curIndex = 0;
    }
    
    return self;
}

+(instancetype)valueWithImages:(NSArray <UIImage *>*)images eventCallType:(VEEventCallType)eventType
{
    return [self valueWithImages:images Titles:@[] eventCallType:eventType];
}

+(instancetype)valueWithTitles:(NSArray <NSString *>*)titles eventCallType:(VEEventCallType)eventType
{
    return [self valueWithImages:@[] Titles:titles eventCallType:eventType];
}

+(instancetype)valueWithImages:(NSArray <UIImage *>*)images Titles:(NSArray <NSString *>*)titles eventCallType:(VEEventCallType)eventType
{
    VEBarValue *value = [VEBarValue new];
    
    if (images.count > 0 && titles.count > 0) {
        value.valueType = VEBarValueTypeImageAndText;
    } else if (images.count > 0 && titles.count == 0) {
        value.valueType = VEBarValueTypeImage;
    } else if (images.count == 0 && titles.count > 0) {
        value.valueType = VEBarValueTypeText;
    } else {
        value.valueType = VEBarValueTypeNone;
    }
    
    value.images = [NSMutableArray arrayWithArray:images];
    value.titles = [NSMutableArray arrayWithArray:titles];
    
    [value addEventCallType:eventType];
    
    return value;
}

- (UIImage *)curImage
{
    return [self switchImageAtIndex:self.curIndex];
}
- (NSString *)curTitle
{
    return [self switchTitleAtIndex:self.curIndex];
}

- (UIImage *)switchImageAtIndex:(NSUInteger)index
{
    self.curIndex = index;
    return self.images[index%self.images.count];
}
- (NSString *)switchTitleAtIndex:(NSUInteger)index
{
    self.curIndex = index;
    return self.titles[index%self.titles.count];
}

- (void)addEventCallType:(VEEventCallType)eventType
{
    self.eventType = eventType;
}

- (NSUInteger)subTypeIndex
{
    NSUInteger count = 0;
    if (self.valueType & VEBarValueTypeImage) {
        count = self.images.count;
    } else if (self.valueType & VEBarValueTypeText) {
        count = self.titles.count;
    } else {
        count = 100;
    }
    
    return self.curIndex % count;
}

@end
