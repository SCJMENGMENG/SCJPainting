//
//  FontViewController.h
//  SCJPainting
//
//  Created by scj on 2020/10/13.
//  Copyright © 2020 scj. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

typedef void (^FontVCPopBlock)(UIImage *image);

@interface FontViewController : UIViewController

@property (nonatomic, copy) FontVCPopBlock fontVCPopBlock;

+ (void)openFontVCWithDiyBgImage:(UIImage *)bgImage baseView:(UIViewController *)vc lastImage:(UIImage *)lastImage confirmBlock:(FontVCPopBlock)fontVCPopBlock;

@end

NS_ASSUME_NONNULL_END
