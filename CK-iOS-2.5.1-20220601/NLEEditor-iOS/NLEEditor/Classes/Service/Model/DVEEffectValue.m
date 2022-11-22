//
//  DVEEffectValue.m
//  TTVideoEditorDemo
//
//  Created by bytedance on 2020/12/20
//  Copyright © 2020 bytedance. All rights reserved.
//

#import "DVEEffectValue.h"
#import "DVEMacros.h"

@implementation DVEEffectValue
@synthesize identifier;
@synthesize assetImage;
@synthesize imageURL;
@synthesize name;
@synthesize sourcePath;
@synthesize stickerType;
@synthesize alignType;
@synthesize color;
@synthesize style;
@synthesize overlap;
@synthesize typeSettingKind;
@synthesize textTemplateDeps;
@synthesize resourceTag;
@synthesize mask;

- (instancetype)initWithType:(VEEffectValueType)type
                      Bundle:(NSString *)bundle
                        name:(NSString *)name
                       imageURL:(NSURL *)imageURL
                       assetImage:(UIImage *)assetImage
                         key:(NSString *)key
                     indesty:(float)indesty
{
    if (self = [super init]) {
        self.valueType = type;
        self.name = name;
        self.sourcePath = [name pathInBundle:bundle];
        self.imageURL = imageURL;
        self.assetImage = assetImage;
        self.key = key;
        self.indesty = indesty;
    }
    
    return self;
}

- (instancetype)initWithType:(VEEffectValueType)type
                      Bundle:(NSString *)bundle
                        name:(NSString *)name
                       image:(NSString *)image
                         key:(NSString *)key
                     indesty:(float)indesty{
    if (self = [super init]) {
        self.valueType = type;
        self.name = name;
        self.sourcePath = [name pathInBundle:bundle];
        self.imageURL = imageURL;
        self.assetImage = [image dve_toImage];
        self.key = key;
        self.indesty = indesty;
    }
    
    return self;
}

- (instancetype)initWithInjectModel:(id<DVEResourceModelProtocol>)model{
    
    if(self = [super init]){
        [self updateFromModel:model];
        self.injectModel = model;
    }
    return self;
}

- (NSString *)composerTag
{
    return [NSString stringWithFormat:@"%@",self.sourcePath];;
}

- (NSString *)composerPath
{
    return [NSString stringWithFormat:@"%@:%@:%f",self.sourcePath,self.key,self.indesty];
}

- (id)mutableCopyWithZone:(nullable NSZone *)zone
{
    
    DVEEffectValue *evalue = [[DVEEffectValue allocWithZone:zone] init];
    evalue.valueType = self.valueType;
    evalue.beautyType = self.beautyType;
    evalue.sourcePath = self.sourcePath;
    evalue.imageURL = self.imageURL;
    evalue.assetImage = self.assetImage;
    evalue.name = self.name;
    evalue.key = self.key;
    evalue.indesty = self.indesty;
    evalue.typeSettingKind = self.typeSettingKind;
    evalue.textTemplateDeps = self.textTemplateDeps;
    evalue.resourceTag = self.resourceTag;
    return evalue;
}

- (id)copyWithZone:(nullable NSZone *)zone
{
    
    DVEEffectValue *evalue = [[DVEEffectValue allocWithZone:zone] init];
    evalue.valueType = self.valueType;
    evalue.beautyType = self.beautyType;
    evalue.sourcePath = self.sourcePath;
    evalue.imageURL = self.imageURL;
    evalue.assetImage = self.assetImage;
    evalue.name = self.name;
    evalue.key = self.key;
    evalue.indesty = self.indesty;
    evalue.typeSettingKind = self.typeSettingKind;
    evalue.textTemplateDeps = self.textTemplateDeps;
    evalue.resourceTag = self.resourceTag;
    return evalue;
}


- (void)updateFromModel:(id<DVEResourceModelProtocol>)model {
    self.name = model.name;
    self.assetImage = model.assetImage;
    self.sourcePath = model.sourcePath;
    self.imageURL = model.imageURL;
    self.identifier = model.identifier;
    self.overlap = model.overlap;
    self.style = model.style;
    self.color = model.color;
    self.alignType = model.alignType;
    self.stickerType = model.stickerType;
    self.resourceTag = model.resourceTag;
    self.typeSettingKind = model.typeSettingKind;
    self.textTemplateDeps = model.textTemplateDeps;
    self.mask = model.mask;
}

- (void)downloadModel:(nonnull void (^)(id<DVEResourceModelProtocol> _Nonnull))handler { 
    if(self.injectModel && [self.injectModel respondsToSelector:@selector(downloadModel:)]){
        @weakify(self);
        [self.injectModel downloadModel:^(id<DVEResourceModelProtocol>  _Nonnull model) {
            @strongify(self);
            self.assetImage = model.assetImage;
            self.sourcePath = model.sourcePath;
            self.imageURL = model.imageURL;
            handler(self);
        }];
    }
}

- (DVEResourceModelStatus)status { 
    if(self.injectModel ){
        return [self.injectModel status];
    }
    return DVEResourceModelStatusDefault;
}

@end
