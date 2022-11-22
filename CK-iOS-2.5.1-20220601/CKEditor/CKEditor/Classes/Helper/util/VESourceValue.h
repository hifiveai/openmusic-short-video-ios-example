//
//  VESourceValue.h
//  TTVideoEditorDemo
//
//  Created by bytedance on 2020/12/20
//  Copyright © 2020 bytedance. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSUInteger, VESourceValueType) {

    VESourceValueTypeNone          = 0,
    VESourceValueTypeImage        ,
    VESourceValueTypeVideo          ,
    

};

@interface VESourceValue : NSObject

@property (nonatomic, assign) VESourceValueType type;

@property (nonatomic, copy) NSString *path;
@property (nonatomic, strong) AVURLAsset *asset;
@property (nonatomic, strong) UIImage *image;

@end

NS_ASSUME_NONNULL_END
