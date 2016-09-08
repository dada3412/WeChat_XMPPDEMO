//
//  ChatViewController.m
//  WeChat
//
//  Created by Nico on 16/7/6.
//  Copyright © 2016年 Nico. All rights reserved.
//

#import "ChatViewController.h"
#import "XMPPTool.h"
#import "MsgTableViewCell.h"
#import "MsgFrame.h"
#import "XMPPvCardTemp.h"
#import "UIImage+Resize.h"
#import "HttpTool.h"
#import "UIButton+WebCache.h"
#define OriginHeight 39.0
#define TEXTVIEW_PADING 3.0
#define BOUNDARY (@"----wechat")

@interface ChatViewController ()<UITableViewDataSource,UITableViewDelegate,NSFetchedResultsControllerDelegate,UITextViewDelegate,UIImagePickerControllerDelegate,UINavigationControllerDelegate,NSURLSessionDelegate>
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UITextView *inputTextView;
@property (strong,nonatomic)NSFetchedResultsController *result;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *bottomConstrain;
@property (strong,nonatomic)XMPPTool *xmppTool;
@property (strong,nonatomic)UIImage *myAvatar;
@property (strong,nonatomic)UIImage *friendAvatar;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *viewHeightConstrain;
- (IBAction)sendImage;
- (IBAction)sendMessage;
@property (strong,nonatomic)NSMutableArray *msgFrameArr;
@end

@implementation ChatViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    _msgFrameArr=[NSMutableArray new];
    self.tableView.dataSource=self;
    self.tableView.delegate=self;
    self.tableView.separatorStyle=UITableViewCellSeparatorStyleNone;
    
    self.inputTextView.returnKeyType=UIReturnKeySend;
    self.inputTextView.delegate=self;
    
    _xmppTool=[XMPPTool shareXMPPTool];
    NSData *myAvatarData=_xmppTool.vCard.myvCardTemp.photo;
    _myAvatar=[UIImage imageWithData:myAvatarData];
    NSData *friendAvatarData=[_xmppTool.vCard vCardTempForJID:[XMPPJID jidWithString:self.jidStr] shouldFetch:YES].photo;
    _friendAvatar=[UIImage imageWithData:friendAvatarData];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardChangeNotification:) name:UIKeyboardWillChangeFrameNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(scrollToBottom) name:UIKeyboardDidChangeFrameNotification object:nil];
    
    [self loadMsg];
    [self scrollToBottom];
}

-(void)loadMsg
{
    NSManagedObjectContext *context=_xmppTool.messageStorage.mainThreadManagedObjectContext;
    
    NSFetchRequest *request=[[NSFetchRequest alloc]initWithEntityName:@"XMPPMessageArchiving_Message_CoreDataObject"];
    NSSortDescriptor *sortDescriptor=[[NSSortDescriptor alloc] initWithKey:@"timestamp" ascending:YES];
    request.sortDescriptors=@[sortDescriptor];
NSPredicate *pre=[NSPredicate predicateWithFormat:@"bareJidStr=%@ AND streamBareJidStr=%@",self.jidStr,_xmppTool.userInfo.jidStr];
    request.predicate=pre;
    _result=[[NSFetchedResultsController alloc]initWithFetchRequest:request managedObjectContext:context sectionNameKeyPath:nil cacheName:nil];
    _result.delegate=self;
    
    NSError *err=nil;
    [_result performFetch:&err];
    if (err) {
        NSLog(@"fetch error:%@",err);
    }
    [self loadDatasource];
}

-(void)loadDatasource
{
    [_msgFrameArr removeAllObjects];
    for (XMPPMessageArchiving_Message_CoreDataObject *obj in _result.fetchedObjects) {
        MsgFrame *msgFrame=[MsgFrame new];
        msgFrame.isOutGoing=obj.isOutgoing;
        msgFrame.bodyType=[obj.message attributeStringValueForName:@"bodyType"];
        msgFrame.msgBodyStr=obj.message.body;
        
//        NSLog(@"bodyType:%@",msgFrame.bodyType);
        [_msgFrameArr addObject:msgFrame];
    }
}

-(void)keyboardChangeNotification:(NSNotification *)notification
{
    NSDictionary *userInfo=notification.userInfo;
    CGRect rect=[userInfo[UIKeyboardFrameEndUserInfoKey] CGRectValue];
    CGFloat height=[UIScreen mainScreen].bounds.size.height-rect.origin.y;
    self.bottomConstrain.constant=height;
}


#pragma mark tableView Delegate & datasource
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return _msgFrameArr.count;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    MsgTableViewCell *cell=[MsgTableViewCell cellWithTableView:tableView];
    MsgFrame *msgFrame=_msgFrameArr[indexPath.row];
    cell.msgFrame=msgFrame;
    if (msgFrame.isOutGoing) {
        if (_myAvatar!=nil) {
            cell.avatarView.image=_myAvatar;
        }else
            cell.avatarView.image=[UIImage imageNamed:@"DefaultHead"];
    }else
    {
        if (_friendAvatar!=nil) {
            cell.avatarView.image=_friendAvatar;
        }else
            cell.avatarView.image=[UIImage imageNamed:@"DefaultHead"];
    }
    

    return cell;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    MsgFrame *msgFrame=_msgFrameArr[indexPath.row];
    return msgFrame.cellH;
}


#pragma mark NSFetchResultController Delegate

- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller
{
    [self loadMsg];
    [self.tableView reloadData];
    [self scrollToBottom];
}

-(void)sendMsgWithText:(NSString *)text bodyType:(NSString *)bodyType
{
    XMPPJID *friendJID=[XMPPJID jidWithString:self.jidStr];
    XMPPMessage *msg=[XMPPMessage messageWithType:@"chat" to:friendJID];
    [msg addAttributeWithName:@"bodyType" stringValue:bodyType];
    [msg addBody:text];
    [_xmppTool.xmppStream sendElement:msg];
}


#pragma mark UITextViewDelegate

-(BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text
{
    if ([text isEqualToString:@"\n"]) {
        if ([textView.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]].length==0) {
            textView.text=nil;
            [self alertWithTitle:@"不能发送空消息！"];
            return NO;
        }
        [self sendMsgWithText:textView.text bodyType:@"text"];
        textView.text=nil;
        _viewHeightConstrain.constant=OriginHeight;
        [self scrollToBottom];
        return NO;
    }
    return YES;
}

-(void)scrollToBottom
{
    NSInteger lastRow=self.result.fetchedObjects.count-1;
    if (lastRow<0) {
        return;
    }
    NSIndexPath *lastIndex=[NSIndexPath indexPathForRow:lastRow inSection:0];
    [self.tableView scrollToRowAtIndexPath:lastIndex atScrollPosition:UITableViewScrollPositionBottom animated:YES];
}

-(void)textViewDidChange:(UITextView *)textView
{
    if (_inputTextView.frame.size.height==_inputTextView.contentSize.height || _inputTextView.contentSize.height>100.0)
        return;

    _viewHeightConstrain.constant=_inputTextView.contentSize.height+TEXTVIEW_PADING*2;
}

-(void)alertWithTitle:(NSString *)title
{
    UIAlertController *alert=[UIAlertController alertControllerWithTitle:title message:nil preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *action=[UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
    }];
    [alert addAction:action];
    [self presentViewController:alert animated:YES completion:nil];
}

- (IBAction)sendImage {
    UIAlertController *alertVC=[UIAlertController alertControllerWithTitle:nil message:nil preferredStyle:UIAlertControllerStyleActionSheet];
    __block UIImagePickerController *ipc=[UIImagePickerController new];
//    self.ipc=ipc;
    ipc.delegate=self;
//    ipc.allowsEditing=YES;
    __weak typeof(self) selfVC=self;
    UIAlertAction *takePhotoAction=[UIAlertAction actionWithTitle:@"拍照" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        if ([UIImagePickerController isCameraDeviceAvailable:UIImagePickerControllerCameraDeviceRear]) {
            ipc.sourceType=UIImagePickerControllerSourceTypeCamera;
            [selfVC presentViewController:ipc animated:YES completion:nil];
        }else
        {
            [selfVC alertWithTitle:@"摄像头不可用"];
        }
    }];
    UIAlertAction *selectPhotoAction=[UIAlertAction actionWithTitle:@"从相册选择" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        ipc.sourceType=UIImagePickerControllerSourceTypePhotoLibrary;
        [selfVC presentViewController:ipc animated:YES completion:nil];
    }];
    UIAlertAction *cancelAction=[UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleDefault handler:nil];
    [alertVC addAction:takePhotoAction];
    [alertVC addAction:selectPhotoAction];
    [alertVC addAction:cancelAction];
    [self presentViewController:alertVC animated:YES completion:nil];
}

- (IBAction)sendMessage {
    NSRange range=NSMakeRange(0, NSUIntegerMax);
    [self textView:self.inputTextView shouldChangeTextInRange:range replacementText:@"\n"];
}

#pragma mark imagePicker delegate
-(void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary<NSString *,id> *)info
{
    UIImage *originalImage=info[UIImagePickerControllerOriginalImage];
    CGSize size;
    NSString *sizeRect;
    CGFloat ratio=originalImage.size.width/originalImage.size.height;
    if (ratio>=7.0/6.0) {
        size=CGSizeMake(320, 240);
        sizeRect=@"w";
    }else if(ratio<7.0/6.0 && ratio>5.0/6.0){
        size=CGSizeMake(320, 320);
        sizeRect=@"s";
    }else{
        size=CGSizeMake(240, 320);
        sizeRect=@"h";
    }
    UIImage *image=[originalImage imageForSize:size];
    NSData *imageData=UIImageJPEGRepresentation(image, 0.8);
    
    NSDate *currentDate=[NSDate date];
    NSDateFormatter *formatter=[[NSDateFormatter alloc] init];
    formatter.dateFormat=@"YYMMDDHHmmss";
    NSString *dateStr=[formatter stringFromDate:currentDate];
    NSString *imageName=[NSString stringWithFormat:@"%@%@",dateStr,sizeRect];
    NSString *urlStr=[@"http://192.168.31.207:8080/imfileserver/Upload/Image" stringByAppendingPathComponent:imageName];

    NSURL *url=[NSURL URLWithString:urlStr];
    HttpTool *httpTool=[HttpTool new];
    
    __weak typeof(self) selfVC=self;
    [httpTool uploadData:imageData url:url progressBlock:nil completion:^(NSError *error) {
        if (error) {
            NSLog(@"%@",error);
        }else{
            [selfVC sendMsgWithText:urlStr bodyType:@"image"];
        }
    }];
    [self dismissViewControllerAnimated:YES completion:nil];
}


@end
