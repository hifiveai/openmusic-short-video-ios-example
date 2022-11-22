//
//  DVETextAnimationModel.m
//  NLEEditor
//
//  Created by bytedance on 2021/7/2.
//

#import "DVETextAnimationModel.h"

@implementation DVETextAnimationModel

- (NLEResourceNode_OC *)toResourceNode
{
    NLEResourceNode_OC *node = [[NLEResourceNode_OC alloc] init];
    node.name = self.name;
    node.resourceFile = self.path;
   
    return node;
}

@end
