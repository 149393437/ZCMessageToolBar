//
//  MessageCell.h
//  WeiChat_1511
//
//  Created by zhangcheng on 16/3/11.
//  Copyright © 2016年 zhangcheng. All rights reserved.
//
/*
 本类说明
 为了降低耦合度,所有的东西都没有封装,直接赋值的
 每一个模块都可以进行单独使用,实现了一句话调用
 本类中原有的其实是支持xmpp的,但是我删除了,如果需要请联系我,或者在我的github上下载xmpp完整工程
 
//处理表情使用的
 #import "MMTextParser+ExtData.h"
//处理图像使用
 #import "Photo.h"
 //处理音频使用的
 #import "ZCChatAudioPlay.h"
 //处理音频转字符串使用的
 #import "NSString+Base64.h"
 //处理定位使用的
 #import "LocationViewController.h"
 以上这些都必须加入
 
 */
//发送消息的标记
#define MESSAGE_STR @"[1]"
#define MESSAGE_VOICE @"[2]"
#define MESSAGE_IMAGESTR @"[3]"
#define MESSAGE_BIGIMAGESTR @"[4]"
#define MESSAGE_LOCATION @"[5]"
//增加屏幕适配
#define WIDTH [UIScreen mainScreen].bounds.size.width

#define HEIGHT [UIScreen mainScreen].bounds.size.height
#import <UIKit/UIKit.h>
#import "MMTextView.h"
#import "MessageModel.h"
#import "ZCControl.h"
@interface MessageCell : UITableViewCell
{
//左边
    //头像
    UIImageView*leftImageView;
    //气泡
    UIImageView*leftBubbleImageView;
    //文字
    MMTextView*leftTextView;
    //语音
    UIImageView*leftVoiceImageView;
    //图片
    UIButton*leftPhotoButton;
    //大表情
    UIImageView*leftBigImageView;
    //定位
    UIButton*leftLocationButton;
    
    
//右边
    //头像
    UIImageView*rightImageView;
    //气泡
    UIImageView*rightBubbleImageView;
    //文字
    MMTextView*rightTextView;
    //语音
    UIImageView*rightVoiceImageView;
    //图片
    UIButton*rightPhotoButton;
    //大表情
    UIImageView*rightBigImageView;
    
    //记录放大前的坐标
    CGRect oldRect;
    
    //记录当前父类
    UIView*view;
    //右边
    UIButton*rightLocationButton;

    
    UILabel*timeLabel;
    

}
@property(nonatomic,copy)NSString*path;
//聊天内容
@property(nonatomic,copy)NSString*str;
//根据内容类型,计算出大小
+(CGFloat)contentStrToHeight:(NSString*)str;



-(void)configWithCustomModel:(MessageModel *)object leftImage:(UIImage *)leftImage rightImage:(UIImage *)right;
@end
