//
//  VEEBeautyDataSource.m
//  TTVideoEditorDemo
//
//  Created by bytedance on 2020/12/20
//  Copyright © 2020 bytedance. All rights reserved.
//

#import "VEEBeautyDataSource.h"
#import "NSString+VEToPinYin.h"

static const NSString *ComposeBundleName = @"ComposeMakeup";

#if BEF_USE_CK
    #define beautyResourceName  @"ComposeMakeup/beauty_IOS_lite"
    #define reshapeResourceName  @"ComposeMakeup/reshape_lite"
    #define eyebrowPath  @"eyebrow/lite/"
    #define blushPath  @"blush/lite/"
    #define lipPath  @"lip/lite/"
    #define defaultFacial @"facial/gaoguang"
#else
    #define beautyResourceName  @"ComposeMakeup/beauty_IOS_standard"
    #define reshapeResourceName  @"ComposeMakeup/reshape_standard"
    #define eyebrowPath  @"eyebrow/lite/"
    #define blushPath  @"blush/lite/"
    #define lipPath  @"lip/lite/"
    #define defaultFacial @"facial/gaoguang"
#endif

#define beauty_4ItemsResourceName  @"ComposeMakeup/beauty_4Items"

@implementation VEEBeautyDataSource

static VEEBeautyDataSource *instance = nil;

+ (instancetype)shareManager {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[self alloc] init];
    });
    return instance;
}

+ (instancetype)allocWithZone:(struct _NSZone *)zone {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [super allocWithZone:zone];
    });
    return instance;
}

- (instancetype)init {
    if (self = [super init]) {
        
        [self initFaceDataSource];
        
        [self initVFaceDataSource];
        
        [self initBodyDataSource];
        
        [self initMakeupDataSource];
        
    }
    return self;
}


- (void)initFaceDataSource
{
    
    NSArray *arr = @[CKEditorLocStringWithKey(@"ck_setting_skin_grinding",@"磨皮"),CKEditorLocStringWithKey(@"ck_setting_skin_whitening",@"美白"),CKEditorLocStringWithKey(@"ck_setting_skin_sharpen",@"锐化")];
    NSArray *defaultIndensity = @[@(0.5),@(0.35),@(0.7),@(0.35),@(0.35),@(0.35),@(0.35)];
    NSArray <NSString *>*imagearr = @[@"icon_beauty_mopi",@"icon_beauty_meibai",@"icon_beauty_ruhua"];
    NSArray *namearr = @[beautyResourceName,beautyResourceName,beautyResourceName];
    NSArray *keyarr = @[@"smooth",@"whiten",@"sharp"];
    NSMutableArray *valueArr = [NSMutableArray new];
    for (NSInteger i = 0; i < arr.count; i ++) {
        DVEEffectValue *value = [[DVEEffectValue alloc] initWithType:VEEffectValueTypeBeauty Bundle:ComposeBundleName name:namearr[i] imageURL:nil assetImage:imagearr[i].UI_VEToImage key:keyarr[i] indesty:[defaultIndensity[i] floatValue]];
        value.beautyType = VEEffectBeautyTypeFace;
        value.name = arr[i];
        [valueArr addObject:value];
    }
    
    self.faceSourceArr = valueArr.copy;
    
}

