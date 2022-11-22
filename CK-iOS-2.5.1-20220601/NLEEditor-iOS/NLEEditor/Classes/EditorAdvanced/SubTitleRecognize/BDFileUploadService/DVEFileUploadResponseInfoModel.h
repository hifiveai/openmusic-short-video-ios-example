//
//  DVEFileUploadResponseInfoModel.h
//  NLEEditor
//
//  Created by bytedance on 2021/5/22.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface DVEFileUploadResponseInfoModel : NSObject

@property (nonatomic, copy) NSString *materialId;
@property (nonatomic, copy) NSString *tosKey;
@property (nonatomic, copy) NSString *coverURI;
@property (nonatomic, copy) NSDictionary *videoMediaInfo;

@end

NS_ASSUME_NONNULL_END
