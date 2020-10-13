//
//  ColorSelectCell.m
//  SCJPainting
//
//  Created by scj on 2020/10/13.
//  Copyright © 2020 scj. All rights reserved.
//

#import "ColorSelectCell.h"
#import "ColorSelectModel.h"
#import "UIImage+SCJ.h"

#import <Masonry.h>

@interface ColorSelectCell ()
@property (nonatomic, strong) UIButton *colorBtn;

@property (nonatomic, strong) UIButton *lastSelectedBtn;
@property (nonatomic, strong) UIButton *lastSelectedBtnBgColor;
@end

@implementation ColorSelectCell

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        [self setupUI];
    }
    return self;
}

- (void)setIndexPathRow:(NSInteger)indexPathRow {
    _indexPathRow = indexPathRow;
    self.colorBtn.tag = indexPathRow;
}

- (void)setModel:(ColorSelectModel *)model {
    _model = model;
    
    self.colorBtn.selected = model.isSelected;
    
    [self.colorBtn setBackgroundImage:[UIImage imageNamed:@"diy_color_normal" imageColor:model.color] forState:UIControlStateNormal];
    
    [self.colorBtn setBackgroundImage:[UIImage imageNamed:@"diy_color_selected" imageColor:model.color] forState:UIControlStateSelected];
    
    if (self.indexPathRow == 0) {
        self.colorBtn.layer.borderColor = [UIColor colorWithRed:233/255.0 green:236/255.0 blue:247/255.0 alpha:1].CGColor;
        self.colorBtn.layer.borderWidth = model.isSelected ? 4 : 1;
    } else {
        self.colorBtn.layer.borderWidth = 0;
    }
}

- (void)setupUI {
    
    [self addSubview:self.colorBtn];
    
    [self.colorBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.center.equalTo(self);
        make.size.mas_equalTo(CGSizeMake(kItemWidth, kItemWidth));
    }];
}

- (UIButton *)colorBtn {
    if (!_colorBtn) {
        _colorBtn = [[UIButton alloc] init];
        _colorBtn.userInteractionEnabled = NO;
        _colorBtn.layer.cornerRadius = kItemWidth*0.5;
    }
    return _colorBtn;
}
@end
