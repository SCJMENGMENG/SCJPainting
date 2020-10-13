//
//  DrawViewController.h
//  SCJPainting
//
//  Created by scj on 2020/10/13.
//  Copyright © 2020 scj. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

typedef void (^DrawVCPopBlock)(UIImage *drawImage);

@interface DrawViewController : UIViewController

@property (nonatomic, copy) DrawVCPopBlock drawVCPopBlock;

+ (void)openDrawVCWithDiyBgImage:(UIImage *)bgImage baseVC:(UIViewController *)vc lastImage:(UIImage *)lastImage saveBlock:(DrawVCPopBlock)drawVCPopBlock;
@end

NS_ASSUME_NONNULL_END
