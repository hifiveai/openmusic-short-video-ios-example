//
//   NLESegmentTextSticker_OC+Text.m
//   NLEPlatform
//
//   Created  by ByteDance on 2021/7/20.
//   Copyright © 2021 ByteDance Ltd. All rights reserved.
//
    

#import "NLESegmentTextSticker_OC+Text.h"

@implementation NLESegmentTextSticker_OC (Text)

-(NSString*)adjustContent:(NSInteger)numberOfWordInLine {
    if (self.content.length <= numberOfWordInLine) {
        return self.content;
    }
    NSMutableString* string = [NSMutableString stringWithString:self.content];
    NSString* result = @"";
    do {
        if(result.length == 0){
            result = [string substringToIndex:MIN(string.length, numberOfWordInLine)];
        }else{
            result = [NSString stringWithFormat:@"%@\n%@",result,[string substringToIndex:MIN(string.length, numberOfWordInLine)]];
        }
        [string deleteCharactersInRange:NSMakeRange(0, MIN(string.length, numberOfWordInLine))];
    } while (string.length > 0);
    return result;
}

@end
