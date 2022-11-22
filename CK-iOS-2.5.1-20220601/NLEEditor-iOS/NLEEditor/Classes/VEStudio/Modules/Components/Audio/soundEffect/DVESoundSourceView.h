//
//  DVESoundSourceView.h
//  NLEEditor
//
//  Created by bytedance on 2021/7/4.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN
@class DVEVCContext;

@protocol DVEResourceCategoryModelProtocol;

typedef void (^DVESelectSoundFileBlock)(id _Nullable audio,BOOL isLocal,NSString *audioName) ;

@interface DVESoundSourceView : UIView<UITableViewDelegate,UITableViewDataSource>

@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) id<DVEResourceCategoryModelProtocol> data;
@property (nonatomic, weak) DVEVCContext *vcContext;
@property (nonatomic, copy) DVESelectSoundFileBlock selectBlock;

- (void)showEmptyView;
- (void)reloadData;


@end

NS_ASSUME_NONNULL_END
