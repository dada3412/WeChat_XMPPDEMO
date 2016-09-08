//
//  RefreshingView.m
//  WeChat
//
//  Created by Nico on 16/8/23.
//  Copyright © 2016年 Nico. All rights reserved.
//

#import "RefreshingView.h"

@implementation RefreshingView

-(instancetype)initWithFrame:(CGRect)frame
{
    self=[super initWithFrame:frame];
    if (self) {
        CGRect actFrame=CGRectMake(0, 0, frame.size.width/3.0, frame.size.height);
        UIActivityIndicatorView *actView=[[UIActivityIndicatorView alloc] initWithFrame:actFrame];
        actView.color=[UIColor whiteColor];
//        actView.hidden=NO;
        
        CGRect labelFrame=CGRectMake(frame.size.width/3.0, 0, frame.size.width/3.0*2, frame.size.height);
        UILabel *label=[[UILabel alloc] initWithFrame:labelFrame];
//        label.textAlignment=NSTextAlignmentCenter;
        [label setTextColor:[UIColor whiteColor]];
        [self addSubview:actView];
        [self addSubview: label];
        
        _activityView=actView;
        _label=label;
    }
    return self;
}
@end
