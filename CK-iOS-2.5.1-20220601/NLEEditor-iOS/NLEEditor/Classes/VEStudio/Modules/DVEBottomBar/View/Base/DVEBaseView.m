//
//  DVEBaseView.m
//  TTVideoEditorDemo
//
//  Created by bytedance on 2020/12/20
//  Copyright © 2020 bytedance. All rights reserved.
//

#import "DVEBaseView.h"
#import "DVELoggerImpl.h"

@implementation DVEBaseView

- (void)setVcContext:(DVEVCContext *)vcContext
{
    _vcContext = vcContext;
    [DVEAutoInline(_vcContext.serviceProvider, DVECoreActionServiceProtocol) addUndoRedoListener:self];
}

- (void)undoRedoClikedByUser
{
    DVELogInfo(@"undoRedoClikedByUser -----");
}

- (void)undoRedoWillClikeByUser
{
    DVELogInfo(@"undoRedoWillClikeByUser -----");
}

- (UIView *)hitTest:(CGPoint)point withEvent:(UIEvent *)event
{
    if(CGRectContainsPoint(self.bounds, point))
    {

    }else{
        [self touchOutSide];
    }
    return [super hitTest:point withEvent:event];
}

- (void)touchOutSide
{
    
}


@end
