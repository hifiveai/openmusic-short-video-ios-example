//
//  DVEComponentViewManager.h
//  NLEEditor
//
//  Created by bytedance on 2021/5/27.
//

#import <Foundation/Foundation.h>
#import "DVEBarComponentProtocol.h"
#import "DVEComponentBar.h"

NS_ASSUME_NONNULL_BEGIN

@class DVEViewController;
@class DVEVCContext;

@interface DVEComponentViewManager : NSObject

/// 单例
+ (instancetype)sharedManager;
/// 是否可用
@property(nonatomic,assign)BOOL enable;
/// 根节点Bar高度
@property(nonatomic,assign)CGFloat componentViewBarHeight;

/// 装配节点
/// @param treeComponents 节点
/// @param parentVC 父类VC
/// @param context 编辑上下文
-(void)setupTreeComponents:(id<DVEBarComponentProtocol>)treeComponents parentVC:(DVEViewController*)parentVC context:(DVEVCContext*)context;


/// 释放节点
-(void)unSetupTreeComponents;

/// 当前展示Bar
-(DVEComponentBar*)currentBar;

/// 当前展示Bar类型
-(DVEBarComponentType)currentBarType;

///// 指定展示bar
///// @param type 展示节点类型
///// @param group 展示的节点的子节点分组
-(void)showComponentType:(DVEBarComponentType)type groupTpye:(DVEBarSubComponentGroup)group;

///// 指定展示bar
///// @param type 展示节点类型
-(void)showComponentType:(DVEBarComponentType)type;

/// 返回当前节点的父节点
-(BOOL)backToParentComponent;


/// 回弹至Root节点
-(void)popToRoot;

/// 回弹到指定类型节点
/// @param type 节点类型
-(void)popToComponent:(DVEBarComponentType)type;


/// 回弹到指定类型节点
/// @param type 节点类型
/// @param group 子节点状态
-(void)popToComponent:(DVEBarComponentType)type groupTpye:(DVEBarSubComponentGroup)group;


/// 回弹到指定类型节点
/// @param type 节点类型
/// @param group 子节点状态
/// @param animation 动画
-(void)popToComponent:(DVEBarComponentType)type groupTpye:(DVEBarSubComponentGroup)group animation:(BOOL)animation;

/// 根据类型获取第一个节点
/// @param type 节点类型
-(id<DVEBarComponentProtocol>)firstComponentWithType:(DVEBarComponentType)type;

///  根据类型获取所有节点
/// @param type 节点类型
-(NSArray*)componentsWithType:(DVEBarComponentType)type;


/// 弹出注定类型bar
/// @param type 展示节点类型
/// @param param  传递参数
-(void)pushComponent:(DVEBarComponentType)type param:(id)param;


/// 附属View
- (UIView *)parentView;


/// 更新当前bar状态
/// @param group 类型
-(void)updateCurrentBarGroupTpye:(DVEBarSubComponentGroup)group;


/// 刷新当前bar显示
-(void)refreshCurrentBarGroupTpye;


/// 附属VC
- (DVEViewController *)parentVC;

/// 触发当前面板子面板Action
/// @param index 子面板索引
-(void)triggerCurrentComponentWithIndex:(NSInteger)index;

/// 触发当前面板子面板Action
/// @param index 子面板标题
-(void)triggerCurrentComponentWithTitle:(NSString*)title;

/// 隐藏当前节点操作面板
-(void)dismissCurrentActionView;


@end

NS_ASSUME_NONNULL_END