- (void)initVFaceDataSource
{
    
    NSArray *arr = @[CKEditorLocStringWithKey(@"ck_setting_face_lift",@"瘦脸"),CKEditorLocStringWithKey(@"ck_setting_big_eye",@"大眼"),CKEditorLocStringWithKey(@"ck_beauty_reshape_chin",@"下巴"),CKEditorLocStringWithKey(@"ck_beauty_reshape_nose_lean",@"瘦鼻"),CKEditorLocStringWithKey(@"ck_beauty_reshape_mouth_zoom",@"嘴型"),CKEditorLocStringWithKey(@"ck_beauty_face_remove_pouch",@"黑眼圈"),CKEditorLocStringWithKey(@"ck_beauty_face_brighten_eye",@"亮眼"),CKEditorLocStringWithKey(@"ck_beauty_face_whiten_teeth",@"白牙")];
    NSArray *defaultIndensity = @[@(0.35),@(0.35),@(0.35),@(0.35),@(0.35),@(0.35),@(0.35),@(0.35)];
    NSArray <NSString *>*imagearr = @[@"icon_beauty_shoulian",@"icon_beauty_eye_open",@"ic_beauty_reshape_chin",@"ic_beauty_reshape_nose_lean",@"ic_beauty_reshape_mouth_zoom",@"ic_beauty_smooth",@"ic_beauty_smooth",@"ic_beauty_smooth"];
    NSArray *namearr = @[reshapeResourceName,reshapeResourceName,reshapeResourceName,reshapeResourceName,reshapeResourceName,beauty_4ItemsResourceName,beauty_4ItemsResourceName,beauty_4ItemsResourceName,];
    NSArray *keyarr = @[@"Internal_Deform_Overall",@"Internal_Deform_Eye",@"Internal_Deform_Chin",@"Internal_Deform_Nose",
        @"Internal_Deform_ZoomMouth",@"BEF_BEAUTY_REMOVE_POUCH",@"BEF_BEAUTY_BRIGHTEN_EYE",@"BEF_BEAUTY_WHITEN_TEETH",];
    NSMutableArray *valueArr = [NSMutableArray new];
    for (NSInteger i = 0; i < arr.count; i ++) {
        DVEEffectValue *value = [[DVEEffectValue alloc] initWithType:VEEffectValueTypeBeauty Bundle:ComposeBundleName name:namearr[i] imageURL:nil assetImage:imagearr[i].UI_VEToImage key:keyarr[i] indesty:[defaultIndensity[i] floatValue]];
        value.beautyType = VEEffectBeautyTypeVFace;
        value.name = arr[i];
        [valueArr addObject:value];
    }
    
    self.vFaceSourceArr = valueArr.copy;
    
}

- (void)initBodyDataSource
{
    
    NSArray *arr = @[CKEditorLocStringWithKey(@"ck_beauty_body_thin",@"瘦身"),CKEditorLocStringWithKey(@"ck_beauty_body_long_leg",@"长腿"),CKEditorLocStringWithKey(@"ck_beauty_body_shrink_head",@"小头"),CKEditorLocStringWithKey(@"ck_beauty_body_leg_slim",@"瘦腿"),CKEditorLocStringWithKey(@"ck_beauty_body_waist_slim",@"收腰"),CKEditorLocStringWithKey(@"ck_beauty_body_breast_enlarge",@"丰胸"),CKEditorLocStringWithKey(@"ck_beauty_body_hip_enhance",@"翘臀"),CKEditorLocStringWithKey(@"ck_beauty_body_neck_enhance",@"天鹅颈"),CKEditorLocStringWithKey(@"ck_beauty_body_arm_slim",@"手臂"),];
    NSArray <NSString *>*imagearr = @[@"icon_beauty_body_shoushen",@"icon_beauty_body_changtui",@"icon_beauty_body_xiaotou",@"icon_beauty_body_shoutui",@"icon_beauty_body_shouyao",@"icon_beauty_body_fengxiong",@"icon_beauty_body_qiaotun",@"icon_beauty_body_jingbu",@"icon_beauty_body_shoubi"];
    NSArray *namearr = @[@"body/allslim",@"body/allslim",@"body/allslim",@"body/allslim",@"body/allslim",@"body/allslim",@"body/allslim",@"body/allslim",@"body/allslim",];
    NSArray *keyarr = @[@"BEF_BEAUTY_BODY_THIN",@"BEF_BEAUTY_BODY_LONG_LEG",@"BEF_BEAUTY_BODY_SHRINK_HEAD",@"BEF_BEAUTY_BODY_SLIM_LEG",@"BEF_BEAUTY_BODY_SLIM_WAIST",@"BEF_BEAUTY_BODY_ENLARGR_BREAST",@"BEF_BEAUTY_BODY_ENHANCE_HIP",@"BEF_BEAUTY_BODY_ENHANCE_NECK",@"BEF_BEAUTY_BODY_SLIM_ARM",];
    NSMutableArray *valueArr = [NSMutableArray new];
    for (NSInteger i = 0; i < arr.count; i ++) {
        DVEEffectValue *value = [[DVEEffectValue alloc] initWithType:VEEffectValueTypeBeauty Bundle:ComposeBundleName name:arr[i] imageURL:nil assetImage:imagearr[i].UI_VEToImage key:keyarr[i] indesty:0.3];
        value.beautyType = VEEffectBeautyTypeBody;
        value.sourcePath = [[@"ComposeMakeup/" stringByAppendingString:namearr[i]] pathInBundle:ComposeBundleName];
        [valueArr addObject:value];
    }
    
    self.bodySourceArr = valueArr.copy;
    
}

