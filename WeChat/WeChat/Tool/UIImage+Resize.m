//
//  UIImage+Resize.m
//  WeChat
//
//  Created by Nico on 16/7/8.
//  Copyright © 2016年 Nico. All rights reserved.
//

#import "UIImage+Resize.h"

@implementation UIImage(Resize)
-(UIImage *)imageForSize:(CGSize)size
{
    CGSize originalSize=self.size;
    CGFloat ratioH=size.height/originalSize.height;
    CGFloat ratioW=size.width/originalSize.width;
    CGFloat ratio=MAX(ratioH, ratioW);
    
    UIGraphicsBeginImageContextWithOptions(size, NO, 0.0);
    CGRect newRect=CGRectMake(0, 0, size.width, size.height);
    UIBezierPath *path=[UIBezierPath bezierPathWithRoundedRect:newRect cornerRadius:5.0];
    [path addClip];
    CGRect projectRect;
    projectRect.size.width=ratio*originalSize.width;
    projectRect.size.height=ratio*originalSize.height;
    projectRect.origin.x=(size.width-projectRect.size.width)/2.0;
    projectRect.origin.y=(size.height-projectRect.size.height)/2.0;
    
    [self drawInRect:projectRect];
    UIImage *resizeImage=UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return resizeImage;
}
@end
