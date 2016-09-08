//
//  ProfieldSettingController.h
//  WeChat
//
//  Created by Nico on 16/7/8.
//  Copyright © 2016年 Nico. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol SaveTheChange <NSObject>

-(void)saveTheChangeWithTitle:(NSString *)title Text:(NSString *)text;

@end

@interface ProfieldSettingController : UIViewController
@property (weak, nonatomic) IBOutlet UITextField *settingTextField;
@property (strong,nonatomic)NSString *text;
@property (nonatomic,weak)id<SaveTheChange>delegate;
@end
