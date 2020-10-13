//
//  ArtboardBottomToolBarView.m
//  SCJPainting
//
//  Created by scj on 2020/10/13.
//  Copyright © 2020 scj. All rights reserved.
//

#import "ArtboardBottomToolBarView.h"
#import "ColorSelectView.h"

#import <Masonry.h>

#define kCornerRadius 20

#define HEXColor(rgbValue) [UIColor colorWithRed:((float)((rgbValue & 0xFF0000) >> 16))/255.0 green:((float)((rgbValue &0xFF00) >>8))/255.0 blue:((float)(rgbValue &0xFF))/255.0 alpha:1.0]

@interface ArtboardBottomToolBarView ()
@property (nonatomic, strong) UIView *bgView;
/// 颜色选择
@property (nonatomic, strong) ColorSelectView *colorSelectView;
/// 画笔
@property (nonatomic, strong) UIButton *brushBtn;
/// 橡皮擦
@property (nonatomic, strong) UIButton *eraserBtn;
/// 进度条
//@property (nonatomic, strong) RWDIYSlider *progressSlider;
@property (nonatomic, strong) UISlider *progressSlider;

@property (nonatomic, strong) UIImageView *shadowImage;

@property (nonatomic, strong) UIButton *lastBtn;
@property (nonatomic, assign) float lastBrushSliderValue;
@property (nonatomic, assign) float lastEraserSliderValue;
@end

@implementation ArtboardBottomToolBarView

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        [self setupUI];
        
        self.lastBtn = self.brushBtn;
    }
    return self;
}

- (void)setIsSelectedEraser:(BOOL)isSelectedEraser {
    _isSelectedEraser = isSelectedEraser;
    
    self.colorSelectView.hidden = isSelectedEraser;
    
    if (isSelectedEraser) {
        self.progressSlider.minimumValue = 4;
        self.progressSlider.maximumValue = 64;
        self.progressSlider.value = self.lastEraserSliderValue ? self.lastEraserSliderValue : 34;
    } else {
        self.progressSlider.minimumValue = 2;
        self.progressSlider.maximumValue = 32;
        self.progressSlider.value = self.lastBrushSliderValue ? self.lastBrushSliderValue : 17;
    }
}

#pragma mark - Layout

- (void)setupUI {
    [self addSubview:self.bgView];
    [self.bgView addSubview:self.shadowImage];
    [self.bgView addSubview:self.colorSelectView];
    [self.bgView addSubview:self.brushBtn];
    [self.bgView addSubview:self.eraserBtn];
    [self.bgView addSubview:self.progressSlider];
    
    [self.bgView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self);
    }];
    
    [self.shadowImage mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.bgView.mas_top).offset(-6);
        make.left.right.equalTo(self.bgView);
    }];
    
    [self.colorSelectView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.equalTo(self.bgView.mas_centerY).offset(-12.5);
        make.left.equalTo(self.bgView.mas_left).offset(0);
        make.right.equalTo(self.bgView.mas_right).offset(0);
        make.height.mas_equalTo(24);
    }];
    
    [self.brushBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.equalTo(self.bgView.mas_bottom).offset(-25);
        make.left.equalTo(self.bgView.mas_left).offset(21);
        make.size.mas_equalTo(CGSizeMake(32, 32));
    }];
    
    [self.eraserBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(self.brushBtn);
        make.left.equalTo(self.brushBtn.mas_right).offset(15);
        make.size.equalTo(self.brushBtn);
    }];
    
    [self.progressSlider mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(self.brushBtn.mas_centerY);
        make.left.equalTo(self.eraserBtn.mas_right).offset(21);
        make.right.equalTo(self.bgView.mas_right).offset(-20);
    }];
}

#pragma mark - 懒加载

- (UIView *)bgView {
    if (!_bgView) {
        _bgView = [[UIView alloc] init];
        _bgView.backgroundColor = [UIColor whiteColor];
        _bgView.layer.cornerRadius = kCornerRadius;
//        // 添加阴影
//        _bgView.layer.shadowOpacity = 1;
//        _bgView.layer.shadowColor = RGBA(35, 13, 90, 0.08).CGColor; // 0x230D5A
//        _bgView.layer.shadowOffset = CGSizeMake(0, -2.5);
//        _bgView.layer.shadowRadius = 4;
    }
    return _bgView;
}

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
            HEXColor(0x7060E6),//527AFF
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
        
        __weak __typeof(&*self)weakSelf = self;
        _colorSelectView.colorSelectedBlock = ^(UIColor * _Nonnull color) {
            if (weakSelf.colorChangedBlock) {
                weakSelf.colorChangedBlock(color);
            }
        };
    }
    return _colorSelectView;
}

