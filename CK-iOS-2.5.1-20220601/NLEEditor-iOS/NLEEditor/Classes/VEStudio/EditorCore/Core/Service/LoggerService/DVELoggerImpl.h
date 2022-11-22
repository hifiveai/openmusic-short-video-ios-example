//
//  DVELoggerImpl.h
//  Pods
//
//  Created by bytedance on 2021/5/24.
//

#ifndef DVELoggerImpl_h
#define DVELoggerImpl_h
#import "DVELoggerService.h"

#ifndef DVELogDebug
#define DVELogDebug(format, ...)                  \
    [DVELoggerProtocol() logType:DVELogTypeDebug  \
                             tag:@"NLEEditor"     \
                            file:__FILE__         \
                        function:__FUNCTION__     \
                            line:__LINE__         \
                         message:format, ##__VA_ARGS__];
#endif

#ifndef DVELogInfo
#define DVELogInfo(format, ...)                   \
    [DVELoggerProtocol() logType:DVELogTypeInfo   \
                             tag:@"NLEEditor"     \
                            file:__FILE__         \
                        function:__FUNCTION__     \
                            line:__LINE__         \
                         message:format, ##__VA_ARGS__];
#endif

#ifndef DVELogWarn
#define DVELogWarn(format, ...)                   \
    [DVELoggerProtocol() logType:DVELogTypeWarn   \
                             tag:@"NLEEditor"     \
                            file:__FILE__         \
                        function:__FUNCTION__     \
                            line:__LINE__         \
                         message:format, ##__VA_ARGS__];
#endif

#ifndef DVELogError
#define DVELogError(format, ...)                  \
    [DVELoggerProtocol() logType:DVELogTypeError  \
                             tag:@"NLEEditor"     \
                            file:__FILE__         \
                        function:__FUNCTION__     \
                            line:__LINE__         \
                         message:format, ##__VA_ARGS__];
#endif

#ifndef DVELogReport
#define DVELogReport(format, ...)                  \
    [DVELoggerProtocol() logType:DVELogTypeReport  \
                             tag:@"NLEEditor"     \
                            file:__FILE__         \
                        function:__FUNCTION__     \
                            line:__LINE__         \
                         message:format, ##__VA_ARGS__];
#endif

#endif /* DVELoggerImpl_h */
