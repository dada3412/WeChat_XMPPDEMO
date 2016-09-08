//
//  userDetailController.m
//  WeChat
//
//  Created by Nico on 16/7/9.
//  Copyright © 2016年 Nico. All rights reserved.
//

#import "UserDetailController.h"
#import "XMPPTool.h"
#import "LogInViewController.h"
#import "ProfieldSettingController.h"
#import "XMPPvCardTemp.h"
#import "ChatViewController.h"


@interface UserDetailController ()<UITableViewDelegate,UITableViewDataSource>
@property (weak, nonatomic) IBOutlet UIImageView *avatarImage;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UIButton *confirmButton;

@property (strong,nonatomic)NSMutableArray *arr;

@property (strong,nonatomic)XMPPTool *xmppTool;

@end

@implementation UserDetailController

- (void)viewDidLoad {
    [super viewDidLoad];
    _arr=[NSMutableArray new];
    self.tableView.delegate=self;
    self.tableView.dataSource=self;
    self.tableView.scrollEnabled=NO;
    self.navigationItem.title=@"我";
    if (self.isAddFriend) {
        [self.confirmButton setTitle:@"添加好友" forState:UIControlStateNormal];
    }else
        [self.confirmButton setTitle:@"发送消息" forState:UIControlStateNormal];
    
    [self.confirmButton addTarget:self action:@selector(tapConfirmButton) forControlEvents:UIControlEventTouchUpInside];
    
    _xmppTool=[XMPPTool shareXMPPTool];
    XMPPJID *jid=[XMPPJID jidWithString:self.jidStr];
    [_xmppTool.vCard fetchvCardTempForJID:jid ignoreStorage:YES];
    XMPPvCardTemp *vCard=[_xmppTool.vCard vCardTempForJID:jid shouldFetch:YES];
    [self setDataSourceWithVCard:vCard];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(vCardTempDidChange:) name:XMPPReceivevCardTempNotification object:nil];
    
}

-(void)setDataSourceWithVCard:(XMPPvCardTemp *)vCard
{
    if (vCard.photo.length!=0) {
        self.avatarImage.image=[UIImage imageWithData:vCard.photo];
    }
    [_arr removeAllObjects];
    NSMutableDictionary *nicnameDic=[NSMutableDictionary new];
    [nicnameDic setObject:@"昵称" forKey:@"title"];
    if (vCard.nickname!=nil) {
        [nicnameDic setObject:vCard.nickname forKey:@"subTitle"];
    }
    
    [_arr addObject:nicnameDic];
    
    NSMutableDictionary *jidDic=[NSMutableDictionary new];
    [jidDic setObject:@"帐号" forKey:@"title"];
    
    if (self.jidStr) {
        [jidDic setObject:self.jidStr forKey:@"subTitle"];
    }
    
    [_arr addObject:jidDic];
    
    NSMutableDictionary *mailerDic=[NSMutableDictionary new];
    if (vCard.mailer!=nil) {
        [mailerDic setObject:vCard.mailer forKey:@"subTitle"];
    }
    [mailerDic setObject:@"邮箱" forKey:@"title"];
    
    [_arr addObject:mailerDic];
}

-(void)vCardTempDidChange:(NSNotification *)notification
{
    NSDictionary *dic=notification.userInfo;
    XMPPvCardTemp *vCard=dic[@"vCardTemp"];
    [self setDataSourceWithVCard:vCard];
    [self.tableView reloadData];
}

-(void)tapConfirmButton
{
    XMPPJID *jid=[XMPPJID jidWithString:self.jidStr];
    if (self.isAddFriend) {
        NSString *myJIDStr=_xmppTool.userInfo.jidStr;
        if ([self.jidStr isEqualToString:myJIDStr]) {
            [self alertWithTitle:@"无法添加自己为好友"];
            return;
        }
        
        if ([_xmppTool.roster.xmppRosterStorage userExistsWithJID:jid xmppStream:_xmppTool.xmppStream]) {
            [self alertWithTitle:@"好友已存在"];
            return;
        }
        [_xmppTool.roster subscribePresenceToUser:jid];
        return;
    }else
    {
        ChatViewController *cvc=[ChatViewController new];
        cvc.jidStr=self.jidStr;
        [self.navigationController pushViewController:cvc animated:YES];
    }
    
    
}

-(void)alertWithTitle:(NSString *)title
{
    UIAlertController *alert=[UIAlertController alertControllerWithTitle:title message:nil preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *action=[UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
    }];
    [alert addAction:action];
    [self presentViewController:alert animated:YES completion:nil];
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

    cell.selectionStyle=UITableViewCellSelectionStyleNone;

    return cell;
}





-(void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:XMPPReceivevCardTempNotification object:nil];
}
@end
