//
//  CloseAndConfirmView.m
//  SCJPainting
//
//  Created by scj on 2020/10/13.
//  Copyright © 2020 scj. All rights reserved.
//

#import "CloseAndConfirmView.h"

#import <Masonry.h>

@interface CloseAndConfirmView ()

@property (nonatomic, strong) UIView *bgView;

@property (nonatomic, strong) UIButton *closeBtn;

@property (nonatomic, strong) UIButton *confirmBtn;

@property (nonatomic, strong) UIImageView *shadowImage;
@end

@implementation CloseAndConfirmView

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        [self setupUI];
    }
    return self;
}

#pragma mark - Layout

- (void)setupUI {
    [self addSubview:self.bgView];
    [self.bgView addSubview:self.shadowImage];
    [self.bgView addSubview:self.closeBtn];
    [self.bgView addSubview:self.confirmBtn];
    
    [self.bgView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self);
    }];
    
    [self.shadowImage mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.bgView.mas_top).offset(-3);
        make.left.right.equalTo(self.bgView);
    }];
    
    [self.closeBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.bgView.mas_left).offset(20);
        make.centerY.equalTo(self.bgView.mas_centerY).offset(-17);
        make.size.mas_equalTo(CGSizeMake(22, 22));
    }];
    
    [self.confirmBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(self.bgView.mas_right).offset(-20);
        make.centerY.equalTo(self.closeBtn);
        make.size.equalTo(self.closeBtn);
    }];
}
#pragma mark - 懒加载

- (UIView *)bgView {
    if (!_bgView) {
        _bgView = [[UIView alloc] init];
        _bgView.backgroundColor = [UIColor whiteColor];
//        // 添加阴影
//        _bgView.layer.shadowOpacity = 1;
//        _bgView.layer.shadowColor = RGBA(35, 13, 90, 0.08).CGColor;
//        _bgView.layer.shadowOffset = CGSizeMake(0, -2.5);
//        _bgView.layer.shadowRadius = 4;
    }
    return _bgView;
}

- (UIButton *)closeBtn {
    if (!_closeBtn) {
        _closeBtn = [[UIButton alloc] init];
        _closeBtn.tag = 0;
        [_closeBtn setBackgroundImage:[UIImage imageNamed:@"diy_close"] forState:UIControlStateNormal];
        [_closeBtn addTarget:self action:@selector(btnClick:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _closeBtn;
}

- (UIButton *)confirmBtn {
    if (!_confirmBtn) {
        _confirmBtn = [[UIButton alloc] init];
        _confirmBtn.tag = 1;
        [_confirmBtn setBackgroundImage:[UIImage imageNamed:@"diy_confirm"] forState:UIControlStateNormal];
        [_confirmBtn addTarget:self action:@selector(btnClick:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _confirmBtn;
}

- (UIImageView *)shadowImage {
    if (!_shadowImage) {
        _shadowImage = [[UIImageView alloc] init];
        _shadowImage.image = [UIImage imageNamed:@"tabbar_top_line"];
    }
    return _shadowImage;
}

- (void)btnClick:(UIButton *)btn {
    if (self.diyCloseAndConfirmBtnClickBlock) {
        self.diyCloseAndConfirmBtnClickBlock(btn.tag);
    }
}

@end
