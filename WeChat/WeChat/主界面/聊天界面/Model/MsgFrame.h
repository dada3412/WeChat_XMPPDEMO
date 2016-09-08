//
//  MsgFrame.h
//  WeChat
//
//  Created by Nico on 16/7/16.
//  Copyright © 2016年 Nico. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MsgFrame : NSObject
@property (nonatomic,strong) NSString *msgBodyStr;
@property (nonatomic,strong) NSString *bodyType;
@property (nonatomic,assign) CGRect msgFrame;
@property (nonatomic,assign) CGRect avatarFrame;
@property (nonatomic,assign) CGRect dateFrame;
@property (nonatomic,assign) CGFloat cellH;
@property (nonatomic,assign) BOOL isOutGoing;
@end
