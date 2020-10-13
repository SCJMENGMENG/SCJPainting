//
//  ArtboardView.h
//  SCJPainting
//
//  Created by scj on 2020/10/13.
//  Copyright © 2020 scj. All rights reserved.
//

#import <UIKit/UIKit.h>

#define kScreenWidth  [UIScreen mainScreen].bounds.size.width
#define kArtboardViewMargin 15
#define kArtboardViewWidth (kScreenWidth - kArtboardViewMargin*2)

NS_ASSUME_NONNULL_BEGIN

@interface ArtboardView : UIView

/// 线宽
@property (nonatomic, assign) CGFloat lineWidth;
/// 画线的颜色 默认蓝色
@property (nonatomic, strong) UIColor *lineColor;
/// 是否是橡皮擦状态
@property (nonatomic, assign) BOOL isErase;
/// 回退
- (void)back;
/// 前进
- (void)next;
/// 清屏
- (void)clearScreen;

/// 截屏
- (UIImage *)snapshot;
/// 触摸屏幕结束回调
@property (nonatomic, copy) void(^touchesEndedBlock)(NSArray *pathArr, NSArray * backPathArr);
/// 前进和后腿操作后的回调
@property (nonatomic, copy) void(^revokeAndBackClickBlock)(NSArray *pathArr, NSArray * backPathArr);
/// 捏合回调
@property (nonatomic, copy) void(^pinchGestureBlock) (UIView *artboardView, CGFloat scale);
/// 画板平移回调
@property (nonatomic, copy) void(^panGestureBlock) (UIView *artboardView);

@end

NS_ASSUME_NONNULL_END
