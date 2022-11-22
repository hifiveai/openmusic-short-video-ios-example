//
//  DVEMaskConfigModel.m
//  NLEEditor
//
//  Created by bytedance on 2021/4/13.
//

#import "DVEMaskConfigModel.h"

@implementation DVEMaskConfigModel

- (NSString *)svgFilePath
{
    NSString *svgPath = [_curValue.sourcePath stringByAppendingString:@"/material.svg"];
    NSFileManager *fileManager =  [NSFileManager defaultManager];
    //判断文件是否存在
    BOOL isExist = [fileManager fileExistsAtPath:svgPath];
    if (isExist) {
        return svgPath;
    } else {
        return nil;
    }
}

- (instancetype)initWithBorderSize:(CGSize)borderSize
{
    self = [super init];
    if (self) {
        _borderSize = borderSize;
        if (borderSize.width == 0 || borderSize.height == 0
            || isnan(borderSize.width) || isnan(borderSize.height)
            || isinf(borderSize.width) || isinf(borderSize.height)) {
            self.width = 0.5;
            self.height = 0.5;
        } else {
            CGFloat minWH = MIN(borderSize.width, borderSize.height);
            self.width = minWH / borderSize.width / 2.0;
            self.height = minWH / borderSize.height / 2.0;
        }
        self.center = CGPointMake(0, 0);
        self.roundCorner = 0.0;
        

    }
    return self;
}

@end
