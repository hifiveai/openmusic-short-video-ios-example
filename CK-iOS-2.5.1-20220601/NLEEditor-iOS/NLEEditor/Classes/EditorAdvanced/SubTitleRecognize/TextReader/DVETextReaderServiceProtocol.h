//
//  DVETextReaderServiceProtocol.h
//  NLEEditor
//
//  Created by bytedance on 2021/5/27.
//

#import <Foundation/Foundation.h>
#import "DVETextReaderModelProtocol.h"

NS_ASSUME_NONNULL_BEGIN

@protocol DVETextReaderServiceDelegate <NSObject>

- (void)textReaderDidDownload:(NSArray<NSString *> *)audioFiles;
- (void)textReaderFailAnalysis:(NSError *)error;

@end

@protocol DVETextReaderServiceProtocol <NSObject>

@property (nonatomic, weak) id<DVETextReaderServiceDelegate> delegate;

- (void)beginPlayDemo:(NSArray<NSString *> *)texts voiceInfo:(id<DVETextReaderModelProtocol>)voiceInfo;
- (void)beginDownloadVoice:(NSArray<NSString *> *)texts voiceInfo:(id<DVETextReaderModelProtocol>)voiceInfo;
- (void)stopPlayDemo;

@end

NS_ASSUME_NONNULL_END
