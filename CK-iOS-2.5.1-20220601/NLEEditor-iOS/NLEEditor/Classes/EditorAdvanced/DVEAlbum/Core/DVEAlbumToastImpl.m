//
//  DVEAlbumToastImpl.m
//  VideoTemplate
//
//  Created by bytedance on 2020/12/10.
//

#import "UIColor+DVEAlbumAdditions.h"
#import "DVEAlbumToastImpl.h"
#import "DVEAlbumResourceUnion.h"

@implementation DVEAlbumToastImpl

- (void)show:(NSString *)message {
    UIWindow *window = [UIApplication sharedApplication].keyWindow;
    if (window) {
        if (!message || ![message isKindOfClass:NSString.class]) {
            message = @"";
        }
        UIImage *image = TOCResourceImage(@"icon_toast_success");
        [self show:message onView:window image:image];
    }
}

- (void)showError:(NSString *)message {
    dispatch_async(dispatch_get_main_queue(), ^{
        NSString *msg = message;
        UIWindow *window = [UIApplication sharedApplication].keyWindow;
        if (window) {
            if (!msg || ![msg isKindOfClass:NSString.class]) {
                msg = @"";
            }
            UIImage *image = TOCResourceImage(@"icon_toast_error");
            [self show:msg onView:window image:image];
        }
    });
}


- (void)show:(NSString *)message onView:(UIView *)view image:(UIImage *)image {
    dispatch_async(dispatch_get_main_queue(), ^{
        DVEAlbumToastStyle *style = [[DVEAlbumToastStyle alloc] initWithDefaultStyle];
        UIView *toastView = [self toastViewForMessage:message title:nil image:image style:style view:view];
        toastView.alpha = 1;
        [view addSubview:toastView];
        [UIView animateWithDuration:style.fadeDuration delay:1.f options:(UIViewAnimationOptionCurveLinear) animations:^{
            toastView.alpha = 0;
        } completion:^(BOOL finished) {
            [toastView removeFromSuperview];
        }];
    });
}

#pragma mark - View Construction

