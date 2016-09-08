//
//  XMPPTool.m
//  WeChat
//
//  Created by Nico on 16/6/30.
//  Copyright © 2016年 Nico. All rights reserved.
//

#import "XMPPTool.h"
#import "XMPPVCardTemp.h"


NSString *const XMPPReceivevCardTempNotification=@"ReceivevCardTempNotification";
NSString *const XMPPReceivePresenceSubscriptionRequest=@"ReceivePresenceSubscriptionRequest";
NSString *const XMPPConnectionStatusNotification=@"ConnectionStatus";

@interface XMPPTool ()<XMPPStreamDelegate,XMPPvCardTempModuleDelegate,XMPPRosterDelegate>{
    XMPPvCardCoreDataStorage *_vCardStorage;
    XMPPvCardAvatarModule *_avatar;
    XMPPStatusBlock _statusBlock;
    XMPPReconnect *_reconnect;
}

@end

@implementation XMPPTool

static XMPPTool *xmppTool=nil;

+(instancetype)allocWithZone:(struct _NSZone *)zone
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        xmppTool=[super allocWithZone:zone];
    });
    return xmppTool;
}

+(instancetype)shareXMPPTool
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        xmppTool=[[self alloc]init];
    });
    return xmppTool;
}

-(instancetype)init
{
    self=[super init];
    [self setupXMPPStream];
    return self;
}


-(void)setupXMPPStream
{
    _presenceRequestArr=[[NSMutableArray alloc] init];
    if (!_xmppStream) {
        _xmppStream=[[XMPPStream alloc]init];
    }
    _xmppStream.enableBackgroundingOnSocket=YES;
    [_xmppStream addDelegate:self delegateQueue:dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)];
    
    //vcard
    _vCardStorage=[XMPPvCardCoreDataStorage sharedInstance];
    _vCard=[[XMPPvCardTempModule alloc]initWithvCardStorage:_vCardStorage];
    [_vCard activate:_xmppStream];
    [_vCard addDelegate:self delegateQueue:dispatch_get_main_queue()];
    
    _avatar=[[XMPPvCardAvatarModule alloc]initWithvCardTempModule:_vCard];
    [_avatar activate:_xmppStream];
    
    //roster
    _rosterStorage=[XMPPRosterCoreDataStorage sharedInstance];
    _roster=[[XMPPRoster alloc]initWithRosterStorage:_rosterStorage];
    _roster.autoAcceptKnownPresenceSubscriptionRequests=NO;
    [_roster addDelegate:self delegateQueue:dispatch_get_main_queue()];
    [_roster activate:_xmppStream];
    
    //message
    _messageStorage=[XMPPMessageArchivingCoreDataStorage sharedInstance];
    _message=[[XMPPMessageArchiving alloc]initWithMessageArchivingStorage:_messageStorage];
    [_message activate:_xmppStream];
    
    //reconnect
    _reconnect=[[XMPPReconnect alloc]init];
    _reconnect.autoReconnect=YES;
    [_reconnect activate:_xmppStream];
}

-(void)teardownXMPP
{
    [_xmppStream removeDelegate:self];
    
    [_vCard removeDelegate:self];
    [_vCard deactivate];
    
    [_avatar deactivate];
    
    [_roster removeDelegate:self];
    [_roster deactivate];
    
    [_message deactivate];
    [_reconnect deactivate];
    
    [_xmppStream disconnect];
    
    _reconnect=nil;
    _vCard=nil;
    _vCardStorage=nil;
    _avatar=nil;
    _roster=nil;
    _rosterStorage=nil;
    _xmppStream=nil;
}

-(UserInfo *)userInfo
{
    if (!_userInfo) {
        _userInfo=[UserInfo new];
    }
    return _userInfo;
}

-(void)postConnectionStatusNotification:(XMPPStatusType)statusType
{
    NSDictionary *info=[NSDictionary dictionaryWithObject:@(statusType) forKey:@"status"];
    [[NSNotificationCenter defaultCenter] postNotificationName:XMPPConnectionStatusNotification object:nil userInfo:info];
}

