//
//  DVEComponentViewManager.m
//  NLEEditor
//
//  Created by bytedance on 2021/5/27.
//

#import "DVEComponentViewManager.h"
#import "DVEVCContext.h"
#import "DVEViewController.h"
#import "DVEUIHelper.h"
#import "DVEAudioBar.h"
#import "DVEStickerBar.h"
#import "DVETextBar.h"
#import "DVEAnimationBar.h"
#import "DVESpeedBar.h"
#import "DVECanvasBar.h"
#import "DVERegulateBar.h"
#import "DVECropBar.h"
#import "DVEMaskBar.h"
#import "DVEFilterBar.h"
#import "DVEEffectsBar.h"
#import "DVEAudioSelectView.h"
#import "DVEMixedEffectBar.h"
#import "DVEComponentAction.h"
#import "DVEComponentAction+Private.h"
#import "DVEComponentModelFactory.h"
#import "DVEComponentBar+Private.h"

@interface DVEComponentViewManager ()

///剪辑上下文
@property (nonatomic, weak) DVEVCContext *vcContext;
///Bar依附VC
@property (nonatomic, weak) DVEViewController *parentVC;
///节点树
@property (nonatomic,strong) id<DVEBarComponentProtocol> treeComponents;
/// 历史路径队列
/// 首位代表栈顶（当前展示节点）
@property(nonatomic,strong)NSMutableArray<DVEComponentBar*>* linkBar;
/// 节点类型-节点映射表
@property(nonatomic,strong)NSMapTable* typeComponentsMap;

@end

@implementation DVEComponentViewManager

+ (instancetype)sharedManager {
    static DVEComponentViewManager *s_manager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        s_manager = [[super allocWithZone:nil] init];
        s_manager.enable = YES;
        s_manager.componentViewBarHeight = (98 - VEBottomMargnValue) + VEBottomMargn;
    });
    return s_manager;
}

+(id)allocWithZone:(NSZone *)zone{
    return [self sharedManager];
}
-(id)copyWithZone:(NSZone *)zone{
    return [[self class] sharedManager];
}
-(id)mutableCopyWithZone:(NSZone *)zone{
    return [[self class] sharedManager];
}

- (NSMutableArray<DVEComponentBar *> *)linkBar
{
    if(!_linkBar){
        _linkBar = [NSMutableArray array];
    }
    return _linkBar;
}

- (NSMapTable *)typeComponentsMap
{
    if(!_typeComponentsMap) {
        _typeComponentsMap = [NSMapTable mapTableWithKeyOptions:NSMapTableStrongMemory valueOptions:NSMapTableWeakMemory];
    }
    return _typeComponentsMap;
}

- (UIView *)parentView
{
    return self.parentVC.view;
}

- (DVEViewController *)parentVC
{
    return _parentVC;
}

#pragma mark public api

-(id<DVEBarComponentProtocol>)firstComponentWithType:(DVEBarComponentType)type
{
    NSMutableArray* array = [NSMutableArray array];
    [array addObject:self.treeComponents];
    do {
        id<DVEBarComponentProtocol> c = array.firstObject;
        [array removeObjectAtIndex:0];
        if(c.componentType == type){
            return c;
        }
        [array addObjectsFromArray:c.subComponents];
    } while (array.count > 0);
    
    return nil;
}

-(NSArray*)componentsWithType:(DVEBarComponentType)type
{
    NSMutableArray* components = [NSMutableArray array];
    NSMutableArray* array = [NSMutableArray array];
    [array addObject:self.treeComponents];
    do {
        id<DVEBarComponentProtocol> c = array.firstObject;
        [array removeObjectAtIndex:0];
        if(c.componentType == type){
            [components addObject:c];
        }
        [array addObjectsFromArray:c.subComponents];
    } while (array.count > 0);
    return components;
}

-(void)setupTreeComponents:(id<DVEBarComponentProtocol>)treeComponents parentVC:(DVEViewController*)parentVC context:(DVEVCContext*)context
{
    self.treeComponents = treeComponents;
    self.parentVC = parentVC;
    self.vcContext = context;
    [self unSetupTreeComponents];
    [self cacheComponentToMap:treeComponents];
    [[DVEComponentAction shareManager] setupParentVC:self.parentVC context:self.vcContext];
}

