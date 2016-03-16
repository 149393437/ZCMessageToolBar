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
#import <MapKit/MapKit.h>

@protocol LocationViewDelegate <NSObject>

-(void)sendLocationLatitude:(double)latitude
                  longitude:(double)longitude
                 andAddress:(NSString *)address;
@end

@interface LocationViewController : UIViewController

@property (nonatomic, assign) id<LocationViewDelegate> delegate;
@property (nonatomic,copy)void(^myBlock)(NSString*str);
@property(nonatomic,copy)NSString*locationStr;
- (instancetype)initWithLocation:(CLLocationCoordinate2D)locationCoordinate;
-(instancetype)initWithBlock:(void(^)(NSString*locationStr))a;


@end
