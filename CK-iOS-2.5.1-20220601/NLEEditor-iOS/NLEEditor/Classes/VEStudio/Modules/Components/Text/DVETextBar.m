//
//  DVETextBar.m
//  TTVideoEditorDemo
//
//  Created by bytedance on 2020/12/20
//  Copyright © 2020 bytedance. All rights reserved.
//

#import "DVETextBar.h"
#import "DVETextStyleView.h"
#import <SGPagingView/SGPagingView.h>
#import "DVETextParm.h"
#import "DVEViewController.h"
#import "DVEVCContext.h"
#import "DVEMacros.h"
#import <DVETrackKit/DVECustomResourceProvider.h>
#import "NSString+VEToImage.h"
#import <ReactiveObjC/ReactiveObjC.h>
#import <NLEPlatform/NLETrack+iOS.h>
#import <NLEPlatform/NLEStyleText+iOS.h>
#import <DVETrackKit/UIView+VEExt.h>
#import <DVETrackKit/NLEVideoFrameModel_OC+NLE.h>
#import "DVEPickerView.h"
#import "DVETextAnimationView.h"
#import "DVEModuleBaseCategoryModel.h"
#import "DVETextTemplatePickerUIDefaultConfiguration.h"
#import "DVECustomerHUD.h"
#import "DVEBundleLoader.h"
#import "DVELoggerImpl.h"
#import <DVETrackKit/UIColor+DVEStyle.h>
#import <YYModel/NSObject+YYModel.h>
#import "DVEPlaceholderTextView.h"
#import "NSString+DVE.h"
#import "DVEReportUtils.h"
#import "DVECoreSlotProtocol.h"
#import "DVEComponentViewManager.h"

@implementation DVEEffectColorModel


@end

@interface DVETextBar ()<SGPageTitleViewDelegate,UITextViewDelegate, DVEPickerViewDelegate, DVEAnimationViewDelegate, DVEAnimationViewDataSource,DVEStickerEditAdpterDelegate>

@property (nonatomic, strong) DVEPlaceholderTextView *textView;


@property (nonatomic, strong) SGPageTitleView *functionView;

@property (nonatomic, strong) UIView *contentView;
@property (nonatomic, strong) DVETextStyleView *styleView;
/// 花字
@property (nonatomic, strong) DVEPickerView *textTemplatePickerView;
/// 气泡
@property (nonatomic, strong) DVEPickerView *shapePickerView;
/// 动画
@property (nonatomic, strong) DVETextAnimationView *textAnimationView;

@property (nonatomic, strong) UIButton *dismissBack;

@property (nonatomic) DVETextParm *lastParm;
@property (nonatomic) DVETextParm *curParm;
@property (nonatomic, strong) NLEResourceNode_OC *textFlower;
/// 文字气泡
@property (nonatomic, strong) NLEResourceNode_OC *bubbleText;
/// 文字动画
@property (nonatomic, strong) NLEStyStickerAnimation_OC *textAnimation;
@property (nonatomic) BOOL isValueChanged;

@property (nonatomic, strong) NSMutableDictionary *parmDic;

@property (nonatomic, weak) id<DVECoreStickerProtocol> stickerEditor;
@property (nonatomic, weak) id<DVECoreSlotProtocol> slotEditor;
@property (nonatomic, weak) id<DVECoreActionServiceProtocol> actionService;
@property (nonatomic, weak) id<DVENLEEditorProtocol> nleEditor;
@property (nonatomic, weak) id<DVENLEInterfaceProtocol> nle;

@end

@implementation DVETextBar

DVEAutoInject(self.vcContext.serviceProvider, slotEditor, DVECoreSlotProtocol)
DVEAutoInject(self.vcContext.serviceProvider, stickerEditor, DVECoreStickerProtocol)
DVEAutoInject(self.vcContext.serviceProvider, actionService, DVECoreActionServiceProtocol)
DVEAutoInject(self.vcContext.serviceProvider, nleEditor, DVENLEEditorProtocol)
DVEAutoInject(self.vcContext.serviceProvider, nle, DVENLEInterfaceProtocol)

- (void)dealloc
{
    DVELogInfo(@"VEVCTextBar dealloc");
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (instancetype)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
        self.parmDic = [NSMutableDictionary new];
        self.curParm = [DVETextParm new];
        self.isMainEdit = YES;
        [self buildLayout];
        [self addKeyboardNotice];
        self.backgroundColor = [UIColor blackColor];
    }
    
    return self;
}