-(void)unSetupTreeComponents
{
    [self.typeComponentsMap removeAllObjects];
    
    for(UIView* v in self.linkBar){
        [v removeFromSuperview];
    }
    [self.linkBar removeAllObjects];
}

- (DVEComponentBar*)currentBar
{
    return self.linkBar.firstObject;
}

-(DVEBarComponentType)currentBarType
{
    return self.currentBar.panelType;
}

- (BOOL)backToParentComponent
{
    if(!self.enable) return NO;
    DVEComponentBar* bar = self.currentBar;
    if(bar && bar.backComponentDic.count > 0){
        [bar clickToBack];
        return YES;
    }
    return NO;
}

-(void)refreshCurrentBarGroupTpye
{
    if(!self.enable) return;
    DVEComponentBar* bar = self.currentBar;
    [bar refreshBar];
}

-(void)updateCurrentBarGroupTpye:(DVEBarSubComponentGroup)group
{
    if(!self.enable) return;
    DVEComponentBar* bar = self.currentBar;
    id<DVEBarComponentProtocol> component = bar.component;
    component.currentSubGroup = group;
    [bar refreshBar];
}

-(void)showComponentType:(DVEBarComponentType)type groupTpye:(DVEBarSubComponentGroup)group
{
    if(!self.enable) return;
    id<DVEBarComponentProtocol> component = [self.typeComponentsMap objectForKey:@(type)];
    if(!component) return;
    
    component.currentSubGroup = group;
    
    [[DVEComponentAction shareManager] callMethod:component.clickActionName withArgument:@[component]];
    
}

-(void)showComponentType:(DVEBarComponentType)type
{
    [self showComponentType:type groupTpye:DVEBarSubComponentGroupAdd];
}

-(void)pushComponent:(DVEBarComponentType)type param:(id)param
{
    if(!self.enable) return;

    id<DVEBarComponentProtocol> component = [self firstComponentWithType:type];
    if(component == nil)return;
  
    [[DVEComponentAction shareManager] callMethod:component.clickActionName withArgument:param == nil ? @[component] : @[component, param]];
}

- (void)popToRoot
{
    [self popToComponent:DVEBarComponentTypeRoot];
}

-(void)popToComponent:(DVEBarComponentType)type
{
    [self popToComponent:type groupTpye:-1];
}

-(void)popToComponent:(DVEBarComponentType)type groupTpye:(DVEBarSubComponentGroup)group
{
    [self popToComponent:type groupTpye:group animation:NO];
}

-(void)popToComponent:(DVEBarComponentType)type groupTpye:(DVEBarSubComponentGroup)group animation:(BOOL)animation
{
    if(!self.enable) return;
    
    NSInteger index = 0;
    ///查找相同节点类型
    for(;index < self.linkBar.count ;index++){
        if(self.linkBar[index].panelType == type){
            break;
        }
    }
    if(index == 0 || index >= self.linkBar.count) return;

    DVEComponentBar* topView = self.currentBar;
    DVEComponentBar* target = self.linkBar[index];
    if(group >= 0){
        target.component.currentSubGroup = group;
    }

    [[DVEComponentAction shareManager] dismissCurrentActionView];
    [topView dismiss:animation];
    [self.linkBar removeObjectsInRange:NSMakeRange(0, index)];//移除目标bar以及它顶部的bar，后面会把目标bar添加到队列头
    [target showInView:self.parentView animation:animation];
}

-(void)dismissCurrentActionView
{
    [[DVEComponentAction shareManager] dismissCurrentActionView];
}

-(void)triggerCurrentComponentWithTitle:(NSString*)title
{
    if(!self.enable) return;
    id<DVEBarComponentProtocol> component = [self.typeComponentsMap objectForKey:@([self currentBarType])];
    if(!component) return;
    
    for(id<DVEBarComponentProtocol> sub in component.subComponents){
        if([sub.viewModel.title isEqualToString:title]){
            [[DVEComponentAction shareManager] callMethod:sub.clickActionName withArgument:@[component]];
            break;
        }
    }
}

