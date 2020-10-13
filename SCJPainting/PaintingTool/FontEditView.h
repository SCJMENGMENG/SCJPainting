//
//  FontEditView.h
//  SCJPainting
//
//  Created by scj on 2020/10/13.
//  Copyright © 2020 scj. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface FontEditView : UIView

@property (nonatomic, strong) NSMutableArray *textViewList;

/// 添加文本框
- (void)addText;
/// 截屏
- (UIImage *)snapshot;

/// 拖动或者点击文本框
@property (nonatomic, copy) void(^textBoxPanOrTapBlock)(UIView *clickView, BOOL isOperation, BOOL isTapGesture);
@end

NS_ASSUME_NONNULL_END
