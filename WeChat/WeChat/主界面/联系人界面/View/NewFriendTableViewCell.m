//
//  NewFriendTableViewCell.m
//  WeChat
//
//  Created by Nico on 16/8/4.
//  Copyright © 2016年 Nico. All rights reserved.
//

#import "NewFriendTableViewCell.h"
#import "XMPPPresence.h"
#import "XMPPTool.h"
#import "XMPPVCardTemp.h"

@interface NewFriendTableViewCell ()
@property (nonatomic,strong)XMPPTool *xmpptool;
@end
@implementation NewFriendTableViewCell

-(XMPPTool *)xmpptool
{
    if (!_xmpptool) {
        _xmpptool=[XMPPTool shareXMPPTool];
    }
    return _xmpptool;
}
- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}


-(void)setJidStr:(NSString *)jidStr
{
    _jidStr=jidStr;
    XMPPJID *jid=[XMPPJID jidWithString:jidStr];
    XMPPTool *xmpptool=[XMPPTool shareXMPPTool];
    XMPPvCardTemp *vCardTemp=[xmpptool.vCard vCardTempForJID:jid shouldFetch:YES];
    if (vCardTemp.photo.length==0) {
        self.contentImageView.image=[UIImage imageNamed:@"DefaultHead"];
    }else
    {
        self.contentImageView.image=[UIImage imageWithData:vCardTemp.photo];
    }
    
    self.contentTextLabel.text=jidStr;
}

- (IBAction)tapAgreeButton:(id)sender {
    if (_jidStr.length==0) {
        return;
    }
    XMPPJID *jid=[XMPPJID jidWithString:_jidStr];
    XMPPUserCoreDataStorageObject *obj=[_xmpptool.rosterStorage userForJID:jid xmppStream:_xmpptool.xmppStream managedObjectContext:_xmpptool.rosterStorage.mainThreadManagedObjectContext];
    if (obj==nil) {
        [self.xmpptool.roster acceptPresenceSubscriptionRequestFrom:jid andAddToRoster:YES];
    }else if ([obj.subscription isEqualToString:@"from"]) {
        [self.xmpptool.roster acceptPresenceSubscriptionRequestFrom:jid andAddToRoster:YES];
        [self.xmpptool sendMsgToUser:jid WithText:@"我们已经是好友，可以开始聊天。" bodyType:@"text"];
    }

    [_xmpptool.presenceRequestArr removeObject:_jidStr];
    [[NSNotificationCenter defaultCenter] postNotificationName:XMPPReceivePresenceSubscriptionRequest object:jid userInfo:nil];
    for (UIView *next=[self superview]; next; next=[next superview]) {
        if ([next isKindOfClass:[UITableView class]]) {
            UITableView *tableView=(UITableView *)next;
            [tableView reloadData];
            return;
        }
    }
    
    
    
}
@end
