//
//  DVEAlbumVideoConfigProtocol.h
//  VideoTemplate
//
//  Created by bytedance on 2020/12/1.
//

#import <Foundation/Foundation.h>
//#import "DVEAlbumServiceLocator.h"

@protocol DVEAlbumVideoConfigProtocol <NSObject>


@optional

@property (nonatomic, assign, readonly) NSInteger videoMinSeconds;
@property (nonatomic, assign, readonly) NSInteger videoMaxSeconds;
@property (nonatomic, assign, readonly) NSInteger standardVideoMaxSeconds;
@property (nonatomic, assign, readonly) NSInteger videoSelectableMaxSeconds;
@property (nonatomic, assign, readonly) NSInteger videoUploadMaxSeconds;
@property (nonatomic, assign, readonly) NSInteger videoFromLvUploadMaxSeconds;
@property (nonatomic, assign, readonly) NSInteger musicMaxSeconds;
@property (nonatomic, assign, readonly) NSInteger clipVideoInitialMaxSeconds;
@property (nonatomic, assign, readonly) NSInteger clipVideoFromLvInitialMaxSeconds;
@property (nonatomic, assign, readonly) BOOL isLimitInitialMaxSeconds;
@property (nonatomic, assign, readonly) BOOL isReshoot;

@end

FOUNDATION_STATIC_INLINE id<DVEAlbumVideoConfigProtocol> TOCVideoConfig() {
    return nil;
}

