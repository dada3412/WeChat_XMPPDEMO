//
//  MsgTableViewCell.h
//  WeChat
//
//  Created by Nico on 16/7/18.
//  Copyright © 2016年 Nico. All rights reserved.
//

#import <UIKit/UIKit.h>
@class MsgFrame;
@interface MsgTableViewCell : UITableViewCell
@property (weak, nonatomic)  UIImageView *avatarView;
@property (strong,nonatomic)MsgFrame *msgFrame;

+(instancetype)cellWithTableView:(UITableView *)tableView;
@end
