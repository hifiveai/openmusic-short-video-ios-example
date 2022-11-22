//
//  NSString+VEToPinYin.m
//  TTVideoEditorDemo
//
//  Created by bytedance on 2020/12/20
//  Copyright © 2020 bytedance. All rights reserved.
//

#import "NSString+VEToPinYin.h"

@implementation NSString (VEToPinYin)

- (NSString *)VE_transformToPinyin
{
    NSMutableString *mutableString = [NSMutableString stringWithString:self];
    CFStringTransform((CFMutableStringRef)mutableString, NULL, kCFStringTransformToLatin, false);
    mutableString = (NSMutableString *)[mutableString stringByFoldingWithOptions:NSDiacriticInsensitiveSearch locale:[NSLocale currentLocale]];
    NSString *str = [mutableString stringByReplacingOccurrencesOfString:@" " withString:@""];
    return str;
}

+ (NSString *)VETimeFormatWithTimeInterval:(NSTimeInterval)duration
{
    if (duration < 60) {
        return [NSString stringWithFormat:@"00:%02d",(int)duration];
    } else if (duration < 3600) {
        int minute = (int)duration / 60;
        int second = (int)duration % 60;
        return [NSString stringWithFormat:@"%02d:%02d",minute,second];
    } else {
        int hour = duration / 3600;
        int seconds = hour % 3600;
        int minute = seconds / 60;
        int second = seconds % 60;
        return [NSString stringWithFormat:@"%02d:%02d:%02d",hour,minute,second];
    }
}

+ (NSString *)curDateString
{
    //获取系统当前时间
    NSDate *currentDate = [NSDate date];
    //用于格式化NSDate对象
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    //设置格式：zzz表示时区
    [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss zzz"];
    //NSDate转NSString
    NSString *currentDateString = [dateFormatter stringFromDate:currentDate];
    //输出currentDateString
    NSLog(@"%@",currentDateString);
    return currentDateString;;
}

@end
