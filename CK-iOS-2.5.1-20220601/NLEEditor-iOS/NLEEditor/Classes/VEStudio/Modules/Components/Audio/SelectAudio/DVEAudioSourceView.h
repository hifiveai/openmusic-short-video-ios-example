//
//  DVEAudioSourceView.h
//  TTVideoEditorDemo
//
//  Created by bytedance on 2020/12/20
//  Copyright © 2020 bytedance. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@class DVEVCContext;

@protocol DVEResourceCategoryModelProtocol;

typedef void (^DVESelectAudioFileBlock)(id _Nullable audio,BOOL isLocal,NSString *audioName) ;

@interface DVEAudioSourceView : UIView<UITableViewDelegate,UITableViewDataSource>

@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) id<DVEResourceCategoryModelProtocol> data;
@property (nonatomic, weak) DVEVCContext *vcContext;
@property (nonatomic, copy) DVESelectAudioFileBlock selectBlock;

- (void)reloadData;



@end

NS_ASSUME_NONNULL_END
