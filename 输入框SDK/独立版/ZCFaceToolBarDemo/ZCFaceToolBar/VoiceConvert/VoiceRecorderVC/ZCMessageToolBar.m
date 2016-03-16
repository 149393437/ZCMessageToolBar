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

#import "ZCMessageToolBar.h"


#import "LocationViewController.h"
#import <AVFoundation/AVFoundation.h>
#import "Photo.h"

@interface DXMessageToolBar()<UITextViewDelegate, MMEmotionCentreDelegate>
{
    CGFloat _previousTextViewContentHeight;//上一次inputTextView的contentSize.height
}

@property (nonatomic) CGFloat version;

/**
 *  背景
 */
@property (strong, nonatomic) UIImageView *toolbarBackgroundImageView;
@property (strong, nonatomic) UIImageView *backgroundImageView;

/**
 *  按钮、输入框、toolbarView
 */
@property (strong, nonatomic) UIView *toolbarView;
@property (strong, nonatomic) UIButton *styleChangeButton;
@property (strong, nonatomic) UIButton *moreButton;
@property (strong, nonatomic) UIButton *faceButton;

/**
 *  底部扩展页面
 */
@property (nonatomic) BOOL isShowButtomView;
@property (strong, nonatomic) UIView *activityButtomView;//当前活跃的底部扩展页面

@end

@implementation DXMessageToolBar
-(instancetype)initWithFrame:(CGRect)frame Block:(void(^)(NSString*sign,NSString*message))a
{
    //对数据进行适配修改
    if (frame.size.height < (kVerticalPadding * 2 + kInputTextViewMinHeight)) {
        frame.size.height = kVerticalPadding * 2 + kInputTextViewMinHeight;
    }
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        [self setupConfigure];
        [self setupSubviews];
        //对表情包进行初始化操作
        [[MMEmotionCentre defaultCentre] setAppId:BQMM_APPID secret:BQMM_SECRET];
        [MMEmotionCentre defaultCentre].delegate = self;
        
        self.MyBlock=a;
    }
    return self;
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillChangeFrameNotification object:nil];
    
    _delegate = nil;
    _inputTextView.delegate = nil;
    _inputTextView = nil;
}

#pragma mark - getter

- (UIImageView *)backgroundImageView
{
    if (_backgroundImageView == nil) {
        _backgroundImageView = [[UIImageView alloc] initWithFrame:self.bounds];
        _backgroundImageView.backgroundColor = [UIColor clearColor];
        _backgroundImageView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
    }
    
    return _backgroundImageView;
}

- (UIImageView *)toolbarBackgroundImageView
{
    if (_toolbarBackgroundImageView == nil) {
        _toolbarBackgroundImageView = [[UIImageView alloc] init];
        _toolbarBackgroundImageView.backgroundColor = [UIColor clearColor];
        _toolbarBackgroundImageView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    }
    
    return _toolbarBackgroundImageView;
}

- (UIView *)toolbarView
{
    if (_toolbarView == nil) {
        _toolbarView = [[UIView alloc] init];
        _toolbarView.backgroundColor = [UIColor clearColor];
    }
    
    return _toolbarView;
}

#pragma mark - setter

- (void)setBackgroundImage:(UIImage *)backgroundImage
{
    _backgroundImage = backgroundImage;
    self.backgroundImageView.image = backgroundImage;
}

- (void)setToolbarBackgroundImage:(UIImage *)toolbarBackgroundImage
{
    _toolbarBackgroundImage = toolbarBackgroundImage;
    self.toolbarBackgroundImageView.image = toolbarBackgroundImage;
}

- (void)setMaxTextInputViewHeight:(CGFloat)maxTextInputViewHeight
{
    if (maxTextInputViewHeight > kInputTextViewMaxHeight) {
        maxTextInputViewHeight = kInputTextViewMaxHeight;
    }
    _maxTextInputViewHeight = maxTextInputViewHeight;
}

#pragma mark - UITextViewDelegate

- (BOOL)textViewShouldBeginEditing:(UITextView *)textView
{
    if ([self.delegate respondsToSelector:@selector(inputTextViewWillBeginEditing:)]) {
        [self.delegate inputTextViewWillBeginEditing:self.inputTextView];
    }
    
    self.faceButton.selected = NO;
    self.styleChangeButton.selected = NO;
    self.moreButton.selected = NO;
    return YES;
}

