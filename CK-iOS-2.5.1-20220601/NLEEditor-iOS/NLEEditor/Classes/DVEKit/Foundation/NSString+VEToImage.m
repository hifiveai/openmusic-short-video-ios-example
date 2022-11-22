//
//  NSString+VEToImage.m
//  TTVideoEditorDemo
//
//  Created by bytedance on 2020/12/20
//  Copyright © 2020 bytedance. All rights reserved.
//

#import "NSString+VEToImage.h"
#import <DVETrackKit/UIImage+DVEStyle.h>

@implementation NSString (DVE)

- (UIImage *)dve_toImage
{
    if (self.length  == 0) {
        return [UIImage new];
    }

    __block UIImage *image = [UIImage dve_image:self];
    if (!image) {
        image = [UIImage imageNamed:self];
        if (image) {
            return image;
        }
        
        NSArray *suffixs = @[@".png", @".jpg", @".JPG", @".jpeg", @".webp"];
        [suffixs enumerateObjectsUsingBlock:^(id  _Nonnull suffix, NSUInteger idx, BOOL * _Nonnull stop) {
            NSString *imageName = self;
            if (![self containsString:suffix]) {
                imageName = [self stringByAppendingString:suffix];
            }
            NSString *path = [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:imageName];
            image = [UIImage imageWithContentsOfFile:path];
            if (image) {
                *stop = true;
            }
        }];
    }
    return image;
}

@end
