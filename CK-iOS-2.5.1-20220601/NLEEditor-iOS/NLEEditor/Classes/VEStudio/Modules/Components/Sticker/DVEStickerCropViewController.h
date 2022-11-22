//
//  DVEStickerCropViewController.h
//  NLEEditor
//
//  Created by bytedance on 2021/9/18.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@protocol DVEStickerCropViewControllerDelegate;

@interface DVEStickerCropViewController : UIViewController

@property (nonatomic, weak) id<DVEStickerCropViewControllerDelegate> delegate;

- (instancetype)initWithImagePath:(NSString *)imagePath;

@end


@protocol DVEStickerCropViewControllerDelegate <NSObject>

- (void)cropViewController:(DVEStickerCropViewController *)viewController didFinishProcessingImage:(NSString *)imagePath;

@end

NS_ASSUME_NONNULL_END
