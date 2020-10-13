//
//  ColorSelectCell.h
//  SCJPainting
//
//  Created by scj on 2020/10/13.
//  Copyright © 2020 scj. All rights reserved.
//

#import <UIKit/UIKit.h>
@class ColorSelectModel;

#define kItemWidth 24
#define kCellWidth (kItemWidth + 14)

NS_ASSUME_NONNULL_BEGIN

@interface ColorSelectCell : UICollectionViewCell

@property (nonatomic, assign) NSInteger indexPathRow;

@property (nonatomic, strong) ColorSelectModel *model;
@end

NS_ASSUME_NONNULL_END
