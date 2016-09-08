//
//  RecentChatTableViewCell.h
//  WeChat
//
//  Created by Nico on 16/8/2.
//  Copyright © 2016年 Nico. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface RecentChatTableViewCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UIImageView *avartarImageView;
@property (weak, nonatomic) IBOutlet UIButton *badgeButton;
@property (weak, nonatomic) IBOutlet UILabel *userLabel;
@property (weak, nonatomic) IBOutlet UILabel *messageLabel;
@property (weak, nonatomic) IBOutlet UILabel *dateLabel;

@end
