//
//   VEResourceLoader.m
//   TTVideoEditorDemo
//
//   Created  by bytedance on 2021/5/14.
//   Copyright © 2021 ByteDance Ltd. All rights reserved.
//
    

#import "VEResourceLoader.h"
#import "VEResourceModel.h"
#import "VEResourceMusicModel.h"
#import "VETextReaderModel.h"
#import "VECurveSpeedModel.h"
#import <MJExtension/MJExtension.h>

typedef NSString *const VEBundleName;

static VEBundleName VEBundleNameStickerAnimation = @"sticker_animation";
static VEBundleName VEBundleNameTextAnimation    = @"text_animation";

@interface VEResourceLoader ()

@end

@implementation VEResourceLoader

- (instancetype)init {
    self = [super init];
    if (self) {
    }
    return self;
}

+ (NSString *)curNameWithDic:(NSDictionary *)dic
{
    NSString *namekey = @"name";
    // iOS 获取设备当前语言和地区的代码 zh-Hans-CN
    NSString *currentLanguageRegion = [[[NSUserDefaults standardUserDefaults] objectForKey:@"AppleLanguages"] firstObject];
    NSString *str = CKEditorLocStringWithKey(@"ck_edit", @"");
    if ([str isEqualToString:@"Edit"] && ![currentLanguageRegion isEqualToString:@"zh-Hans-CN"]) {
        namekey = @"name_en";
    }
    if ([dic[namekey] length] > 0) {
        return dic[namekey];
    } else {
        return dic[@"name"];
    }
}

- (id)jsonObjWithJsonPath:(NSString *)name withBunle:(NSString *)bundle
{
    NSString *path = [name pathInBundle:bundle];
    NSData *data = [NSData dataWithContentsOfFile:path];
    NSError *error = nil;
    id result = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:&error];
         NSLog(@"\n%@", [error localizedDescription]);
    
    return result;
    
}

- (void)canvasRatioModel:(DVEResourceModelLoadHandler)hander {
    if (hander) {
        NSArray<NSString *> *ratios = @[CKEditorLocStringWithKey(@"ck_ratio_origin", @"原始"), @"9:16", @"3:4", @"1:1", @"4:3", @"16:9"];
        NSMutableArray* modelArr = [NSMutableArray array];
        for (NSInteger i = 0; i < ratios.count; i++) {
            VEResourceModel *eValue = [[VEResourceModel alloc] init];
            eValue.canvasType = (DVEModuleCanvasType)i;
            eValue.name = ratios[i];
            [modelArr addObject:eValue];
        }
        hander(modelArr, nil);
    }
}

- (void)duetValueArr:(void(^)(NSArray<DVEEffectValue*>* _Nullable datas,NSString* _Nullable error))handler
{
    if(handler){
        [self duetModel:^(NSArray<id<DVEResourceCategoryModelProtocol>> * _Nullable datas, NSString * _Nullable errMsg) {
            NSMutableArray* array = nil;
            if(!errMsg){
                array = [NSMutableArray array];
                for(id<DVEResourceModelProtocol> model in datas){
                    DVEEffectValue* eValue = [DVEEffectValue new];
                    eValue.name = model.name;
                    eValue.identifier = eValue.name;
                    eValue.assetImage = model.assetImage;
                    eValue.sourcePath = model.sourcePath;
                    eValue.imageURL = model.imageURL;
                    eValue.key = @"switchButton";
                    eValue.indesty = 1;
                    [array addObject:eValue];
                }
            }
            handler(array,errMsg);
        }];
    }
}

- (void)duetModel:(DVEResourceModelLoadHandler)hander   {

    if(hander){
        NSDictionary *styledic = [self jsonObjWithJsonPath:@"duet.json" withBunle:@"duet"];
        NSArray *listArr = [[styledic objectForKey:@"resource"] objectForKey:@"list"];
        NSMutableArray* styles = [NSMutableArray arrayWithCapacity:listArr.count];
        

        for(NSDictionary* m in listArr){
            VEResourceModel* eValue = [VEResourceModel new];
            eValue.name = m[@"name"];
            eValue.identifier = eValue.name;
            eValue.sourcePath = [m[@"path"] pathInBundle:@"duet"];
            ///TODO 暂时测试写死图片
            eValue.imageURL = [NSURL fileURLWithPath:[m[@"icon"] pathInBundle:@"duet"]];
            eValue.assetImage = [UIImage imageNamed:@"iconFilterwu"];
            [styles addObject:eValue];
        }
        
        hander(styles,nil);
    }

}

