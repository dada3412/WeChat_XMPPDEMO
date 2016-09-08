//
//  TabBarViewController.m
//  WeChat
//
//  Created by Nico on 16/6/30.
//  Copyright © 2016年 Nico. All rights reserved.
//

#import "TabBarViewController.h"
#import "RecentChatViewController.h"
#import "ProfileController.h"
#import "RosterController.h"
#import "ChatViewController.h"
#import "LogInViewController.h"
#import "XMPPTool.h"
#import "XMPPVCardTemp.h"
@interface TabBarViewController ()
{
    UINavigationController *_vc2;
}
@property(nonatomic,strong)XMPPTool *xmpptool;
@property(nonatomic,strong)NSMutableArray *presenceRequestArr;
@end

@implementation TabBarViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    _xmpptool=[XMPPTool shareXMPPTool];
    _presenceRequestArr=_xmpptool.presenceRequestArr;
    if (!_xmpptool.xmppStream.isConnected) {
        [self connectToHost];
    }
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(receivePresence) name:XMPPReceivePresenceSubscriptionRequest object:nil];
    
    RecentChatViewController *rvc=[RecentChatViewController new];
    UINavigationController *vc1=[[UINavigationController alloc] initWithRootViewController:rvc];
    vc1.tabBarItem.selectedImage=[UIImage imageNamed:@"tabbar_mainframeHL"];
    vc1.tabBarItem.image=[UIImage imageNamed:@"tabbar_mainframe"];
    vc1.title=@"信息";
    vc1.view.backgroundColor=[UIColor lightGrayColor];
    
    RosterController *rc=[RosterController new];
    _vc2=[[UINavigationController alloc]initWithRootViewController:rc];
    _vc2.tabBarItem.selectedImage=[UIImage imageNamed:@"tabbar_contactsHL"];
    _vc2.tabBarItem.image=[UIImage imageNamed:@"tabbar_contacts"];
    _vc2.title=@"联系人";
    
    ProfileController *pc=[ProfileController new];
    UINavigationController *vc3=[[UINavigationController alloc]initWithRootViewController:pc];
    vc3.tabBarItem.selectedImage=[UIImage imageNamed:@"tabbar_meHL"];
    vc3.tabBarItem.image=[UIImage imageNamed:@"tabbar_me"];
    vc3.title=@"我";
    
    [self addChildViewController:vc1];
    [self addChildViewController:_vc2];
    [self addChildViewController:vc3];
}

//-(void)viewDidAppear:(BOOL)animated
//{
//    [super viewDidAppear:animated];
//    
//}

-(void)receivePresence
{
    if (_presenceRequestArr.count==0) {
        _vc2.tabBarItem.badgeValue=nil;
    }else
        _vc2.tabBarItem.badgeValue=[NSString stringWithFormat:@"%lu",self.presenceRequestArr.count];
    NSIndexPath *indexPath=[NSIndexPath indexPathForRow:0 inSection:0];
    UITableViewController *tbc=[_vc2.viewControllers firstObject];
    [tbc.tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationNone];

}

-(void)connectToHost
{
    XMPPTool *xmppTool=[XMPPTool shareXMPPTool];
    [xmppTool userLogin:^(XMPPStatusType statustype) {
        switch (statustype) {
            case XMPPStatusTypeConnecting:
            {
                NSLog(@"XMPPStatusTypeconnecting");
            }
                break;
            case XMPPStatusTypeLoginSucess:
            {
                NSLog(@"XMPPStatusTypeLoginSucess");
            }
                break;
            case XMPPStatusTypeLoginFailure:
            {
                NSLog(@"XMPPStatusTypeLoginFailure");
                dispatch_async(dispatch_get_main_queue(), ^{
                    LogInViewController *lvc=[LogInViewController new];
                    UIWindow *window=[UIApplication sharedApplication].keyWindow;
                    window.rootViewController=lvc;
                });
            }
                break;
            case XMPPStatusTypeNetErr:
            {
                NSLog(@"XMPPStatusTypeNetErr");
            }
                break;
                
            default:
            {
                
            }
                break;
        }
    }];
}


-(void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:XMPPReceivePresenceSubscriptionRequest object:nil];
    NSLog(@"tab delloc");
}


@end