- (UIView *)toastViewForMessage:(NSString *)message title:(NSString *)title image:(UIImage *)image style:(DVEAlbumToastStyle *)style view:(UIView *)view {
    // sanity
    if(message == nil && title == nil && image == nil) return nil;
    
    // default to the shared style
    if (style == nil) {
        style = [[DVEAlbumToastStyle alloc] initWithDefaultStyle];
    }
    
    // dynamically build a toast view with any combination of message, title, & image
    UILabel *messageLabel = nil;
    UILabel *titleLabel = nil;
    UIImageView *imageView = nil;
    
    UIView *wrapperView = [[UIView alloc] init];
    wrapperView.autoresizingMask = (UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleBottomMargin);
    wrapperView.layer.cornerRadius = style.cornerRadius;
    wrapperView.layer.borderColor = [UIColor acc_colorWithHexString:@"#E36E55"].CGColor;
    wrapperView.layer.borderWidth = 1.0;
    if (style.displayShadow) {
        wrapperView.layer.shadowColor = style.shadowColor.CGColor;
        wrapperView.layer.shadowOpacity = style.shadowOpacity;
        wrapperView.layer.shadowRadius = style.shadowRadius;
        wrapperView.layer.shadowOffset = style.shadowOffset;
    }
    
    wrapperView.backgroundColor = style.backgroundColor;
    
    if(image != nil) {
        imageView = [[UIImageView alloc] initWithImage:image];
        imageView.contentMode = UIViewContentModeScaleAspectFit;
        imageView.frame = CGRectMake(style.horizontalPadding, style.verticalPadding, style.imageSize.width, style.imageSize.height);
    }
    
    CGRect imageRect = CGRectZero;
    
    if(imageView != nil) {
        imageRect.origin.x = style.horizontalPadding;
        imageRect.origin.y = style.verticalPadding;
        imageRect.size.width = imageView.bounds.size.width;
        imageRect.size.height = imageView.bounds.size.height;
    }
    
    if (title != nil) {
        titleLabel = [[UILabel alloc] init];
        titleLabel.numberOfLines = style.titleNumberOfLines;
        titleLabel.font = style.titleFont;
        titleLabel.textAlignment = style.titleAlignment;
        titleLabel.lineBreakMode = NSLineBreakByTruncatingTail;
        titleLabel.textColor = style.titleColor;
        titleLabel.backgroundColor = [UIColor clearColor];
        titleLabel.alpha = 1.0;
        titleLabel.text = title;
        
        // size the title label according to the length of the text
        CGSize maxSizeTitle = CGSizeMake((view.bounds.size.width * style.maxWidthPercentage) - imageRect.size.width, view.bounds.size.height * style.maxHeightPercentage);
        CGSize expectedSizeTitle = [titleLabel sizeThatFits:maxSizeTitle];
        // UILabel can return a size larger than the max size when the number of lines is 1
        expectedSizeTitle = CGSizeMake(MIN(maxSizeTitle.width, expectedSizeTitle.width), MIN(maxSizeTitle.height, expectedSizeTitle.height));
        titleLabel.frame = CGRectMake(0.0, 0.0, expectedSizeTitle.width, expectedSizeTitle.height);
    }
    
    if (message != nil) {
        messageLabel = [[UILabel alloc] init];
        messageLabel.numberOfLines = style.messageNumberOfLines;
        messageLabel.font = style.messageFont;
        messageLabel.textAlignment = style.messageAlignment;
        messageLabel.lineBreakMode = NSLineBreakByTruncatingTail;
        messageLabel.textColor = style.messageColor;
        messageLabel.backgroundColor = [UIColor clearColor];
        messageLabel.alpha = 1.0;
        messageLabel.text = message;
        
        CGSize maxSizeMessage = CGSizeMake((view.bounds.size.width * style.maxWidthPercentage) - imageRect.size.width, view.bounds.size.height * style.maxHeightPercentage);
        CGSize expectedSizeMessage = [messageLabel sizeThatFits:maxSizeMessage];
        // UILabel can return a size larger than the max size when the number of lines is 1
        expectedSizeMessage = CGSizeMake(MIN(maxSizeMessage.width, expectedSizeMessage.width), MIN(maxSizeMessage.height, expectedSizeMessage.height));
        if (imageView) {
            messageLabel.frame = CGRectMake(0.0, 0.0, expectedSizeMessage.width, imageView.bounds.size.height);
        } else {
            messageLabel.frame = CGRectMake(0.0, 0.0, expectedSizeMessage.width, expectedSizeMessage.height);
        }

    }
    
    CGRect titleRect = CGRectZero;
    
    if(titleLabel != nil) {
        titleRect.origin.x = imageRect.origin.x + imageRect.size.width + style.horizontalPadding;
        titleRect.origin.y = style.verticalPadding;
        titleRect.size.width = titleLabel.bounds.size.width;
        titleRect.size.height = titleLabel.bounds.size.height;
    }
    
    CGRect messageRect = CGRectZero;
    
    if(messageLabel != nil) {
        messageRect.origin.x = imageRect.origin.x + imageRect.size.width + style.horizontalPadding - 4;
        messageRect.origin.y = titleRect.origin.y + titleRect.size.height + style.verticalPadding;
        messageRect.size.width = messageLabel.bounds.size.width;
        messageRect.size.height = messageLabel.bounds.size.height;
    }
    
    CGFloat longerWidth = MAX(titleRect.size.width, messageRect.size.width);
    CGFloat longerX = MAX(titleRect.origin.x, messageRect.origin.x);
    
    // Wrapper width uses the longerWidth or the image width, whatever is larger. Same logic applies to the wrapper height.
    CGFloat wrapperWidth = MAX((imageRect.size.width + (style.horizontalPadding * 2.0)), (longerX + longerWidth + style.horizontalPadding));
    CGFloat wrapperHeight = MAX((messageRect.origin.y + messageRect.size.height + style.verticalPadding), (imageRect.size.height + (style.verticalPadding * 2.0)));
    
    CGSize parentSize = view.frame.size;
    
    CGFloat wrapperX = (parentSize.width - wrapperWidth) / 2.f;
    CGFloat wrapperY = 50.0f;// (parentSize.height - wrapperHeight) / 2.f;
    
    wrapperView.frame = CGRectMake(wrapperX, wrapperY, wrapperWidth, wrapperHeight);
    if(titleLabel != nil) {
        titleLabel.frame = titleRect;
        [wrapperView addSubview:titleLabel];
    }
    
    if(messageLabel != nil) {
        messageLabel.frame = messageRect;
        [wrapperView addSubview:messageLabel];
    }
    
    if(imageView != nil) {
        [wrapperView addSubview:imageView];
    }
    
    return wrapperView;
}

@end

@implementation DVEAlbumToastStyle

- (instancetype)initWithDefaultStyle {
    self = [super init];
    if (self) {
        self.backgroundColor = [[UIColor acc_colorWithHexString:@"#181718"] colorWithAlphaComponent:0.8];
        self.titleColor = [UIColor acc_colorWithHexString:@"#F9F9F9"];
        self.messageColor = [UIColor acc_colorWithHexString:@"#F9F9F9"];;
        self.maxWidthPercentage = 0.6;
        self.maxHeightPercentage = 0.6;
        self.horizontalPadding = 16.0;
        self.verticalPadding = 11.0;
        self.cornerRadius = 6.0;
        self.titleFont = [UIFont boldSystemFontOfSize:12.0];
        self.messageFont = [UIFont systemFontOfSize:12.0];
        self.titleAlignment = NSTextAlignmentLeft;
        self.messageAlignment = NSTextAlignmentLeft;
        self.titleNumberOfLines = 0;
        self.messageNumberOfLines = 0;
        self.displayShadow = NO;
        self.shadowOpacity = 0.8;
        self.shadowRadius = 6.0;
        self.shadowOffset = CGSizeMake(4.0, 4.0);
        self.imageSize = CGSizeMake(20.0, 20.0);
        self.activitySize = CGSizeMake(100.0, 100.0);
        self.fadeDuration = 0.2;
    }
    return self;
}

- (void)setMaxWidthPercentage:(CGFloat)maxWidthPercentage {
    _maxWidthPercentage = MAX(MIN(maxWidthPercentage, 1.0), 0.0);
}

- (void)setMaxHeightPercentage:(CGFloat)maxHeightPercentage {
    _maxHeightPercentage = MAX(MIN(maxHeightPercentage, 1.0), 0.0);
}

- (instancetype)init NS_UNAVAILABLE {
    return nil;
}

@end
