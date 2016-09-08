//
//  userInfo.h
//  WeChat
//
//  Created by Nico on 16/7/2.
//  Copyright © 2016年 Nico. All rights reserved.
//

#import <Foundation/Foundation.h>
//#import "XMPPJID.h"
@interface UserInfo : NSObject
@property (strong,nonatomic)NSString *user;
@property (strong,nonatomic)NSString *domain;
@property (strong,nonatomic)NSString *password;
@property (assign,nonatomic)BOOL isLogin;
@property (strong,nonatomic, readonly)NSString *jidStr;


@end