- (void)adjustModel:(DVEResourceModelLoadHandler)hander {
    if(hander){
        NSDictionary *modelDic = [self jsonObjWithJsonPath:@"Adjust.json" withBunle:@"adjust"];
        NSArray *listArr = [[modelDic objectForKey:@"resource"] objectForKey:@"list"];
        NSMutableArray* modelArr = [NSMutableArray arrayWithCapacity:listArr.count];
        

        for(NSDictionary* m in listArr){
            VEResourceModel* eValue = [VEResourceModel new];
            eValue.name = [VEResourceLoader curNameWithDic:m];
            eValue.identifier = eValue.name;
            eValue.sourcePath = [m[@"path"] pathInBundle:@"adjust"];
            eValue.imageURL = [NSURL fileURLWithPath:[m[@"icon"] pathInBundle:@"adjust"]];
            eValue.resourceTag = DVEResourceTagAmazing;
            [modelArr addObject:eValue];
        }
        hander(modelArr,nil);
    }
}

- (void)animationCombinModel:(DVEResourceModelLoadHandler)hander{
    
    if(hander){
        NSDictionary *modelDic = [self jsonObjWithJsonPath:@"video_animation.json" withBunle:@"video_animation"];
        NSDictionary *outDic = [modelDic objectForKey:@"resource"];
        NSArray *listArr = [outDic objectForKey:@"list"];
        NSMutableArray* modelArr = [NSMutableArray arrayWithCapacity:listArr.count];
        

        for(NSDictionary* m in listArr){
            NSString *tag = m[@"tags"];
            if ([tag rangeOfString:@"组合"].length > 0) {
                VEResourceModel* eValue = [VEResourceModel new];
                eValue.name = [VEResourceLoader curNameWithDic:m];
                eValue.identifier = eValue.name;
                eValue.sourcePath = [m[@"path"] pathInBundle:@"video_animation"];
                eValue.imageURL = [NSURL fileURLWithPath:[m[@"icon"] pathInBundle:@"video_animation"]];
                [modelArr addObject:eValue];
            }
            
        }
        hander(modelArr,nil);
    }
    
}

- (void)animationInModel:(DVEResourceModelLoadHandler)hander{
    
    if(hander){
        NSDictionary *modelDic = [self jsonObjWithJsonPath:@"video_animation.json" withBunle:@"video_animation"];
        NSDictionary *outDic = [modelDic objectForKey:@"resource"];
        NSArray *listArr = [outDic objectForKey:@"list"];
        NSMutableArray* modelArr = [NSMutableArray arrayWithCapacity:listArr.count];
        

        for(NSDictionary* m in listArr){
            NSString *tag = m[@"tags"];
            if ([tag rangeOfString:@"入场"].length > 0) {
                VEResourceModel* eValue = [VEResourceModel new];
                eValue.name = [VEResourceLoader curNameWithDic:m];
                eValue.identifier = eValue.name;
                eValue.sourcePath = [m[@"path"] pathInBundle:@"video_animation"];
                eValue.imageURL = [NSURL fileURLWithPath:[m[@"icon"] pathInBundle:@"video_animation"]];
                [modelArr addObject:eValue];
            }
        }
        hander(modelArr,nil);
    }
    
}

- (void)animationOutModel:(DVEResourceModelLoadHandler)hander{
    
    if(hander){
        NSDictionary *modelDic = [self jsonObjWithJsonPath:@"video_animation.json" withBunle:@"video_animation"];
        NSDictionary *outDic = [modelDic objectForKey:@"resource"];
        NSArray *listArr = [outDic objectForKey:@"list"];
        NSMutableArray* modelArr = [NSMutableArray arrayWithCapacity:listArr.count];
        

        for(NSDictionary* m in listArr){
            NSString *tag = m[@"tags"];
            if ([tag rangeOfString:@"出场"].length > 0) {
                VEResourceModel* eValue = [VEResourceModel new];
                eValue.name = [VEResourceLoader curNameWithDic:m];
                eValue.identifier = eValue.name;
                eValue.sourcePath = [m[@"path"] pathInBundle:@"video_animation"];
                eValue.imageURL = [NSURL fileURLWithPath:[m[@"icon"] pathInBundle:@"video_animation"]];
                [modelArr addObject:eValue];
            }
        }
        hander(modelArr,nil);
    }
    
}

