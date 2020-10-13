//
//  ArtboardTopToolBarView.h
//  SCJPainting
//
//  Created by scj on 2020/10/13.
//  Copyright © 2020 scj. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface ArtboardTopToolBarView : UIView

/// 控制 撤消和回退按钮是否隐藏
@property (nonatomic, assign) BOOL revokeBtnAndBackBtnHidden;
/// 撤消按钮状态
@property (nonatomic, assign) BOOL revokeBtnSelected;
/// 回退按钮状态
@property (nonatomic, assign) BOOL backBtnSelected;

///
@property (nonatomic, assign) BOOL topLineHidden;
///
@property (nonatomic, assign) BOOL btmLineHidden;

/// 撤消按钮点击 block
@property (nonatomic, copy) void(^revokeBtnClickBlock) (void);
/// 回退按钮点击 block
@property (nonatomic, copy) void(^backBtnClickBlock) (void);
@end

NS_ASSUME_NONNULL_END
