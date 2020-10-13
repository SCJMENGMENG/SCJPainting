//
//  FontColorSelectView.m
//  SCJPainting
//
//  Created by scj on 2020/10/13.
//  Copyright © 2020 scj. All rights reserved.
//

#import "FontColorSelectView.h"
#import "ColorSelectView.h"

#import <Masonry.h>

#define HEXColor(rgbValue) [UIColor colorWithRed:((float)((rgbValue & 0xFF0000) >> 16))/255.0 green:((float)((rgbValue &0xFF00) >>8))/255.0 blue:((float)(rgbValue &0xFF))/255.0 alpha:1.0]

@interface FontColorSelectView ()

@property (nonatomic, strong) UIImageView *shadowImage;

@property (nonatomic, strong) UIButton *addTextBtn;
/// 颜色选择
@property (nonatomic, strong) ColorSelectView *colorSelectView;
 
@end

@implementation FontColorSelectView

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        self.layer.cornerRadius = 20;
        [self setupUI];
    }
    return self;
}

- (void)setColorSelcetedIndex:(NSInteger)colorSelcetedIndex {
    _colorSelcetedIndex = colorSelcetedIndex;
    
    self.colorSelectView.defaultSelectedIndex = colorSelcetedIndex;
}

- (void)setCurrentTextColor:(UIColor *)currentTextColor {
    _currentTextColor = currentTextColor;
    self.colorSelectView.selectedColor = currentTextColor;
}

#pragma mark - Layout

- (void)setupUI {
    [self addSubview:self.shadowImage];
    [self addSubview:self.addTextBtn];
    [self addSubview:self.colorSelectView];
    
    [self.shadowImage mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.mas_top).offset(-6);
        make.left.right.equalTo(self);
    }];
    
    [self.addTextBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(self);
        make.left.equalTo(self.mas_left).offset(20);
        make.size.mas_equalTo(CGSizeMake(24, 24));
    }];
    
    [self.colorSelectView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(self);
        make.left.equalTo(self.addTextBtn.mas_right).offset(20);
        make.right.equalTo(self.mas_right).offset(0);
        make.height.mas_equalTo(24);
    }];
}

#pragma mark - 懒加载

- (UIImageView *)shadowImage {
    if (!_shadowImage) {
        _shadowImage = [[UIImageView alloc] init];
        _shadowImage.image = [UIImage imageNamed:@"diy_corner_shadow"];
    }
    return _shadowImage;
}

- (ColorSelectView *)colorSelectView {
    if (!_colorSelectView) {
        NSArray *colorArr = @[
            HEXColor(0xFFFFFF),
            HEXColor(0x000000),
            HEXColor(0xFF324A),
            HEXColor(0xBF16D7),
            HEXColor(0x7060E6),
            HEXColor(0x10AEFF),
            HEXColor(0x53D769),
            HEXColor(0x79C8A6),
            HEXColor(0xEADFFE),
            HEXColor(0xFEA0EC),
            HEXColor(0xFFA500),
            HEXColor(0xFFDF06),
        ];
        _colorSelectView = [[ColorSelectView alloc] init];
        _colorSelectView.colorArr = colorArr;
        _colorSelectView.defaultSelectedIndex = 1;
        _colorSelectView.edgeInsetsLeft = 0;
        
        __weak __typeof(&*self)weakSelf = self;
        _colorSelectView.colorSelectedBlock = ^(UIColor * _Nonnull color) {
            if (weakSelf.colorChangedBlock) {
                weakSelf.colorChangedBlock(color);
            }
        };
    }
    return _colorSelectView;
}

- (UIButton *)addTextBtn {
    if (!_addTextBtn) {
        _addTextBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [_addTextBtn setBackgroundImage:[UIImage imageNamed:@"diy_add_text"] forState:UIControlStateNormal];
        [_addTextBtn addTarget:self action:@selector(addTextBtnClick:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _addTextBtn;
}

- (void)addTextBtnClick:(UIButton *)btn {
    if (self.addTextBtnClickBlock) {
        self.addTextBtnClickBlock();
    }
}

@end
