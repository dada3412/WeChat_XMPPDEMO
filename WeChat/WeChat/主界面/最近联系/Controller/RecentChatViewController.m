//
//  RecentChatViewController.m
//  WeChat
//
//  Created by Nico on 16/7/28.
//  Copyright © 2016年 Nico. All rights reserved.
//

#import "RecentChatViewController.h"
#import "RecentChatTableViewCell.h"
#import "XMPPTool.h"
#import "XMPPVCardTemp.h"
#import "ChatViewController.h"
#import "RefreshingView.h"
#import "LogInViewController.h"

typedef enum
{
    CurrentDateIntervalToday,
    CurrentDateIntervalYesterday,
    CurrentDateIntervalAnother
}CurrentDateInterval;

@interface RecentChatViewController ()<NSFetchedResultsControllerDelegate>
@property (nonatomic,strong)XMPPTool *xmppTool;
@property (nonatomic,strong)NSFetchedResultsController *result;
@property (nonatomic,strong)NSManagedObjectContext *unreadContext;
@property (nonatomic,weak) RefreshingView *refreshView;
@end

@implementation RecentChatViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    RefreshingView *refreshView=[[RefreshingView alloc] initWithFrame:CGRectMake(0, 0, 100, 44)];
    refreshView.label.text=@"消息";
    self.navigationItem.titleView=refreshView;
    UINib *nib=[UINib nibWithNibName:@"RecentChatTableViewCell" bundle:[NSBundle mainBundle]];
    [self.tableView registerNib:nib forCellReuseIdentifier:@"cell"];
    [self loadRecentChatUser];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(connectionStatusChange:) name:XMPPConnectionStatusNotification object:nil];
    
    _refreshView=refreshView;
}

-(void)connectionStatusChange:(NSNotification *)notification
{
    NSDictionary *userInfo=notification.userInfo;
    XMPPStatusType statusType=[userInfo[@"status"] unsignedIntegerValue];
    NSLog(@"%lu",statusType);
    __weak typeof(self) weakSelf=self;
    switch (statusType) {
        case XMPPStatusTypeConnecting:
        {
            NSLog(@"connecting");
            dispatch_async(dispatch_get_main_queue(), ^{
                [weakSelf.refreshView.activityView startAnimating];
                weakSelf.refreshView.label.text=@"连接中";
            });
            
        }
            break;
        case XMPPStatusTypeLoginSucess:
        {
            dispatch_async(dispatch_get_main_queue(), ^{
                [weakSelf.refreshView.activityView stopAnimating];
                weakSelf.refreshView.label.text=@"消息";
            });
        }
            break;
        case XMPPStatusTypeLoginFailure:
        {
            dispatch_async(dispatch_get_main_queue(), ^{
                LogInViewController *lvc=[LogInViewController new];
                UIWindow *window=[UIApplication sharedApplication].keyWindow;
                window.rootViewController=lvc;
            });
        }
            break;
        case XMPPStatusTypeNetErr:
        {
            dispatch_async(dispatch_get_main_queue(), ^{
                [weakSelf.refreshView.activityView stopAnimating];
                weakSelf.refreshView.label.text=@"未连接";
            });
        }
            break;
            
        default:
        {
            
        }
            break;
    }
}

-(void)loadRecentChatUser
{
    _xmppTool=[XMPPTool shareXMPPTool];
    NSManagedObjectContext *context=_xmppTool.messageStorage.mainThreadManagedObjectContext;
    
    NSFetchRequest *request=[[NSFetchRequest alloc]initWithEntityName:NSStringFromClass([XMPPMessageArchiving_Contact_CoreDataObject class])];
    NSSortDescriptor *sortDescriptor=[[NSSortDescriptor alloc] initWithKey:@"mostRecentMessageTimestamp" ascending:NO];
    request.sortDescriptors=@[sortDescriptor];
    
    NSString *streamBareJidUser=[[NSUserDefaults standardUserDefaults] valueForKey:@"user"];
    NSString *streamBareJidStr=[NSString stringWithFormat:@"%@@%@",streamBareJidUser,DOMAIN_NAME];
    NSPredicate *pre=[NSPredicate predicateWithFormat:@"streamBareJidStr=%@",streamBareJidStr];
    request.predicate=pre;
    _result=[[NSFetchedResultsController alloc]initWithFetchRequest:request managedObjectContext:context sectionNameKeyPath:nil cacheName:nil];
    _result.delegate=self;
    
    NSError *err=nil;
    [_result performFetch:&err];
    if (err) {
        NSLog(@"fetch error:%@",err);
    }
}

