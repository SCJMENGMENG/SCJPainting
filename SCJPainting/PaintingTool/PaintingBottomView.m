//
//  PaintingBottomView.m
//  SCJPainting
//
//  Created by scj on 2020/10/13.
//  Copyright © 2020 scj. All rights reserved.
//

#import "PaintingBottomView.h"
#import <Masonry.h>

@interface PaintingBottomView ()
@property (nonatomic, strong) UIView *bgView;
/// 照片
@property (nonatomic, strong) UIButton *photoBtn;
/// 绘制
@property (nonatomic, strong) UIButton *drawBtn;
/// 贴图
@property (nonatomic, strong) UIButton *stickersBtn;
/// 字体
@property (nonatomic, strong) UIButton *fontBtn;
@end

@implementation PaintingBottomView

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        [self setupUI];
    }
    return self;
}

#pragma mark - Layout

- (void)setupUI {
    
    [self addSubview:self.bgView];
    [self.bgView addSubview:self.photoBtn];
    [self.bgView addSubview:self.drawBtn];
    [self.bgView addSubview:self.stickersBtn];
    [self.bgView addSubview:self.fontBtn];
    
    [self.bgView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self);
    }];
    
    [self.photoBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.bgView.mas_left).offset(20);
        make.centerY.equalTo(self.bgView.mas_centerY).offset(-17);
        make.size.mas_equalTo(CGSizeMake(65, 44));
    }];
    
    [self.drawBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.photoBtn.mas_right).mas_equalTo(10);
        make.centerY.equalTo(self.photoBtn);
        make.size.equalTo(self.photoBtn);
    }];
    
    [self.stickersBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(self.fontBtn.mas_left).mas_equalTo(-10);
        make.centerY.equalTo(self.drawBtn);
        make.size.equalTo(self.drawBtn);
    }];
    
    [self.fontBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(self.bgView.mas_right).offset(-20);
        make.centerY.equalTo(self.drawBtn);
        make.size.equalTo(self.drawBtn);
    }];
}

- (void)photoBtnClick {
    if (self.photoBtnClickBlock) {
        self.photoBtnClickBlock();
    }
}

- (void)drawBtnClick {
    if (self.drawBtnClickBlock) {
        self.drawBtnClickBlock();
    }
}

- (void)stickersBtnClick {
    if (self.stickersBtnClickBlock) {
        self.stickersBtnClickBlock();
    }
}

- (void)fontBtnClick {
    if (self.fontBtnClickBlock) {
        self.fontBtnClickBlock();
    }
}

#pragma mark - 懒加载

- (UIView *)bgView {
    if (!_bgView) {
        _bgView = [[UIView alloc] init];
        _bgView.backgroundColor = [UIColor colorWithRed:247/255.0 green:249/255.0 blue:255/255.0 alpha:1];
//        // 添加阴影
//        _bgView.layer.shadowOpacity = 1;
//        _bgView.layer.shadowColor = RGBA(35, 13, 90, 0.08).CGColor;
//        _bgView.layer.shadowOffset = CGSizeMake(0, -2.5);
//        _bgView.layer.shadowRadius = 4;
    }
    return _bgView;
}

- (UIButton *)photoBtn {
    if (!_photoBtn) {
        _photoBtn = [[UIButton alloc] init];
        [_photoBtn setTitle:@"照片" forState:UIControlStateNormal];
        _photoBtn.titleLabel.font = [UIFont systemFontOfSize:15];
        [_photoBtn setTitleColor: [UIColor redColor] forState:UIControlStateNormal];
        [_photoBtn setImage:[UIImage imageNamed:@"diy_add_photo"] forState:UIControlStateNormal];
        _photoBtn.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
        [_photoBtn setTitleEdgeInsets:UIEdgeInsetsMake(0, 6, 0, 0)];
        [_photoBtn addTarget:self action:@selector(photoBtnClick) forControlEvents:UIControlEventTouchUpInside];
    }
    return _photoBtn;
}

- (UIButton *)drawBtn {
    if (!_drawBtn) {
        _drawBtn = [[UIButton alloc] init];
        _drawBtn.tag = 0;
        [_drawBtn setTitle:@"绘制" forState:UIControlStateNormal];
        _drawBtn.titleLabel.font = [UIFont systemFontOfSize:15];
        [_drawBtn setTitleColor: [UIColor redColor] forState:UIControlStateNormal];
        [_drawBtn setImage:[UIImage imageNamed:@"diy_draw"] forState:UIControlStateNormal];
        _drawBtn.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
        [_drawBtn setTitleEdgeInsets:UIEdgeInsetsMake(0, 6, 0, 0)];
        [_drawBtn addTarget:self action:@selector(drawBtnClick) forControlEvents:UIControlEventTouchUpInside];
    }
    return _drawBtn;
}

- (UIButton *)stickersBtn {
    if (!_stickersBtn) {
        _stickersBtn = [[UIButton alloc] init];
        _stickersBtn.tag = 1;
        [_stickersBtn setTitle:@"贴图" forState:UIControlStateNormal];
        _stickersBtn.titleLabel.font = [UIFont systemFontOfSize:15];
        [_stickersBtn setTitleColor: [UIColor redColor] forState:UIControlStateNormal];
        [_stickersBtn setImage:[UIImage imageNamed:@"diy_chartlet"] forState:UIControlStateNormal];
        _stickersBtn.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
        [_stickersBtn setTitleEdgeInsets:UIEdgeInsetsMake(0, 6, 0, 0)];
        [_stickersBtn addTarget:self action:@selector(stickersBtnClick) forControlEvents:UIControlEventTouchUpInside];
    }
    return _stickersBtn;
}

- (UIButton *)fontBtn {
    if (!_fontBtn) {
        _fontBtn = [[UIButton alloc] init];
        _fontBtn.tag = 2;
        [_fontBtn setTitle:@"字体" forState:UIControlStateNormal];
        _fontBtn.titleLabel.font = [UIFont systemFontOfSize:15];
        [_fontBtn setTitleColor: [UIColor redColor] forState:UIControlStateNormal];
        [_fontBtn setImage:[UIImage imageNamed:@"diy_font"] forState:UIControlStateNormal];
        _fontBtn.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
        [_fontBtn setTitleEdgeInsets:UIEdgeInsetsMake(0, 6, 0, 0)];
        [_fontBtn addTarget:self action:@selector(fontBtnClick) forControlEvents:UIControlEventTouchUpInside];
    }
    return _fontBtn;
}

@end
