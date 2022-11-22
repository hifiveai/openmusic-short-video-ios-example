//
//  VECMUtilities.m
//  TTVideoEditorDemo
//
//  Created by bytedance on 2020/12/20
//  Copyright © 2021 bytedance. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreMedia/CoreMedia.h>

BOOL VECMimeRangeContain(CMTimeRange range, CMTime time) {
    CMTime start = range.start;
    CMTime end = CMTimeAdd(start, range.duration);
    
    return CMTimeCompare(start, time) <= 0 && CMTimeCompare(end, time) >= 0;
    
}
