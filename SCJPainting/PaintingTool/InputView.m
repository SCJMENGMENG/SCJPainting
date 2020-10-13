//
//  InputView.m
//  SCJPainting
//
//  Created by scj on 2020/10/13.
//  Copyright © 2020 scj. All rights reserved.
//

#import "InputView.h"

#import <Masonry.h>

#define kTextViewHeight 34
#define kTextViewTopMargin 6
#define kTextViewLeftMargin 14
#define kTextViewRightMargin 10

#define kBgViewHeight (kTextViewHeight + kTextViewTopMargin*2)

#define kConfirmBtnWidth 59
#define kConfirmBtnHeight kConfirmBtnWidth*36/59

#define kScreenWidth  [UIScreen mainScreen].bounds.size.width

#define HEXColor(rgbValue) [UIColor colorWithRed:((float)((rgbValue & 0xFF0000) >> 16))/255.0 green:((float)((rgbValue &0xFF00) >>8))/255.0 blue:((float)(rgbValue &0xFF))/255.0 alpha:1.0]

@interface InputView ()<UITextViewDelegate>

@property (nonatomic, strong) UIView *bgView;

@property (nonatomic, strong) UITextView *textView;
/// 占位符
@property (nonatomic, strong) UILabel *placeHolder;

@property (nonatomic, strong) UIButton *confirmBtn;

@end

@implementation InputView

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        self.backgroundColor = [UIColor whiteColor];
        [self setupUI];
        [self addNotification];
    }
    return self;
}

- (void)setTextViewText:(NSString *)textViewText {
    _textViewText = textViewText;
    
    self.textView.text = textViewText;
    self.placeHolder.hidden = textViewText.length > 0 ? YES : NO;
    [self updateTextViewHeight];
}

- (void)setTextViewFirstResponder:(BOOL)textViewFirstResponder {
    _textViewFirstResponder = textViewFirstResponder;
    
    if (textViewFirstResponder) {
        [self.textView becomeFirstResponder];
        self.placeHolder.hidden = self.textView.text.length > 0 ? YES : NO;
    } else {
        [self.textView resignFirstResponder];
    }
}

#pragma mark - UITextViewDelegate

- (void)textViewDidChange:(UITextView *)textView {
    
    self.placeHolder.hidden = textView.text.length > 0 ? YES : NO;
    
    if (self.textChangedBlock) {
        self.textChangedBlock(textView.text);
    }
    
    [self updateTextViewHeight];
}

#pragma mark - Help Method

- (void)addNotification {
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
}

- (void)keyboardWillShow:(NSNotification *)notifaton {
    
    NSDictionary *userInfo = [notifaton userInfo];
    NSValue *aValue = [userInfo objectForKey:UIKeyboardFrameEndUserInfoKey];
    CGRect keyboardRect = [aValue CGRectValue];
    int height = keyboardRect.size.height;
    
    if (self.keyboardShowOrHideBlock) {
        self.keyboardShowOrHideBlock(NO, height);
    }
}

- (void)keyboardWillHide:(NSNotification *)notifaton {
    if (self.keyboardShowOrHideBlock) {
        self.keyboardShowOrHideBlock(YES, 0);
    }
    
    if (self.textViewText.length > 0) {
        [self updateTextViewDefaultHeight];
    }
}

- (void)updateTextViewDefaultHeight {
    [self.bgView mas_updateConstraints:^(MASConstraintMaker *make) {
        make.height.mas_equalTo(kBgViewHeight);
    }];
}

- (void)updateTextViewHeight {
    CGFloat height = [self heightWithTextView:self.textView textViewWidth:kScreenWidth - 40 - kConfirmBtnWidth -12 - kTextViewLeftMargin - kTextViewRightMargin];
    
    height = height < 52 ? height : 52; // 2行高度52 3行高度70
    
    if (self.textViewHeightChangeBlock) {
        self.textViewHeightChangeBlock(height-kTextViewHeight);
    }
    
    [UIView animateWithDuration:0.25 animations:^{
        [self.bgView mas_updateConstraints:^(MASConstraintMaker *make) {
            make.height.mas_equalTo(height + kTextViewTopMargin*2);
        }];
        [self.bgView.superview layoutIfNeeded];
    }];
}

