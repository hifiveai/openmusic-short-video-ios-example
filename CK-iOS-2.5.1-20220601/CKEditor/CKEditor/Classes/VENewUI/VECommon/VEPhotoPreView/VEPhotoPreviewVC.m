//
//  VEPhotoPreviewVC.m
//  TTVideoEditorDemo
//
//  Created by bytedance on 2020/12/20
//  Copyright © 2021 bytedance. All rights reserved.
//

#import "VEPhotoPreviewVC.h"
#import <NLEEditor/DVEUIFactory.h>
#import "UIButton+layout.h"
#import "VECustomerHUD.h"
#import "VEResourcePicker.h"
#import "VENLEEditorServiceContainer.h"
#import <NLEEditor/DVEViewController.h>

@interface VEPhotoPreviewVC ()

@property (nonatomic, strong)  UIImageView *imageView;
@property (nonatomic, strong) UIButton *backButton;
@property (nonatomic, strong) UIButton *saveButton;
@property (nonatomic, strong) UIButton *editButton;
@end

@implementation VEPhotoPreviewVC

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    self.imageView.image = self.image;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [self buildLayout];
    @weakify(self);
    [[self.saveButton rac_signalForControlEvents:UIControlEventTouchUpInside] subscribeNext:^(__kindof UIControl * _Nullable x) {
        @strongify(self);
        [self saveMethod];
    }];
    
    [[self.backButton rac_signalForControlEvents:UIControlEventTouchUpInside] subscribeNext:^(__kindof UIControl * _Nullable x) {
        @strongify(self);
        [self backMethod];
    }];
    
    [[self.editButton rac_signalForControlEvents:UIControlEventTouchUpInside] subscribeNext:^(__kindof UIControl * _Nullable x) {
        @strongify(self);
        [self editMethod];
    }];
}

- (void)backMethod
{
    [self.navigationController popViewControllerAnimated:NO];
//    [self dismissViewControllerAnimated:YES completion:^{
//
//    }];
}

- (void)saveMethod
{
    UIImageWriteToSavedPhotosAlbum(self.image, self, @selector(image:didFinishSavingWithError:contextInfo:), nil);
}

- (void)image:(UIImage *)image didFinishSavingWithError:(NSError *)error contextInfo:(void *)contextInfo;
{
    if (error) {
        [VECustomerHUD showMessage:[NSString stringWithFormat:@"%@",error.description]];
    } else {
        [VECustomerHUD showMessage:@"保存成功"];
    }
    
}

- (void)editMethod
{
    VEResourcePickerModel *model = [VEResourcePickerModel new];
    model.type = DVEResourceModelPickerTypeImage;
    model.image = self.image;
    
    UIViewController* vc = [DVEUIFactory createDVEViewControllerWithResources:@[model] injectService:[VENLEEditorServiceContainer new]];
    vc.modalPresentationStyle = UIModalPresentationFullScreen;
    [self.navigationController pushViewController:vc animated:NO];
//    [self presentViewController:vc animated:YES completion:^{
//    }];
    
}

- (void)buildLayout
{
    [self.view addSubview:self.imageView];
    [self.view addSubview:self.saveButton];
    [self.view addSubview:self.backButton];
    [self.view addSubview:self.editButton];
    
    self.editButton.center = CGPointMake(VE_SCREEN_WIDTH * 0.5, VE_SCREEN_HEIGHT - 100);
    self.backButton.centerY = self.editButton.centerY;
    self.saveButton.centerY = self.backButton.centerY;
    self.backButton.left = 30;
    self.saveButton.right = VE_SCREEN_WIDTH - 30;
}

- (UIImageView *)imageView
{
    if (!_imageView) {
        _imageView = [[UIImageView alloc] initWithFrame:self.view.bounds];
        _imageView.contentMode = UIViewContentModeScaleAspectFit;
        _imageView.backgroundColor = HEXRGBCOLOR(0x181718);
    }
    
    return _imageView;
}

- (UIButton *)backButton
{
    if (!_backButton) {
        _backButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 60, 60)];
        [_backButton setTitle:@"返回" forState:UIControlStateNormal];
        [_backButton setImage:@"icon_vecommon_back".UI_VEToImage forState:UIControlStateNormal];
        [_backButton VElayoutWithType:VEButtonLayoutTypeImageTop space:5];
        _backButton.titleLabel.font = SCRegularFont(12);
    }
    
    return _backButton;
}

- (UIButton *)saveButton
{
    if (!_saveButton) {
        _saveButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 60, 60)];
        [_saveButton setTitle:CKEditorLocStringWithKey(@"ck_save", @"保存")  forState:UIControlStateNormal];
        [_saveButton setImage:@"icon_vecommon_save".UI_VEToImage forState:UIControlStateNormal];
        [_saveButton VElayoutWithType:VEButtonLayoutTypeImageTop space:5];
        _saveButton.titleLabel.font = SCRegularFont(12);
    }
    
    return _saveButton;
}

- (UIButton *)editButton
{
    if (!_editButton) {
        _editButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 60, 60)];
        [_editButton setTitle:CKEditorLocStringWithKey(@"ck_import_editing",@"导入剪辑") forState:UIControlStateNormal];
        [_editButton setImage:@"icon_vecommon_edit".UI_VEToImage forState:UIControlStateNormal];
        [_editButton VElayoutWithType:VEButtonLayoutTypeImageTop space:5];
        _editButton.titleLabel.font = SCRegularFont(12);
    }
    
    return _editButton;
}

@end
