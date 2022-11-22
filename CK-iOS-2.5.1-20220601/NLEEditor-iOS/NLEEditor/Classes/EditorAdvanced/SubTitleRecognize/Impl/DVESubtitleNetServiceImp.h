//
//  DVESubtitleNetServiceImp.h
//  TTVideoEditorDemo
//
//  Created by bytedance on 2021/5/23.
//  Copyright © 2021 bytedance. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <NLEEditor/DVESubtitleNetServiceProtocol.h>

NS_ASSUME_NONNULL_BEGIN

@interface DVESubtitleNetServiceImp : NSObject<DVESubtitleNetServiceProtocol>

@property (nonatomic, copy) NSString *appid;
@property (nonatomic, copy) NSString *token;
@property (nonatomic, copy) NSString *language;
@property (nonatomic, copy) NSString *baseUrlStr;

@end

NS_ASSUME_NONNULL_END
