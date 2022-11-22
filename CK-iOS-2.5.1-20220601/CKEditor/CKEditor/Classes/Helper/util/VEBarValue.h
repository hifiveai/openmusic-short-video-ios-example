//
//  VEBarValue.h
//  TTVideoEditorDemo
//
//  Created by bytedance on 2020/12/20
//  Copyright © 2020 bytedance. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "VEEventCallDefine.h"

NS_ASSUME_NONNULL_BEGIN


typedef NS_OPTIONS(NSUInteger, VEBarValueType) {

    VEBarValueTypeNone          = 0 << 0,
    VEBarValueTypeImage         = 1 << 0,
    VEBarValueTypeText          = 1 << 1,
    VEBarValueTypeImageAndText  = 1 << 2,

};

@interface VEBarValue : NSObject

@property (nonatomic, assign) VEBarValueType valueType;
@property (nonatomic, assign) VEEventCallType eventType;
@property (nonatomic, strong) NSMutableArray <UIImage *>*images;
@property (nonatomic, strong) NSMutableArray <NSString *>*titles;
@property (nonatomic, assign) NSUInteger curIndex;

+(instancetype)valueWithImages:(NSArray <UIImage *>*)images eventCallType:(VEEventCallType)eventType;;
+(instancetype)valueWithTitles:(NSArray <NSString *>*)titles eventCallType:(VEEventCallType)eventType;
+(instancetype)valueWithImages:(NSArray <UIImage *>*)images Titles:(NSArray <NSString *>*)titles eventCallType:(VEEventCallType)eventType; 

- (UIImage *)curImage;
- (NSString *)curTitle;

- (UIImage *)switchImageAtIndex:(NSUInteger)index;
- (NSString *)switchTitleAtIndex:(NSUInteger)index;

- (void)addEventCallType:(VEEventCallType)eventType;

- (NSUInteger)subTypeIndex;


@end

NS_ASSUME_NONNULL_END