- (void)buildLayout
{
    [self addSubview:self.textView];
    [self addSubview:self.functionView];
    [self addSubview:self.dismissBack];
    [self addSubview:self.contentView];
    [self.contentView addSubview:self.styleView];
    [self.contentView addSubview:self.textTemplatePickerView];
    [self.contentView addSubview:self.textAnimationView];
    
    self.functionView.top = self.textView.bottom + 14 + 10;
    self.functionView.left = 15;
    self.dismissBack.centerY = self.functionView.centerY;
    self.dismissBack.right = VE_SCREEN_WIDTH - 10;
    self.contentView.top = self.functionView.bottom + 16;
}

- (void)initData
{
    DVEViewController *parentVC = (DVEViewController *)self.parentVC;
    parentVC.stickerEditAdatper.delegate = self;
    
    if(self.segmentId == nil){
        self.segmentId = [self.stickerEditor addNewRandomPositonTextSticker];
    }
    
    NLETrackSlot_OC *slot = nil;
    if (self.isMainEdit) {
        slot = [self.nleEditor.nleModel slotOf:self.segmentId];
    } else {
        slot = [self.nleEditor.nleModel.coverModel slotOf:self.segmentId];
    }

    NLESegmentTextSticker_OC *segTextSticker = (NLESegmentTextSticker_OC *)slot.segment;
    
    [self initParm:segTextSticker];
    [self.functionView setSelectedIndex:0];
    [self.textView becomeFirstResponder];
    self.styleView.vcContext = self.vcContext;
    
    self.textAnimationView.slot = slot;
    [self.textTemplatePickerView updateLoading];
    
    // 花字
    @weakify(self);
    [[DVEBundleLoader shareManager] flowerText:self.vcContext handler:^(NSArray<DVEEffectValue *> * _Nullable datas, NSString * _Nullable error) {
        @strongify(self);
        
        NSMutableArray* array = [NSMutableArray arrayWithArray:datas];
        [array enumerateObjectsUsingBlock:^(DVEEffectValue *obj, NSUInteger idx, BOOL * _Nonnull stop) {
            obj.identifier = [NSString stringWithFormat:@"%@",@(idx)];
            obj.valueState = VEEffectValueStateNone;
        }];
        
        
        DVEEffectValue *model = [DVEEffectValue new];
        model.valueState = VEEffectValueStateShuntDown;
        model.identifier = @"";
        [array insertObject:model atIndex:0];
        
        DVEModuleBaseCategoryModel *categoryModel = [DVEModuleBaseCategoryModel new];
        DVEEffectCategory* category = [DVEEffectCategory new];
        category.models = array;
        categoryModel.category = category;
        @weakify(self);
        dispatch_async(dispatch_get_main_queue(), ^{
            @strongify(self);
            if(!error){
                [self.textTemplatePickerView updateCategory:@[categoryModel]];
                [self.textTemplatePickerView updateFetchFinish];
            }else{
                [DVECustomerHUD showMessage:error];
                [self.textTemplatePickerView updateFetchError];
            }
        });
    }];
}

- (DVEPlaceholderTextView *)textView
{
    if (!_textView) {
        
        _textView = [[DVEPlaceholderTextView alloc] initWithFrame:CGRectMake(10, 10, VE_SCREEN_WIDTH - 20, 34)];
        _textView.font = SCRegularFont(12);
        _textView.placeholder = NLELocalizedString(@"ck_enter_text", @"输入文字");
        _textView.placeholderColor = UIColor.whiteColor;
        _textView.delegate = self;
        _textView.backgroundColor = HEXRGBCOLOR(0x181718);
        _textView.layer.cornerRadius = 8;
        _textView.clipsToBounds = YES;
        _textView.textColor = UIColor.whiteColor;
        _textView.tintColor = UIColor.whiteColor;
    }
    
    return _textView;
}

- (SGPageTitleViewConfigure *)functionViewConfig {
    SGPageTitleViewConfigure *config = [SGPageTitleViewConfigure pageTitleViewConfigure];
    config.showBottomSeparator = NO;
    config.titleAdditionalWidth = 0;
    config.titleColor = [[UIColor whiteColor] colorWithAlphaComponent:0.5];
    config.titleSelectedColor = [UIColor whiteColor];
    config.indicatorColor = HEXRGBCOLOR(0xFE6646);
    config.titleFont = SCRegularFont(14);
    return config;
}

