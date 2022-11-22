//
//   DVEAlbumResourcePickerModel.m
//   NLEEditor
//
//   Created  by ByteDance on 2021/9/9.
//   Copyright © 2021 ByteDance Ltd. All rights reserved.
//
    

#import "DVEAlbumResourcePickerModel.h"
#import "NSString+VEIEPath.h"

@implementation DVEAlbumResourcePickerModel

- (instancetype)initWithURL:(NSURL *)videoUrl {
    if (self = [super init]) {
        _URL = videoUrl;
        _type = DVEResourceModelPickerTypeVideo;
        _imageDuration = CMTimeMakeWithSeconds(3, USEC_PER_SEC);
    }
    return self;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        _imageDuration = CMTimeMakeWithSeconds(3, USEC_PER_SEC);
    }
    return self;
}

- (AVURLAsset *)videoAsset
{
    if (!_videoAsset) {
        if (self.type == DVEResourceModelPickerTypeVideo) {
            AVURLAsset *asset = [AVURLAsset URLAssetWithURL:self.URL
                                                    options:@{AVURLAssetPreferPreciseDurationAndTimingKey: @(YES)}];
            _videoAsset = (AVURLAsset *)asset;
        }
    }
    
    return _videoAsset;
}

- (NSURL *)URL
{
    if (!_URL) {
        if (self.type == DVEResourceModelPickerTypeImage) {
            NSString *filePath = [[DVEAlbumResourcePickerModel tempImageResourceDirectory] stringByAppendingPathComponent:[NSString VEUUIDString]];
            if (self.isGIFImage) {
                filePath = [filePath stringByAppendingString:@".gif"];
                [self.imageData writeToFile:filePath atomically:YES];
            } else {
                [UIImageJPEGRepresentation(self.image, 1) writeToFile:filePath atomically:YES];
            }
            NSURL *picURL = [NSURL fileURLWithPath:filePath];
            _URL = picURL;
        }
    }
    
    return _URL;
}

+ (NSString*)tempImageResourceDirectory {
    NSString *imageTempDirectory = [NSTemporaryDirectory() stringByAppendingPathComponent:@"DVEAlbumImage"];
    if (![[NSFileManager defaultManager] fileExistsAtPath:imageTempDirectory]) {
        [[NSFileManager defaultManager] createDirectoryAtPath:imageTempDirectory
                                  withIntermediateDirectories:YES
                                                   attributes:nil
                                                        error:nil];
    }
    return imageTempDirectory;
}

@end
