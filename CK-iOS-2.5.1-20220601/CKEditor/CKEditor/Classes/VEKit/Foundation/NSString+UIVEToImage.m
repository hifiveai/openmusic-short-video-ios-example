//
//  NSString+VEToImage.m
//  TTVideoEditorDemo
//
//  Created by bytedance on 2020/12/20
//  Copyright © 2020 bytedance. All rights reserved.
//

#import "NSString+UIVEToImage.h"

@implementation NSString (UIVEToImage)

- (UIImage *)UI_VEToImage
{
    if (self.length  == 0) {
        return [UIImage new];
    }
        
    NSString *path = [[NSBundle mainBundle] pathForResource:@"CKEditor" ofType:@"bundle"];
    NSBundle *bundle = [NSBundle bundleWithPath:path];
    
    __block UIImage *resultImage = [UIImage imageNamed:self inBundle:bundle compatibleWithTraitCollection:nil];

    if (!resultImage) {
        NSArray *suffixs = @[@".png", @".jpg", @".JPG", @".jpeg", @".webp"];
        [suffixs enumerateObjectsUsingBlock:^(id  _Nonnull suffix, NSUInteger idx, BOOL * _Nonnull stop) {
            NSString *imageName = self;
            if (![self containsString:suffix]) {
                imageName = [self stringByAppendingString:suffix];
            }
            NSString *path = [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:imageName];
            resultImage = [UIImage imageWithContentsOfFile:path];
            if (resultImage) {
                *stop = true;
            }
        }];
    }
    return resultImage ? resultImage :[UIImage new];
}

@end