- (SGPageTitleView *)functionView
{
    if (!_functionView) {
        _functionView = [[SGPageTitleView alloc] initWithFrame:CGRectMake(0, 20, 240, 24) delegate:self titleNames:@[NLELocalizedString(@"ck_text_keyboard", @"键盘"),NLELocalizedString(@"ck_text_style",@"样式"),NLELocalizedString(@"ck_text_flower",@"花字"), NLELocalizedString(@"ck_text_bubble",@"气泡"), NLELocalizedString(@"ck_text_anima",@"动画")] configure:[self functionViewConfig]];
        _functionView.backgroundColor = [UIColor clearColor];
        _functionView.selectedIndex = 0;
    }
    
    return _functionView;
}

- (UIView *)contentView
{
    if (!_contentView) {
        CGFloat y = 120;
        CGFloat h = self.height - y;
        _contentView = [[UIView alloc] initWithFrame:CGRectMake(0, 120, VE_SCREEN_WIDTH, h)];
        _contentView.backgroundColor = UIColor.clearColor;
    }
    
    return _contentView;
}
- (DVEPickerView *)textTemplatePickerView {

    if (!_textTemplatePickerView) {
        _textTemplatePickerView = [[DVEPickerView alloc] initWithUIConfig:[DVETextTemplatePickerUIDefaultConfiguration new]];
        _textTemplatePickerView.delegate = self;
        _textTemplatePickerView.frame = CGRectMake(0, 0, VE_SCREEN_WIDTH, self.frame.size.height);
        _textTemplatePickerView.backgroundColor = [UIColor blackColor];
    }
    return _textTemplatePickerView;
}

- (DVETextStyleView *)styleView
{
    if (!_styleView) {
        _styleView = [[DVETextStyleView alloc] initWithFrame:CGRectMake(0, 0, VE_SCREEN_WIDTH, self.contentView.height)];
        @weakify(self);
        _styleView.selectStyleBlock = ^(DVEEffectValue *value) {
            @strongify(self);
            DVEEffectColorModel* model = [DVEEffectColorModel yy_modelWithDictionary:value.style];
            self.curParm.textColor = model.textColor;
            self.curParm.backgroundColor = model.backgroundColor;
            self.curParm.outlineColor = model.outlineColor;
            self.curParm.outlineWidth = model.outlineColor.count > 0 ? 0.06 : 0;
            self.curParm.shadowColor = model.shadowColor;
            [self textParmDidChang];
        };
        _styleView.alignMentBlock = ^(DVEEffectValue *alignment) {
            @strongify(self);
            self.curParm.alignment = alignment;
            [self textParmDidChang];
        };
        _styleView.fontBlock = ^(DVEEffectValue * _Nonnull font) {
            @strongify(self);
            self.curParm.font = font;
            [self textParmDidChang];
        };
        _styleView.colorBlock = ^(DVEEffectValue * _Nonnull color, NSInteger colorType, NSDictionary * _Nonnull extraDict) {
            @strongify(self);
            switch (colorType) {
                case DVETextColorConfigTypeFont:
                    self.curParm.textColor = color.color;
                    break;
                case DVETextColorConfigTypeBackground:
                    self.curParm.backgroundColor = color.color;
                    break;
                case DVETextColorConfigTypeOutline: {
                    self.curParm.outlineColor = color.color;
                    self.curParm.outlineWidth = [extraDict[@"outlineWidth"] floatValue];
                }
                    break;
                case DVETextColorConfigTypeShadow: {
                    self.curParm.shadowColor = color.color;
                    NSArray *shadowOffset = extraDict[@"shadowOffset"];
                    self.curParm.shadowOffset = shadowOffset;
                    
                    self.curParm.shadowSmoothing = [extraDict[@"shadowSmoothing"] floatValue];
                }
                    break;
                case DVETextColorConfigTypeArrange: {
                    DVEEffectValue *alignment = self.curParm.alignment;
                    if (!alignment) {
                        alignment = [DVEEffectValue new];
                        self.curParm.alignment = alignment;
                    }
                    
                    alignment.alignType = color.alignType;
                    self.curParm.typeSettingKind = color.typeSettingKind.intValue;
                    
                    self.curParm.lineGap = [extraDict[@"lineGap"] floatValue];
                    self.curParm.charSpacing = [extraDict[@"charSpacing"] floatValue];
                }
                    break;
                case DVETextColorConfigTypeBlod: {
                    self.curParm.boldWidth = [extraDict[@"boldWidth"] floatValue];
                    self.curParm.italicDegree = [extraDict[@"italicDegree"] floatValue];
                    self.curParm.underline = [extraDict[@"underline"] boolValue];
                }
                    break;
                default:
                    break;
            }
            self.curParm.useEffectDefaultColor = NO;
            [self textParmDidChang];
        };
    }
    
    return _styleView;
}

