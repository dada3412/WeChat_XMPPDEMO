//
//  RosterController.m
//  WeChat
//
//  Created by Nico on 16/7/4.
//  Copyright © 2016年 Nico. All rights reserved.
//

#import "RosterController.h"
#import "XMPPTool.h"
#import "XMPPvCardTemp.h"
#import "AddFriendController.h"
#import "UserDetailController.h"
#import "RosterTableViewCell.h"
#import "NewFriendTableViewController.h"
@interface RosterController ()<NSFetchedResultsControllerDelegate>
@property(nonatomic,strong)NSArray *friends;
@property(nonatomic,strong)NSFetchedResultsController *resultsController;
@property(nonatomic,strong)XMPPTool *xmppTool;
@end

@implementation RosterController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self loadFriends];
    self.tableView.contentInset=UIEdgeInsetsMake(-25, 0, 0, 0);
    self.navigationItem.rightBarButtonItem=[[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"contacts_add_friend"] style:UIBarButtonItemStylePlain target:self action:@selector(tapAddButton)];
    self.navigationItem.title=@"联系人";
    
    UINib *nib=[UINib nibWithNibName:@"RosterTableViewCell" bundle:[NSBundle mainBundle]];
    [self.tableView registerNib:nib forCellReuseIdentifier:@"cell"];
    }

-(instancetype)initWithStyle:(UITableViewStyle)style
{
    self=[super initWithStyle:UITableViewStyleGrouped];
    return self;
}

-(void)tapAddButton
{
    AddFriendController *addVC=[AddFriendController new];
    addVC.hidesBottomBarWhenPushed=YES;
    [self.navigationController pushViewController:addVC animated:YES];
    
}



-(void)loadFriends
{
    _xmppTool=[XMPPTool shareXMPPTool];
    NSManagedObjectContext *managedObjectContext=_xmppTool.rosterStorage.mainThreadManagedObjectContext;
    NSFetchRequest *request=[NSFetchRequest fetchRequestWithEntityName:@"XMPPUserCoreDataStorageObject"];
    
    NSPredicate *pre=[NSPredicate predicateWithFormat:@"streamBareJidStr=%@ AND subscription=%@",_xmppTool.userInfo.jidStr,@"both"];
    NSSortDescriptor *sort=[NSSortDescriptor sortDescriptorWithKey:@"displayName" ascending:YES];
    request.predicate=pre;
    request.sortDescriptors=@[sort];
    _resultsController=[[NSFetchedResultsController alloc]initWithFetchRequest:request managedObjectContext:managedObjectContext sectionNameKeyPath:nil cacheName:nil];
    _resultsController.delegate=self;
    [_resultsController performFetch:nil];
}


#pragma mark tableview datasource & delegate
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 2;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (section==1) {
        return _resultsController.fetchedObjects.count;
    }else
        return 1;
    
}



-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    RosterTableViewCell *cell=[tableView dequeueReusableCellWithIdentifier:@"cell" forIndexPath:indexPath];
//    NSLog(@"----------%@",self.tabBarItem.badgeValue);
    if (indexPath.section==0) {
        NSString *badgeValue=[self parentViewController].tabBarItem.badgeValue;
        if (badgeValue.length==0) {
            cell.badgeButton.hidden=YES;
        }else{
            cell.badgeButton.hidden=NO;
            [cell.badgeButton setTitle:badgeValue forState:UIControlStateNormal];
        }
        
        cell.contentTextLabel.text=@"新的朋友";
        cell.contentImageView.image=[UIImage imageNamed:@"tabbar_contactsHL"];
    }else{
        cell.badgeButton.hidden=YES;
        XMPPUserCoreDataStorageObject *obj=_resultsController.fetchedObjects[indexPath.row];
        cell.contentTextLabel.text=obj.jidStr;
        XMPPJID *jid=obj.jid;
        XMPPvCardTemp *vCard=[_xmppTool.vCard vCardTempForJID:jid shouldFetch:YES];
        if (vCard.photo.length==0) {
            cell.contentImageView.image=[UIImage imageNamed:@"DefaultHead"];
        }else
        {
            cell.contentImageView.image=[UIImage imageWithData:vCard.photo];
        }
    }
    
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section==1) {
        UserDetailController *udController=[UserDetailController new];
        XMPPUserCoreDataStorageObject *obj=_resultsController.fetchedObjects[indexPath.row];
        XMPPJID *jid=obj.jid;
        udController.jidStr=jid.full;
        udController.isAddFriend=NO;
        udController.hidesBottomBarWhenPushed=YES;
        [self.navigationController pushViewController:udController animated:YES];
    }else{
        NewFriendTableViewController *nfc=[[NewFriendTableViewController alloc] init];
        nfc.hidesBottomBarWhenPushed=YES;
        [self.navigationController pushViewController:nfc animated:YES];
    }
}

-(void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle==UITableViewCellEditingStyleDelete) {
        XMPPTool *xmppTool=[XMPPTool shareXMPPTool];
        XMPPUserCoreDataStorageObject *obj=_resultsController.fetchedObjects[indexPath.row];
        [xmppTool.roster removeUser:obj.jid];
    }
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 60;
}

#pragma mark fetchRequestController delegate
- (void)controller:(NSFetchedResultsController *)controller didChangeObject:(id)anObject atIndexPath:(nullable NSIndexPath *)indexPath forChangeType:(NSFetchedResultsChangeType)type newIndexPath:(nullable NSIndexPath *)newIndexPath
{
//    NSLog(@"recent  anObject :%@ atIndexPath:%@ forChangeType:%lu newIndexPath:%@", anObject,indexPath,type,newIndexPath);
    [self.tableView reloadData];
}

//-(void)controller:(NSFetchedResultsController *)controller didChangeObject:(id)anObject atIndexPath:(NSIndexPath *)indexPath forChangeType:(NSFetchedResultsChangeType)type newIndexPath:(NSIndexPath *)newIndexPath
//{
//    
//}



@end
