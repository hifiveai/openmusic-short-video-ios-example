//
//  VEEBeautyDataSource.h
//  TTVideoEditorDemo
//
//  Created by bytedance on 2020/12/20
//  Copyright © 2020 bytedance. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface VEEBeautyDataSource : NSObject

+ (instancetype)shareManager;

@property (nonatomic, strong) NSArray <DVEEffectValue *>*faceSourceArr;
@property (nonatomic, strong) NSArray <DVEEffectValue *>*vFaceSourceArr;
@property (nonatomic, strong) NSArray <DVEEffectValue *>*bodySourceArr;
@property (nonatomic, strong) NSArray <DVEEffectValue *>*makeupSourceArr;


- (NSArray *)blushArr;
- (NSArray *)lipArr;
- (NSArray *)facialArr;
- (NSArray *)pupilArr;
- (NSArray *)hairArr;
- (NSArray *)eyeshadowArr;
- (NSArray *)eyebrowArr;

@end

NS_ASSUME_NONNULL_END
