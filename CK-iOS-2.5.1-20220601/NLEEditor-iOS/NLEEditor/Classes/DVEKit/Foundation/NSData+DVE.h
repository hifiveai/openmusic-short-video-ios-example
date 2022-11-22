//
//  NSData+DVE.h
//  NLEEditor
//
//  Created by bytedance on 2021/5/25.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface NSData (DVE)

- (id)dve_jsonValueDecoded;

- (BOOL)dve_isGIFImage;

@end

NS_ASSUME_NONNULL_END
