//
//  DVEAlbumGradientView.m
//  Aweme
//
//  Created by bytedance on 3/24/17.
//  Copyright © 2017 Bytedance. All rights reserved.
//

#import "DVEAlbumGradientView.h"

@implementation DVEAlbumGradientView

+ (Class)layerClass
{
    return [CAGradientLayer class];
}

- (CAGradientLayer *)gradientLayer
{
    return (CAGradientLayer *)self.layer;
}

@end
