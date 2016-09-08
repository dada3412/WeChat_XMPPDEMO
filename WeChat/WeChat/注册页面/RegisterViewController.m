//
//  RegisterViewController.m
//  WeChat
//
//  Created by Nico on 16/7/1.
//  Copyright © 2016年 Nico. All rights reserved.
//

#import "RegisterViewController.h"
#import "XMPPTool.h"
#import "XMPPVCardTemp.h"
#import "MBProgressHUD+HM.h"

@interface RegisterViewController ()
@property (weak, nonatomic) IBOutlet UITextField *userTestFile;
@property (weak, nonatomic) IBOutlet UITextField *pwdTextFiled;
@property (weak, nonatomic) IBOutlet UITextField *pwdConfirmTextFiled;

- (IBAction)tapReturnButton:(id)sender;
- (IBAction)tapConfirmRegisterButton;
@end

@implementation RegisterViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)alertWithTitle:(NSString *)title
{
    UIAlertController *alert=[UIAlertController alertControllerWithTitle:title message:nil preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *action=[UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
    }];
    [alert addAction:action];
    [self presentViewController:alert animated:YES completion:nil];
}

- (IBAction)tapReturnButton:(id)sender {
    if ([self.delegate respondsToSelector:@selector(dismisRegisterController)]) {
        [self.delegate dismisRegisterController];
    }
}

- (IBAction)tapConfirmRegisterButton
{
    if (self.userTestFile.text.length==0 || self.pwdTextFiled.text.length==0) {
        [self alertWithTitle:@"请输入用户名和密码"];
        return;
    }
    
    if (![self.pwdTextFiled.text isEqualToString:self.pwdConfirmTextFiled.text]) {
        [self alertWithTitle:@"密码不一致"];
        self.pwdConfirmTextFiled.text=nil;
        self.pwdTextFiled.text=nil;
        return;
    }
    
    [MBProgressHUD showMessage:@"注册中"];
    XMPPTool *xmppTool=[XMPPTool shareXMPPTool];
    [xmppTool.xmppStream disconnect];
    xmppTool.isRegister=YES;
    NSString *newUser=self.userTestFile.text;
    NSString *newPassword=self.pwdTextFiled.text;
    [[NSUserDefaults standardUserDefaults] setObject:newUser forKey:@"newUser"];
    [[NSUserDefaults standardUserDefaults] setObject:newPassword forKey:@"newPassword"];
    [xmppTool userRegister:^(XMPPStatusType statustype) {
        __weak typeof(self) selfVC=self;
        switch (statustype) {
            case XMPPStatusTypeRegisterSucess:
            {
                dispatch_async(dispatch_get_main_queue(), ^{
                    [MBProgressHUD hideHUDForView:self.view animated:YES];
                    UIAlertController *alertVC=[UIAlertController alertControllerWithTitle:@"注册成功,请登录" message:nil preferredStyle:UIAlertControllerStyleAlert];
                    UIAlertAction *action=[UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                            [self.delegate dismisRegisterController];
                    }];
                    [alertVC addAction:action];
                    [self presentViewController:alertVC animated:YES completion:nil];

                });
            }
                break;
            case XMPPStatusTypeRegisterFailure:
            {
                dispatch_async(dispatch_get_main_queue(), ^{
                    [MBProgressHUD hideHUDForView:self.view animated:YES];
                    [selfVC alertWithTitle:@"注册失败"];
                    self.userTestFile.text=nil;
                    self.pwdTextFiled.text=nil;
                    self.pwdConfirmTextFiled.text=nil;
                });
            }
                break;
            case XMPPStatusTypeNetErr:
            {
                dispatch_async(dispatch_get_main_queue(), ^{
                    [MBProgressHUD hideHUDForView:self.view animated:YES];
                    [selfVC alertWithTitle:@"无法连接到服务器"];
                });
            }
                break;
                
            default:
            {
                dispatch_async(dispatch_get_main_queue(), ^{
                    [MBProgressHUD hideHUDForView:self.view animated:YES];
                    [selfVC alertWithTitle:@"未知错误"];
                });
            }
                break;
        }

        
    }];
}

@end
