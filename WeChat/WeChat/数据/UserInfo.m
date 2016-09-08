//
//  userInfo.m
//  WeChat
//
//  Created by Nico on 16/7/2.
//  Copyright © 2016年 Nico. All rights reserved.
//

#import "UserInfo.h"

@implementation UserInfo

-(NSString *)jidStr
{
    if (_user.length!=0 && _domain.length!=0) {
        return [NSString stringWithFormat:@"%@@%@",_user,_domain];
    }else return nil;
}
@end
