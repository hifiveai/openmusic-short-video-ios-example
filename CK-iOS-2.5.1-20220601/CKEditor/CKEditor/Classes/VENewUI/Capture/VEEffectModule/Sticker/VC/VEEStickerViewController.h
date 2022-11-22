//
//  VEEStickerViewController.h
//  TTVideoEditorDemo
//
//  Created by bytedance on 2020/12/20
//  Copyright © 2020 bytedance. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "VECapProtocol.h"
#import <NLEEditor/DVEEffectValue.h>



NS_ASSUME_NONNULL_BEGIN
typedef void (^VEEStickerCallBackBlock)(DVEEffectValue *evalue);

@interface VEEStickerViewController : UIViewController
@property (nonatomic, weak) id<VECapProtocol> capManager;

@property (nonatomic, assign) NSUInteger index;

@property (nonatomic, copy) VEEStickerCallBackBlock didSelectedBlock;

- (void)reset;

@end

NS_ASSUME_NONNULL_END