-(void)triggerCurrentComponentWithIndex:(NSInteger)index
{
    if(!self.enable) return;
    id<DVEBarComponentProtocol> component = [self.typeComponentsMap objectForKey:@([self currentBarType])];
    if(!component || index < 0 || index >= component.subComponents.count) return;
    
    id<DVEBarComponentProtocol> sub = [component.subComponents objectAtIndex:index];
    [[DVEComponentAction shareManager] callMethod:sub.clickActionName withArgument:@[component]];

}

#pragma mark private api

-(void)cacheComponentToMap:(id<DVEBarComponentProtocol>)treeComponents
{
    if(treeComponents && treeComponents.subComponents.count > 0){
        ///只需要缓冲带有子节点的component，不带子节点的component基本上是触发业务action，不会做下级菜单展示
        [self.typeComponentsMap setObject:treeComponents forKey:@(treeComponents.componentType)];
        for(id<DVEBarComponentProtocol> sub in treeComponents.subComponents){
            [self cacheComponentToMap:sub];
        }
    }
}

- (DVEComponentBar*)createSecondBar:(id<DVEBarComponentProtocol>)component
{
    CGFloat H = [DVEComponentViewManager sharedManager].componentViewBarHeight;
    
    DVEComponentBar* view = [[DVEComponentBar alloc] initWithFrame:CGRectMake(0,VE_SCREEN_HEIGHT - H, VE_SCREEN_WIDTH, H)];
    view.component = component;
    if(component.parent){
        view.backComponentDic[@(DVEBarSubComponentGroupAdd)] = [DVEComponentModelFactory createComponentWithType:DVEBarComponentTypeBack parent:component createSubComponent:NO];
        view.backComponentDic[@(DVEBarSubComponentGroupEdit)] = [DVEComponentModelFactory createComponentWithType:DVEBarComponentTypeBack2 parent:component createSubComponent:NO];
    }
    return view;
}

//构造展示子菜单面板
- (DVEComponentBar *)createCurrentBarViewWithBarComponent:(id<DVEBarComponentProtocol>)component{
    DVEComponentBar *barView = [self createSecondBar:component];
    barView.vcContext = self.vcContext;
    barView.parentVC = self.parentVC;
    return barView;
}

-(DVEComponentBar*)showComponent:(id<DVEBarComponentProtocol>)component animation:(BOOL)animation
{
    if(!self.enable) return nil;
    if(!component) return nil;
    
    DVEComponentBar* topView = self.currentBar;
    
    if(topView.panelType == component.componentType){
        [topView refreshBar];
        return topView;///如果是当前展示节点则return；
    }
    
    [[DVEComponentAction shareManager] dismissCurrentActionView];


    DVEComponentBar* bar = [self createCurrentBarViewWithBarComponent:component];
    if(bar == nil) return nil;


    [topView dismiss:animation];
    [bar showInView:self.parentView animation:animation];
    [self.linkBar insertObject:bar atIndex:0];
    return bar;
}

-(DVEComponentBar*)showComponent:(id<DVEBarComponentProtocol>)component
{
    return [self showComponent:component animation:NO];
}

-(DVEComponentBar*)popToParentComponent
{
    return [self popToParentComponent:NO];
}

-(DVEComponentBar*)popToParentComponent:(BOOL)animation
{
    if(!self.enable) return nil;
    if(self.linkBar.count == 0) return nil;
    DVEComponentBar* topView = self.currentBar;
    id<DVEBarComponentProtocol> component = [self.typeComponentsMap objectForKey:@(topView.panelType)];
    if(!component || !component.parent) return nil;
    DVEComponentBar* preView = nil;
    if(self.linkBar.count > 1){
        preView = [self.linkBar objectAtIndex:1];
    }

    [[DVEComponentAction shareManager] dismissCurrentActionView];
    [self.linkBar removeObject:topView];
    [preView showInView:self.parentView animation:animation];
    [topView dismiss:animation];
    return preView;
}

//判断selector有几个参数

-(NSUInteger)selectorArgumentCount:(SEL)selector

{
    NSUInteger argumentCount = 0;
//sel_getName获取selector名的C字符串
    const char *selectorStringCursor = sel_getName(selector);
    char ch;
//    遍历字符串有几个:来确定有几个参数
    while((ch = *selectorStringCursor)) {
        if(ch == ':') {
            ++argumentCount;

        }
        ++selectorStringCursor;
    }
    return argumentCount;
}

@end
