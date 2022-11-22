//
//  UIView+ACCMasonry.m
//  CutSameIF
//
//  Created by bytedance on 2020/8/25.
//

#import "UIView+DVEAlbumMasonry.h"

#import <Masonry/MASConstraintMaker.h>

@implementation UIView (DVEAlbumMasonry)

- (MASConstraintMaker *)acc_makeConstraint
{
    self.translatesAutoresizingMaskIntoConstraints = NO;
    MASConstraintMaker *constraintMaker = [[MASConstraintMaker alloc] initWithView:self];
    return constraintMaker;
}

- (MASConstraintMaker *)acc_updateConstraint
{
    self.translatesAutoresizingMaskIntoConstraints = NO;
    MASConstraintMaker *constraintMaker = [[MASConstraintMaker alloc] initWithView:self];
    constraintMaker.updateExisting = YES;
    return constraintMaker;
}

- (MASConstraintMaker *)acc_remakeConstraint
{
    self.translatesAutoresizingMaskIntoConstraints = NO;
    MASConstraintMaker *constraintMaker = [[MASConstraintMaker alloc] initWithView:self];
    constraintMaker.removeExisting = YES;
    return constraintMaker;
}

@end