-(void)connect
{
    if ([self.xmppStream isConnected]) {
        return;
    }
    
    NSString *domain=DOMAIN_NAME;
    self.userInfo.domain=domain;
    if (self.isRegister) {
        self.userInfo.user=[[NSUserDefaults standardUserDefaults] objectForKey:@"newUser"];
    }else
        self.userInfo.user=[[NSUserDefaults standardUserDefaults] objectForKey:@"user"];
    XMPPJID *jid=[XMPPJID jidWithUser:self.userInfo.user domain:domain resource:@"Iphone"];
    self.xmppStream.myJID=jid;
    self.xmppStream.hostName=@"192.168.31.207";
    self.xmppStream.hostPort=5222;
    
    NSError *err=nil;
    if (![_xmppStream connectWithTimeout:XMPPStreamTimeoutNone error:&err]) {
        NSLog(@"error:%@",err);
    }
}


#pragma mark --XMPPStream Delegate

//连接到服务器成功
-(void)xmppStreamWillConnect:(XMPPStream *)sender
{
    [self postConnectionStatusNotification:XMPPStatusTypeConnecting];
}

-(void)xmppStreamDidConnect:(XMPPStream *)sender
{
    if (self.isRegister) {
        self.userInfo.password=[[NSUserDefaults standardUserDefaults] objectForKey:@"newPassword"];
    }else
        self.userInfo.password=[[NSUserDefaults standardUserDefaults] objectForKey:@"password"];
    __block NSError *err=nil;
    
    if (self.isRegister) {
        if (![_xmppStream registerWithPassword:self.userInfo.password error:&err]) {
            NSLog(@"%@",err);
        }
    }else{
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            if (![_xmppStream authenticateWithPassword:self.userInfo.password error:&err]) {
                NSLog(@"%@",err);
            }
        });
        
    }
    
}

//连接到服务器失败
-(void)xmppStreamDidDisconnect:(XMPPStream *)sender withError:(NSError *)error
{
    [self postConnectionStatusNotification:XMPPStatusTypeNetErr];
    if (_statusBlock && error) {
        _statusBlock(XMPPStatusTypeNetErr);
        _statusBlock=nil;
    }

}

//登录成功
-(void)xmppStreamDidAuthenticate:(XMPPStream *)sender
{
    [self postConnectionStatusNotification:XMPPStatusTypeLoginSucess];
    [[NSUserDefaults standardUserDefaults] setObject:@"yes" forKey:@"isLogin"];
    XMPPPresence *xmppPresence=[XMPPPresence presence];
    [_xmppStream sendElement:xmppPresence];

    if (_statusBlock) {
        _statusBlock(XMPPStatusTypeLoginSucess);
        _statusBlock=nil;
    }
}


//登录失败
-(void)xmppStream:(XMPPStream *)sender didNotAuthenticate:(DDXMLElement *)error
{
    [self postConnectionStatusNotification:XMPPStatusTypeLoginFailure];
    [[NSUserDefaults standardUserDefaults] setObject:@"no" forKey:@"isLogin"];
    if (_statusBlock) {
        _statusBlock(XMPPStatusTypeLoginFailure);
        _statusBlock=nil;
    }
}

//注册成功
-(void)xmppStreamDidRegister:(XMPPStream *)sender
{
    NSString *newUser=[[NSUserDefaults standardUserDefaults] objectForKey:@"newUser"];
    [[NSUserDefaults standardUserDefaults] setObject:newUser forKey:@"user"];
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"password"];
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"newUser"];
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"newPassword"];
    
    //将前缀设置成默认的昵称
    
    [self.vCard updateMyvCardTemp:self.vCard.myvCardTemp];
    NSLog(@"my:%@",newUser);
    if (_statusBlock) {
        _statusBlock(XMPPStatusTypeRegisterSucess);
        _statusBlock=nil;
    }
}

//注册失败
-(void)xmppStream:(XMPPStream *)sender didNotRegister:(DDXMLElement *)error
{
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"password"];
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"newUser"];
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"newPassword"];
    if (_statusBlock) {
        _statusBlock(XMPPStatusTypeRegisterFailure);
        _statusBlock=nil;
    }
}