- (void)effectCategory:(DVEResourceCategoryLoadHandler)hander{
    if(hander){
        NSMutableArray* array = [NSMutableArray array];
        
        NSMutableDictionary *effect_basic = [NSMutableDictionary dictionary];
        [effect_basic setDictionary:[self jsonObjWithJsonPath:@"ve_effect.json" withBunle:@"ve_effect"]];
        [effect_basic setObject:@"ve_effect.json" forKey:@"file"];
        
        NSArray *effectDic = @[effect_basic];

        for(NSDictionary* category in effectDic){
            VEResourceCategoryModel* categoryModel = [VEResourceCategoryModel new];
            categoryModel.categoryId = [category objectForKey:@"file"];
            categoryModel.name = [category objectForKey:@"name"];
            [array addObject:categoryModel];
        }
        hander(array,nil);
    }
}
/// 模板资源分类
- (void)textTemplateCategory:(DVEResourceCategoryLoadHandler)hander{
    if(!hander){
        return;
    }
    NSString *bundleName = @"text_template";
    NSMutableArray* array = [NSMutableArray array];

    NSArray *names = @[@"text_template.json", ];
    for (NSString *n in names) {
        NSMutableDictionary *category = [NSMutableDictionary dictionary];
        [category setDictionary:[self jsonObjWithJsonPath:n withBunle:bundleName]];
        [category setObject:n forKey:@"file"];
        
        VEResourceCategoryModel* categoryModel = [VEResourceCategoryModel new];
        categoryModel.categoryId = [category objectForKey:@"file"];
//        categoryModel.name = [VEResourceLoader curNameWithDic:category];
        NSString *namekey = @"热门";
        // iOS 获取设备当前语言和地区的代码 zh-Hans-CN
        NSString *currentLanguageRegion = [[[NSUserDefaults standardUserDefaults] objectForKey:@"AppleLanguages"] firstObject];
        NSString *str = CKEditorLocStringWithKey(@"ck_edit", @"");
        if ([str isEqualToString:@"Edit"] && ![currentLanguageRegion isEqualToString:@"zh-Hans-CN"]) {
            namekey = @"hot";
        }
        categoryModel.name = namekey;
        [array addObject:categoryModel];
    }

    hander(array,nil);
}

- (void)effectModel:(id<DVEResourceCategoryModelProtocol>)category handler:(DVEResourceModelLoadHandler)hander{
    if(hander){
        NSDictionary *dic = [self jsonObjWithJsonPath:category.categoryId withBunle:@"ve_effect"];
        NSArray* sublist = [[dic objectForKey:@"resource"] objectForKey:@"list"];
        NSMutableArray* effects = [NSMutableArray arrayWithCapacity:sublist.count];
        
        for(NSDictionary* effect in sublist){
            NSString* effectName = [VEResourceLoader curNameWithDic:effect];
            NSString* effectPath = effect[@"path"];
            NSString* effectIconPath = effect[@"icon"];
            VEResourceModel* eValue = [VEResourceModel new];
            eValue.name = effectName;
            eValue.identifier = eValue.name;
            eValue.imageURL = [NSURL fileURLWithPath:[effectIconPath pathInBundle:@"ve_effect"]];
            eValue.sourcePath = [effectPath pathInBundle:@"ve_effect"];
            eValue.resourceTag = DVEResourceTagAmazing;
            [effects addObject:eValue];
        }
        hander(effects,nil);
    }
}
/// 模板资源
- (void)textTemplateModel:(id<DVEResourceCategoryModelProtocol>)category handler:(DVEResourceModelLoadHandler)hander{
    if(hander){
        NSString *bundleName = @"text_template";
        NSDictionary *dic = [self jsonObjWithJsonPath:category.categoryId withBunle:bundleName];
        NSArray* sublist = [[dic objectForKey:@"resource"] objectForKey:@"list"];
        NSMutableArray* resList = [NSMutableArray arrayWithCapacity:sublist.count];
        
        for(NSDictionary* res in sublist){
            NSString* name = [VEResourceLoader curNameWithDic:res];
            NSString* path = res[@"path"];
            VEResourceModel* eValue = [VEResourceModel new];
            eValue.name = name;
            eValue.identifier = eValue.name;
            ///TODO 暂时测试写死图片
            eValue.assetImage = [UIImage imageNamed:@"iconFilterwu"];
            eValue.imageURL = [NSURL fileURLWithPath:[res[@"icon"] pathInBundle:bundleName]];
            eValue.sourcePath = [path pathInBundle:bundleName];
            NSArray *depList = res[@"dep"];
            if (depList) {
                NSMutableArray *depModels = [[NSMutableArray alloc] initWithCapacity:depList.count];
                for (NSDictionary *info in depList) {
                    VETextTemplateDepResourceModel *tmp = [[VETextTemplateDepResourceModel alloc] init];
                    tmp.resourceId = info[@"resourceId"];
                    tmp.path = [info[@"path"] pathInBundle:bundleName];
                    [depModels addObject:tmp];
                }
                eValue.textTemplateDeps = [depModels copy];
            }
            
            [resList addObject:eValue];
        }
        hander(resList,nil);
    }
}

- (void)filterModel:(DVEResourceModelLoadHandler)hander {
    if(hander){
        NSDictionary *modelDic = [self jsonObjWithJsonPath:@"ve_filter.json" withBunle:@"ve_filter"];
        NSArray *listArr = [[modelDic objectForKey:@"resource"] objectForKey:@"list"];
        NSMutableArray* modelArr = [NSMutableArray arrayWithCapacity:listArr.count];
        

        for(NSDictionary* m in listArr){
            VEResourceModel* eValue = [VEResourceModel new];
            eValue.name = [VEResourceLoader curNameWithDic:m];
            eValue.identifier = eValue.name;
            eValue.sourcePath = [m[@"path"] pathInBundle:@"ve_filter"];
            eValue.imageURL = [NSURL fileURLWithPath:[m[@"icon"] pathInBundle:@"ve_filter"]];
            eValue.resourceTag = DVEResourceTagAmazing;
            [modelArr addObject:eValue];
        }
        hander(modelArr,nil);
    }
}

