//
//  XMPPTool.h
//  WeChat
//
//  Created by Nico on 16/6/30.
//  Copyright © 2016年 Nico. All rights reserved.
//

#import <Foundation/Foundation.h>
//#import <UIKit/UIKit.h>
#import <XMPPFramework.h>
#import "UserInfo.h"
#define DOMAIN_NAME @"wechat.local"

//typedef enum
//{
//    XMPPStatusTypeConnecting,
//    XMPPStatusTypeLoginSucess,
//    XMPPStatusTypeLoginFailure,
//    XMPPStatusTypeNetErr,
//    XMPPStatusTypeRegisterSucess,
//    XMPPStatusTypeRegisterFailure
//}XMPPStatusType;

typedef NS_ENUM(NSUInteger, XMPPStatusType) {
    XMPPStatusTypeConnecting,
    XMPPStatusTypeLoginSucess,
    XMPPStatusTypeLoginFailure,
    XMPPStatusTypeNetErr,
    XMPPStatusTypeRegisterSucess,
    XMPPStatusTypeRegisterFailure
    
};

extern NSString *const XMPPReceivevCardTempNotification;
extern NSString *const XMPPReceivePresenceSubscriptionRequest;
extern NSString *const XMPPConnectionStatusNotification;

typedef void(^XMPPStatusBlock)(XMPPStatusType statustype);


@interface XMPPTool : NSObject
@property(nonatomic,strong,readonly)XMPPStream *xmppStream;
@property(nonatomic,assign)BOOL isRegister;
@property(nonatomic,strong)XMPPvCardTempModule *vCard;
@property(nonatomic,strong)UserInfo *userInfo;
@property(nonatomic,strong)XMPPRoster *roster;
@property(nonatomic,strong)XMPPRosterCoreDataStorage *rosterStorage;
@property(nonatomic,strong)XMPPMessageArchiving *message;
@property(nonatomic,strong)XMPPMessageArchivingCoreDataStorage *messageStorage;
@property(nonatomic,strong)NSMutableArray *presenceRequestArr;

+(instancetype)shareXMPPTool;
-(void)userLogin:(XMPPStatusBlock) statusBlock;
-(void)userLogout;
-(void)userRegister:(XMPPStatusBlock) statusBlock;
-(void)sendMsgToUser:(XMPPJID *)userJID WithText:(NSString *)text bodyType:(NSString *)bodyType;
@end