- (UIButton *)dismissBack
{
    if (!_dismissBack) {
        _dismissBack = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 44, 44)];
        [_dismissBack setImage:@"icon_bottonbar_dismiss".dve_toImage forState:UIControlStateNormal];
        @weakify(self);
        [[_dismissBack rac_signalForControlEvents:UIControlEventTouchUpInside] subscribeNext:^(__kindof UIControl * _Nullable x) {
            @strongify(self);
            if (![self.lastParm isEqualToParm:self.curParm]) {
                //有gengxin
                DVELogInfo(@"更新了extt");
            }
            DVEViewController *vc =  (DVEViewController *) self.parentVC;
            if (self.curParm.text.length == 0) {
                [self removeTempText:self.segmentId commit:self.isMainEdit];
                [[DVEComponentViewManager sharedManager] showComponentType:DVEBarComponentTypeText];
                [self dismiss:YES];
                [self.actionService refreshUndoRedo];
                
            } else {
                [self dismiss:YES];
                
                self.lastParm = self.curParm;
                self.textView.text = @"";
                
                [self.stickerEditor updateTextStickerWithParm:self.curParm segmentID:self.segmentId isCommit:self.isMainEdit isMainEdit:self.isMainEdit];
                NLETrackSlot_OC *slot = nil;
                if (self.isMainEdit) {
                    slot = [self.nleEditor.nleModel slotOf:self.segmentId];
                } else {
                    slot = [self.nleEditor.nleModel.coverModel slotOf:self.segmentId];
                }
                [self.nle setStickerPreviewMode:slot previewMode:0];

                [vc.stickerEditAdatper changeSelectTextSlot:self.segmentId];
            }
            vc.stickerEditAdatper.delegate = vc;
        }];
    }
    
    return _dismissBack;
}

- (DVEPickerView *)shapePickerView {

    if (!_shapePickerView) {
        _shapePickerView = [[DVEPickerView alloc] initWithUIConfig:[DVETextTemplatePickerUIDefaultConfiguration new]];
        _shapePickerView.delegate = self;
        _shapePickerView.frame = CGRectMake(0, 0, VE_SCREEN_WIDTH, 171 + 120);
        _shapePickerView.backgroundColor = [UIColor clearColor];
    }
    return _shapePickerView;
}

- (DVETextAnimationView *)textAnimationView {
    if (!_textAnimationView) {
        _textAnimationView = [[DVETextAnimationView alloc] init];
        _textAnimationView.frame = CGRectMake(0, 0, VE_SCREEN_WIDTH, 171 + 120);
        _textAnimationView.backgroundColor = [UIColor clearColor];
        _textAnimationView.delegate = self;
        _textAnimationView.dataSource = self;
    }
    return _textAnimationView;
}


- (void)removeTempText:(NSString*)segmentId  commit:(BOOL)commit{
    DVEViewController *parentVC = (DVEViewController *)self.parentVC;
    [self.slotEditor removeSlot:segmentId needCommit:commit isMainEdit:commit];
    [parentVC.stickerEditAdatper removeStickerBox:segmentId];
}

- (void)addKeyboardNotice
{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];

}

- (void)keyboardWillShow:(NSNotification *)notification
{
    //获取键盘的高度
    NSDictionary *userInfo = [notification userInfo];

    NSValue *value = [userInfo objectForKey:UIKeyboardFrameEndUserInfoKey];

    CGRect keyboardRect = [value CGRectValue];
    NSInteger height = keyboardRect.size.height;
    
    CGFloat delt = height + 108 - self.frame.size.height;
    self.transform = CGAffineTransformMakeTranslation(0, -delt);
    self.functionView.resetSelectedIndex = 0;
}