- (void)initMakeupDataSource
{
    
    NSArray *arr = @[CKEditorLocStringWithKey(@"ck_makeup_blusher",@"腮红"),CKEditorLocStringWithKey(@"ck_makeup_lip",@"口红"),CKEditorLocStringWithKey(@"ck_makeup_facial",@"阴影"),CKEditorLocStringWithKey(@"ck_makeup_pupil",@"美瞳"),CKEditorLocStringWithKey(@"ck_makeup_hair",@"染发"),CKEditorLocStringWithKey(@"ck_makeup_eye",@"眼影"),CKEditorLocStringWithKey(@"ck_makeup_eyebrow",@"眉毛"),];
    NSArray *defaultIndensity = @[@(0.2),@(0.5),@(0.35),@(0.4),@(0.35),@(0.35),@(0.35)];
    NSArray <NSString *>*imagearr = @[@"icon_makeup_saihong",@"icon_makeup_kouhong",@"icon_makeup_yinying",@"icon_makeup_qudou",@"icon_makeup_hair",@"icon_makeup_yanying",@"icon_makeup_meimao",];
    NSArray *namearr = @[[NSString stringWithFormat:@"%@mitao",blushPath],[NSString stringWithFormat:@"%@doushafen",lipPath],defaultFacial,@"pupil/chujianhui",@"hair/anlan",@"eyeshadow/jiaotangzong",[NSString stringWithFormat:@"%@BK01",eyebrowPath]];
    NSArray *keyarr = @[@"Internal_Makeup_Blusher",@"Internal_Makeup_Lips",@"Internal_Makeup_Facial",@"Internal_Makeup_Pupil",@"头发",@"Internal_Makeup_Eye",@"Internal_Makeup    _Brow",];
    
    NSMutableArray *valueArr = [NSMutableArray new];
    for (NSInteger i = 0; i < arr.count; i ++) {
        DVEEffectValue *value = [[DVEEffectValue alloc] initWithType:VEEffectValueTypeBeauty Bundle:ComposeBundleName name:namearr[i] imageURL:nil assetImage:imagearr[i].UI_VEToImage key:keyarr[i] indesty:[defaultIndensity[i] floatValue]];
        value.beautyType = VEEffectBeautyTypeMakeup;
        value.makeSubUp = i;
        value.name = arr[i];
        value.sourcePath = [[@"ComposeMakeup/" stringByAppendingString:namearr[i]] pathInBundle:ComposeBundleName];
        [valueArr addObject:value];
    }
    self.makeupSourceArr = valueArr.copy;
}

