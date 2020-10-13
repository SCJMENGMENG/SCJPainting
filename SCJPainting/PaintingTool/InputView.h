//
//  InputView.h
//  SCJPainting
//
//  Created by scj on 2020/10/13.
//  Copyright © 2020 scj. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface InputView : UIView

@property (nonatomic, copy) NSString *textViewText;

@property (nonatomic, assign) BOOL textViewFirstResponder;

/// 键盘弹起和隐藏
@property (nonatomic, copy) void(^keyboardShowOrHideBlock)(BOOL hidden, CGFloat keyboardHeight);
/// 确认按钮点击
@property (nonatomic, copy) void(^textConfirmBlock)(NSString *text);
/// 文本框高度变化
@property (nonatomic, copy) void(^textViewHeightChangeBlock)(CGFloat height);

@property (nonatomic, copy) void(^textChangedBlock)(NSString *text);
@end

NS_ASSUME_NONNULL_END
