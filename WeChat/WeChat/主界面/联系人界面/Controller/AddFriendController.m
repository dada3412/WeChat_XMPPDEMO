//
//  AddFriendController.m
//  WeChat
//
//  Created by Nico on 16/7/5.
//  Copyright © 2016年 Nico. All rights reserved.
//

#import "AddFriendController.h"
#import "NSString+JIDName.h"
#import "UserDetailController.h"
#import "XMPPTool.h"
@interface AddFriendController ()
@property (weak, nonatomic) IBOutlet UITextField *userTextField;
- (IBAction)userSearch;


@end

@implementation AddFriendController

- (void)viewDidLoad {
    [super viewDidLoad];

}



- (IBAction)userSearch {
    NSString *jidStr=[self.userTextField.text JIDName];
//    XMPPTool *xmppTool=[XMPPTool shareXMPPTool];
    UserDetailController *udController=[UserDetailController new];
    udController.jidStr=jidStr;
    udController.isAddFriend=YES;
    [self.navigationController pushViewController:udController animated:YES];
//    [xmppTool.vCard vCardTempForJID:jid shouldFetch:YES];
}
@end