- (void)textViewDidBeginEditing:(UITextView *)textView
{
    [textView becomeFirstResponder];
    
    if ([self.delegate respondsToSelector:@selector(inputTextViewDidBeginEditing:)]) {
        [self.delegate inputTextViewDidBeginEditing:self.inputTextView];
    }
}

- (void)textViewDidEndEditing:(UITextView *)textView
{
    [textView resignFirstResponder];
}

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text
{
    if ([text isEqualToString:@"\n"]) {
        
      __block  NSString *sendStr = @"";
        if (self.MyBlock) {
            [MMTextParser localParseMMText:textView.mmText completionHandler:^(NSArray *textImgArray) {
                NSDictionary *ext = nil;
                for (id obj in textImgArray) {
                    if ([obj isKindOfClass:[MMEmoji class]]) {
                        MMEmoji *emoji = (MMEmoji*)obj;
                        if (!ext) {
                            ext = @{@"txt_msgType":@"emojitype",
                                    @"msg_data":[MMTextParser extDataWithTextImageArray:textImgArray]};
                        }
                        sendStr = [sendStr stringByAppendingString:[NSString stringWithFormat:@"[%@]", emoji.emojiName]];
                    }
                    else if ([obj isKindOfClass:[NSString class]]) {
                        sendStr = [sendStr stringByAppendingString:obj];
                    }
                }
            }];
            
            if (sendStr) {
                self.MyBlock(@"[1]",sendStr);
            }else{
                self.MyBlock(@"[1]",textView.mmText);

            }
            self.inputTextView.text = @"";
            [self willShowInputTextViewToHeight:[self getTextViewContentH:self.inputTextView]];
        }
        
        return NO;
    }
    return YES;
}

- (void)textViewDidChange:(UITextView *)textView
{
    if (textView.markedTextRange == nil) {
        NSRange selectedRange = textView.selectedRange;
        textView.mmText = textView.mmText;
        textView.selectedRange = selectedRange;
    }
    [self willShowInputTextViewToHeight:[self getTextViewContentH:textView]];
}

#pragma mark - UIKeyboardNotification

- (void)keyboardWillChangeFrame:(NSNotification *)notification
{
    NSDictionary *userInfo = notification.userInfo;
    CGRect endFrame = [userInfo[UIKeyboardFrameEndUserInfoKey] CGRectValue];
    CGRect beginFrame = [userInfo[UIKeyboardFrameBeginUserInfoKey] CGRectValue];
    CGFloat duration = [userInfo[UIKeyboardAnimationDurationUserInfoKey] doubleValue];
    UIViewAnimationCurve curve = [userInfo[UIKeyboardAnimationCurveUserInfoKey] integerValue];
    
    void(^animations)() = ^{
        [self willShowKeyboardFromFrame:beginFrame toFrame:endFrame];
    };
    
    void(^completion)(BOOL) = ^(BOOL finished){
    };
    
    [UIView animateWithDuration:duration delay:0.0f options:(curve << 16 | UIViewAnimationOptionBeginFromCurrentState) animations:animations completion:completion];
}

#pragma mark - private

/**
 *  设置初始属性
 */
- (void)setupConfigure
{
    self.version = [[[UIDevice currentDevice] systemVersion] floatValue];
    
    self.maxTextInputViewHeight = kInputTextViewMaxHeight;
    
    self.activityButtomView = nil;
    self.isShowButtomView = NO;
    self.backgroundImageView.image = [[UIImage imageNamed:@"messageToolbarBg"] stretchableImageWithLeftCapWidth:0.5 topCapHeight:10];
    [self addSubview:self.backgroundImageView];
    
    self.toolbarView.frame = CGRectMake(0, 0, self.frame.size.width, kVerticalPadding * 2 + kInputTextViewMinHeight);
    self.toolbarBackgroundImageView.frame = self.toolbarView.bounds;
    [self.toolbarView addSubview:self.toolbarBackgroundImageView];
    [self addSubview:self.toolbarView];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillChangeFrame:) name:UIKeyboardWillChangeFrameNotification object:nil];
}

