//
//  MsgTableViewCell.m
//  WeChat
//
//  Created by Nico on 16/7/18.
//  Copyright © 2016年 Nico. All rights reserved.
//

#import "MsgTableViewCell.h"
#import "MsgFrame.h"
#import "UIButton+WebCache.h"
@interface MsgTableViewCell()

@property (weak, nonatomic)  UIButton *msgButton;
@end
@implementation MsgTableViewCell

+(instancetype)cellWithTableView:(UITableView *)tableView
{
    static NSString *identifier=@"MsgCell";
    MsgTableViewCell *cell=[tableView dequeueReusableCellWithIdentifier:identifier];
    if (!cell) {
        cell=[[self alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
    }
    return cell;
}

-(instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self=[super initWithStyle:style reuseIdentifier:reuseIdentifier];
    self.contentView.backgroundColor=[UIColor lightGrayColor];
    UIImageView *avatarView=[UIImageView new];
    [self.contentView addSubview:avatarView];
    
    UIButton *button=[UIButton new];
    button.titleLabel.font=[UIFont systemFontOfSize:15];
    [button setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    button.titleLabel.numberOfLines=0;
    [self.contentView addSubview:button];
//    [button setBackgroundColor:[UIColor yellowColor]];
    self.msgButton=button;
    self.avatarView=avatarView;
    
    
    return self;
}

-(void)setMsgFrame:(MsgFrame *)msgFrame
{
    _msgFrame=msgFrame;
    
    if ([msgFrame.bodyType isEqualToString:@"text"] || msgFrame.bodyType.length==0) {
        [self.msgButton setImage:nil forState:UIControlStateNormal];
        [self.msgButton setContentEdgeInsets:UIEdgeInsetsMake(12,18, 12, 18)];
        [self.msgButton setTitle:_msgFrame.msgBodyStr forState:UIControlStateNormal];
        
    }else if ([msgFrame.bodyType isEqualToString:@"image"]){
        [self.msgButton setTitle:nil forState:UIControlStateNormal];
        NSURL *url=[NSURL URLWithString:msgFrame.msgBodyStr];
        [self.msgButton sd_setImageWithURL:url forState:UIControlStateNormal placeholderImage:[UIImage imageNamed:@"DefaultProfileHead_qq"]];
        [self.msgButton setContentEdgeInsets:UIEdgeInsetsMake(10,16, 10, 16)];
    }
    
    
    self.msgButton.frame=_msgFrame.msgFrame;
    self.avatarView.frame=_msgFrame.avatarFrame;
    if (msgFrame.isOutGoing) {
        UIImage *image=[UIImage imageNamed:@"chat_send_nor"];
        NSInteger left=image.size.width/2-1;
        NSInteger top=image.size.height/2-1;
        UIImage *resizeImage=[image stretchableImageWithLeftCapWidth:left topCapHeight:top];
        [self.msgButton setBackgroundImage:resizeImage forState:UIControlStateNormal];
    }else{
        UIImage *image=[UIImage imageNamed:@"chat_recive_nor"];
        NSInteger left=image.size.width/2-1;
        NSInteger top=image.size.height/2-1;
        UIImage *resizeImage=[image stretchableImageWithLeftCapWidth:left topCapHeight:top];
        [self.msgButton setBackgroundImage:resizeImage forState:UIControlStateNormal];
        [self.msgButton setBackgroundImage:resizeImage forState:UIControlStateNormal];
    }
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
