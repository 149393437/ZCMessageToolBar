//  Created by zhangcheng on 16/3/14.
//  Copyright © 2016年 zhangcheng. All rights reserved.
//     _                            _
// ___| |__   __ _ _ __   __ _  ___| |__   ___ _ __   __ _
//|_  / '_ \ / _` | '_ \ / _` |/ __| '_ \ / _ \ '_ \ / _` |
// / /| | | | (_| | | | | (_| | (__| | | |  __/ | | | (_| |
///___|_| |_|\__,_|_| |_|\__, |\___|_| |_|\___|_| |_|\__, |
//                       |___/                       |___/

//小张诚技术博客http://blog.sina.com.cn/u/2914098025
//github代码地址https://github.com/149393437
//欢迎加入iOS研究院 QQ群号305044955    你的关注就是我开源的动力

#import <UIKit/UIKit.h>

#import "XHMessageTextView.h"

#import "ZCChatBarMoreView.h"

#define kInputTextViewMinHeight 36
#define kInputTextViewMaxHeight 200
#define kHorizontalPadding 8
#define kVerticalPadding 5
//修改表情MM的APPID
#define BQMM_APPID @"4d48577b82a54219be0515939c7521c9"
#define BQMM_SECRET @"7d125164fb4b42b6ae3da3fa5e3a933f"

#import <BQMM/BQMM.h>
#import "MMTextParser+ExtData.h"
#import "ZCChatAudioPlay.h"
/**
 *  类说明：
 *  1、推荐使用[initWithFrame:...]方法进行初始化
 *  2、提供默认的录音，表情，更多按钮的附加页面
 *  3、可自定义以上的附加页面
 */

@protocol DXMessageToolBarDelegate;
@interface DXMessageToolBar : UIView<ZCChatBarMoreViewDelegate,UIImagePickerControllerDelegate,UINavigationControllerDelegate>
{
    
}
@property (nonatomic, weak) id <DXMessageToolBarDelegate> delegate;
//进行模块化操作,使用block进行统一设置
@property(nonatomic,copy)void(^MyBlock)(NSString*,NSString*);

-(instancetype)initWithFrame:(CGRect)frame Block:(void(^)(NSString*sign,NSString*message))a;

@property (strong, nonatomic) UIButton *recordButton;

/**
 *  操作栏背景图片
 */
@property (strong, nonatomic) UIImage *toolbarBackgroundImage;

/**
 *  背景图片
 */
@property (strong, nonatomic) UIImage *backgroundImage;

/**
 *  更多的附加页面
 */
@property (strong, nonatomic) ZCChatBarMoreView *moreView;

/**
 *  表情的附加页面
 */
@property (strong, nonatomic) UIView *faceView;

/**
 *  录音单例
 */
@property (strong, nonatomic) ZCChatAudioPlay *audio;

/**
 *  用于输入文本消息的输入框
 */
@property (strong, nonatomic) XHMessageTextView *inputTextView;

/**
 *  文字输入区域最大高度，必须 > KInputTextViewMinHeight(最小高度)并且 < KInputTextViewMaxHeight，否则设置无效
 */
@property (nonatomic) CGFloat maxTextInputViewHeight;

/**
 *  默认高度
 *
 *  @return 默认高度
 */
+ (CGFloat)defaultHeight;



@end

@protocol DXMessageToolBarDelegate <NSObject>

@optional

/**
 *  在普通状态和语音状态之间进行切换时，会触发这个回调函数
 *
 *  @param changedToRecord 是否改为发送语音状态
 */
- (void)didStyleChangeToRecord:(BOOL)changedToRecord;

///**
// *  点击“表情”按钮触发
// *
// *  @param isSelected 是否选中。YES,显示表情页面；NO，收起表情页面
// */
//- (void)didSelectedFaceButton:(BOOL)isSelected;
//
///**
// *  点击“更多”按钮触发
// *
// *  @param isSelected 是否选中。YES,显示更多页面；NO，收起更多页面
// */
//- (void)didSelectedMoreButton:(BOOL)isSelected;

/**
 *  文字输入框开始编辑
 *
 *  @param inputTextView 输入框对象
 */
- (void)inputTextViewDidBeginEditing:(XHMessageTextView *)messageInputTextView;

/**
 *  文字输入框将要开始编辑
 *
 *  @param inputTextView 输入框对象
 */
- (void)inputTextViewWillBeginEditing:(XHMessageTextView *)messageInputTextView;

/**
 *  发送文字消息，可能包含系统自带表情
 *
 *  @param text 文字消息
 */
- (void)didSendText:(NSString *)text;

/**
 *  发送表情MM大表情
 *
 *  @param emoji 表情对象
 */
- (void)didSendMMFace:(MMEmoji *)emoji;

/**
 *  发送第三方表情，不会添加到文字输入框中
 *
 *  @param faceLocalPath 选中的表情的本地路径
 */
- (void)didSendFace:(NSString *)faceLocalPath;

/**
 *  按下录音按钮开始录音
 */
- (void)didStartRecordingVoiceAction:(UIView *)recordView;
/**
 *  手指向上滑动取消录音
 */
- (void)didCancelRecordingVoiceAction:(UIView *)recordView;
/**
 *  松开手指完成录音
 */
- (void)didFinishRecoingVoiceAction:(UIView *)recordView;
/**
 *  当手指离开按钮的范围内时，主要为了通知外部的HUD
 */
- (void)didDragOutsideAction:(UIView *)recordView;
/**
 *  当手指再次进入按钮的范围内时，主要也是为了通知外部的HUD
 */
- (void)didDragInsideAction:(UIView *)recordView;

@required
/**
 *  高度变到toHeight
 */
- (void)didChangeFrameToHeight:(CGFloat)toHeight;

@end