/// 获取textView高度
/// @param textView textView
/// @param width textView宽度
- (CGFloat)heightWithTextView:(UITextView *)textView textViewWidth:(CGFloat)width {
    CGSize sizeToFit = [textView sizeThatFits:CGSizeMake(width, MAXFLOAT)];
    return sizeToFit.height;
}

#pragma mark - Layout

- (void)setupUI {
    
    [self addSubview:self.bgView];
    [self addSubview:self.confirmBtn];
    [self addSubview:self.placeHolder];
    [self.bgView addSubview:self.textView];
    
    [self.bgView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.mas_left).offset(20);
        make.bottom.equalTo(self.mas_bottom).offset(-12);
        make.right.equalTo(self.confirmBtn.mas_left).offset(-12);
        make.height.mas_equalTo(kBgViewHeight);
    }];
    
    [self.textView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.bgView.mas_top).offset(kTextViewTopMargin);
        make.left.equalTo(self.bgView.mas_left).offset(kTextViewLeftMargin);
        make.bottom.equalTo(self.bgView.mas_bottom).offset(-kTextViewTopMargin);
        make.right.equalTo(self.bgView.mas_right).offset(-kTextViewRightMargin);
    }];
    
    [self.confirmBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.equalTo(self.bgView);
        make.right.equalTo(self.mas_right).offset(-20);
        make.size.mas_equalTo(CGSizeMake(kConfirmBtnWidth, kConfirmBtnHeight));
    }];
    
    [self.placeHolder mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(self.textView);
        make.left.equalTo(self.textView.mas_left).offset(5);
    }];
}

#pragma mark - 懒加载

- (UIView *)bgView {
    if (!_bgView) {
        _bgView = [[UIView alloc] init];
        _bgView.backgroundColor = HEXColor(0xF2F5FF);
        _bgView.layer.cornerRadius = kBgViewHeight*0.5;
    }
    return _bgView;
}

- (UITextView *)textView {
    if (!_textView) {
        _textView = [[UITextView alloc] init];
        _textView.backgroundColor = HEXColor(0xF2F5FF);
        _textView.delegate = self;
        _textView.textColor = HEXColor(0x5F4F87);
        _textView.font = [UIFont systemFontOfSize:15];
    }
    return _textView;
}

- (UIButton *)confirmBtn {
    if (!_confirmBtn) {
        _confirmBtn = [[UIButton alloc] init];
        _confirmBtn.backgroundColor = HEXColor(0x527AFF);
        _confirmBtn.layer.cornerRadius = kConfirmBtnHeight*0.5;
        [_confirmBtn setBackgroundImage:[UIImage imageNamed:@"diy_done"] forState:UIControlStateNormal];
        [_confirmBtn setBackgroundImage:[UIImage imageNamed:@"diy_done"] forState:UIControlStateSelected];
        [_confirmBtn addTarget:self action:@selector(confirmBtnClick) forControlEvents:UIControlEventTouchUpInside];
    }
    return _confirmBtn;
}

- (UILabel *)placeHolder {
    if (!_placeHolder) {
        _placeHolder = [[UILabel alloc] init];
        _placeHolder.text = @"请添加文本";
        _placeHolder.font = [UIFont systemFontOfSize:15];
        _placeHolder.textColor = HEXColor(0xB6B8D1);
    }
    return _placeHolder;
}

- (void)confirmBtnClick {
    
    NSString *text = self.textView.text.length > 0 ? self.textView.text : @"";
    if (self.textConfirmBlock) {
        self.textConfirmBlock(text);
    }
    
    self.textView.text = @"";
    [self.textView resignFirstResponder];
}

@end