- (void)flowerTextModel:(DVEResourceModelLoadHandler)hander  {
    
    if(hander){
        
        NSDictionary *modelDic = [self jsonObjWithJsonPath:@"flower.json" withBunle:@"flower"];
        NSArray *listArr = [[modelDic objectForKey:@"resource"] objectForKey:@"list"];
        NSMutableArray* modelArr = [NSMutableArray arrayWithCapacity:listArr.count];
        

        for(NSDictionary* m in listArr){
            VEResourceModel* eValue = [VEResourceModel new];
            eValue.name = m[@"name"];
            eValue.identifier = eValue.name;
            eValue.sourcePath = [m[@"path"] pathInBundle:@"flower"];
            eValue.imageURL = [NSURL fileURLWithPath:[m[@"icon"] pathInBundle:@"flower"]];
            [modelArr addObject:eValue];
        }
        hander(modelArr,nil);
    }

}

- (void)textAnimationModel:(DVEResourceModelLoadHandler)hander type:(DVEAnimationType)type
{
    [self handleAnimationModelsWithBundleName:VEBundleNameTextAnimation type:type handler:hander];
}

- (void)stickerAnimationModel:(DVEResourceModelLoadHandler)hander type:(DVEAnimationType)type
{
    [self handleAnimationModelsWithBundleName:VEBundleNameStickerAnimation type:type handler:hander];
}

- (void)handleAnimationModelsWithBundleName:(VEBundleName)bundleName type:(DVEAnimationType)type handler:(DVEResourceModelLoadHandler)handler
{
    NSString *jsonName = [bundleName stringByAppendingPathExtension:@"json"];
    
    NSString *tagName = @"";
    if (type == DVEAnimationTypeIn) {
        tagName = @"入场";
    }
    if (type == DVEAnimationTypeLoop) {
        tagName = @"循环";
    }
    if (type == DVEAnimationTypeOut) {
        tagName = @"出场";
    }
    
    NSArray *models = [self resourceModelsWithJsonName:jsonName bundleName:bundleName tag:tagName];
    
    handler(models, nil);
}

- (NSArray<VEResourceModel *> *)resourceModelsWithJsonName:(NSString *)jsonName bundleName:(VEBundleName)bundleName tag:(NSString *)tagName
{
    NSDictionary *modelDic = [self jsonObjWithJsonPath:jsonName withBunle:bundleName];
    NSArray *listArr = [[modelDic objectForKey:@"resource"] objectForKey:@"list"];
    NSMutableArray* modelArr = [NSMutableArray arrayWithCapacity:listArr.count];

    for (NSDictionary *m in listArr){
        NSString *tag = m[@"tags"];
        if (tag && ![tag containsString:tagName]) {
            continue;
        }
        
        VEResourceModel *model = [[VEResourceModel alloc] init];
        model.name = [VEResourceLoader curNameWithDic:m];
        model.identifier = model.name;
        model.sourcePath = [m[@"path"] pathInBundle:bundleName];
        model.imageURL = [NSURL fileURLWithPath:[m[@"icon"] pathInBundle:bundleName]];
        [modelArr addObject:model];
    }
    
    return modelArr;
}

- (void)textBubbleModel:(DVEResourceModelLoadHandler)hander {
    if(!hander){
        return;
    }
    NSString *name = @"bubble";
    NSDictionary *modelDic = [self jsonObjWithJsonPath:@"bubble.json" withBunle:name];
    NSArray *listArr = [[modelDic objectForKey:@"resource"] objectForKey:@"list"];
    NSMutableArray* modelArr = [NSMutableArray arrayWithCapacity:listArr.count];
    

    for(NSDictionary* m in listArr){
        VEResourceModel* eValue = [VEResourceModel new];
        eValue.name = [VEResourceLoader curNameWithDic:m];
        eValue.identifier = eValue.name;
        eValue.sourcePath = [m[@"path"] pathInBundle:name];
        eValue.imageURL = [NSURL fileURLWithPath:[m[@"icon"] pathInBundle:name]];
        [modelArr addObject:eValue];
    }
    hander(modelArr,nil);
}
- (void)maskModel:(DVEResourceModelLoadHandler)hander{
    
    if(hander){
        
        NSDictionary *modelDic = [self jsonObjWithJsonPath:@"videomask.json" withBunle:@"video_mask"];
        NSArray *listArr = [[modelDic objectForKey:@"resource"] objectForKey:@"list"];
        NSMutableArray* modelArr = [NSMutableArray arrayWithCapacity:listArr.count];
        

        for(NSDictionary* m in listArr){
            VEResourceModel* eValue = [VEResourceModel new];
            eValue.name = [VEResourceLoader curNameWithDic:m];
            eValue.identifier = eValue.name;
            eValue.sourcePath = [m[@"path"] pathInBundle:@"video_mask"];
            eValue.imageURL = [NSURL fileURLWithPath:[m[@"icon"] pathInBundle:@"video_mask"]];
            eValue.mask = m[@"mask"];
            [modelArr addObject:eValue];
        }
        hander(modelArr,nil);
    }

}

