//
//  DVERecognizeSentence.h
//  NLEEditor
//
//  Created by bytedance on 2021/5/18.
//

#import <Foundation/Foundation.h>
#import <Mantle/Mantle.h>

NS_ASSUME_NONNULL_BEGIN

@interface DVERecognizeSentence : MTLModel<MTLJSONSerializing>

@property (nonatomic, assign) NSInteger startTime;
@property (nonatomic, assign) NSInteger endTime;
@property (nonatomic, copy) NSString *text;
@property (nonatomic, copy) NSString *type;
@property (nonatomic, assign, readonly) BOOL isValid;


@end

NS_ASSUME_NONNULL_END
