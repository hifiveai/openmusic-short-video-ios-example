//
//  VEDVideoTool.m
//  TTVideoEditorDemo
//
//  Created by bytedance on 2021/3/9.
//  Copyright © 2021 bytedance. All rights reserved.
//

#import "VEDVideoTool.h"
#import <AVFoundation/AVFoundation.h>
#import <sys/utsname.h>

@implementation VEDVideoTool

+ (NSTimeInterval)getVideoDurationWithVideoURL:(NSURL *)URL
{
    NSDictionary *opts = [NSDictionary dictionaryWithObject:@(NO) forKey:AVURLAssetPreferPreciseDurationAndTimingKey];
    AVURLAsset *urlAsset = [AVURLAsset URLAssetWithURL:URL options:opts]; // 初始化视频媒体文件
    
    return CMTimeGetSeconds(urlAsset.duration);
}

+ (CGSize)getVideoSizeWithVideoURL:(NSURL *)URL
{
    AVURLAsset *urlAsset = [AVURLAsset assetWithURL:URL];
    AVAssetTrack *track = [[urlAsset tracksWithMediaType:AVMediaTypeVideo] firstObject];
    return  track.naturalSize;
}

+ (NSString *)deviceVersion
{
   
    struct utsname systemInfo;
    uname(&systemInfo);
    NSString * deviceString = [NSString stringWithCString:systemInfo.machine encoding:NSUTF8StringEncoding];
    //iPhone
    
    if ([deviceString isEqualToString:@"iPhone5,1"])    return @"51";
    if ([deviceString isEqualToString:@"iPhone5,2"])    return @"52";
    if ([deviceString isEqualToString:@"iPhone5,3"])    return @"53";
    if ([deviceString isEqualToString:@"iPhone5,4"])    return @"54";
    if ([deviceString isEqualToString:@"iPhone6,1"])    return @"61";
    if ([deviceString isEqualToString:@"iPhone6,2"])    return @"62";
    if ([deviceString isEqualToString:@"iPhone7,1"])    return @"71";
    if ([deviceString isEqualToString:@"iPhone7,2"])    return @"72";
    if ([deviceString isEqualToString:@"iPhone8,1"])    return @"81";
    if ([deviceString isEqualToString:@"iPhone8,2"])    return @"82";
    if ([deviceString isEqualToString:@"iPhone9,1"])    return @"91";
    if ([deviceString isEqualToString:@"iPhone9,2"])    return @"92";
    if([deviceString  isEqualToString:@"iPhone10,1"])   return @"101";
    if([deviceString  isEqualToString:@"iPhone10,4"])   return @"101";
    if([deviceString  isEqualToString:@"iPhone10,2"])   return @"101";
    if([deviceString  isEqualToString:@"iPhone10,5"])   return @"101";
    if([deviceString  isEqualToString:@"iPhone10,3"])   return @"101";
    if([deviceString  isEqualToString:@"iPhone10,6"])   return @"101";
    deviceString = @"100";
    
    return deviceString;
}


@end
