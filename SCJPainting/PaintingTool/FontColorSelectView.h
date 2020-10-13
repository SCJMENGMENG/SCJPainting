//
//  FontColorSelectView.h
//  SCJPainting
//
//  Created by scj on 2020/10/13.
//  Copyright © 2020 scj. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface FontColorSelectView : UIView

/// 当前颜色的index
@property (nonatomic, assign) NSInteger colorSelcetedIndex;
/// 当前选中的文本框的文本颜色
@property (nonatomic, strong) UIColor *currentTextColor;

@property (nonatomic, copy) void(^colorChangedBlock)(UIColor *selectedColor);
@property (nonatomic, copy) void(^addTextBtnClickBlock)(void);

@end

NS_ASSUME_NONNULL_END