- (void)setupSubviews
{
    CGFloat allButtonWidth = 0.0;
    CGFloat textViewLeftMargin = 6.0;
    
    //转变输入样式
    self.styleChangeButton = [[UIButton alloc] initWithFrame:CGRectMake(kHorizontalPadding, kVerticalPadding, kInputTextViewMinHeight, kInputTextViewMinHeight)];
    self.styleChangeButton.autoresizingMask = UIViewAutoresizingFlexibleTopMargin;
    [self.styleChangeButton setImage:[UIImage imageNamed:@"chatBar_record"] forState:UIControlStateNormal];
    [self.styleChangeButton setImage:[UIImage imageNamed:@"chatBar_keyboard"] forState:UIControlStateSelected];
    [self.styleChangeButton addTarget:self action:@selector(buttonAction:) forControlEvents:UIControlEventTouchUpInside];
    self.styleChangeButton.tag = 0;
    allButtonWidth += CGRectGetMaxX(self.styleChangeButton.frame);
    textViewLeftMargin += CGRectGetMaxX(self.styleChangeButton.frame);
    
    //更多
    self.moreButton = [[UIButton alloc] initWithFrame:CGRectMake(CGRectGetWidth(self.bounds) - kHorizontalPadding - kInputTextViewMinHeight, kVerticalPadding, kInputTextViewMinHeight, kInputTextViewMinHeight)];
    self.moreButton.autoresizingMask = UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleLeftMargin;
    [self.moreButton setImage:[UIImage imageNamed:@"chatBar_more"] forState:UIControlStateNormal];
    [self.moreButton setImage:[UIImage imageNamed:@"chatBar_moreSelected"] forState:UIControlStateHighlighted];
    [self.moreButton setImage:[UIImage imageNamed:@"chatBar_keyboard"] forState:UIControlStateSelected];
    [self.moreButton addTarget:self action:@selector(buttonAction:) forControlEvents:UIControlEventTouchUpInside];
    self.moreButton.tag = 2;
    allButtonWidth += CGRectGetWidth(self.moreButton.frame) + kHorizontalPadding * 2.5;
    
    //表情
    self.faceButton = [[UIButton alloc] initWithFrame:CGRectMake(CGRectGetMinX(self.moreButton.frame) - kInputTextViewMinHeight - kHorizontalPadding, kVerticalPadding, kInputTextViewMinHeight, kInputTextViewMinHeight)];
    self.faceButton.autoresizingMask = UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleLeftMargin;
    [self.faceButton setImage:[UIImage imageNamed:@"chatBar_face"] forState:UIControlStateNormal];
    [self.faceButton setImage:[UIImage imageNamed:@"chatBar_faceSelected"] forState:UIControlStateHighlighted];
    [self.faceButton setImage:[UIImage imageNamed:@"chatBar_keyboard"] forState:UIControlStateSelected];
    [self.faceButton addTarget:self action:@selector(buttonAction:) forControlEvents:UIControlEventTouchUpInside];
    self.faceButton.tag = 1;
    allButtonWidth += CGRectGetWidth(self.faceButton.frame) + kHorizontalPadding * 1.5;
    
    
    // 输入框的高度和宽度
    CGFloat width = CGRectGetWidth(self.bounds) - (allButtonWidth ? allButtonWidth : (textViewLeftMargin * 2));
    // 初始化输入框
    self.inputTextView = [[XHMessageTextView  alloc] initWithFrame:CGRectMake(textViewLeftMargin, kVerticalPadding, width, kInputTextViewMinHeight)];
    self.inputTextView.autoresizingMask = UIViewAutoresizingFlexibleHeight;
//    self.inputTextView.contentMode = UIViewContentModeCenter;
    _inputTextView.scrollEnabled = YES;
    _inputTextView.returnKeyType = UIReturnKeySend;
    _inputTextView.enablesReturnKeyAutomatically = YES; // UITextView内部判断send按钮是否可以用
    _inputTextView.placeHolder = @"请输入内容";
    _inputTextView.delegate = self;
    _inputTextView.backgroundColor = [UIColor clearColor];
    _inputTextView.layer.borderColor = [UIColor colorWithWhite:0.8f alpha:1.0f].CGColor;
    _inputTextView.layer.borderWidth = 0.65f;
    _inputTextView.layer.cornerRadius = 6.0f;
    _previousTextViewContentHeight = [self getTextViewContentH:_inputTextView];
    
    //录制
    self.recordButton = [[UIButton alloc] initWithFrame:CGRectMake(textViewLeftMargin, kVerticalPadding, width, kInputTextViewMinHeight)];
    self.recordButton.titleLabel.font = [UIFont systemFontOfSize:15.0];
    [self.recordButton setTitleColor:[UIColor darkGrayColor] forState:UIControlStateNormal];
    [self.recordButton setBackgroundImage:[[UIImage imageNamed:@"chatBar_recordBg"] stretchableImageWithLeftCapWidth:10 topCapHeight:10] forState:UIControlStateNormal];
    [self.recordButton setBackgroundImage:[[UIImage imageNamed:@"chatBar_recordSelectedBg"] stretchableImageWithLeftCapWidth:10 topCapHeight:10] forState:UIControlStateHighlighted];
    [self.recordButton setTitle:@"按住 说话" forState:UIControlStateNormal];
    [self.recordButton setTitle:@"松开 结束" forState:UIControlStateHighlighted];
    self.recordButton.hidden = YES;
    [self.recordButton addTarget:self action:@selector(recordButtonTouchDown) forControlEvents:UIControlEventTouchDown];
    [self.recordButton addTarget:self action:@selector(recordButtonTouchUpOutside) forControlEvents:UIControlEventTouchUpOutside];
    [self.recordButton addTarget:self action:@selector(recordButtonTouchUpInside) forControlEvents:UIControlEventTouchUpInside];
    [self.recordButton addTarget:self action:@selector(recordDragOutside) forControlEvents:UIControlEventTouchDragExit];
    [self.recordButton addTarget:self action:@selector(recordDragInside) forControlEvents:UIControlEventTouchDragEnter];
    self.recordButton.hidden = YES;
    
    if (!_moreView) {
        _moreView = [[ZCChatBarMoreView alloc] initWithFrame:CGRectMake(0, (kVerticalPadding * 2 + kInputTextViewMinHeight), self.frame.size.width, 80) type:ChatMoreTypeGroupChat];
        _moreView.delegate=self;
        _moreView.backgroundColor = [UIColor lightGrayColor];
        _moreView.autoresizingMask = UIViewAutoresizingFlexibleTopMargin;
    }
    
    [self.toolbarView addSubview:self.styleChangeButton];
    [self.toolbarView addSubview:self.moreButton];
    [self.toolbarView addSubview:self.faceButton];
    [self.toolbarView addSubview:self.inputTextView];
    [self.toolbarView addSubview:self.recordButton];
    
    [[MMEmotionCentre defaultCentre] shouldShowShotcutPopoverAboveView:self.faceButton withInput:self.inputTextView];
}
#pragma mark DXChatBarMoreViewDelegate

