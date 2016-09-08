//
//  ViewController.m
//  WeChat
//
//  Created by Nico on 16/6/29.
//  Copyright © 2016年 Nico. All rights reserved.
//

#import "LogInViewController.h"
#import "TabBarViewController.h"
#import "RegisterViewController.h"
#import "XMPPTool.h"
#import "XMPPVCardTemp.h"
#import "MBProgressHUD+HM.h"

@interface LogInViewController ()<dismisRegisterController>
@property (weak, nonatomic) IBOutlet UITextField *userTextField;
@property (weak, nonatomic) IBOutlet UITextField *pwdTextField;
@property (weak, nonatomic) IBOutlet UIButton *loginButton;
- (IBAction)tapRegisterButton;

@end

@implementation LogInViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.loginButton addTarget:self action:@selector(login) forControlEvents:UIControlEventTouchUpInside];
    NSString *userStr=[[NSUserDefaults standardUserDefaults] objectForKey:@"user"];
    if (userStr!=nil) {
        self.userTextField.text=userStr;
        [self.pwdTextField becomeFirstResponder];
    }
    // Do any additional setup after loading the view, typically from a nib.
}

-(void)alertWithTitle:(NSString *)title
{
    UIAlertController *alert=[UIAlertController alertControllerWithTitle:title message:nil preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *action=[UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
    }];
    [alert addAction:action];
    [self presentViewController:alert animated:YES completion:nil];
}

-(void)login
{
    if (self.userTextField.text.length==0 || self.pwdTextField.text.length==0) {
        [self alertWithTitle:@"用户名或者密码不能为空！"];
        return;
    }
    
    [MBProgressHUD showMessage:@"登录中……" toView:self.view];
    __block XMPPTool *xmpptool=[XMPPTool shareXMPPTool];
    [xmpptool.xmppStream disconnect];
    xmpptool.isRegister=NO;
    NSString *user=self.userTextField.text;
    NSString *password=self.pwdTextField.text;
    [[NSUserDefaults standardUserDefaults] setObject:user forKey:@"user"];
    [[NSUserDefaults standardUserDefaults] setObject:password forKey:@"password"];
    
    [xmpptool userLogin:^(XMPPStatusType statustype) {
        __weak typeof(self) selfVC=self;
        switch (statustype) {
            case XMPPStatusTypeLoginSucess:
            {
                NSLog(@"current Thread:%@",[NSThread currentThread]);
                dispatch_async(dispatch_get_main_queue(), ^{
                    NSLog(@"current Thread:%@",[NSThread currentThread]);
                    [MBProgressHUD hideHUDForView:self.view animated:YES];
                    TabBarViewController *tbc=[TabBarViewController new];
                    UIWindow *window=[UIApplication sharedApplication].keyWindow;
                    window.rootViewController=tbc;
                    
                });
            }
                break;
            case XMPPStatusTypeLoginFailure:
            {
                dispatch_async(dispatch_get_main_queue(), ^{
                    [MBProgressHUD hideHUDForView:self.view animated:YES];
                    [selfVC alertWithTitle:@"帐号或者密码错误！"];
                    self.pwdTextField.text=nil;
                    [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"password"];
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
                [MBProgressHUD hideHUDForView:self.view animated:YES];
                [selfVC alertWithTitle:@"未知错误"];
            }
                break;
        }
    }];

}


#pragma mark --dismisRegisterController delegate
-(void)dismisRegisterController
{
    NSString *userStr=[[NSUserDefaults standardUserDefaults] objectForKey:@"user"];
    [self dismissViewControllerAnimated:YES completion:^{
        self.userTextField.text=userStr;
        self.pwdTextField.text=nil;
        [self.pwdTextField becomeFirstResponder];
    }];
}

- (IBAction)tapRegisterButton {
    RegisterViewController *registerViewController=[RegisterViewController new];
    registerViewController.delegate=self;
    [self presentViewController:registerViewController animated:YES completion:nil];
}
@end