- (void)audioChangModel:(DVEResourceModelLoadHandler)hander
{
    if(hander){
        
        NSDictionary *modelDic = [self jsonObjWithJsonPath:@"tone.json" withBunle:@"tone"];
        NSArray *listArr = [[modelDic objectForKey:@"resource"] objectForKey:@"list"];
        NSMutableArray* modelArr = [NSMutableArray arrayWithCapacity:listArr.count];
        

        for(NSDictionary* m in listArr){
            VEResourceModel* eValue = [VEResourceModel new];
            eValue.name = [VEResourceLoader curNameWithDic:m];
            eValue.identifier = eValue.name;
            eValue.sourcePath = [m[@"path"] pathInBundle:@"tone"];
            eValue.imageURL = [NSURL fileURLWithPath:[m[@"icon"] pathInBundle:@"tone"]];
            [modelArr addObject:eValue];
        }
        hander(modelArr,nil);
    }
}

- (void)mixedEffectModel:(DVEResourceModelLoadHandler)hander{
    if(hander){
        NSMutableArray* array = [NSMutableArray array];
        NSDictionary *mixedEffectData = [self jsonObjWithJsonPath:@"mix.json" withBunle:@"mix"];
        NSArray *dataList = [[mixedEffectData objectForKey:@"resource"] objectForKey:@"list"];
        
        NSString *bundlePath = [[NSBundle mainBundle] pathForResource:@"mix" ofType:@"bundle"];
//        VEResourceModel *model = [[VEResourceModel alloc] init];
//        model.name = @"正常";
//        model.imageURL = [NSURL fileURLWithPath:[bundlePath stringByAppendingPathComponent:@"ic_mode_normal.png"]];
//        [array addObject:model];
        for (NSDictionary *data in dataList) {
            VEResourceModel *model = [[VEResourceModel alloc] init];
            NSString *name = data[@"name"];
            NSString *path = [data[@"path"] pathInBundle:@"mix"];
            model.name = [VEResourceLoader curNameWithDic:data];
            model.identifier = model.name;
            model.sourcePath = path;
            model.imageURL = [NSURL fileURLWithPath:[bundlePath stringByAppendingPathComponent:data[@"icon"]]];
            [array addObject:model];
        }
        hander(array,nil);
    }
}

- (void)musicCategory:(DVEResourceCategoryLoadHandler)hander {
    ///下面都是测试数据逻辑
    if(hander){
        NSMutableArray* array = [NSMutableArray array];
        VEResourceCategoryModel* localCategoryModel = [VEResourceCategoryModel new];

        localCategoryModel.name = CKEditorLocStringWithKey(@"ck_local_music",@"本地");
        localCategoryModel.categoryId = @"1";
        [array addObject:localCategoryModel];
        
        VEResourceCategoryModel* onlineCategoryModel = [VEResourceCategoryModel new];
        onlineCategoryModel.name = CKEditorLocStringWithKey(@"ck_music_library",@"音乐库");
        onlineCategoryModel.categoryId = @"2";
        [array addObject:onlineCategoryModel];
        hander(array,nil);
    }
}

- (void)musicRefresh:(id<DVEResourceCategoryModelProtocol>)category handler:(void(^)(NSArray<id<DVEResourceMusicModelProtocol>>* _Nullable newData,NSString* _Nullable error))hander {
    ///下面都是测试数据逻辑
    if(hander){
        NSMutableArray* musics = nil;
        if([category.categoryId isEqualToString:@"2"]){
            NSDictionary *aligndic = [self jsonObjWithJsonPath:@"music.json" withBunle:@"music"];
            NSArray *listArr = [[aligndic objectForKey:@"resource"] objectForKey:@"list"];
            musics = [NSMutableArray arrayWithCapacity:listArr.count];
        
        
            for(NSDictionary* m in listArr){
                VEResourceMusicModel* eValue = [VEResourceMusicModel new];
                eValue.name = [VEResourceLoader curNameWithDic:m];
                eValue.identifier = eValue.name;
                eValue.sourcePath = [m[@"path"] pathInBundle:@"music"];
                eValue.imageURL = [NSURL fileURLWithPath:[m[@"icon"] pathInBundle:@"music"]];
                eValue.singer = m[@"singer"];
                eValue.modelState = DVEResourceModelStatusDefault;
                [musics addObject:eValue];
            }
        } else if ([category.categoryId isEqualToString:@"1"]) {
            
            NSString *json = [[NSUserDefaults standardUserDefaults] valueForKey:@"DVELocalMusicDic"];
            if (json.length > 0) {
                NSMutableArray *dic = json.mj_JSONObject;
                musics = [VEResourceMusicModel mj_objectArrayWithKeyValuesArray:dic];
                for(VEResourceMusicModel* m in musics){
                    NSString *audioLocalPath = [NSHomeDirectory() stringByAppendingPathComponent:@"Documents/"];
                    audioLocalPath = [audioLocalPath stringByAppendingPathComponent:@"DVELocalMusicDic"];
                    m.sourcePath = [audioLocalPath stringByAppendingPathComponent:m.sourcePath.lastPathComponent];
                    m.imageURL = [NSURL fileURLWithPath:[@"icon.jpg" pathInBundle:@"music"]];
                    m.modelState = DVEResourceModelStatusDefault;
                }
            }
        }
        hander(musics,nil);
    }
}

