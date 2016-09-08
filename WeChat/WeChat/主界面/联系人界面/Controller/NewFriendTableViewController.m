//
//  NewFriendTableViewController.m
//  WeChat
//
//  Created by Nico on 16/8/3.
//  Copyright © 2016年 Nico. All rights reserved.
//

#import "NewFriendTableViewController.h"
#import "XMPPTool.h"
#import "NewFriendTableViewCell.h"

@interface NewFriendTableViewController ()
@property (nonatomic,strong)NSMutableArray *arr;
@end

@implementation NewFriendTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    XMPPTool *xmpptool=[XMPPTool shareXMPPTool];
    _arr=xmpptool.presenceRequestArr;
    self.navigationItem.title=@"新的朋友";
    UINib *nib=[UINib nibWithNibName:@"NewFriendTableViewCell" bundle:[NSBundle mainBundle]];
    [self.tableView registerNib:nib forCellReuseIdentifier:@"cell"];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(vCardTempDidChange:) name:XMPPReceivevCardTempNotification object:nil];
}

-(void)vCardTempDidChange:(NSNotification *)note
{
    if ([note.userInfo[@"jid"] isKindOfClass:[XMPPJID class]]) {
        XMPPJID *jid=note.userInfo[@"jid"];
        NSString *jidStr=[NSString stringWithFormat:@"%@@%@",jid.user,jid.domain];
        NSUInteger index=[_arr indexOfObject:jidStr];
        if (index!=NSNotFound) {
            NSIndexPath *indexPath=[NSIndexPath indexPathForRow:index inSection:0];
            [self.tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationNone];
        }
    }
}

#pragma mark - Table view data source &delegate


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {

    return _arr.count;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NewFriendTableViewCell *cell=[tableView dequeueReusableCellWithIdentifier:@"cell" forIndexPath:indexPath];
    cell.jidStr=_arr[indexPath.row];
    return cell;
}

#pragma mark - dealloc

-(void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:XMPPReceivePresenceSubscriptionRequest object:nil];
}

@end