- (void)moreViewTakePicAction:(ZCChatBarMoreView *)moreView
{
    NSLog(@"相机");
    
    UIImagePickerController*vc=[[UIImagePickerController alloc]init];
    vc.delegate=self;
    if ([UIImagePickerController isCameraDeviceAvailable:UIImagePickerControllerCameraDeviceRear]) {
        vc.sourceType=UIImagePickerControllerSourceTypeCamera;
    }
    //获取顶层VC
    UIViewController*top;
    for (UIView* next = [self superview]; next; next = next.superview) {
        UIResponder* nextResponder = [next nextResponder];
        if ([nextResponder isKindOfClass:[UIViewController class]]) {
            top=(UIViewController*)nextResponder;
        }  
    }
    if (top) {
        [top presentViewController:vc animated:YES completion:nil];
    }
    
    
}
- (void)moreViewPhotoAction:(ZCChatBarMoreView *)moreView
{
    NSLog(@"相册");
    UIImagePickerController*vc=[[UIImagePickerController alloc]init];
    vc.delegate=self;
    //获取顶层VC
    UIViewController*top;
    for (UIView* next = [self superview]; next; next = next.superview) {
        UIResponder* nextResponder = [next nextResponder];
        if ([nextResponder isKindOfClass:[UIViewController class]]) {
            top=(UIViewController*)nextResponder;
        }
    }
    if (top) {
        [top presentViewController:vc animated:YES completion:nil];
    }
}
-(void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary<NSString *,id> *)info
{
    UIImage*image=[info objectForKey:UIImagePickerControllerOriginalImage];
    NSString*str=[Photo image2String:image];
    self.MyBlock(@"[3]",str);
    
    [picker dismissViewControllerAnimated:YES completion:nil];

}

