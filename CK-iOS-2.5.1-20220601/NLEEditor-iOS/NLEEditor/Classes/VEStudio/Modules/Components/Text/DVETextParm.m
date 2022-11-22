//
//  DVETextParm.m
//  TTVideoEditorDemo
//
//  Created by bytedance on 2020/12/20
//  Copyright © 2020 bytedance. All rights reserved.
//

#import "DVETextParm.h"

@implementation DVETextParm

- (instancetype)init {
    self = [super init];
    if (self) {
        _alpha = 1.0;
    }
    return self;
}

- (BOOL)isEqualToParm:(DVETextParm *)parm
{
    if (![self.text isEqualToString:parm.text]) {
        return NO;
    }
    
    if (self.alignment != parm.alignment) {
        return NO;
    }
    
    if (![self.font isEqual:parm.font]) {
        return NO;
    }
    
    if (![self.textColor isEqual:parm.textColor]) {
        return NO;
    }
    
    if (self.useEffectDefaultColor != parm.useEffectDefaultColor) {
        return NO;
    }
    
    if (_outlineWidth != parm.outlineWidth) {
        return NO;
    }
    
    if (![self.shadowColor isEqual:parm.shadowColor]) {
        return NO;
    }
    
    if (![self.shadowOffset isEqual:parm.shadowOffset]) {
        return NO;
    }
    
    if (_shadowSmoothing != parm.shadowSmoothing) {
        return NO;
    }
    
    if (_boldWidth != parm.boldWidth) {
        return NO;
    }
    
    if (_italicDegree != parm.italicDegree) {
        return NO;
    }
    
    if (_underline != parm.underline) {
        return NO;
    }
    
    if (_charSpacing != parm.charSpacing) {
        return NO;
    }
    
    if (_lineGap != parm.lineGap) {
        return NO;
    }
    
    return YES;
}

@end
