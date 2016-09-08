//
//  RosterTableViewCell.h
//  WeChat
//
//  Created by Nico on 16/8/3.
//  Copyright © 2016年 Nico. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface RosterTableViewCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UIImageView *contentImageView;
@property (weak, nonatomic) IBOutlet UILabel *contentTextLabel;
@property (weak, nonatomic) IBOutlet UIButton *badgeButton;


@end