-(void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{

    [picker dismissViewControllerAnimated:YES completion:nil];

}


- (void)moreViewLocationAction:(ZCChatBarMoreView *)moreView
{
    NSLog(@"定位");
    LocationViewController*vc=[[LocationViewController alloc]initWithBlock:^(NSString *locationStr) {
        self.MyBlock(@"[5]",locationStr);

    }];
    
    //获取顶层VC
    UIViewController*top;
    for (UIView* next = [self superview]; next; next = next.superview) {
        UIResponder* nextResponder = [next nextResponder];
        if ([nextResponder isKindOfClass:[UIViewController class]]) {
            top=(UIViewController*)nextResponder;
        }
    }
    if (top) {
        [top presentViewController:vc animated:YES completion:nil];
    }
}
- (void)moreViewAudioCallAction:(ZCChatBarMoreView *)moreView
{
    NSLog(@"音频");
}
- (void)moreViewVideoCallAction:(ZCChatBarMoreView *)moreView
{
    NSLog(@"视频");
}

#pragma mark - change frame

- (void)willShowBottomHeight:(CGFloat)bottomHeight
{
    CGRect fromFrame = self.frame;
    CGFloat toHeight = self.toolbarView.frame.size.height + bottomHeight;
    CGRect toFrame = CGRectMake(fromFrame.origin.x, fromFrame.origin.y + (fromFrame.size.height - toHeight), fromFrame.size.width, toHeight);
    
    //如果需要将所有扩展页面都隐藏，而此时已经隐藏了所有扩展页面，则不进行任何操作
    if(bottomHeight == 0 && self.frame.size.height == self.toolbarView.frame.size.height)
    {
        return;
    }
    
    if (bottomHeight == 0) {
        self.isShowButtomView = NO;
    }
    else{
        self.isShowButtomView = YES;
    }
    
    self.frame = toFrame;
    
    if (_delegate && [_delegate respondsToSelector:@selector(didChangeFrameToHeight:)]) {
        [_delegate didChangeFrameToHeight:toHeight];
    }
}

- (void)willShowBottomView:(UIView *)bottomView
{
    if (![self.activityButtomView isEqual:bottomView]) {
        CGFloat bottomHeight = bottomView ? bottomView.frame.size.height : 0;
        [self willShowBottomHeight:bottomHeight];
        
        if (bottomView) {
            CGRect rect = bottomView.frame;
            rect.origin.y = CGRectGetMaxY(self.toolbarView.frame);
            bottomView.frame = rect;
            [self addSubview:bottomView];
        }
        
        if (self.activityButtomView) {
            [self.activityButtomView removeFromSuperview];
        }
        self.activityButtomView = bottomView;
    }
}

- (void)willShowKeyboardFromFrame:(CGRect)beginFrame toFrame:(CGRect)toFrame
{
    if (beginFrame.origin.y == [[UIScreen mainScreen] bounds].size.height)
    {
        //一定要把self.activityButtomView置为空
        [self willShowBottomHeight:toFrame.size.height];
        if (self.activityButtomView) {
            [self.activityButtomView removeFromSuperview];
        }
        self.activityButtomView = nil;
    }
    else if (toFrame.origin.y == [[UIScreen mainScreen] bounds].size.height)
    {
        [self willShowBottomHeight:0];
    }
    else{
        [self willShowBottomHeight:toFrame.size.height];
    }
}

- (void)willShowInputTextViewToHeight:(CGFloat)toHeight
{
    if (toHeight < kInputTextViewMinHeight) {
        toHeight = kInputTextViewMinHeight;
    }
    if (toHeight > self.maxTextInputViewHeight) {
        toHeight = self.maxTextInputViewHeight;
    }
    
    if (toHeight == _previousTextViewContentHeight)
    {
        return;
    }
    else{
        CGFloat changeHeight = toHeight - _previousTextViewContentHeight;
        
        CGRect rect = self.frame;
        rect.size.height += changeHeight;
        rect.origin.y -= changeHeight;
        self.frame = rect;
        
        rect = self.toolbarView.frame;
        rect.size.height += changeHeight;
        self.toolbarView.frame = rect;
        
        if (self.version < 7.0) {
            [self.inputTextView setContentOffset:CGPointMake(0.0f, (self.inputTextView.contentSize.height - self.inputTextView.frame.size.height) / 2) animated:YES];
        }
        _previousTextViewContentHeight = toHeight;
        
        if (_delegate && [_delegate respondsToSelector:@selector(didChangeFrameToHeight:)]) {
            [_delegate didChangeFrameToHeight:self.frame.size.height];
        }
    }
}

- (CGFloat)getTextViewContentH:(UITextView *)textView
{
    if (self.version >= 7.0)
    {
        return ceilf([textView sizeThatFits:textView.frame.size].height);
    } else {
        return textView.contentSize.height;
    }
}

#pragma mark - action

- (void)buttonAction:(id)sender
{
    UIButton *button = (UIButton *)sender;
    button.selected = !button.selected;
    NSInteger tag = button.tag;
    
    switch (tag) {
        case 0://切换状态
        {
            if (button.selected) {
                self.faceButton.selected = NO;
                self.moreButton.selected = NO;
                //录音状态下，不显示底部扩展页面
                [self willShowBottomView:nil];
                
                //将inputTextView内容置空，以使toolbarView回到最小高度
                self.inputTextView.text = @"";
                [self textViewDidChange:self.inputTextView];
                [self.inputTextView resignFirstResponder];
            }
            else{
                //键盘也算一种底部扩展页面
                [self.inputTextView becomeFirstResponder];
            }
            
            [UIView animateWithDuration:0.2 delay:0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
                self.recordButton.hidden = !button.selected;
                self.inputTextView.hidden = button.selected;
            } completion:^(BOOL finished) {
                
            }];
            
            if ([self.delegate respondsToSelector:@selector(didStyleChangeToRecord:)]) {
                [self.delegate didStyleChangeToRecord:button.selected];
            }
        }
            break;
        case 1://表情
        {

            if (self.styleChangeButton.selected) {
                self.styleChangeButton.selected = NO;
                self.recordButton.hidden = YES;
                self.inputTextView.hidden = NO;
            }
            if (button.isSelected) {
                self.moreButton.selected = NO;
                
                if (!_inputTextView.isFirstResponder) {
                    [_inputTextView becomeFirstResponder];
                }
                [[MMEmotionCentre defaultCentre] attachEmotionKeyboardToInput:_inputTextView];
                self.faceButton.selected = YES;
            }
            else {
                [[MMEmotionCentre defaultCentre] switchToDefaultKeyboard];
            }
        }
            break;
        case 2://更多
        {
            if (button.selected) {
                self.faceButton.selected = NO;
                //如果选择表情并且处于录音状态，切换成文字输入状态，但是不显示键盘
                if (self.styleChangeButton.selected) {
                    self.styleChangeButton.selected = NO;
                }
                else{//如果处于文字输入状态，使文字输入框失去焦点
                    [self.inputTextView resignFirstResponder];
                }

                [self willShowBottomView:self.moreView];
                [UIView animateWithDuration:0.2 delay:0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
                    self.recordButton.hidden = button.selected;
                    self.inputTextView.hidden = !button.selected;
                } completion:^(BOOL finished) {
                    
                }];
            }
            else
            {
                self.styleChangeButton.selected = NO;
                [self.inputTextView becomeFirstResponder];
            }
        }
            break;
            
        default:
            break;
    }
}