- (void)keyboardWillHide:(NSNotification *)notification
{
    self.transform = CGAffineTransformIdentity;
}
#pragma mark - SGPageTitleViewDelegate
- (void)pageTitleView:(SGPageTitleView *)pageTitleView selectedIndex:(NSInteger)selectedIndex
{
    pageTitleView.selectedIndex = selectedIndex;
    
    switch (selectedIndex) {
        case 1:
        {
            self.contentView.hidden = NO;
            [self.textView resignFirstResponder];
            self.styleView.hidden = NO;
            _textTemplatePickerView.hidden = YES;
            _shapePickerView.hidden = YES;
            _textAnimationView.hidden = YES;
            [DVEReportUtils logEvent:@"video_edit_text_style_show" params:@{}];
        }
            break;
        case 2:
        {
            self.contentView.hidden = NO;
            [self.textView resignFirstResponder];
            _styleView.hidden = YES;
            self.textTemplatePickerView.hidden = NO;
            _shapePickerView.hidden = YES;
            _textAnimationView.hidden = YES;
        }
            break;
        case 3: // 气泡
        {
            self.contentView.hidden = NO;
            [self.textView resignFirstResponder];
            _styleView.hidden = YES;
            _textTemplatePickerView.hidden = YES;
            
            if (!_shapePickerView) {
                [self.contentView addSubview:self.shapePickerView];
                // 文字气泡
                [self p_loadTextBubble];
            }
            self.shapePickerView.hidden = NO;
            
            _textAnimationView.hidden = YES;
        }
            break;
        case 4: // 动画
        {
            self.contentView.hidden = NO;
            [self.textView resignFirstResponder];
            _styleView.hidden = YES;
            _textTemplatePickerView.hidden = YES;
            _shapePickerView.hidden = YES;
            _textAnimationView.hidden = NO;
        }
            break;
        default:
        {
            [self.textView becomeFirstResponder];
            self.contentView.hidden = YES;
        }
            break;
    }
    
    self.textView.textColor = _textView.isFirstResponder ? UIColor.whiteColor : [UIColor.whiteColor colorWithAlphaComponent:0.5];
}

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text {
    
    return YES;
}

- (void)textViewDidChange:(UITextView *)textView {
    
    self.curParm.text = textView.text;
    [self textParmDidChang];
}

- (void)textParmDidChang
{
    DVELogInfo(@"--------------%@",self.curParm);
    [self.stickerEditor updateTextStickerWithParm:self.curParm segmentID:self.segmentId isCommit:NO isMainEdit:self.isMainEdit];
    DVEViewController *vc = (DVEViewController *) self.parentVC;
    [vc.stickerEditAdatper refreshEditBox:self.segmentId];
}

- (void)textFlowerDidChange {
    NLETrackSlot_OC *slot = nil;
    if (self.isMainEdit) {
        slot = [self.nleEditor.nleModel slotOf:self.segmentId];
    } else {
        slot = [self.nleEditor.nleModel.coverModel slotOf:self.segmentId];
    }
    if (!slot) {
        return;
    }
    NLESegmentTextSticker_OC *textSeg = (NLESegmentTextSticker_OC *)slot.segment;
    NLEStyleText_OC *style =  textSeg.style;
    style.flower = self.textFlower;
    [self.stickerEditor updateTextStickerWithParm:self.curParm segmentID:self.segmentId isCommit:NO isMainEdit:self.isMainEdit];
    DVEViewController *vc = (DVEViewController *) self.parentVC;

    [vc.stickerEditAdatper refreshEditBox:self.segmentId];
}

- (void)bubbleTextDidChange {
    NLETrackSlot_OC *slot = nil;
    if (self.isMainEdit) {
        slot = [self.nleEditor.nleModel slotOf:self.segmentId];
    } else {
        slot = [self.nleEditor.nleModel.coverModel slotOf:self.segmentId];
    }
    NLESegmentTextSticker_OC *textSeg = (NLESegmentTextSticker_OC *)slot.segment;
    NLEStyleText_OC *style =  textSeg.style;
    style.shape = self.bubbleText;
    [self.stickerEditor updateTextStickerWithParm:self.curParm segmentID:self.segmentId isCommit:NO isMainEdit:self.isMainEdit];
    DVEViewController *vc = (DVEViewController *) self.parentVC;

    [vc.stickerEditAdatper refreshEditBox:self.segmentId];
}
- (void)textAnimationDidChange {
    NLETrackSlot_OC *slot = [self.nleEditor.nleModel slotOf:self.segmentId];
    if (!slot) {
        return;
    }
    NLESegmentSticker_OC *textSeg = (NLESegmentSticker_OC *)slot.segment;
    textSeg.stickerAnimation = self.textAnimation;
    [self.stickerEditor updateTextStickerWithParm:self.curParm segmentID:self.segmentId isCommit:self.curParm.text.length > 0 ? YES:NO isMainEdit:self.isMainEdit];
    
    DVEViewController *vc = (DVEViewController *) self.parentVC;
    
    [vc.stickerEditAdatper refreshEditBox:self.segmentId];
}

