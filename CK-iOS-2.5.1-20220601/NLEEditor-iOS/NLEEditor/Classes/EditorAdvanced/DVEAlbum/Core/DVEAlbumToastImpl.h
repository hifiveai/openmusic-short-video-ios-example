//
//  DVEAlbumToastImpl.h
//  VideoTemplate
//
//  Created by bytedance on 2020/12/10.
//

#import <Foundation/Foundation.h>
#import "DVEAlbumToastProtocol.h"

NS_ASSUME_NONNULL_BEGIN

@interface DVEAlbumToastImpl : NSObject <DVEAlbumToastProtocol>

@end

@interface DVEAlbumToastStyle : NSObject

/**
 The background color. Default is `[UIColor blackColor]` at 80% opacity.
 */
@property (strong, nonatomic) UIColor *backgroundColor;

/**
 The title color. Default is `[UIColor whiteColor]`.
 */
@property (strong, nonatomic) UIColor *titleColor;

/**
 The message color. Default is `[UIColor whiteColor]`.
 */
@property (strong, nonatomic) UIColor *messageColor;

/**
 A percentage value from 0.0 to 1.0, representing the maximum width of the toast
 view relative to it's superview. Default is 0.8 (80% of the superview's width).
 */
@property (assign, nonatomic) CGFloat maxWidthPercentage;

/**
 A percentage value from 0.0 to 1.0, representing the maximum height of the toast
 view relative to it's superview. Default is 0.8 (80% of the superview's height).
 */
@property (assign, nonatomic) CGFloat maxHeightPercentage;

/**
 The spacing from the horizontal edge of the toast view to the content. When an image
 is present, this is also used as the padding between the image and the text.
 Default is 10.0.
 */
@property (assign, nonatomic) CGFloat horizontalPadding;

/**
 The spacing from the vertical edge of the toast view to the content. When a title
 is present, this is also used as the padding between the title and the message.
 Default is 10.0.
 */
@property (assign, nonatomic) CGFloat verticalPadding;

/**
 The corner radius. Default is 10.0.
 */
@property (assign, nonatomic) CGFloat cornerRadius;

/**
 The title font. Default is `[UIFont awe_boldSystemFontOfSize:16.0]`.
 */
@property (strong, nonatomic) UIFont *titleFont;

/**
 The message font. Default is `[UIFont awe_systemFontOfSize:16.0]`.
 */
@property (strong, nonatomic) UIFont *messageFont;

/**
 The title text alignment. Default is `NSTextAlignmentLeft`.
 */
@property (assign, nonatomic) NSTextAlignment titleAlignment;

/**
 The message text alignment. Default is `NSTextAlignmentLeft`.
 */
@property (assign, nonatomic) NSTextAlignment messageAlignment;

/**
 The maximum number of lines for the title. The default is 0 (no limit).
 */
@property (assign, nonatomic) NSInteger titleNumberOfLines;

/**
 The maximum number of lines for the message. The default is 0 (no limit).
 */
@property (assign, nonatomic) NSInteger messageNumberOfLines;

/**
 Enable or disable a shadow on the toast view. Default is `NO`.
 */
@property (assign, nonatomic) BOOL displayShadow;

/**
 The shadow color. Default is `[UIColor blackColor]`.
 */
@property (strong, nonatomic) UIColor *shadowColor;

/**
 A value from 0.0 to 1.0, representing the opacity of the shadow.
 Default is 0.8 (80% opacity).
 */
@property (assign, nonatomic) CGFloat shadowOpacity;

/**
 The shadow radius. Default is 6.0.
 */
@property (assign, nonatomic) CGFloat shadowRadius;

/**
 The shadow offset. The default is `CGSizeMake(4.0, 4.0)`.
 */
@property (assign, nonatomic) CGSize shadowOffset;

/**
 The image size. The default is `CGSizeMake(80.0, 80.0)`.
 */
@property (assign, nonatomic) CGSize imageSize;

/**
 The size of the toast activity view when `makeToastActivity:` is called.
 Default is `CGSizeMake(100.0, 100.0)`.
 */
@property (assign, nonatomic) CGSize activitySize;

/**
 The fade in/out animation duration. Default is 0.2.
 */
@property (assign, nonatomic) NSTimeInterval fadeDuration;


/**
 Creates a new instance of `CSToastStyle` with all the default values set.
 */
- (instancetype)initWithDefaultStyle NS_DESIGNATED_INITIALIZER;

/**
 @warning Only the designated initializer should be used to create
 an instance of `CSToastStyle`.
 */
- (instancetype)init NS_UNAVAILABLE;

@end

NS_ASSUME_NONNULL_END
