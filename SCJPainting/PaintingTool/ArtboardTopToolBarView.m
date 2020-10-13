//
//  ArtboardTopToolBarView.m
//  SCJPainting
//
//  Created by scj on 2020/10/13.
//  Copyright © 2020 scj. All rights reserved.
//

#import "ArtboardTopToolBarView.h"
#import <Masonry.h>

#define kDrawAssistBtnHeight 22

@interface ArtboardTopToolBarView ()

/// 背景view
@property (nonatomic, strong) UIView *topBarBgView;
/// 撤销按钮
@property (nonatomic, strong) UIButton *revokeBtn;
/// 取消撤销按钮
@property (nonatomic, strong) UIButton *backBtn;
///
@property (nonatomic, strong) UIView *topLine;
///
@property (nonatomic, strong) UIView *btmLine;

@end

@implementation ArtboardTopToolBarView

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        [self setupUI];
    }
    return self;
}

#pragma mark - setter
/// 控制 撤消和回退按钮是否隐藏
- (void)setRevokeBtnAndBackBtnHidden:(BOOL)revokeBtnAndBackBtnHidden {
    _revokeBtnAndBackBtnHidden = revokeBtnAndBackBtnHidden;
    
    self.revokeBtn.hidden = revokeBtnAndBackBtnHidden;
    self.backBtn.hidden = revokeBtnAndBackBtnHidden;
}

/// 撤消按钮状态
- (void)setRevokeBtnSelected:(BOOL)revokeBtnSelected {
    _revokeBtnSelected = revokeBtnSelected;
    
    self.revokeBtn.userInteractionEnabled = revokeBtnSelected;
    
    self.revokeBtn.selected = revokeBtnSelected;
}

/// 回退按钮状态
- (void)setBackBtnSelected:(BOOL)backBtnSelected {
    _backBtnSelected = backBtnSelected;
    
    self.backBtn.userInteractionEnabled = backBtnSelected;
    self.backBtn.selected = backBtnSelected;
}

- (void)setTopLineHidden:(BOOL)topLineHidden {
    _topLineHidden = topLineHidden;
    
    self.topLine.hidden = topLineHidden;
}

- (void)setBtmLineHidden:(BOOL)btmLineHidden {
    _btmLineHidden = btmLineHidden;
    
    self.btmLine.hidden = btmLineHidden;
}

#pragma mark - Action

- (void)revokeBtnClick:(UIButton *)btn {
    if (self.revokeBtnClickBlock) {
        self.revokeBtnClickBlock();
    }
}

- (void)backBtnClick:(UIButton *)btn {
    if (self.backBtnClickBlock) {
        self.backBtnClickBlock();
    }
}

#pragma mark - Layout

- (void)setupUI {
    [self addSubview:self.topBarBgView];
    [self.topBarBgView addSubview:self.revokeBtn];
    [self.topBarBgView addSubview:self.backBtn];
    [self.topBarBgView addSubview:self.topLine];
    [self.topBarBgView addSubview:self.btmLine];
    
    [self.topBarBgView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.left.right.equalTo(self);
        make.height.mas_equalTo(44);
    }];
    
     [self.revokeBtn mas_makeConstraints:^(MASConstraintMaker *make) {
           make.centerY.equalTo(self.topBarBgView);
           make.right.equalTo(self.topBarBgView.mas_centerX).offset(-12);
       }];
       
       [self.backBtn mas_makeConstraints:^(MASConstraintMaker *make) {
           make.centerY.equalTo(self.topBarBgView);
           make.left.equalTo(self.topBarBgView.mas_centerX).offset(12);
       }];
    
    [self.topLine mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.left.right.equalTo(self);
        make.height.mas_equalTo(0.5);
    }];
    
    [self.btmLine mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.left.right.equalTo(self);
        make.height.mas_equalTo(0.5);
    }];
    
    self.revokeBtn.hidden = YES;
    self.backBtn.hidden = YES;
}

#pragma mark - 懒加载

- (UIView *)topBarBgView {
    if (!_topBarBgView) {
        _topBarBgView = [[UIView alloc] init];
    }
    return _topBarBgView;
}

- (UIButton *)revokeBtn {
    if (!_revokeBtn) {
        _revokeBtn = [[UIButton alloc] init];
        _revokeBtn.selected = YES;
        [_revokeBtn setImage:[UIImage imageNamed:@"diy_revoke_n"] forState:UIControlStateNormal];
        [_revokeBtn setImage:[UIImage imageNamed:@"diy_revoke_s"] forState:UIControlStateSelected];
        [_revokeBtn addTarget:self action:@selector(revokeBtnClick:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _revokeBtn;
}

- (UIButton *)backBtn {
    if (!_backBtn) {
        _backBtn = [[UIButton alloc] init];
        [_backBtn setImage:[UIImage imageNamed:@"diy_back_n"] forState:UIControlStateNormal];
        [_backBtn setImage:[UIImage imageNamed:@"diy_back_s"] forState:UIControlStateSelected];
        [_backBtn addTarget:self action:@selector(backBtnClick:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _backBtn;
}

- (UIView *)topLine {
    if (!_topLine) {
        _topLine = [[UIView alloc] init];
        _topLine.backgroundColor = [UIColor colorWithRed:233/255.0 green:236/255.0 blue:247/255.0 alpha:1];
    }
    return _topLine;
}

- (UIView *)btmLine {
    if (!_btmLine) {
        _btmLine = [[UIView alloc] init];
        _btmLine.backgroundColor = [UIColor colorWithRed:233/255.0 green:236/255.0 blue:247/255.0 alpha:1];
    }
    return _btmLine;
}

@end
