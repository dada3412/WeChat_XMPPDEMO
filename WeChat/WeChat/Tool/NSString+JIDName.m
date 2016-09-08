//
//  NSString+JIDName.m
//  WeChat
//
//  Created by Nico on 16/7/5.
//  Copyright © 2016年 Nico. All rights reserved.
//

#import "NSString+JIDName.h"

@implementation NSString(JIDName)

-(NSString *)JIDName
{
    return [NSString stringWithFormat:@"%@@%@",self,@"wechat.local"];
}


@end
