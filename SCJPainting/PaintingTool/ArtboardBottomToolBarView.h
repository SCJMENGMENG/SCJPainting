//
//  ArtboardBottomToolBarView.h
//  SCJPainting
//
//  Created by scj on 2020/10/13.
//  Copyright © 2020 scj. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface ArtboardBottomToolBarView : UIView

@property (nonatomic, copy) void(^brushBtnClickBlock)(CGFloat brushSliderValue);
@property (nonatomic, copy) void(^eraserBtnClickBlock)(CGFloat eraserSliderValue);
@property (nonatomic, copy) void(^sliderChangedBlock)(CGFloat sliderValue);
@property (nonatomic, copy) void(^colorChangedBlock)(UIColor *color);

// 是否选中橡皮擦
@property (nonatomic, assign) BOOL isSelectedEraser;

@end

NS_ASSUME_NONNULL_END
