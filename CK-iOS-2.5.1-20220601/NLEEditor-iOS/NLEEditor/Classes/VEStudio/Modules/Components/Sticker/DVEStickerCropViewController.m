//
//  DVEStickerCropViewController.m
//  NLEEditor
//
//  Created by bytedance on 2021/9/18.
//

#import "DVEStickerCropViewController.h"
#import "DVECropPreview.h"
#import <Masonry/Masonry.h>
#import <DVETrackKit/UIView+VEExt.h>
#import <SDWebImage/SDWebImage.h>
#import "DVELoggerImpl.h"

#define PREVIEW_BOTTOM_MARGIN 40.0f
#define BOTTOM_MARGIN         60.0f
#define TOP_MARGIN            92.0f
#define SIDE_MARGIN           70.0f

#define MAX_SIZE   600

@interface DVEStickerCropViewController ()

@property (nonatomic, strong) DVECropPreview *preview;
@property (nonatomic, strong) UIButton *cancleButton;
@property (nonatomic, strong) UIButton *doneButton;

@property (nonatomic, strong) UIImage *image;
@property (nonatomic, strong) NSString *imagePath;

@end

@implementation DVEStickerCropViewController

- (instancetype)initWithImagePath:(NSString *)imagePath
{
    if (self = [super init]) {
        self.imagePath = imagePath;
    }
    
    return self;
}

- (void)initView
{
    self.view.backgroundColor = [UIColor blackColor];

    [self.view addSubview:self.cancleButton];
    [self.view addSubview:self.doneButton];
    
    self.preview.height = self.cancleButton.top - PREVIEW_BOTTOM_MARGIN - TOP_MARGIN;
    self.preview.width = self.view.width;
    self.preview.bottom = self.cancleButton.top - PREVIEW_BOTTOM_MARGIN;;
    self.preview.top = self.view.top + TOP_MARGIN;
    
    [self.view addSubview:self.preview];

    [self.preview refreshLayoutWithCropInfo:DVEResourceCropMakeDefalutPointInfo()];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self initView];
}

- (UIView *)preview
{
    if (!_preview) {
        self.image = [UIImage imageWithContentsOfFile:self.imagePath];
        DVECropResource *cropResource = [[DVECropResource alloc] initWithResouceType:DVECropResourceImage image:self.image video:nil];
        _preview = [[DVECropPreview alloc] initWithResouce:cropResource];
    }
    
    return _preview;
}

- (UIButton *)cancleButton
{
    if (!_cancleButton) {
        _cancleButton = [[UIButton alloc] initWithFrame:CGRectMake(SIDE_MARGIN, self.view.height - 25 - BOTTOM_MARGIN, 68, 25)];
        [_cancleButton setTitle:@"取消" forState:UIControlStateNormal];
        [_cancleButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [_cancleButton addTarget:self action:@selector(cancel) forControlEvents:UIControlEventTouchUpInside];
    }
    
    return _cancleButton;
}

- (UIButton *)doneButton
{
    if (!_doneButton) {
        _doneButton = [[UIButton alloc] initWithFrame:CGRectMake(self.view.width - 68 - SIDE_MARGIN, self.view.height - 25 - BOTTOM_MARGIN, 68, 25)];
        [_doneButton setTitle:@"确认" forState:UIControlStateNormal];
        [_doneButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [_doneButton addTarget:self action:@selector(done) forControlEvents:UIControlEventTouchUpInside];
    }
    
    return _doneButton;
}

- (void)cancel
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)done
{
    DVEResourceCropPointInfo resourceInfo = DVEResourceCropMakeDefalutPointInfo();
    [self.preview calculateResourceInfoUpperLeftPoint:&resourceInfo.upperLeft
                                      upperRightPoint:&resourceInfo.upperRight
                                       lowerLeftPoint:&resourceInfo.lowerLeft
                                      lowerRightPoint:&resourceInfo.lowerRight];
    
    UIImage  *image    = self.image;
    NSString *filePath = self.imagePath;
    
    if (!DVEResourceCropPointInfoEqual(resourceInfo, DVEResourceCropMakeDefalutPointInfo())) {
        CGRect rect = [self cropRectInSize:image.size resourceInfo:resourceInfo];
        image = [self.image sd_croppedImageWithRect:rect];
    }

    image = [self resizeImageIfNeeded:image];
    
    if (image == self.image) { // No process on image
        [self.delegate cropViewController:self didFinishProcessingImage:filePath];
    } else {
        BOOL result = [UIImagePNGRepresentation(image) writeToFile:filePath atomically:YES];
        if (result) {
            DVELogInfo(@"Write new sticker image to %@", filePath);
            [self.delegate cropViewController:self didFinishProcessingImage:filePath];
        } else {
            DVELogError(@"Failed to write image");
        }
    }
    
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (UIImage *)resizeImageIfNeeded:(UIImage *)image
{
    CGSize size = image.size;
    
    CGFloat longSide = MAX(size.width, size.height);
    if (longSide <= MAX_SIZE) {
        return image;
    }
        
    CGFloat shoutSide = MIN(size.width, size.height);

    CGFloat scale = MAX_SIZE / longSide;
    longSide = MAX_SIZE;
    shoutSide *= scale;
    
    CGSize newSize;
    if (size.width > size.height) {
        newSize = CGSizeMake(longSide, shoutSide);
    } else {
        newSize = CGSizeMake(shoutSide, longSide);
    }
        
    UIImage *resizedImage = [image sd_resizedImageWithSize:newSize scaleMode:SDImageScaleModeFill];
    
    DVELogInfo(@"Resize image, (%f,%f) => (%f,%f)", size.width, size.height, newSize.width, newSize.height);
    
    return resizedImage;
}

- (CGRect)cropRectInSize:(CGSize)size resourceInfo:(DVEResourceCropPointInfo)resourceInfo
{
    CGFloat width  = size.width;
    CGFloat height = size.height;
     
    CGFloat x = width  * resourceInfo.upperLeft.x;
    CGFloat y = height * resourceInfo.upperLeft.x;
    CGFloat w = width  * (resourceInfo.upperRight.x - resourceInfo.upperLeft.x);
    CGFloat h = height * (resourceInfo.lowerLeft.y  - resourceInfo.upperLeft.y);
    
    return CGRectMake(x, y, w, h);
}

@end