- (void)showInView:(UIView *)view animation:(BOOL)animation
{
    [super showInView:view animation:(BOOL)animation];
    [self initData];
}


// MARK: - Private

- (void)p_loadTextBubble {
    @weakify(self);
    [[DVEBundleLoader shareManager] textBubble:self.vcContext handler:^(NSArray<DVEEffectValue *> * _Nullable datas, NSString * _Nullable error) {
        @strongify(self);
        
        NSMutableArray* array = [NSMutableArray arrayWithArray:datas];
        [array enumerateObjectsUsingBlock:^(DVEEffectValue *obj, NSUInteger idx, BOOL * _Nonnull stop) {
            obj.identifier = [NSString stringWithFormat:@"%@",@(idx)];
            obj.valueState = VEEffectValueStateNone;
        }];
        
        
        DVEEffectValue *model = [DVEEffectValue new];
        model.valueState = VEEffectValueStateShuntDown;
        model.identifier = @"";
        [array insertObject:model atIndex:0];
        
        DVEModuleBaseCategoryModel *categoryModel = [DVEModuleBaseCategoryModel new];
        DVEEffectCategory* category = [DVEEffectCategory new];
        category.models = array;
        categoryModel.category = category;
        @weakify(self);
        dispatch_async(dispatch_get_main_queue(), ^{
            @strongify(self);
            if(!error){
                [self.shapePickerView updateCategory:@[categoryModel]];
                [self.shapePickerView updateFetchFinish];
            }else{
                [DVECustomerHUD showMessage:error];
                [self.shapePickerView updateFetchError];
            }
        });
    }];
}

-(void)initParm:(NLESegmentTextSticker_OC*)segTextSticker
{
    if(!segTextSticker) return;
    self.curParm = [DVETextParm yy_modelWithJSON:[segTextSticker toEffectJSON]];
    NLEStyleText_OC *style = segTextSticker.style;
    DVEEffectValue *font = [DVEEffectValue new];
    font.sourcePath = style.font.resourceFile;
    self.curParm.font = font;
    DVEEffectValue *align = [DVEEffectValue new];
    align.alignType = @(style.alignType);
    self.curParm.alignment = align;
    self.textFlower = style.flower;
    self.bubbleText = style.shape;
    
    if (segTextSticker.content.length > 0) {
        if ([segTextSticker.content isEqualToString:NLELocalizedString(@"ck_enter_text", @"输入文字")]) {
            self.curParm.text = @"";
        } else {
            self.curParm.text = segTextSticker.content;
        }
    } else {
        self.curParm.text = @"";
    }
    
    if (self.curParm.text) {
        self.textView.text = self.curParm.text;
    } else {
        self.textView.text = @"";
    }
    
    self.lastParm = [self.curParm yy_modelCopy];
}

-(DVETextParm*)createDefaultTextParm
{
    DVETextParm* parm = [DVETextParm new];
    parm.textColor = @[@(1.0),@(1.0),@(1.0),@(1.0)];//白色字
    parm.outlineColor = @[@(0),@(0),@(0),@(1.0)];//黑色描边
    return parm;
}

#pragma mark - DVEPickerViewDelegate

- (void)pickerView:(DVEPickerView *)pickerView didSelectTabIndex:(NSInteger)index {

}

