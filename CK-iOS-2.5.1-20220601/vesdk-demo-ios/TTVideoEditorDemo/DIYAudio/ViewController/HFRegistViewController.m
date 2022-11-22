//
//  HFRegistViewController.m
//  TTVideoEditorDemo
//
//  Created by ly on 2022/8/2.
//  Copyright © 2022 bytedance. All rights reserved.
//

#import "HFRegistViewController.h"
#import <HFOpenApi/HFOpenApi.h>
#import "DVECustomerHUD.h"
#import "HFPlayerConfigManager.h"

@interface HFRegistViewController ()
@property (weak, nonatomic) IBOutlet UITextField *appIdTextF;
@property (weak, nonatomic) IBOutlet UITextField *serverTextFiled;
@property (weak, nonatomic) IBOutlet UITextField *clientId;
@property (weak, nonatomic) IBOutlet UIButton *nextBtn;

@end

@implementation HFRegistViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.nextBtn.layer.cornerRadius = 8;
    // Do any additional setup after loading the view from its nib.
}
- (IBAction)nextBtnAction:(UIButton *)sender {
    __weak typeof(self) weakSelf = self;
    [[HFOpenApiManager shared] registerAppWithAppId:self.appIdTextF.text serverCode:self.serverTextFiled.text clientId:self.clientId.text version:@"V4.2.0" success:^(id  _Nullable response) {
        NSLog(@"注册成功");
        //静默登录
        [[HFOpenApiManager shared] baseLoginWithNickname:weakSelf.clientId.text gender:nil birthday:nil location:nil education:nil profession:nil isOrganization:false reserve:nil favoriteSinger:nil favoriteGenre:nil success:^(id  _Nullable response) {
            NSLog(@"登录成功");
            [HFPlayerConfigManager shared].isRegister = YES;
            [weakSelf dismissViewControllerAnimated:YES completion:^{
                if (weakSelf.loginSuccessBlock) {
                    weakSelf.loginSuccessBlock();
                }
            }];
        } fail:^(NSError * _Nullable error) {
            [DVECustomerHUD showMessage:error.localizedDescription];
        }];
       
        
    } fail:^(NSError * _Nullable error) {
        NSLog(@"注册失败");
        [DVECustomerHUD showMessage:error.localizedDescription];
        
    }];
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [super touchesBegan:touches withEvent:event];
    [self.view endEditing:YES];
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
