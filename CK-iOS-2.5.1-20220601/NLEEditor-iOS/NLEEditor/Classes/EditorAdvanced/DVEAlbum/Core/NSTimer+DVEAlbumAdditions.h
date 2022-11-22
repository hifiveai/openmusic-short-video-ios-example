//
//  NSTimer+ACCAdditions.h
//  CameraClient
//
//  Created by bytedance on 2020/4/1.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface NSTimer (DVEAlbumAdditions)

/**
 以block形式生成一个新的NSTimer对象

 @param seconds 回调的时间间隔
 @param block 回调的block,timer会强引用block直到timer无效
 @param repeats 如果YES,会重复回调直到timer无效,如果为NO,不会重复回调
 @return 生成一个新的NSTimer对象
 */
+ (nonnull NSTimer *)acc_scheduledTimerWithTimeInterval:(NSTimeInterval)seconds block:(nonnull void (^)(NSTimer * _Nonnull timer))block repeats:(BOOL)repeats;

/**
 以block形式生成一个新的NSTimer对象,注意，生成的timer对象一定要加入到运行循环中去  [runloop addTimer: forMode:]

 @param seconds 回调的时间间隔
 @param block 回调的block,timer会强引用block直到timer无效
 @param repeats 如果YES,会重复回调直到timer无效,如果为NO,不会重复回调
 @return 生成一个新的NSTimer对象
 */
+ (nonnull NSTimer *)acc_timerWithTimeInterval:(NSTimeInterval)seconds block:(nonnull void (^)(NSTimer * _Nonnull timer))block repeats:(BOOL)repeats;

@end

NS_ASSUME_NONNULL_END
