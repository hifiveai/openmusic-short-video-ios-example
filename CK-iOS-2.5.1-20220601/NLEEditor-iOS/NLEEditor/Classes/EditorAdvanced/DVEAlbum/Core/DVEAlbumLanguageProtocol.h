//
//  DVEAlbumLanguageProtocol.h
//  VideoTemplate
//
//  Created by bytedance on 2020/11/26.
//

#import <Foundation/Foundation.h>

#define DVEAlbumOptionsStringValue(__value__, __placeholder__) __value__
#define DVEAlbumNSLocalizedString(key, comment) [[NSBundle mainBundle] localizedStringForKey:key value:@"" table:nil]
#define DVEAlbumLocalizedString(key, placeholder) ([DVEAlbumNSLocalizedString(DVEAlbumOptionsStringValue(key,@""),@"") isEqualToString:DVEAlbumOptionsStringValue(key,@"")] ? DVEAlbumOptionsStringValue(placeholder,@"") : (DVEAlbumNSLocalizedString(DVEAlbumOptionsStringValue(key,@""),@"")))

#define TOCLocalizedString(str, defaultTrans)  (DVEAlbumLocalizedString(str, defaultTrans).length > 0 ? DVEAlbumLocalizedString(str, defaultTrans) : defaultTrans)
#define TOCLocalizedCurrentString(str)  (TOCLanguage() ? [TOCLanguage() localizedStringWithStr:str defaultTranslation:nil] : str)
#define TOCLocalizedStringWithFormat(format, defaultTrans, ...) [TOCLanguage() localizedStringWithFormat:format defaultTranslation:defaultTrans, __VA_ARGS__]

@protocol DVEAlbumLanguageProtocol <NSObject>

- (NSString * _Nullable)localizedStringWithStr:(NSString * _Nonnull)key defaultTranslation:(NSString * _Nullable)defaultTrans;

- (NSString * _Nullable)localizedStringWithFormat:(NSString * _Nonnull)key defaultTranslation:(NSString * _Nullable)defaultTrans, ...;

@end

FOUNDATION_STATIC_INLINE id<DVEAlbumLanguageProtocol> _Nullable TOCLanguage() {
    return nil;
}
