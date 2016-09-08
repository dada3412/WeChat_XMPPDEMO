//
//  MsgFrame.m
//  WeChat
//
//  Created by Nico on 16/7/16.
//  Copyright © 2016年 Nico. All rights reserved.
//

#import "MsgFrame.h"
#define PADDINGW 2.0
#define PADDINGH 8.0
#define AVATARW 40.0
#define MSG_FONT_SIZE 15.0
#define EDGE_INSETW 18.0
#define EDGE_INSETH 12.0
#define SCREENW ([UIScreen mainScreen].bounds.size.width)
@implementation MsgFrame

-(void)setMsgBodyStr:(NSString *)msgBodyStr
{
    _msgBodyStr=msgBodyStr;
    
    UIFont *font=[UIFont systemFontOfSize:MSG_FONT_SIZE];
    NSDictionary *dic=[NSDictionary dictionaryWithObject:font forKey:NSFontAttributeName];
    CGFloat msgMaxW=SCREENW-2*AVATARW-4*PADDINGW-2*EDGE_INSETW;
    CGSize tSize=CGSizeMake(msgMaxW, CGFLOAT_MAX);
    CGSize textSize=[_msgBodyStr boundingRectWithSize:tSize options:NSStringDrawingUsesLineFragmentOrigin attributes:dic context:nil].size;
    
    
    CGFloat imageX;
    CGFloat imageY=PADDINGW;
    CGFloat imageW=AVATARW;
    CGFloat imageH=AVATARW;
    
    CGFloat msgX;
    CGFloat msgY=PADDINGW-6;
    CGSize msgSize=CGSizeZero;
    
    if ([_bodyType isEqualToString:@"text"] || _bodyType.length==0) {
        msgSize=CGSizeMake(textSize.width+2*EDGE_INSETW, textSize.height+2*EDGE_INSETH+12);
    }else if ([_bodyType isEqualToString:@"image"]){
        NSRange range=NSMakeRange(_msgBodyStr.length-1, 1);
        NSString *sizeRectStr=[_msgBodyStr substringWithRange:range];
        if ([sizeRectStr isEqualToString:@"w"]) {
            msgSize=CGSizeMake(160, 120);
        }else if ([sizeRectStr isEqualToString:@"s"]) {
            msgSize=CGSizeMake(120, 120);
        }else if ([sizeRectStr isEqualToString:@"h"]) {
            msgSize=CGSizeMake(120, 160);
        }
    }
    
    
    if (self.isOutGoing) {
        //avatar
        imageX=SCREENW-PADDINGW-AVATARW;
        
        //msgFramw
        msgX=SCREENW-msgSize.width-PADDINGW-AVATARW;
   
    }else
    {
        //avatar
        imageX=PADDINGW;

        //msgFramw
        msgX=PADDINGW+AVATARW;

    }
    self.avatarFrame=CGRectMake(imageX, imageY, imageW, imageH);
    self.msgFrame=(CGRect){{msgX,msgY},msgSize};
    CGFloat maxMsgY=CGRectGetMaxY(self.msgFrame);
    CGFloat maxAvatarY=CGRectGetMaxY(self.avatarFrame);
    self.cellH=MAX(maxMsgY, maxAvatarY)+PADDINGH-6;
}

@end
