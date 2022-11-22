//
//  DVEHUDCustomerView.m
//  TTVideoEditorDemo
//
//  Created by bytedance on 2020/12/20
//  Copyright © 2020 bytedance. All rights reserved.
//

#import "DVEHUDCustomerView.h"
#import <DVETrackKit/UIView+VEExt.h>
#import "DVEMacros.h"
#import "NSBundle+DVE.h"
#import <DVETrackKit/DVEUILayout.h>
#import <DVETrackKit/DVECustomResourceProvider.h>
#import <Lottie/LOTAnimationView.h>

@implementation DVEHUDCustomerView

- (instancetype)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
        CGSize size = [DVEUILayout dve_sizeWithName:DVEUILayoutExportLoadingSize];
        if(CGSizeEqualToSize(size, CGSizeZero)){
            size = CGSizeMake(160, 160);
        }
        UIView* backgroundView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, size.width, size.height)];
        backgroundView.center = CGPointMake(self.width * 0.5, self.height * 0.5);
        backgroundView.layer.masksToBounds = YES;
        backgroundView.layer.cornerRadius = 10;
        backgroundView.backgroundColor = [UIColor colorWithRed:0.09 green:0.09 blue:0.09 alpha:1.0];
        [self addSubview:backgroundView];
        if(self.gifView.size.width > self.gifView.size.height){
            if(self.gifView.size.width > size.width){
                CGFloat w = size.width *2/3;
                self.gifView.frame = CGRectMake(0, 0, w, w * self.gifView.size.height / self.gifView.size.width);
            }
        }else{
            if(self.gifView.size.height > size.height){
                CGFloat h = size.height *2/3;
                self.gifView.frame = CGRectMake(0, 0, h * self.gifView.size.width / self.gifView.size.height, h);
            }
        }

        [self addSubview:self.gifView];
        [self addSubview:self.progressLable];
        CGFloat offset = (size.height - (self.gifView.frame.size.height + self.progressLable.frame.size.height))/2;
        self.gifView.center = backgroundView.center;
        self.gifView.top = backgroundView.top + offset;
        self.progressLable.top = self.gifView.bottom;
    }
    
    return self;
}

- (LOTAnimationView *)gifView
{
    if (!_gifView) {
        
        NSString *filePath = [[DVECustomResourceProvider shareManager] pathForResource:@"loading" ofType:@"json"];
        LOTAnimationView * animationView = [LOTAnimationView animationWithFilePath:filePath];
        animationView.loopAnimation = YES;
        _gifView = animationView;
    }
    
    return _gifView;
}

- (UILabel *)progressLable
{
    if (!_progressLable) {
        _progressLable = [[UILabel alloc] initWithFrame:CGRectMake(0,0, self.width, 30)];
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
