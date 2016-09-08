//
//  ProfileController.m
//  WeChat
//
//  Created by Nico on 16/6/30.
//  Copyright © 2016年 Nico. All rights reserved.
//

#import "ProfileController.h"
#import "XMPPTool.h"
#import "LogInViewController.h"
#import "ProfieldSettingController.h"
#import "XMPPvCardTemp.h"
#import "UIImage+Resize.h"
@interface ProfileController ()<UITableViewDelegate,UITableViewDataSource,UIImagePickerControllerDelegate,UINavigationControllerDelegate,SaveTheChange>
@property (weak, nonatomic) IBOutlet UIImageView *avatarImage;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (strong,nonatomic)NSMutableArray *arr;
@property (nonatomic,weak)UIImagePickerController *ipc;
@property (strong,nonatomic)XMPPTool *xmppTool;
@property (strong,nonatomic)XMPPvCardTemp *myCard;

- (IBAction)tapLogOut:(id)sender;
@end

@implementation ProfileController

- (void)viewDidLoad {
    [super viewDidLoad];
    _arr=[NSMutableArray new];
    self.tableView.delegate=self;
    self.tableView.dataSource=self;
    self.tableView.scrollEnabled=NO;
    self.navigationItem.title=@"我";

    _xmppTool=[XMPPTool shareXMPPTool];
    _myCard=_xmppTool.vCard.myvCardTemp;
    [self setDataSourceWithVCard:_myCard];
    
}

-(void)setDataSourceWithVCard:(XMPPvCardTemp *)vCard
{
    if (vCard.photo.length) {
        self.avatarImage.image=[UIImage imageWithData:vCard.photo];
    }else
    {
        self.avatarImage.image=[UIImage imageNamed:@"DefaultProfileHead_phone"];
    }
    
    NSMutableDictionary *nicnameDic=[NSMutableDictionary new];
    [nicnameDic setObject:@"昵称" forKey:@"title"];
    if (vCard.nickname!=nil) {
        [nicnameDic setObject:vCard.nickname forKey:@"subTitle"];
    }
    
    [_arr addObject:nicnameDic];
    
    NSMutableDictionary *jidDic=[NSMutableDictionary new];
    [jidDic setObject:@"帐号" forKey:@"title"];
    
    if ([_xmppTool.userInfo jidStr]!=nil) {
        [jidDic setObject:[_xmppTool.userInfo jidStr] forKey:@"subTitle"];
    }
    
    [_arr addObject:jidDic];
    
    NSMutableDictionary *mailerDic=[NSMutableDictionary new];
    if (vCard.mailer!=nil) {
        [mailerDic setObject:vCard.mailer forKey:@"subTitle"];
    }
    [mailerDic setObject:@"邮箱" forKey:@"title"];
    
    [_arr addObject:mailerDic];
}


-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    UIButton *avatarButton=[[UIButton alloc]init];
    avatarButton.frame=self.avatarImage.frame;
    [avatarButton addTarget:self action:@selector(editAvatar) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:avatarButton];
}

-(void)alertWithTitle:(NSString *)title
{
    UIAlertController *alert=[UIAlertController alertControllerWithTitle:title message:nil preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *action=[UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
    }];
    [alert addAction:action];
    [self presentViewController:alert animated:YES completion:nil];
}

-(void)editAvatar
{
    UIAlertController *alertVC=[UIAlertController alertControllerWithTitle:nil message:nil preferredStyle:UIAlertControllerStyleActionSheet];
    __block UIImagePickerController *ipc=[UIImagePickerController new];
    self.ipc=ipc;
    ipc.delegate=self;
    ipc.allowsEditing=YES;
    
    __weak typeof(self) selfVC=self;
    UIAlertAction *takePhotoAction=[UIAlertAction actionWithTitle:@"拍照" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        if ([UIImagePickerController isCameraDeviceAvailable:UIImagePickerControllerCameraDeviceRear]) {
            ipc.sourceType=UIImagePickerControllerSourceTypeCamera;
            [selfVC presentViewController:ipc animated:YES completion:nil];
        }else
        {
            [selfVC alertWithTitle:@"摄像头不可用"];
        }
        
        
    }];
    UIAlertAction *selectPhotoAction=[UIAlertAction actionWithTitle:@"从相册选择" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        ipc.sourceType=UIImagePickerControllerSourceTypePhotoLibrary;
        [selfVC presentViewController:ipc animated:YES completion:nil];
    }];
    UIAlertAction *cancelAction=[UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleDefault handler:nil];
    [alertVC addAction:takePhotoAction];
    [alertVC addAction:selectPhotoAction];
    [alertVC addAction:cancelAction];
    [self presentViewController:alertVC animated:YES completion:nil];
    
}

#pragma mark --imagePicker delegate
-(void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary<NSString *,id> *)info
{
    UIImage *editeImage=info[UIImagePickerControllerEditedImage];
    NSData *data=UIImageJPEGRepresentation(editeImage, 0.8);
    XMPPTool *xmppTool=[XMPPTool shareXMPPTool];
    XMPPvCardTemp *myCard=xmppTool.vCard.myvCardTemp;
    myCard.photo=data;
    self.avatarImage.image=editeImage;
    [xmppTool.vCard updateMyvCardTemp:myCard];
    [self dismissViewControllerAnimated:YES completion:nil];
}


#pragma mark --tableView datasource
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return _arr.count;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *identifier=@"cell";
    UITableViewCell *cell=[tableView dequeueReusableCellWithIdentifier:identifier];
    if (!cell) {
        cell=[[UITableViewCell alloc]initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:identifier];
    }
    
    NSDictionary *dic=self.arr[indexPath.row];
    cell.textLabel.text=dic[@"title"];
    cell.detailTextLabel.text=dic[@"subTitle"];
    if (indexPath.row!=1) {
        cell.accessoryType=UITableViewCellAccessoryDisclosureIndicator;
    }else
    {
        cell.selectionStyle=UITableViewCellSelectionStyleNone;
    }
    
    return cell;
}

#pragma mark --tableView delegate
-(NSIndexPath *)tableView:(UITableView *)tableView willSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row==1) {
        return nil;
    }else
        return indexPath;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    ProfieldSettingController *psc=[ProfieldSettingController new];
    NSDictionary *dic=self.arr[indexPath.row];
    psc.navigationItem.title=dic[@"title"];
    NSString *str=dic[@"subTitle"];
    psc.text=str;
    psc.delegate=self;
    [self.navigationController pushViewController:psc animated:YES];
}


- (IBAction)tapLogOut:(id)sender {
    
    XMPPTool *xmppTool=[XMPPTool shareXMPPTool];
    [xmppTool userLogout];
    LogInViewController *logInViewController=[LogInViewController new];
    UIWindow *window=[UIApplication sharedApplication].keyWindow;
    window.rootViewController=logInViewController;
}

#pragma mark delegate
-(void)saveTheChangeWithTitle:(NSString *)title Text:(NSString *)text
{
    if ([title isEqualToString:@"昵称"]) {
        NSMutableDictionary *dic=self.arr[0];
        [dic setValue:text forKey:@"subTitle"];
        _myCard.nickname=text;
    }else if([title isEqualToString:@"邮箱"]){
        NSMutableDictionary *dic=self.arr[2];
        [dic setValue:text forKey:@"subTitle"];
        _myCard.mailer=text;
    }
    [_xmppTool.vCard updateMyvCardTemp:_myCard];
    [self.tableView reloadData];
//    [self.navigationController.presentedViewController.navigationController popViewControllerAnimated:YES];

}
@end