#pragma mark 开始录音
- (void)recordButtonTouchDown
{
    if (_audio==nil) {
        //加载录音模块
        _audio=[ZCChatAudioPlay sharedInstance];

    }
    [_audio startRecording];
    
    if (_audio) {
        _audio.recorderVC.recorderView.countDownLabel.text=@"松开手指,发送语音";
        _audio.recorderVC.recorderView.backgroundColor=[UIColor clearColor];

    }

}
#pragma mark  取消录音
- (void)recordButtonTouchUpOutside
{
    if (_audio) {
        _audio.recorderVC.recorderView.countDownLabel.text=@"松开手指,取消录音";
        _audio.recorderVC.recorderView.backgroundColor=[UIColor redColor];
    }
    
    //结束录音
    if (_audio) {
        [_audio endRecordingWithBlock:^(NSString *aa) {
            
        }];
        //不进行处理
    }

}
#pragma mark 手指松开完成录音
- (void)recordButtonTouchUpInside
{
    if (_audio) {
        _audio.recorderVC.recorderView.countDownLabel.text=@"结束录音";
        _audio.recorderVC.recorderView.backgroundColor=[UIColor clearColor];
    }

    [_audio endRecordingWithBlock:^(NSString *aa) {
        if (self.MyBlock) {
            self.MyBlock(@"[2]",aa);
        }
        
    }];
   
}
#pragma makr  手指移动到录音按钮外部