- (void)musicLoadMore:(id<DVEResourceCategoryModelProtocol>)category handler:(void(^)(NSArray<id<DVEResourceMusicModelProtocol>>* _Nullable moreData,NSString* _Nullable error))hander {
    ///下面都是测试数据逻辑

    if(hander){
        hander(@[],nil);
    }
}


- (void)soundCategory:(DVEResourceCategoryLoadHandler)hander
{
    if(hander){
        NSMutableArray* array = [NSMutableArray array];
        VEResourceCategoryModel* localCategoryModel = [VEResourceCategoryModel new];

        localCategoryModel.name = CKEditorLocStringWithKey(@"ck_hot",@"热门");
        localCategoryModel.categoryId = @"3";
        [array addObject:localCategoryModel];
        
        hander(array,nil);
    }
}


- (void)soundRefresh:(id<DVEResourceCategoryModelProtocol>)category handler:(void(^)(NSArray<id<DVEResourceMusicModelProtocol>>* _Nullable newData,NSString* _Nullable error))hander
{
    ///下面都是测试数据逻辑
    if(hander){
        NSMutableArray* musics = nil;
        if([category.categoryId isEqualToString:@"3"]){
            NSDictionary *aligndic = [self jsonObjWithJsonPath:@"sound.json" withBunle:@"sound"];
            NSArray *listArr = [[aligndic objectForKey:@"resource"] objectForKey:@"list"];
            musics = [NSMutableArray arrayWithCapacity:listArr.count];
        
        
            for(NSDictionary* m in listArr){
                VEResourceMusicModel* eValue = [VEResourceMusicModel new];
                eValue.name = [VEResourceLoader curNameWithDic:m];
                eValue.identifier = eValue.name;
                eValue.sourcePath = [m[@"path"] pathInBundle:@"sound"];
                eValue.imageURL = [NSURL fileURLWithPath:[m[@"icon"] pathInBundle:@"sound"]];
                eValue.singer = m[@"singer"];
                eValue.modelState = DVEResourceModelStatusDefault;
                [musics addObject:eValue];
            }
        }

        
        hander(musics,nil);
    }
}


- (void)soundLoadMore:(id<DVEResourceCategoryModelProtocol>)category handler:(void(^)(NSArray<id<DVEResourceMusicModelProtocol>>* _Nullable moreData,NSString* _Nullable error))hander
{
    if(hander){
        hander(@[],nil);
    }
}


- (void)stickerModel:(DVEResourceModelLoadHandler)hander{
    if(hander){
        
        NSMutableArray* array = [NSMutableArray array];
        
        NSDictionary *stickerDict = [self jsonObjWithJsonPath:@"sticker.json" withBunle:@"sticker"];
        NSArray *stickerList = [[stickerDict objectForKey:@"resource"] objectForKey:@"list"];
        
        for (NSDictionary *sticker in stickerList) {
            VEResourceModel *model = [[VEResourceModel alloc] init];
            model.name = sticker[@"name"];
            model.identifier = model.name;
            model.sourcePath = [sticker[@"path"] pathInBundle:@"sticker"];
            model.imageURL = [NSURL fileURLWithPath:[sticker[@"icon"] pathInBundle:@"sticker"]];
            [array addObject:model];
        }
        
        hander(array,nil);
    }
}

- (void)textAlignModel:(DVEResourceModelLoadHandler)hander {
    if(hander){
        
        NSMutableArray* array = [NSMutableArray array];
        
        NSDictionary *textAlignDict = [self jsonObjWithJsonPath:@"align.json" withBunle:@"text_align"];
        NSArray *textAlignList = [[textAlignDict objectForKey:@"resource"] objectForKey:@"list"];
        
        for (NSDictionary *textAlign in textAlignList) {
            VEResourceModel *model = [[VEResourceModel alloc] init];
            model.name = textAlign[@"name"];
            model.identifier = model.name;
            model.sourcePath = [textAlign[@"path"] pathInBundle:@"text_align"];
            model.imageURL = [NSURL fileURLWithPath:[textAlign[@"icon"] pathInBundle:@"text_align"]];
            model.alignType = textAlign[@"alignType"];
            model.typeSettingKind = textAlign[@"typeSettingKind"];
            [array addObject:model];
        }

        hander(array,nil);
    }
}

