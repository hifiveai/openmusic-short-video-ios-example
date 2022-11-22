//
//  VELogger.m
//  TTVideoEditorDemo
//
//  Created by bytedance on 2021/5/24.
//  Copyright © 2021 bytedance. All rights reserved.
//

#import "VELogger.h"
//#import <BDALog/BDAgileLog.h>

#define DVELogToFile

@interface VELogger ()

@property (nonatomic, assign) DVELogType currentType;

@end

@implementation VELogger

- (instancetype)init {
    self = [super init];
    if (self) {
        _currentType = DVELogTypeWarn;
        [NLELogger registerPerformer:self];
    }
    return self;
}

- (void)logType:(DVELogType)type
            tag:(NSString *)tag
           file:(const char *)file
       function:(const char *)function
           line:(int)line
        message:(NSString *)message, ...{
    
    if (type < self.currentType) {
        return;
    }
    
    va_list args;
    va_start(args, message);
    NSString *formatMessage = [[NSString alloc] initWithFormat:message arguments:args];
    va_end(args);
    
    NSString *fileName = [[NSString stringWithUTF8String:file] lastPathComponent];
    
    formatMessage = [NSString stringWithFormat:@"[%@%s %d] %@", fileName, function, line, formatMessage];
    
    [self logMessageWithTag:tag content:formatMessage];
    
//    switch (type) {
//        case DVELogTypeDebug:
//            BDALOG_DEBUG_TAG(tag, formatMessage);
//            break;
//        case DVELogTypeInfo:
//            BDALOG_INFO_TAG(tag, formatMessage);
//            break;
//        case DVELogTypeWarn:
//            BDALOG_WARN_TAG(tag, formatMessage);
//            break;
//        case DVELogTypeError:
//            BDALOG_ERROR_TAG(tag, formatMessage);
//            break;
//        default:
//            NSAssert(NO, @"DVELogType invalid!!!");
//            break;
//    }
}

- (void)logger:(NLELogger *)logger
           log:(NSString *)tag
         level:(NLELogLevel)level
          file:(NSString *)file
      function:(NSString *)function
          line:(int)line
       message:(NSString *)message {
    
    if ((DVELogType)level < self.currentType) {
        return;
    }
    NSString *fileName = [file lastPathComponent];
    NSString *formatMessage = [NSString stringWithFormat:@"[%@ %@ %d] %@", fileName, function, line, message];
    
    [self logMessageWithTag:tag content:formatMessage];
    
//    switch (level) {
//        case NLELogLevelVerbose:
//        case NLELogLevelDebug:
//            BDALOG_DEBUG_TAG(tag, formatMessage);
//            break;
//        case NLELogLevelInfo:
//            BDALOG_INFO_TAG(tag, formatMessage);
//            break;
//        case NLELogLevelWarning:
//            BDALOG_WARN_TAG(tag, formatMessage);
//            break;
//        case NLELogLevelError:
//            BDALOG_ERROR_TAG(tag, formatMessage);
//            break;
//        default:
//            NSAssert(NO, @"NLELogLevel invalid!!!");
//            break;
//    }
}

- (void)logMessageWithTag:(NSString *)tag content:(NSString *)content {


#ifdef DVELogToFile
    [self saveString:[NSString stringWithFormat:@"%@|%@", tag, content]];
#else
    NSLog(@"%@|%@", tag, content);
#endif
    

}

- (void)saveString:(NSString *)str {
    //在某个范围内搜索文件夹的路径.
    //directory:获取哪个文件夹
    //domainMask:在哪个路径下搜索
    //expandTilde:是否展开路径.
    
    //这个方法获取出的结果是一个数组.因为有可以搜索到多个路径.
    NSArray *array =  NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
    //在这里,我们指定搜索的是Cache目录,所以结果只有一个,取出Cache目录
    NSString *cachePath = array[0];
    //拼接文件路径
    NSString *filePathName = [cachePath stringByAppendingPathComponent:@"Log.txt"];
    
    NSString *writeTotext = [@"\n" stringByAppendingString:[NSString stringWithFormat:@"%@----%@",[self getCurrentTime],str]];
    
    if ([[NSFileManager defaultManager] fileExistsAtPath:filePathName]) {
        
        NSFileHandle *fileHandle = [NSFileHandle fileHandleForUpdatingAtPath:filePathName];
        
        [fileHandle seekToEndOfFile]; //将节点跳到文件的末尾
        
        NSData *stringData = [writeTotext dataUsingEncoding:NSUTF8StringEncoding];
        
        [fileHandle writeData:stringData]; // 追加写入数据
        
        [fileHandle closeFile];
    } else {
        [writeTotext writeToFile:filePathName atomically:YES encoding:NSUTF8StringEncoding error:nil];
    }
}

- (NSString *)getCurrentTime {
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];//yyyy-MM-dd-hh-mm-ss
    [formatter setDateFormat:@"yyyy:MM:dd hh:mm:ss"];
    NSString *dateTime = [formatter stringFromDate:[NSDate date]];
    return dateTime;
}


@end