- (void)recordDragOutside
{
    if (_audio) {

    _audio.recorderVC.recorderView.countDownLabel.text=@"松开手指,取消录音";
    _audio.recorderVC.recorderView.backgroundColor=[UIColor redColor];
    
    }

}
#pragma mark 手指移动到录音按钮内部
- (void)recordDragInside
{
    if (_audio) {

    _audio.recorderVC.recorderView.backgroundColor=[UIColor clearColor];
    _audio.recorderVC.recorderView.countDownLabel.text=@"手指上滑,取消发送";
    }
}

#pragma mark - public

/**
 *  停止编辑
 */
- (BOOL)endEditing:(BOOL)force
{
    BOOL result = [super endEditing:force];
    
    self.faceButton.selected = NO;
    self.moreButton.selected = NO;
    [self willShowBottomView:nil];
    [[MMEmotionCentre defaultCentre] switchToDefaultKeyboard];
    
    return result;
}



+ (CGFloat)defaultHeight
{
    return kVerticalPadding * 2 + kInputTextViewMinHeight;
}

//表情MM代理
#pragma mark - *MMEmotionCentreDelegate
- (void)didSelectEmoji:(MMEmoji *)emoji
{
    if (self.MyBlock) {
        self.MyBlock(@"[4]",emoji.emojiName);
    }
  
}

- (void)didSelectTipEmoji:(MMEmoji *)emoji
{
    if (self.MyBlock) {
        self.MyBlock(@"[4]",emoji.emojiName);
        self.inputTextView.text = @"";
    }
}

- (void)didSendWithInput:(UIResponder<UITextInput> *)input
{
    if (self.MyBlock) {
        __block  NSString *sendStr = @"";
        [MMTextParser localParseMMText:_inputTextView.mmText completionHandler:^(NSArray *textImgArray) {
            NSDictionary *ext = nil;
            for (id obj in textImgArray) {
                if ([obj isKindOfClass:[MMEmoji class]]) {
                    MMEmoji *emoji = (MMEmoji*)obj;
                    if (!ext) {
                        ext = @{@"txt_msgType":@"emojitype",
                                @"msg_data":[MMTextParser extDataWithTextImageArray:textImgArray]};
                    }
                    sendStr = [sendStr stringByAppendingString:[NSString stringWithFormat:@"[%@]", emoji.emojiName]];
                }
                else if ([obj isKindOfClass:[NSString class]]) {
                    sendStr = [sendStr stringByAppendingString:obj];
                }
            }
        }];

        if (sendStr) {
            self.MyBlock(@"[1]",sendStr);
        }else{
            self.MyBlock(@"[1]",_inputTextView.mmText);
        }
        self.inputTextView.text = @"";
        [self willShowInputTextViewToHeight:[self getTextViewContentH:self.inputTextView]];
    }
}

- (void)tapOverlay
{
    self.faceButton.selected = NO;
}

@end