- (void)textColorModel:(DVEResourceModelLoadHandler)hander {
    if(hander){
        
        NSMutableArray* array = [NSMutableArray array];
        
        NSDictionary *textColorDict = [self jsonObjWithJsonPath:@"color.json" withBunle:@"text_color"];
        NSArray *textColorList = [[textColorDict objectForKey:@"resource"] objectForKey:@"list"];
        
        for (NSDictionary *textColor in textColorList) {
            VEResourceModel *model = [[VEResourceModel alloc] init];
            model.name = textColor[@"name"];
            model.identifier = model.name;
            model.sourcePath = [textColor[@"path"] pathInBundle:@"text_color"];
            model.imageURL = [NSURL fileURLWithPath:[textColor[@"icon"] pathInBundle:@"text_color"]];
            model.color = textColor[@"color"];
            [array addObject:model];
        }
        
        hander(array,nil);
    }
}

- (void)textFontModel:(DVEResourceModelLoadHandler)hander {
    if(hander){
        
        NSMutableArray* array = [NSMutableArray array];
        
        //是否有默认 有的话 添加一次 没有的话 走下面
        NSDictionary *defaultDict = [self jsonObjWithJsonPath:@"font.json" withBunle:@"default"];
        NSArray *defaultList = [[defaultDict objectForKey:@"resource"] objectForKey:@"list"];
        if(defaultDict.count > 0) {
            for (NSDictionary *textFont in defaultList) {
                VEResourceModel *model = [[VEResourceModel alloc] init];
                model.name = [VEResourceLoader curNameWithDic:textFont];
                model.identifier = model.identifier;
                model.sourcePath = [textFont[@"path"] pathInBundle:@"default"];
                model.imageURL = [NSURL fileURLWithPath:[textFont[@"icon"] pathInBundle:@"default"]];
                [array addObject:model];
            }
        }

        NSDictionary *textFontDict = [self jsonObjWithJsonPath:@"font.json" withBunle:@"text_fonts"];
        NSArray *textFontList = [[textFontDict objectForKey:@"resource"] objectForKey:@"list"];
        
        for (NSDictionary *textFont in textFontList) {
            VEResourceModel *model = [[VEResourceModel alloc] init];
            model.name = [VEResourceLoader curNameWithDic:textFont];
            model.identifier = model.identifier;
            NSString *path = [textFont[@"path"] pathInBundle:@"text_fonts"];
            NSFileManager * fileManager = [NSFileManager defaultManager];
            NSArray *pathArr = [fileManager subpathsAtPath:path];
            if(pathArr.count >0){
                model.sourcePath = [NSString stringWithFormat:@"%@/%@",path,[pathArr objectAtIndex:0]];
            }else{
                model.sourcePath = path;
            }
            model.imageURL = [NSURL fileURLWithPath:[textFont[@"icon"] pathInBundle:@"text_fonts"]];
            [array addObject:model];
        }
        
        hander(array,nil);
    }
}

- (void)textStyleModel:(DVEResourceModelLoadHandler)hander {
    if(hander){
        
        NSMutableArray* array = [NSMutableArray array];
        
        NSDictionary *textStyleDict = [self jsonObjWithJsonPath:@"style.json" withBunle:@"text_style"];
        NSArray *textStyleList = [[textStyleDict objectForKey:@"resource"] objectForKey:@"list"];
        
        for (NSDictionary *textStyle in textStyleList) {
            VEResourceModel *model = [[VEResourceModel alloc] init];
            model.name = [VEResourceLoader curNameWithDic:textStyle];
            model.identifier = model.name;
            model.sourcePath = [textStyle[@"path"] pathInBundle:@"text_style"];
            model.imageURL = [NSURL fileURLWithPath:[textStyle[@"icon"] pathInBundle:@"text_style"]];
            model.style = textStyle[@"style"];
            [array addObject:model];
        }
        
        hander(array,nil);
    }
}

- (void)transitionModel:(DVEResourceModelLoadHandler)hander  {
    
    if(hander){
        NSMutableArray* array = [NSMutableArray array];
        
        NSDictionary *transitionDict = [self jsonObjWithJsonPath:@"transitions.json" withBunle:@"transitions"];
        NSArray *transitionList = [[transitionDict objectForKey:@"resource"] objectForKey:@"list"];
        
        for (NSDictionary *transition in transitionList) {
            VEResourceModel *model = [[VEResourceModel alloc] init];
            model.name = [VEResourceLoader curNameWithDic:transition];
            model.identifier = model.name;
            model.sourcePath = [transition[@"path"] pathInBundle:@"transitions"];
            model.imageURL = [NSURL fileURLWithPath:[transition[@"icon"] pathInBundle:@"transitions"]];
            model.overlap = [transition[@"isOverlap"] boolValue];
            [array addObject:model];
        }
        
        hander(array,nil);
    }
}