- (BOOL)pickerView:(DVEPickerView *)pickerView isSelected:(DVEEffectValue*)sticker {
    NLEResourceNode_OC *res = nil;
    if (pickerView == self.textTemplatePickerView) {
        res = self.textFlower;
    } else if (pickerView == self.shapePickerView) {
        res = self.bubbleText;
    }
    
    // 上次无选中的情况
    
    if (res.resourceFile.length == 0) {
        // 默认选中「无样式」
        return sticker.identifier.length == 0;
    }
    
    // 上次有选中的情况

    if (pickerView == self.textTemplatePickerView) {
        return [res.resourceFile.dve_lowercasePathName isEqualToString:sticker.sourcePath.dve_lowercasePathName];
    } else if (pickerView == self.shapePickerView) {
        NSArray *arr = [res.resourceFile componentsSeparatedByString:@"/"];
        NSUInteger c = arr.count;
        if (c > 1) {
            NSString *name = arr[c-2]; // 倒数第二个为名称
            return [name.localizedLowercaseString isEqualToString:sticker.name];
        }
    }
    
    // 默认选中「无样式」
    return sticker.identifier.length == 0;
}

- (void)pickerView:(DVEPickerView *)pickerView
         didSelectSticker:(DVEEffectValue*)sticker
                 category:(id<DVEPickerCategoryModel>)category
         indexPath:(NSIndexPath *)indexPath {

    if(sticker.status == DVEResourceModelStatusDefault){
        [pickerView updateSelectedStickerForId:sticker.identifier];

        NLEResourceNode_OC *resNode = nil;
        self.curParm.useEffectDefaultColor = YES;
        if (sticker.valueState == VEEffectValueStateShuntDown) {
            resNode = nil;
        } else {
            resNode = [[NLEResourceNode_OC alloc] init];
            resNode.resourceId = sticker.identifier;
            resNode.resourceFile = sticker.sourcePath;
        }
        
        self.curParm.useEffectDefaultColor = YES;
        
        if (pickerView == _shapePickerView) {
            resNode.resourceType = NLEResourceTypeBubble;
            self.bubbleText = resNode;
            [self bubbleTextDidChange];
        } else if (pickerView == _textTemplatePickerView) {
            resNode.resourceType = NLEResourceTypeFlower;
            self.textFlower = resNode;
            [self textFlowerDidChange];
        }
        return;
    }else if(sticker.status == DVEResourceModelStatusNeedDownlod || sticker.status == DVEResourceModelStatusDownlodFailed){
        @weakify(self);
        [sticker downloadModel:^(id<DVEResourceModelProtocol>  _Nonnull model) {
            [pickerView updateStickerStatusForId:model.identifier];
            if(model.status != DVEResourceModelStatusDefault) return;
            dispatch_async(dispatch_get_main_queue(), ^{
                @strongify(self);
                [self pickerView:pickerView didSelectSticker:sticker category:category indexPath:indexPath];
            });
        }];
    }
    [pickerView updateStickerStatusForId:sticker.identifier];

}


- (void)pickerViewDidClearSticker:(DVEPickerView *)pickerView {
    
}
#pragma mark - DVETextAnimationViewDelegate
- (void)textAnimationView:(DVETextAnimationView *)ta_view didChangeAnimationWithType:(DVEAnimationType)ta_type {
    if (!_textAnimation) {
        _textAnimation = [[NLEStyStickerAnimation_OC alloc] init];
    }
    NLETrackSlot_OC *slot = [self.nleEditor.nleModel slotOf:self.segmentId];
    if (!slot) {
        slot = [self.nleEditor.nleModel.coverModel slotOf:self.segmentId];
    }
    
    if (ta_type == DVEAnimationTypeIn || ta_type == DVEAnimationTypeOut) {
        _textAnimation.inAnimation = [ta_view.inAnimation toResourceNode];
        _textAnimation.inDuration = CMTimeMakeWithSeconds(ta_view.inDuration, USEC_PER_SEC);

        _textAnimation.outAnimation = [ta_view.outAnimation toResourceNode];;
        _textAnimation.outDuration = CMTimeMakeWithSeconds(ta_view.outDuration, USEC_PER_SEC);
        
        _textAnimation.loop = NO;
    } else if (ta_type == DVEAnimationTypeLoop) {
        _textAnimation.inAnimation = [ta_view.loopAnimation toResourceNode];
        _textAnimation.inDuration = CMTimeMakeWithSeconds(ta_view.loopDuration, USEC_PER_SEC);
        _textAnimation.loop = ta_view.loopAnimation ? YES : NO;
    }
    
    [self textAnimationDidChange];
    if (CMTimeGetSeconds(_textAnimation.inDuration) > 0 || CMTimeGetSeconds(_textAnimation.outDuration) > 0) {
        [self.nle setStickerPreviewMode:slot previewMode:0];
        [self.nle setStickerPreviewMode:slot previewMode:(int)ta_type + 1];
    }
}

