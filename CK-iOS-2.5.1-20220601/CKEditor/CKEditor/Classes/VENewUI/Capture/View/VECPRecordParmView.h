//
//  VECPRecordParmView.h
//  TTVideoEditorDemo
//
//  Created by bytedance on 2020/12/20
//  Copyright © 2020 bytedance. All rights reserved.
//

#import "VECPBaseBar.h"
#import "VETwoLableButton.h"

NS_ASSUME_NONNULL_BEGIN

@interface VECPRecordParmView : VECPBaseBar

@property (nonatomic, strong) VETwoLableButton *rateButton;
@property (nonatomic, strong) VETwoLableButton *timeButton;
@property (nonatomic, strong) UISegmentedControl *rateControl;
@property (nonatomic, strong) UISegmentedControl *timeControl;

@end

NS_ASSUME_NONNULL_END
