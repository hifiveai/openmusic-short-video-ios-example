//
//  NSArray+RGBA.m
//  TTVideoEditorDemo
//
//  Created by bytedance on 2020/12/20
//  Copyright © 2021 bytedance. All rights reserved.
//

#import "NSArray+RGBA.h"
#import "DVEMacros.h"
#import "DVELoggerImpl.h"

@implementation NSArray (RGBA)

- (uint32_t)genRGBA {
    if (self.count != 4) {
        DVELogError(@"转RGBA 应该是为4位");
        return -1;
    }
    uint8_t r = [[self objectAtIndex:0] floatValue] * 255;
    uint8_t g = [[self objectAtIndex:1] floatValue] * 255;
    uint8_t b = [[self objectAtIndex:2] floatValue] * 255;
    uint8_t a = [[self objectAtIndex:3] floatValue] * 255;
    
    uint32_t rgba = 0;
    rgba |= a;
    rgba |= (b << 8);
    rgba |= (g << 16);
    rgba |= (r << 24);
    return rgba;
    
}
@end

////
//NSArray * VEConverRGBAArray(uint32_t rgba) {
//
//    uint8_t r = (uint8_t)((rgba >> 24) & 0xFF) ;
//    uint8_t g = (uint8_t)((rgba >> 16) & 0xFF);
//    uint8_t b = (uint8_t)((rgba >> 8)  & 0xFF) ;
//    uint8_t a = (uint8_t)(rgba & 0xFF);
//    
//    float rf = r / 255.f;
//    float gf = g / 255.f;
//    float bf = b / 255.f;
//    float af = a / 255.f;
//    
//    return @[@(rf),@(gf),@(bf),@(af)];
//}