- (UIButton *)brushBtn {
    if (!_brushBtn) {
        _brushBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        _brushBtn.selected = YES;
        [_brushBtn setBackgroundImage:[UIImage imageNamed:@"diy_brush_n"] forState:UIControlStateNormal];
        [_brushBtn setBackgroundImage:[UIImage imageNamed:@"diy_brush_s"] forState:UIControlStateSelected];
        [_brushBtn addTarget:self action:@selector(brushBtnClick:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _brushBtn;
}

- (UIButton *)eraserBtn {
    if (!_eraserBtn) {
        _eraserBtn = [[UIButton alloc] init];
        [_eraserBtn setBackgroundImage:[UIImage imageNamed:@"diy_eraser_n"] forState:UIControlStateNormal];
        [_eraserBtn setBackgroundImage:[UIImage imageNamed:@"diy_eraser_s"] forState:UIControlStateSelected];
        [_eraserBtn addTarget:self action:@selector(eraserBtnClick:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _eraserBtn;
}
/*
- (RWDIYSlider *)progressSlider {
    if (!_progressSlider) {
        _progressSlider = [[RWDIYSlider alloc] init];
        _progressSlider.backgroundColor = [UIColor orangeColor];
        _progressSlider.sliderDefaultValue = 16;
        _progressSlider.minimumValue = 2;
        _progressSlider.maximumValue = 32;
//        _progressSlider.value = 16;
        _progressSlider.height = 5;
        _progressSlider.thumbTintColor = HEXColor(0x527AFF);
        _progressSlider.minimumTrackTintColor = HEXColor(0x527AFF);
        _progressSlider.maximumTrackTintColor = HEXColor(0xEDF1FF);
//        [_progressSlider setThumbImage:[UIImage imageNamed:@"diy_slider_thumb"] forState:UIControlStateHighlighted];
//        [_progressSlider setThumbImage:[UIImage imageNamed:@"diy_slider_thumb"] forState:UIControlStateNormal];
        [_progressSlider addTarget:self action:@selector(sliderValueChanged:) forControlEvents:UIControlEventValueChanged];
//        [_progressSlider addTarget:self action:@selector(sliderValurChanged:forEvent:) forControlEvents:UIControlEventValueChanged];
    }
    return _progressSlider;
}
*/

- (UISlider *)progressSlider {
    if (!_progressSlider) {
        _progressSlider = [[UISlider alloc] init];
        _progressSlider.minimumValue = 2;
        _progressSlider.maximumValue = 32;
        _progressSlider.value = 17;
        _progressSlider.thumbTintColor = HEXColor(0x527AFF);
        _progressSlider.minimumTrackTintColor = HEXColor(0x527AFF);
        _progressSlider.maximumTrackTintColor = HEXColor(0xEDF1FF);
        
        [_progressSlider setThumbImage:[UIImage imageNamed:@"diy_slider_thumb"] forState:UIControlStateNormal];
        [_progressSlider setThumbImage:[UIImage imageNamed:@"diy_slider_thumb"] forState:UIControlStateHighlighted];
        
        [_progressSlider setMinimumTrackImage:[UIImage imageNamed:@"diy_slider_MinTrack"] forState:UIControlStateNormal];
        [_progressSlider setMinimumTrackImage:[UIImage imageNamed:@"diy_slider_MinTrack"] forState:UIControlStateHighlighted];
        
        [_progressSlider setMaximumTrackImage:[UIImage imageNamed:@"diy_slider_MaxTrack"] forState:UIControlStateNormal];
        [_progressSlider setMaximumTrackImage:[UIImage imageNamed:@"diy_slider_MaxTrack"] forState:UIControlStateHighlighted];
        
        [_progressSlider addTarget:self action:@selector(sliderValueChanged:) forControlEvents:UIControlEventValueChanged];
    }
    return _progressSlider;
}

- (void)brushBtnClick:(UIButton *)btn {
    if (!btn.selected) {
        btn.selected = !btn.selected;
        
        self.lastBtn.selected = NO;
        self.lastBtn = btn;
        
        if (self.brushBtnClickBlock) {
            self.brushBtnClickBlock(self.lastBrushSliderValue ? self.lastBrushSliderValue : 17);
        }
    }
}

- (void)eraserBtnClick:(UIButton *)btn {
    if (!btn.selected) {
        btn.selected = !btn.selected;
        
        self.lastBtn.selected = NO;
        self.lastBtn = btn;
        
        if (self.eraserBtnClickBlock) {
            self.eraserBtnClickBlock(self.lastEraserSliderValue ? self.lastEraserSliderValue : 34);
        }
    }
}

- (void)sliderValueChanged:(UISlider *)slider {
    
    if (self.sliderChangedBlock) {
        self.sliderChangedBlock(slider.value);
    }
    
    if (self.isSelectedEraser) {
        self.lastEraserSliderValue = slider.value;
    } else {
        self.lastBrushSliderValue = slider.value;
    }
}

@end
