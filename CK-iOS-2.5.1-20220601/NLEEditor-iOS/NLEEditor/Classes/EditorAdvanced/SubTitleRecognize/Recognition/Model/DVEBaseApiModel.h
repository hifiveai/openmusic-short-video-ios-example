//
//  DVEBaseApiModel.h
//  NLEEditor
//
//  Created by bytedance on 2021/5/18.
//

#import <Foundation/Foundation.h>
#import <Mantle/Mantle.h>

NS_ASSUME_NONNULL_BEGIN

@interface DVEBaseApiModel : MTLModel<MTLJSONSerializing>

@property (nonatomic, strong) NSString *requestID;
@property (nonatomic, strong) NSNumber *statusCode;
@property (nonatomic, strong) NSNumber *timestamp;
@property (nonatomic, strong) NSString *statusMessage;

@end

NS_ASSUME_NONNULL_END
