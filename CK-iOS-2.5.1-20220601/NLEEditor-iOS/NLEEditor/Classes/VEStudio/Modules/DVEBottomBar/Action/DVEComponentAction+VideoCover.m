//
//  DVEComponentAction+VideoCover.m
//  NLEEditor
//
//  Created by bytedance on 2021/6/23.
//

#import "DVEComponentAction+VideoCover.h"
#import "DVEComponentAction+Private.h"
#import "DVEVideoCoverEditViewController.h"

@implementation DVEComponentAction (VideoCover)

- (instancetype)init {
    if (self = [super init]) {
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(openVideoCover)
                                                     name:@"showVideoCoverEditView"
                                                   object:nil];
    }
    return self;
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)openVideoCover {
    DVEVideoCoverEditViewController *videoCoverEditVC = [[DVEVideoCoverEditViewController alloc] initWithContext:self.vcContext];
    videoCoverEditVC.parentVC = self.parentVC;
    [videoCoverEditVC setDismissBlock:^{
        [self.parentVC resetVideoPreview];
    }];
    videoCoverEditVC.modalPresentationStyle = UIModalPresentationFullScreen;
    [self.parentVC presentViewController:videoCoverEditVC
                                animated:YES
                              completion:^{
        
    }];
}


@end