#pragma mark DVEAnimationViewDataSource
- (float)animationView:(DVETextAnimationView *)animationView defaultAnimationDuration:(DVEAnimationType)type
{
    if (type == DVEAnimationTypeIn || type == DVEAnimationTypeOut) {
        return 0.5f;
    } else if (type == DVEAnimationTypeLoop) {
        return 0.6f;
    }
    
    return 0;
}

- (float)animationView:(DVETextAnimationView *)animationView maxAnimationDuration:(DVEAnimationType)type
{
    float duration = CMTimeGetSeconds(self.vcContext.mediaContext.selectTextSlot.duration);
    if (type == DVEAnimationTypeLoop){
        return MIN(duration, 5);
    }
    return duration;
}

- (void)animationView:(DVETextAnimationView *)animationView requestForAnimationResource:(DVEAnimationType)type handler:(DVEModuleModelHandler)handler
{
    [[DVEBundleLoader shareManager] textAnimation:self.vcContext type:type handler:handler];
}

- (void)updateTextCategoryWithNames:(NSArray<NSString *> *)names {
    [self.functionView removeFromSuperview];
    CGRect rect = self.functionView.frame;
    rect.size.width = rect.size.width / 5 * names.count;
    self.functionView = [[SGPageTitleView alloc] initWithFrame:rect
                                                      delegate:self
                                                    titleNames:names
                                                     configure:[self functionViewConfig]];
    self.functionView.backgroundColor = [UIColor clearColor];
    self.functionView.selectedIndex = 0;
    [self addSubview:self.functionView];
    self.functionView.top = self.textView.bottom + 14 + 10;
    self.functionView.left = 15;
}

#pragma mark - DVEStickerEditAdpterDelegate

- (BOOL)triggerAction:(DVEEditCornerType)type segmentId:(NSString *)segmentId {
    if (type == DVECornrDelete) {
        [self removeTempText:segmentId commit:self.isMainEdit];
        [[DVEComponentViewManager sharedManager] showComponentType:DVEBarComponentTypeText];
        [self dismiss:YES];
        [self.actionService refreshUndoRedo];
        return YES;
    }else if (type == DVECornerCopy) {
        DVEViewController *parentVC = (DVEViewController *)self.parentVC;
        NLETrackSlot_OC* slot = [self.slotEditor copyForSlot:segmentId needCommit:self.isMainEdit];
        [parentVC.stickerEditAdatper refreshEditBox:segmentId];
        self.segmentId = slot.nle_nodeId;
        return YES;
    }
    return NO;
}

- (BOOL)stickerTransform:(NSString *)segmentId offsetX:(CGFloat)offsetX offsetY:(CGFloat)offsetY angle:(CGFloat)angle scale:(CGFloat)scale {
    [self.stickerEditor setSticker:segmentId offsetX:offsetX offsetY:offsetY angle:angle scale:scale isCommitNLE:NO];
    return YES;
}

- (void)changeSelectTextSlot:(NSString *)segmentId {
    if([segmentId isEqualToString:self.segmentId]) return;
    NLETrackSlot_OC *slot = nil;
    if (self.isMainEdit) {
        slot = [self.nleEditor.nleModel slotOf:segmentId];
    } else {
        slot = [self.nleEditor.nleModel.coverModel slotOf:segmentId];
    }
    
    if([slot.segment isKindOfClass:NLESegmentTextSticker_OC.class]){
        self.segmentId = segmentId;
        NLESegmentTextSticker_OC *segTextSticker = (NLESegmentTextSticker_OC *)slot.segment;
        [self initParm:segTextSticker];
    }else{///如果切换的textSlot非文字（例如文字模板和文字之间来回切换），则关闭面板
        [self dismiss:YES];
        [self.stickerEditor updateTextStickerWithParm:self.curParm segmentID:self.segmentId isCommit:self.isMainEdit isMainEdit:self.isMainEdit];
        DVEViewController *vc =  (DVEViewController *) self.parentVC;
        if(vc.stickerEditAdatper.delegate == self){
            vc.stickerEditAdatper.delegate = vc;
        }
    }
}

@end
