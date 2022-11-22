//
//  HFCollectionCellModel.h
//  TTVideoEditorDemo
//
//  Created by ly on 2022/7/15.
//  Copyright © 2022 bytedance. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface HFPlaylistCollectionCellModel : NSObject

@property (nonatomic ,strong) NSString *picUrl;
@property (nonatomic ,strong) NSString *listName;
@property (nonatomic ,strong) NSString *sheetId;

@end

NS_ASSUME_NONNULL_END
