//
//  AppDelegate.m
//  WeChat
//
//  Created by Nico on 16/6/29.
//  Copyright © 2016年 Nico. All rights reserved.
//

#import "AppDelegate.h"
#import "LogInViewController.h"
#import "TabBarViewController.h"
#import "DDLog.h"
#import "DDTTYLogger.h"
@interface AppDelegate ()

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    UINavigationBar *bar=[UINavigationBar appearance];
    [bar setBarTintColor:[UIColor darkGrayColor]];
    NSDictionary *dic=[NSDictionary dictionaryWithObject:[UIColor whiteColor] forKey:NSForegroundColorAttributeName];
    [bar setTitleTextAttributes:dic];
    [[UIButton appearance]setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    self.window=[[UIWindow alloc]initWithFrame:[UIScreen mainScreen].bounds];
    NSString *path=NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES).lastObject;
    NSLog(@"%@",path);
//    [DDLog addLogger:[DDTTYLogger sharedInstance]];
//    LogInViewController *vc=[[LogInViewController alloc]init];
//    self.window.rootViewController=vc;
    
    NSString *loginStatusStr=[[NSUserDefaults standardUserDefaults] objectForKey:@"isLogin"];
    if ([loginStatusStr isEqualToString:@"yes"]) {
        TabBarViewController *tbc=[TabBarViewController new];
//        tbc.isConnect=NO;
        self.window.rootViewController=tbc;
    }else
    {
        LogInViewController *vc=[[LogInViewController alloc]init];
        self.window.rootViewController=vc;
    }
    
    [self.window makeKeyAndVisible];
    
    if ([[UIDevice currentDevice].systemVersion doubleValue]>=8.0) {
        UIUserNotificationSettings *settings=nil;
        [application registerUserNotificationSettings:settings];
    }
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

@end
