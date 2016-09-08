//
//  ProfieldSettingController.m
//  WeChat
//
//  Created by Nico on 16/7/8.
//  Copyright © 2016年 Nico. All rights reserved.
//

#import "ProfieldSettingController.h"
#import "ProfileController.h"
#import "XMPPTool.h"
@interface ProfieldSettingController ()<UITextFieldDelegate>


@end

@implementation ProfieldSettingController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.settingTextField.text=self.text;
    self.settingTextField.delegate=self;
    self.settingTextField.returnKeyType=UIReturnKeyDone;
    self.settingTextField.enablesReturnKeyAutomatically=YES;
    self.settingTextField.clearButtonMode=UITextFieldViewModeWhileEditing;
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(textFieldDidChange) name:UITextFieldTextDidChangeNotification object:nil];
    UIBarButtonItem *bbi=[[UIBarButtonItem alloc] initWithTitle:@"保存" style:UIBarButtonItemStylePlain target:self action:@selector(tapSaveButton)];
    self.navigationItem.rightBarButtonItem=bbi;
    [bbi setEnabled:NO];
    // Do any additional setup after loading the view from its nib.
}

-(void)tapSaveButton
{
    if ([self.delegate respondsToSelector:@selector(saveTheChangeWithTitle: Text:)]) {
        [self.delegate saveTheChangeWithTitle:self.navigationItem.title Text:self.settingTextField.text];
    }
    [self.navigationController popViewControllerAnimated:YES];
}

-(void)textFieldDidChange
{
    if ([self.settingTextField.text isEqualToString:self.text]||self.settingTextField.text.length==0) {
        [self.navigationItem.rightBarButtonItem setEnabled:NO];
        
    }else
        [self.navigationItem.rightBarButtonItem setEnabled:YES];

}

#pragma mark textField Delegate
-(BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    if (![self.settingTextField.text isEqualToString:self.text]) {
        [self tapSaveButton];
    }
    return YES;
}

-(BOOL)textFieldShouldEndEditing:(UITextField *)textField
{
    return YES;
}

-(void)textFieldDidEndEditing:(UITextField *)textField
{
    NSLog(@"%s",__func__);
}



@end
