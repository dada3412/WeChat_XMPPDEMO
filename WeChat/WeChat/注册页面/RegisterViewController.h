//
//  RegisterViewController.h
//  WeChat
//
//  Created by Nico on 16/7/1.
//  Copyright © 2016年 Nico. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol dismisRegisterController <NSObject>

-(void)dismisRegisterController;

@end

@interface RegisterViewController : UIViewController

@property(nonatomic,weak)id<dismisRegisterController> delegate;

@end