- (void)textReaderSoundEffectModel:(void(^)(NSArray<id<DVETextReaderModelProtocol>>* _Nullable newData, NSError* _Nullable error))handler
{
    if (handler) {
        NSMutableArray* array = [NSMutableArray array];
        
        NSArray<NSString *> *readerSoundEffectNames = @[@"台湾女生", @"小萝莉", @"动漫海绵", @"重庆小伙", @"小姐姐", @"动漫小新"];
        NSArray<NSString *> *types = @[@"BV025_streaming", @"BV064_streaming", @"BV063_streaming", @"BV019_streaming", @"BV001_fast_streaming", @"BV050_streaming"];
        NSArray<NSNumber *> *rates = @[@(24000), @(24000), @(24000), @(24000), @(24000), @(24000)];

        VETextReaderModel *noneModel = [[VETextReaderModel alloc] init];
        noneModel.isNone = YES;
        noneModel.imageURL = [NSURL URLWithString: @""];
        noneModel.identifier = @"none";
        [array addObject:noneModel];
        for (NSInteger i = 0; i < readerSoundEffectNames.count; i++) {
            VETextReaderModel *model = [[VETextReaderModel alloc] init];
            model.name = readerSoundEffectNames[i];
            model.identifier = model.name;
            model.type = types[i];
            model.rate = rates[i].integerValue;
            [array addObject:model];
        }
        
        handler(array, nil);
    }
}


- (void)curveSpeedResourceModel:(void(^)(NSArray<id<DVEResourceCurveSpeedModelProtocol>>* _Nullable datas, NSError* _Nullable error))handler {
    if (handler) {
        NSMutableArray *array = [NSMutableArray new];
        
        NSDictionary *curveSpeedDict = [self jsonObjWithJsonPath:@"curvespeed.json" withBunle:@"curve_speed"];
        NSArray *curveSpeedList = [[curveSpeedDict objectForKey:@"resource"] objectForKey:@"list"];
        for (NSDictionary *curveSpeed in curveSpeedList) {
            VECurveSpeedModel *model = [[VECurveSpeedModel alloc] init];
            model.name = [VEResourceLoader curNameWithDic:curveSpeed];
            model.identifier = model.name;
            model.imageURL = [NSURL fileURLWithPath:[curveSpeed[@"icon"] pathInBundle:@"curve_speed"]];
            NSData *extraData =  [(NSString *)curveSpeed[@"extra"] dataUsingEncoding:NSUTF8StringEncoding];
            NSDictionary *extraJson = [NSJSONSerialization JSONObjectWithData:extraData options:0 error:nil];
            NSData *speedPointData = [(NSString *)extraJson[@"speed_points"] dataUsingEncoding:NSUTF8StringEncoding];
            NSDictionary *speedPointDict = [NSJSONSerialization JSONObjectWithData:speedPointData options:0 error:nil];
            
            model.speedPoints = speedPointDict[@"speed_points"];
            [array addObject:model];
        }
        
        handler(array, nil);
    }
}


- (void)canvasStyleResourceModel:(DVEResourceModelLoadHandler)handler {
    if (!handler) {
        return;
    }
    
    NSMutableArray *array = [[NSMutableArray alloc] init];
    NSDictionary *canvasStyleDict = [self jsonObjWithJsonPath:@"canvas.json" withBunle:@"canvas"];
    NSArray *canvasStyleList = [[canvasStyleDict objectForKey:@"resource"] objectForKey:@"list"];
    for (NSDictionary *canvasStyle in canvasStyleList) {
        VEResourceModel *model = [[VEResourceModel alloc] init];
        model.name = [VEResourceLoader curNameWithDic:canvasStyle];
        model.identifier = canvasStyle[@"icon"];
        model.sourcePath = [canvasStyle[@"path"] pathInBundle:@"canvas"];
        model.imageURL = [NSURL fileURLWithPath:[canvasStyle[@"icon"] pathInBundle:@"canvas"]];
        [array addObject:model];
    }
    
    VEResourceCategoryModel *category = [[VEResourceCategoryModel alloc] init];
    category.models = array;
    
    handler(@[category], nil);
}

- (void)downloadResourceModelWithID:(NSString *)modelID
                            handler:(void (^)(NSError * _Nullable, NSString * _Nullable))handler {
    
    /*
    IESEffectModel *effectModel = self.effectsMap[modelID];
    if (!effectModel) {
        NSAssert(NO, @"this IESEffectModel has been not fetched!!!");
        NSError *error = [NSError errorWithDomain:@""
                                             code:-1
                                         userInfo:@{NSLocalizedDescriptionKey : @""}];
        if (handler) {
            handler(error, nil);
        }
        return;
    }
    
    [EffectPlatform downloadEffect:effectModel
                          progress:nil
                        completion:^(NSError * _Nullable error, NSString * _Nullable filePath) {
        if (handler) {
            handler(error, filePath);
        }
    }];
     */
}

/*
- (NSString *)filePathForResourceModelWithID:(NSString *)modelID {
    IESEffectModel *effectModel = self.effectsMap[modelID];
    return [effectModel filePath];
}
 */

@end
