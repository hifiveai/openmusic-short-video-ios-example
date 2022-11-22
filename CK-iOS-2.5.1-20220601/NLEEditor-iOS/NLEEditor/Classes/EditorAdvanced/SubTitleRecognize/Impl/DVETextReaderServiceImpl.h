//
//  DVETextReaderServiceImpl.h
//  NLEEditor
//
//  Created by bytedance on 2021/5/27.
//

#import <Foundation/Foundation.h>
#import "DVETextReaderServiceProtocol.h"

NS_ASSUME_NONNULL_BEGIN

FOUNDATION_EXPORT NSErrorDomain const DVETextReaderServiceErrorDomain;

@interface DVETextReaderServiceImpl : NSObject <DVETextReaderServiceProtocol>

@property (nonatomic, copy) NSString *appId;
@property (nonatomic, copy) NSString *uid;
@property (nonatomic, copy) NSString *ttsAddress;
@property (nonatomic, copy) NSString *ttsUri;
@property (nonatomic, copy) NSString *ttsCluster;
@property (nonatomic, copy) NSString *captUri;

@end

NS_ASSUME_NONNULL_END
