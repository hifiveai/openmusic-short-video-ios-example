//
//  DVETextAnimationModel.h
//  NLEEditor
//
//  Created by bytedance on 2021/7/2.
//

#import <Foundation/Foundation.h>
#import "DVEResourceModelProtocol.h"
#import <NLEPlatform/NLEResourceNode+iOS.h>

NS_ASSUME_NONNULL_BEGIN

@interface DVETextAnimationModel : NSObject

@property (nonatomic, assign) DVEAnimationType type;
@property (nonatomic, strong) NSString *name;
@property (nonatomic, strong) NSString *path;
@property (nonatomic, strong) NSString *icon;
@property (nonatomic, assign) CGFloat duration;

- (NLEResourceNode_OC *)toResourceNode;

@end

NS_ASSUME_NONNULL_END
