//
//  CloseAndConfirmView.h
//  SCJPainting
//
//  Created by scj on 2020/10/13.
//  Copyright © 2020 scj. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface CloseAndConfirmView : UIView

@property (nonatomic, copy) void(^diyCloseAndConfirmBtnClickBlock)(NSInteger btnTag);
@end

NS_ASSUME_NONNULL_END