- (NSArray *)blushArr
{
    NSArray *arr = @[@"蜜桃",@"俏皮",@"日常",@"晒伤",@"甜橙",@"微醺",@"心机",];
    NSArray *namearr = @[CKEditorLocStringWithKey(@"ck_blusher_mitao",@"蜜桃"),CKEditorLocStringWithKey(@"ck_blusher_qiaopi",@"俏皮"),CKEditorLocStringWithKey(@"ck_blusher_richang",@"日常"),CKEditorLocStringWithKey(@"ck_blusher_shaishang",@"晒伤"),CKEditorLocStringWithKey(@"ck_blusher_tiancheng",@"甜橙"),CKEditorLocStringWithKey(@"ck_blusher_weixunfen",@"微醺"),CKEditorLocStringWithKey(@"ck_blusher_xinji",@"心机"),];
   
    NSMutableArray *valueArr = [NSMutableArray new];
    for (NSInteger i = 0; i < arr.count; i ++) {
        DVEEffectValue *value = [[DVEEffectValue alloc] initWithType:VEEffectValueTypeBeauty Bundle:ComposeBundleName name:[NSString stringWithFormat:@"%@%@",blushPath,[arr[i] VE_transformToPinyin]] imageURL:nil assetImage:@"icon_makeup_saihong".UI_VEToImage key:@"Internal_Makeup_Blusher" indesty:0.2];
        value.name = namearr[i];
        value.beautyType = VEEffectBeautyTypeMakeup;
        value.makeSubUp = i;
        value.sourcePath = [[@"ComposeMakeup/" stringByAppendingString:[NSString stringWithFormat:@"%@%@",blushPath,[arr[i] VE_transformToPinyin]]] pathInBundle:ComposeBundleName];
        [valueArr addObject:value];
    }
    
    return valueArr.copy;
}
- (NSArray *)lipArr
{
    NSArray *arr = @[@"豆沙粉",@"复古红",@"梅子色",@"珊瑚色",@"丝绒红",@"西瓜红",@"西柚色",@"元气橘",@"脏橘色",];
    NSArray *namearr = @[CKEditorLocStringWithKey(@"ck_lip_doushafen",@"豆沙粉"),CKEditorLocStringWithKey(@"ck_lip_fuguhong",@"复古红"),CKEditorLocStringWithKey(@"ck_lip_meizise",@"梅子色"),CKEditorLocStringWithKey(@"ck_lip_shanhuse",@"珊瑚色"),CKEditorLocStringWithKey(@"ck_lip_sironghong",@"丝绒红"),CKEditorLocStringWithKey(@"ck_lip_xiguahong",@"西瓜红"),CKEditorLocStringWithKey(@"ck_lip_xiyouse",@"西柚色"),CKEditorLocStringWithKey(@"ck_lip_yuanqiju",@"元气橘"),CKEditorLocStringWithKey(@"ck_lip_zangjuse",@"脏橘色"),];
    NSMutableArray *valueArr = [NSMutableArray new];
    for (NSInteger i = 0; i < arr.count; i ++) {
        DVEEffectValue *value = [[DVEEffectValue alloc] initWithType:VEEffectValueTypeBeauty Bundle:ComposeBundleName name:[NSString stringWithFormat:@"%@%@",lipPath,[arr[i] VE_transformToPinyin]] imageURL:nil assetImage:@"icon_makeup_kouhong".UI_VEToImage key:@"Internal_Makeup_Lips" indesty:0.5];
        value.name = namearr[i];
        value.beautyType = VEEffectBeautyTypeMakeup;
        value.makeSubUp = i;
        value.sourcePath = [[@"ComposeMakeup/" stringByAppendingString:[NSString stringWithFormat:@"%@%@",lipPath,[arr[i] VE_transformToPinyin]]] pathInBundle:ComposeBundleName];
        [valueArr addObject:value];
    }
    
    return valueArr.copy;
}
- (NSArray *)facialArr
{
#if BEF_USE_CK
    NSArray *arr = @[@"高光",@"精致",@"小v",@"自然",];
#else
//    NSArray *arr = @[@"修容01",@"修容02",@"修容03",@"修容04",];
    NSArray *arr = @[@"高光",@"精致",@"小v",@"自然",];
#endif
    
    NSArray *namearr = @[CKEditorLocStringWithKey(@"ck_facial_1",@"修容01"),CKEditorLocStringWithKey(@"ck_facial_2",@"修容02"),CKEditorLocStringWithKey(@"ck_facial_3",@"修容03"),CKEditorLocStringWithKey(@"ck_facial_4",@"修容04"),];
   
    NSMutableArray *valueArr = [NSMutableArray new];
    for (NSInteger i = 0; i < arr.count; i ++) {
        DVEEffectValue *value = [[DVEEffectValue alloc] initWithType:VEEffectValueTypeBeauty Bundle:ComposeBundleName name:[NSString stringWithFormat:@"%@%@",@"facial/",[arr[i] VE_transformToPinyin]] imageURL:nil assetImage:@"icon_makeup_yinying".UI_VEToImage key:@"Internal_Makeup_Facial" indesty:0.35];
        value.name = namearr[i];
        value.beautyType = VEEffectBeautyTypeMakeup;
        value.makeSubUp = i;
        value.sourcePath = [[@"ComposeMakeup/" stringByAppendingString:[NSString stringWithFormat:@"%@%@",@"facial/",[arr[i] VE_transformToPinyin]]] pathInBundle:ComposeBundleName];
        [valueArr addObject:value];
    }
    
    return valueArr.copy;
}
- (NSArray *)pupilArr
{
    NSArray *arr = @[@"初见灰",@"混血棕",@"可可棕",@"蜜桃粉",@"水光黑",@"星空蓝"];
    NSArray *namearr = @[CKEditorLocStringWithKey(@"ck_pupil_chujianhui",@"初见灰"),CKEditorLocStringWithKey(@"ck_pupil_hunxuezong",@"混血棕"),CKEditorLocStringWithKey(@"ck_pupil_kekezong",@"可可棕"),CKEditorLocStringWithKey(@"ck_pupil_mitaofen",@"蜜桃粉"),CKEditorLocStringWithKey(@"ck_pupil_shuiguanghei",@"水光黑"),CKEditorLocStringWithKey(@"ck_pupil_xingkonglan",@"星空蓝")];
    
    NSMutableArray *valueArr = [NSMutableArray new];
    for (NSInteger i = 0; i < arr.count; i ++) {
        DVEEffectValue *value = [[DVEEffectValue alloc] initWithType:VEEffectValueTypeBeauty Bundle:ComposeBundleName name:[NSString stringWithFormat:@"%@%@",@"pupil/",[arr[i] VE_transformToPinyin]] imageURL:nil assetImage:@"icon_makeup_qudou".UI_VEToImage key:@"Internal_Makeup_Pupil" indesty:0.4];
        value.name = namearr[i];
        value.beautyType = VEEffectBeautyTypeMakeup;
        value.makeSubUp = i;
        value.sourcePath = [[@"ComposeMakeup/" stringByAppendingString:[NSString stringWithFormat:@"%@%@",@"pupil/",[arr[i] VE_transformToPinyin]]] pathInBundle:ComposeBundleName];
        [valueArr addObject:value];
    }
    
    return valueArr.copy;
}
- (NSArray *)hairArr
{
    NSArray *arr = @[@"暗蓝",@"墨绿",@"深棕",];
    NSArray *titilearr = @[CKEditorLocStringWithKey(@"ck_hair_anlan",@"暗蓝"),CKEditorLocStringWithKey(@"ck_hair_molv",@"墨绿"),CKEditorLocStringWithKey(@"ck_hair_shenzong",@"深棕"),];
    NSArray *namearr = @[@"hair/anlan",@"hair/molv",@"hair/shenzong",];
    NSMutableArray *valueArr = [NSMutableArray new];
    for (NSInteger i = 0; i < arr.count; i ++) {
        DVEEffectValue *value = [[DVEEffectValue alloc] initWithType:VEEffectValueTypeBeauty Bundle:ComposeBundleName name:namearr[i] imageURL:nil assetImage:@"icon_makeup_hair".UI_VEToImage key:@"hair" indesty:0.35];
        value.name = titilearr[i];
        value.beautyType = VEEffectBeautyTypeMakeup;
        value.makeSubUp = i;
        value.sourcePath = [[@"ComposeMakeup/" stringByAppendingString:namearr[i]] pathInBundle:ComposeBundleName];
        [valueArr addObject:value];
    }
    
    return valueArr.copy;
}
- (NSArray *)eyeshadowArr
{
    NSArray *arr = @[@"焦糖棕",@"梅子红",@"奶茶色",@"气质粉",@"晚霞红",@"元气橘",];
    NSArray *namearr = @[CKEditorLocStringWithKey(@"ck_eye_jiaotangzong",@"焦糖棕"),CKEditorLocStringWithKey(@"ck_eye_meizihong",@"梅子红"),CKEditorLocStringWithKey(@"ck_eye_naichase",@"奶茶色"),CKEditorLocStringWithKey(@"ck_eye_qizhifen",@"气质粉"),CKEditorLocStringWithKey(@"ck_eye_wanxiahong",@"晚霞红"),CKEditorLocStringWithKey(@"ck_eye_yuanqiju",@"元气橘"),];
    NSMutableArray *valueArr = [NSMutableArray new];
    for (NSInteger i = 0; i < arr.count; i ++) {
        DVEEffectValue *value = [[DVEEffectValue alloc] initWithType:VEEffectValueTypeBeauty Bundle:ComposeBundleName name:[NSString stringWithFormat:@"%@%@",@"eyeshadow/",[arr[i] VE_transformToPinyin]] imageURL:nil assetImage:@"icon_makeup_yanying".UI_VEToImage key:@"Internal_Makeup_Eye" indesty:0.35];
        value.name = namearr[i];
        value.beautyType = VEEffectBeautyTypeMakeup;
        value.makeSubUp = i;
        value.sourcePath = [[NSString stringWithFormat:@"%@%@",@"ComposeMakeup/eyeshadow/",[arr[i] VE_transformToPinyin]] pathInBundle:ComposeBundleName];
        [valueArr addObject:value];
    }
    
    return valueArr.copy;
}
- (NSArray *)eyebrowArr
{
    NSArray *arr = @[@"BK01",@"BK02",@"BK03",@"BR01",];
    
    NSMutableArray *valueArr = [NSMutableArray new];
    for (NSInteger i = 0; i < arr.count; i ++) {
        DVEEffectValue *value = [[DVEEffectValue alloc] initWithType:VEEffectValueTypeBeauty Bundle:ComposeBundleName name:[NSString stringWithFormat:@"%@%@",eyebrowPath,arr[i]] imageURL:nil assetImage:@"icon_makeup_meimao".UI_VEToImage key:@"Internal_Makeup_Brow" indesty:0.35];
        value.name = arr[i];
        value.makeSubUp = i;
        value.sourcePath = [[NSString stringWithFormat:@"%@%@%@",@"ComposeMakeup/",eyebrowPath,arr[i]] pathInBundle:ComposeBundleName];
        [valueArr addObject:value];
    }
    
    return valueArr.copy;
}


@end
