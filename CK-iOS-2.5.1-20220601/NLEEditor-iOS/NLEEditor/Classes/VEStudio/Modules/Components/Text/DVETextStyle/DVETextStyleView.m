//
//  DVETextStyleView.m
//  TTVideoEditorDemo
//
//  Created by bytedance on 2020/12/20
//  Copyright © 2020 bytedance. All rights reserved.
//

#import "DVETextStyleView.h"
#import "DVETextBaseStyleCell.h"
#import "DVETextFontCell.h"
#import "DVETextColorCell.h"
#import "DVEMacros.h"
#import <DVETrackKit/UIView+VEExt.h>

@interface DVETextStyleView ()

@end

@implementation DVETextStyleView

- (instancetype)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
        [self buildLayout];
    }
    
    return self;
}

- (UIView *)hitTest:(CGPoint)point withEvent:(UIEvent *)event {
    /*
     直接拖动DVEBaseSlider，此时touch时间在150ms以内，UIScrollView会认为是拖动自己，从而拦截了event，导致DVEBaseSlider接受不到滑动的event。但是只要按住DVEBaseSlider一会再拖动，此时此时touch时间超过150ms，因此滑动的event会发送到DVEBaseSlider上。
     */
    UIView *view = [super hitTest:point withEvent:event];
    
    BOOL onSlider = NO;
    if([view isKindOfClass:NSClassFromString(@"DVEBaseSlider")]) {
        // 因为DVETextSliderView里将所有事件都交给DVEBaseSlider，所以需要再判断point
        if(CGRectContainsPoint(view.bounds, [self convertPoint:point toView:view])){
            // 如果是在 DVEBaseSlider 的范围内
            onSlider = YES;
        }
    }
    
    self.tableView.scrollEnabled = !onSlider;
    return view;
}

- (void)buildLayout
{
    [self addSubview:self.tableView];
    [self.tableView reloadData];
}


- (UITableView *)tableView
{
    if (!_tableView) {
        _tableView = ({
            UITableView *tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, VE_SCREEN_WIDTH, self.height) style:UITableViewStylePlain];
            tableView.delegate = self;
            tableView.dataSource = self;
            tableView.backgroundColor = HEXRGBCOLOR(0x181718);
            tableView.backgroundView = nil;
            tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
            tableView.separatorColor = [UIColor clearColor];
            tableView.estimatedRowHeight = 0;
            tableView.estimatedSectionHeaderHeight = 0;
            tableView.estimatedSectionFooterHeight = 0;
            tableView.scrollEnabled = YES;
            tableView.showsVerticalScrollIndicator = NO;
            [tableView registerClass:[DVETextBaseStyleCell class] forCellReuseIdentifier:DVETextBaseStyleCell.description];
            [tableView registerClass:[DVETextFontCell class] forCellReuseIdentifier:DVETextFontCell.description];
            [tableView registerClass:[DVETextColorCell class] forCellReuseIdentifier:DVETextColorCell.description];
            tableView;
        });
    }
    
    return _tableView;
}

#pragma mark - UITableViewDelegate & UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 3;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 1;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 0;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    
    return nil;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    return 0;
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section
{
    
    return nil;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = nil;
    
    
    switch (indexPath.section) {
        case 0:
        {
            DVETextBaseStyleCell *styleCell = [tableView dequeueReusableCellWithIdentifier:DVETextBaseStyleCell.description forIndexPath:indexPath];
            styleCell.selectStyleBlock = self.selectStyleBlock;
            styleCell.alignMentBlock = self.alignMentBlock;
            styleCell.vcContext = self.vcContext;
            cell = styleCell;
        }
            break;
        case 1:
        {
            DVETextFontCell *fontCell = [tableView dequeueReusableCellWithIdentifier:DVETextFontCell.description forIndexPath:indexPath];
            fontCell.fontBlock = self.fontBlock;
            fontCell.vcContext = self.vcContext;
            cell = fontCell;
        }
            break;
        case 2:
        {
            DVETextColorCell *colorCell = [tableView dequeueReusableCellWithIdentifier:DVETextColorCell.description forIndexPath:indexPath];
            colorCell.colorBlock = self.colorBlock;
            colorCell.vcContext = self.vcContext;
            cell = colorCell;
        }
            break;
            
        default:
            break;
    }
    
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    return cell;
}



- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    CGFloat height = 0;
    switch (indexPath.section) {
        case 0:
        {
            height = 60;
        }
            break;
        case 1:
        {
            height = 60;
        }
            break;
        case 2:
        {
            height = 321;
        }
            break;
            
        default: 
            break;
    }
    
    return height;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    
}



@end
