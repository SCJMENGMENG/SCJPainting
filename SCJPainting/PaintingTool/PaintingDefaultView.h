//
//  PaintingDefaultView.h
//  SCJPainting
//
//  Created by scj on 2020/10/13.
//  Copyright © 2020 scj. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface PaintingDefaultView : UIView

/// 背景图
@property (nonatomic, strong) UIImage *bgImage;
/// 回退
- (void)back;
/// 前进
- (void)next;
/// 保存添加的图片
@property (nonatomic, strong) NSMutableArray *addImageArr;
/// 保存撤销的图片
@property (nonatomic, strong) NSMutableArray *backImageArr;

/// 添加截图
- (void)addImage:(UIImage *)image edit:(BOOL)isEdit;
/// 添加缓存的截图
- (void)addCacheImage:(NSArray *)imageArr;
/// 截屏
- (UIImage *)snapshot;
/// 合并图片
- (UIImage *)mergeImage;
/// 跳转下个页面或者点击保存时，清除撤销的数据
- (void)cleanRevokeImage;

/// 点击回退，前进时回调
@property (nonatomic, copy) void (^backAndNextClickBlock)(NSArray *imageArr, NSArray *backImageArr);

@end

NS_ASSUME_NONNULL_END
