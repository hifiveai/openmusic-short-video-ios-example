//
//  DVETextTemplateDepResourceModelProtocol.h
//  NLEEditor
//
//  Created by bytedance on 2021/7/1.
//
//  文字模板 资源依赖
#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@protocol DVETextTemplateDepResourceModelProtocol <NSObject>
@property (nonatomic, copy) NSString *resourceId;
@property (nonatomic, copy) NSString *path;
@end

NS_ASSUME_NONNULL_END
