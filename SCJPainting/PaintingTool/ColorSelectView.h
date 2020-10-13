//
//  ColorSelectView.h
//  SCJPainting
//
//  Created by scj on 2020/10/13.
//  Copyright © 2020 scj. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface ColorSelectView : UIView
@property (nonatomic, strong) NSArray <UIColor*> *colorArr;

/// 设置选中的颜色 - 通过index
@property (nonatomic, assign) NSInteger defaultSelectedIndex;
/// 设置选中的颜色 - 通过颜色
@property (nonatomic, strong) UIColor *selectedColor;

@property (nonatomic, assign) CGFloat edgeInsetsLeft;

@property (nonatomic, copy) void(^colorSelectedBlock)(UIColor *color);
@end

NS_ASSUME_NONNULL_END
