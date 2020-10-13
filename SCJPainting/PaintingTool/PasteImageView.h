//
//  PasteImageView.h
//  SCJPainting
//
//  Created by scj on 2020/10/13.
//  Copyright © 2020 scj. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

/// 控制按钮半径
#define Ctrl_Radius 22/2.0

typedef NS_ENUM(NSInteger, PasteType) {
    /// 图片类型
    PasteTypeImage,
    /// 文本类型
    PasteTypeText
};

@interface PasteImageView : UIView

/// 类型
@property (nonatomic, assign) PasteType pasteType;
/// 是否是点击 - 用于区分拖动和点击
@property (nonatomic, assign) BOOL isTapGesture;
/// 输入的文字
@property (nonatomic, copy) NSString *text;
/// 文字的颜色
@property (nonatomic, strong) UIColor *textColor;
/// 是否移除
@property (nonatomic, assign) BOOL isRemove;

/// 是否处于可操作
@property (nonatomic, assign) BOOL isOperation;
/// 相册选择的图片
@property (nonatomic, strong) UIImage *image;
/// 点击image时的 Block - 使点击的视图在最上面
@property (nonatomic, copy) void(^clickPasteImageBlock)(UIView *clickView);
/// 移除block
@property (nonatomic, copy) void(^removeBlock)(PasteImageView *pasteImageView);

@end

NS_ASSUME_NONNULL_END
