//
//  VEHUDCustomerView.m
//  TTVideoEditorDemo
//
//  Created by bytedance on 2020/12/20
//  Copyright © 2020 bytedance. All rights reserved.
//

#import "VEHUDCustomerView.h"
#import <Lottie/LOTAnimationView.h>

@implementation VEHUDCustomerView

- (instancetype)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
        [self addSubview:self.gifView];
        _gifView.center = CGPointMake(self.width * 0.5, self.height * 0.5);
        [self addSubview:self.progressLable];
        self.progressLable.top = _gifView.bottom;
        [self.VEaddPanGestureSignal subscribeNext:^(id  _Nullable x) {
            NSLog(@"VEHUDCustomerView");
        }];
    }
    
    return self;
}

- (LOTAnimationView *)gifView
{
    if (!_gifView) {
        LOTAnimationView * animationView = [LOTAnimationView animationNamed:@"loading(old)"];
        animationView.loopAnimation = YES;
        animationView.frame = CGRectMake(0, 0, 120, 120);
        
        [animationView playWithCompletion:^(BOOL animationFinished) {
            //动画完成后执行
            //当loopAnimation = YES时,循环播放的时候不执行
        }];
        _gifView = animationView;
    }
    
    return _gifView;
}

- (UILabel *)progressLable
{
    if (!_progressLable) {
        _progressLable = [[UILabel alloc] initWithFrame:CGRectMake(0, _gifView.height, self.width, 30)];
        _progressLable.textAlignment = NSTextAlignmentCenter;
        _progressLable.font = SCRegularFont(14);
        _progressLable.textColor = [UIColor whiteColor];
        _progressLable.text = @"正在加载...";
    }
    
    return _progressLable;
}

- (UIImageView *)gifImageViewWithSize:(CGSize)size gifFilePath:(NSURL *)fileUrl
{
    
    CGImageSourceRef gifSource = CGImageSourceCreateWithURL((CFURLRef) fileUrl, NULL);           //将GIF图片转换成对应的图片源
    size_t frameCout = CGImageSourceGetCount(gifSource);                                         //获取其中图片源个数，即由多少帧图片组成
    NSMutableArray *frames = [[NSMutableArray alloc] init];                                      //定义数组存储拆分出来的图片
    for (size_t i = 0; i < frameCout; i++) {
        CGImageRef imageRef = CGImageSourceCreateImageAtIndex(gifSource, i, NULL); //从GIF图片中取出源图片
        UIImage *imageName = [UIImage imageWithCGImage:imageRef];                  //将图片源转换成UIimageView能使用的图片源
        [frames addObject:imageName];                                              //将图片加入数组中
        CGImageRelease(imageRef);
    }
    UIImageView *gifImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, size.width, size.height)];
    gifImageView.contentMode = UIViewContentModeScaleAspectFit;
    gifImageView.animationImages = frames; //将图片数组加入UIImageView动画数组中
    gifImageView.animationDuration = 3; //每次动画时长
    [gifImageView startAnimating];         //开启动画，此处没有调用播放次数接口，UIImageView默认播放次数为无限次，故这里不做处理
    
    CFRelease(gifSource);
    return gifImageView;
}

- (void)setShowText:(NSString *)showText
{
    self.progressLable.hidden = NO;
    self.progressLable.text = showText;
}

@end