-(void)loadUnreadMessageCount
{
    _unreadContext=[[NSManagedObjectContext alloc] initWithConcurrencyType:NSPrivateQueueConcurrencyType];
    
    NSURL *url=[[NSBundle mainBundle]
                URLForResource:@"UserUnreadMessageCount" withExtension:@"momd"];
    NSManagedObjectModel *model=[[NSManagedObjectModel alloc] initWithContentsOfURL:url];
    
    NSPersistentStoreCoordinator *store=[[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:model];
    NSString *cachePath=NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES).lastObject;
    NSString *filePath=[cachePath stringByAppendingPathComponent:@"unreadMessageCount.sqlite"];
    NSURL *pathURL=[NSURL fileURLWithPath:filePath];
    [store addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:pathURL options:nil error:nil];
    
    _unreadContext.persistentStoreCoordinator=store;
    
}

#pragma mark NSFetchedResultsControllerDelegate
-(void)controller:(NSFetchedResultsController *)controller didChangeObject:(id)anObject atIndexPath:(NSIndexPath *)indexPath forChangeType:(NSFetchedResultsChangeType)type newIndexPath:(NSIndexPath *)newIndexPath
{
//    if (<#condition#>) {
//        <#statements#>
//    }
    
    [self.tableView reloadData];
}

#pragma mark tableViewControllerDelegate
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return _result.fetchedObjects.count;
    
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 69;
}
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    RecentChatTableViewCell *cell=[tableView dequeueReusableCellWithIdentifier:@"cell" forIndexPath:indexPath];
    
    XMPPMessageArchiving_Contact_CoreDataObject *obj=_result.fetchedObjects[indexPath.row];
    
    XMPPvCardTemp *vCardTemp=[_xmppTool.vCard vCardTempForJID:[XMPPJID jidWithString:obj.bareJidStr] shouldFetch:YES];
    if (vCardTemp.photo.length==0) {
        cell.avartarImageView.image=[UIImage imageNamed:@"DefaultHead"];
    }else
    {
        cell.avartarImageView.image=[UIImage imageWithData:vCardTemp.photo];
    }
    cell.userLabel.text=obj.bareJidStr;
    cell.messageLabel.text=obj.mostRecentMessageBody;
    cell.dateLabel.text=[self stringWithDate:obj.mostRecentMessageTimestamp];
    if (cell.badgeButton.titleLabel.text.length==0) {
        cell.badgeButton.hidden=YES;
    }else
        cell.badgeButton.hidden=NO;
    
    return cell;
}



-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    ChatViewController *cvc=[ChatViewController new];
    XMPPMessageArchiving_Contact_CoreDataObject *obj=_result.fetchedObjects[indexPath.row];
    cvc.jidStr=obj.bareJidStr;
    cvc.hidesBottomBarWhenPushed=YES;
    [self.navigationController pushViewController:cvc animated:YES];
}


#pragma mark 私有方法
-(NSString *)stringWithDate:(NSDate *)date
{
    if ([self currentDateIntevelWithDate:date]==CurrentDateIntervalToday) {
        NSDateFormatter *formatter=[[NSDateFormatter alloc] init];
        formatter.dateFormat=@"HH:mm";
        return [formatter stringFromDate:date];
    }else if ([self currentDateIntevelWithDate:date]==CurrentDateIntervalYesterday){
        return @"昨天";
    }else{
        NSDateFormatter *formatter=[[NSDateFormatter alloc] init];
        formatter.dateFormat=@"yy/MM/dd";
        return [formatter stringFromDate:date];
    }
}

//判断最后消息时间和当前时间的天数间隔
-(CurrentDateInterval)currentDateIntevelWithDate:(NSDate *)date
{
    NSDate *currentDate=[NSDate date];
    NSDateFormatter *formatter=[[NSDateFormatter alloc] init];
    formatter.dateFormat=@"yyyy/MM/dd";
    
    NSString *dateStr=[formatter stringFromDate:date];
    date=[formatter dateFromString:dateStr];
    
    NSString *currentDateStr=[formatter stringFromDate:currentDate];
    currentDate=[formatter dateFromString:currentDateStr];
    
    NSCalendar *calendar=[NSCalendar currentCalendar];
    NSCalendarUnit unit=NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitDay;
    NSDateComponents *cmps=[calendar components:unit fromDate:date toDate:currentDate options:NSCalendarMatchStrictly];
    
    if (cmps.year==0 && cmps.month==0 && cmps.date==0) {
        return CurrentDateIntervalToday;
    }else if (cmps.year==0 && cmps.month==0 && cmps.day==1){
        return CurrentDateIntervalYesterday;
    }else
        return CurrentDateIntervalAnother;
        
    
    
}
@end
