//
//  PaintingBottomView.h
//  SCJPainting
//
//  Created by scj on 2020/10/13.
//  Copyright © 2020 scj. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface PaintingBottomView : UIView

@property (nonatomic, copy) void(^photoBtnClickBlock)(void);
@property (nonatomic, copy) void(^drawBtnClickBlock)(void);
@property (nonatomic, copy) void(^stickersBtnClickBlock)(void);
@property (nonatomic, copy) void(^fontBtnClickBlock)(void);

@end

NS_ASSUME_NONNULL_END
