//
//  NewFriendTableViewCell.h
//  WeChat
//
//  Created by Nico on 16/8/4.
//  Copyright © 2016年 Nico. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface NewFriendTableViewCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UIImageView *contentImageView;
@property (weak, nonatomic) IBOutlet UILabel *contentTextLabel;
@property (strong,nonatomic) NSString *jidStr;
@property (weak, nonatomic) IBOutlet UIButton *agreeButton;
- (IBAction)tapAgreeButton:(id)sender;

@end