//收到消息
-(void)xmppStream:(XMPPStream *)sender didReceiveMessage:(XMPPMessage *)message
{
    XMPPJID *senderJID=sender.myJID;
    XMPPvCardTemp *senderVcard=[_vCard vCardTempForJID:senderJID shouldFetch:YES];
    if ([UIApplication sharedApplication].applicationState!=UIApplicationStateActive) {
        UILocalNotification *localNotification=[[UILocalNotification alloc] init];
        NSString *userName;
        if (senderVcard.nickname.length==0) {
            userName=[NSString stringWithFormat:@"%@@%@",senderJID.user,senderJID.domain];
        }else
            userName=senderVcard.nickname;
        if (![[[message attributeForName:@"bodyType"] stringValue] isEqualToString:@"image"]) {
            localNotification.alertBody=[NSString stringWithFormat:@"%@: %@",userName,message.body];
        }else
        {
            localNotification.alertBody=[NSString stringWithFormat:@"%@: [图片]",userName];
        }
        localNotification.fireDate=[NSDate date];
        localNotification.soundName=@"default";
        
        //执行
        [[UIApplication sharedApplication] scheduleLocalNotification:localNotification];
    }
    
}



#pragma mark --XMPPRoster Delegate
//接收到好友申请
-(void)xmppRoster:(XMPPRoster *)sender didReceivePresenceSubscriptionRequest:(XMPPPresence *)presence
{
    if (![presence.type isEqualToString:@"subscribe"]) {
        return;
    }
    

    XMPPUserCoreDataStorageObject *obj=[_rosterStorage userForJID:presence.from xmppStream:_xmppStream managedObjectContext:_rosterStorage.mainThreadManagedObjectContext];
    if (obj==nil) {
        NSString *jidStr=presence.fromStr;
        
        for (NSString *str in _presenceRequestArr) {
            if ([jidStr isEqualToString:str]) {
                return;
            }
        }
        [_presenceRequestArr addObject:jidStr];
        [[NSNotificationCenter defaultCenter] postNotificationName:XMPPReceivePresenceSubscriptionRequest object:nil];
        return;
    }
    
    if ([obj.subscription isEqualToString:@"to"]) {
        [_roster acceptPresenceSubscriptionRequestFrom:presence.from andAddToRoster:YES];
        [self sendMsgToUser:presence.from WithText:@"我们已经是好友，可以开始聊天。" bodyType:@"text"];
        
    }
    
}


#pragma mark XMPPvCardTempModuleDelegate
- (void)xmppvCardTempModule:(XMPPvCardTempModule *)vCardTempModule
        didReceivevCardTemp:(XMPPvCardTemp *)vCardTemp
                     forJID:(XMPPJID *)jid;
{
    NSDictionary *infoDic=[NSDictionary dictionaryWithObjectsAndKeys:vCardTemp,@"vCardTemp",jid,@"jid", nil ];
    [[NSNotificationCenter defaultCenter] postNotificationName:XMPPReceivevCardTempNotification object:nil userInfo:infoDic];
}

#pragma  mark 公共接口方法
-(void)userLogin:(XMPPStatusBlock) statusBlock
{
    _statusBlock=statusBlock;
    self.isRegister=NO;
    [self connect];
}

-(void)userLogout
{
    [[NSUserDefaults standardUserDefaults] setObject:@"no" forKey:@"isLogin"];
    XMPPPresence *offline=[XMPPPresence presenceWithType:@"unavailable"];
    [_xmppStream sendElement:offline];
    [_xmppStream disconnect];
    [_presenceRequestArr removeAllObjects];
}

-(void)userRegister:(XMPPStatusBlock) statusBlock
{
    _statusBlock=statusBlock;
    self.isRegister=YES;
    [self connect];
}

-(void)sendMsgToUser:(XMPPJID *)userJID WithText:(NSString *)text bodyType:(NSString *)bodyType
{
    XMPPMessage *msg=[XMPPMessage messageWithType:@"chat" to:userJID];
    [msg addAttributeWithName:@"bodyType" stringValue:bodyType];
    [msg addBody:text];
    [_xmppStream sendElement:msg];
}

-(void)dealloc
{
    [self teardownXMPP];
    NSLog(@"delloc");
}

@end


