//
//  FontViewController.m
//  SCJPainting
//
//  Created by scj on 2020/10/13.
//  Copyright © 2020 scj. All rights reserved.
//

#import "FontViewController.h"
#import "ArtboardTopToolBarView.h"
#import "CloseAndConfirmView.h"
#import "FontEditView.h"
#import "FontColorSelectView.h"
#import "InputView.h"
#import "PasteImageView.h"

#import <Masonry.h>

#define kInputViewHeight 34+6*2+24

#define HEXColor(rgbValue) [UIColor colorWithRed:((float)((rgbValue & 0xFF0000) >> 16))/255.0 green:((float)((rgbValue &0xFF00) >>8))/255.0 blue:((float)(rgbValue &0xFF))/255.0 alpha:1.0]

#define WS(weakSelf)  __weak __typeof(&*self)weakSelf = self

#define kScreenWidth  [UIScreen mainScreen].bounds.size.width

@interface FontViewController ()

/// 背景图
@property (nonatomic, strong) UIImage *diyBgImage;
/// 上一次绘制的图(合成图)
@property (nonatomic, strong) UIImage *lastImage;
/// UV图隐藏状态
@property (nonatomic, assign) BOOL diyUVImageHidden;


@property (nonatomic, strong) UIImageView *bgImageView;
/// 顶部工具栏
@property (nonatomic, strong) ArtboardTopToolBarView *topToolbarView;
/// 底部关闭确认view
@property (nonatomic, strong) CloseAndConfirmView *closeAndConfirmView;

@property (nonatomic, strong) UIView *shadowView;
/// 背景图
@property (nonatomic, strong) UIImageView *fontBgImageView;
/// 字体编辑View
@property (nonatomic, strong) FontEditView *fontEditView;
/// 辅助图
@property (nonatomic, strong) UIImageView *diyUVImageView;
/// 底部颜色选择View
@property (nonatomic, strong) FontColorSelectView *colorSelectView;

@property (nonatomic, strong) InputView *inputView;

/// 当前文本框
@property (nonatomic, strong) PasteImageView *currentPasteView;
@property (nonatomic, strong) UIColor *currentSelectedColor;

@end

@implementation FontViewController

+ (void)openFontVCWithDiyBgImage:(UIImage *)bgImage baseView:(UIViewController *)vc lastImage:(UIImage *)lastImage confirmBlock:(FontVCPopBlock)fontVCPopBlock {
    FontViewController *fontVC = [[FontViewController alloc] init];
    fontVC.diyBgImage = bgImage;
    fontVC.lastImage = lastImage;
    fontVC.fontVCPopBlock = fontVCPopBlock;
    [vc.navigationController pushViewController:fontVC animated:YES];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.navigationController.navigationBar.hidden = YES;
    self.view.backgroundColor = [UIColor whiteColor];
    
    [self setupUI];
    [self addBlock];
    
    self.diyUVImageView.hidden = self.diyUVImageHidden;
    
    if (self.lastImage) {
        [self showLastImage:self.lastImage];
    }
//    self.fontBgImageView.image = self.diyBgImage ? self.diyBgImage : [self diyBgImageWithDiyTagId:[self.tagModel.FK integerValue]];
    if (self.diyBgImage) {
        self.fontBgImageView.image = self.diyBgImage;
    }
    
    // 进来默认添加一个
    [self.fontEditView.superview layoutIfNeeded];
    [self.fontEditView addText];
    self.currentPasteView = self.fontEditView.textViewList.lastObject;
    self.currentSelectedColor = HEXColor(0x000000);
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
//    [[IQKeyboardManager sharedManager] setEnable:NO];
//    [[IQKeyboardManager sharedManager] setEnableAutoToolbar:NO];
}

- (void)addBlock {
    
    WS(weakSelf);
    
    /** colorSelectView */
    // 添加文本框
    self.colorSelectView.addTextBtnClickBlock = ^{
        [weakSelf.fontEditView addText];
        weakSelf.currentSelectedColor = HEXColor(0x000000);
        weakSelf.colorSelectView.colorSelcetedIndex = 1;
        
        weakSelf.currentPasteView = weakSelf.fontEditView.textViewList.lastObject;
        
    };
    // 颜色选择
    self.colorSelectView.colorChangedBlock = ^(UIColor * _Nonnull selectedColor) {
        if (weakSelf.currentPasteView.isRemove) {
            // 自动选中
            weakSelf.currentPasteView = weakSelf.fontEditView.textViewList.firstObject;
            weakSelf.currentPasteView.isOperation = YES;
        }
        if (weakSelf.currentPasteView.isOperation) {
            weakSelf.currentPasteView.textColor = selectedColor;
            weakSelf.currentSelectedColor = selectedColor;
        }
    };
 
    /** fontEditView */
    self.fontEditView.textBoxPanOrTapBlock = ^(UIView * _Nonnull clickView, BOOL isOperation, BOOL isTapGesture) {
        weakSelf.currentPasteView = ((PasteImageView*)clickView);
        if (isOperation && isTapGesture) {
            weakSelf.inputView.textViewFirstResponder = YES;
            if(weakSelf.currentPasteView.text){//&& ![weakSelf.currentPasteView.text isEqualToString:@"点击添加文本"]
                weakSelf.inputView.textViewText = weakSelf.currentPasteView.text;
            }
            
        } else {
            weakSelf.inputView.textViewText = @"";
            weakSelf.inputView.textViewFirstResponder = NO;
            // 还原inputView高度
            [weakSelf.inputView mas_updateConstraints:^(MASConstraintMaker *make) {
                make.height.mas_equalTo(kInputViewHeight);
            }];
        }
        
        if (weakSelf.currentPasteView.textColor) {
            weakSelf.currentSelectedColor = weakSelf.currentPasteView.textColor;
            weakSelf.colorSelectView.currentTextColor = weakSelf.currentSelectedColor;
        } else {
            weakSelf.currentSelectedColor = HEXColor(0x000000);
            weakSelf.colorSelectView.colorSelcetedIndex = 1;
        }
    };
    
    /** inputView */
    self.inputView.keyboardShowOrHideBlock = ^(BOOL hidden, CGFloat keyboardHeight) {
        CGFloat btmOffset = hidden ? kInputViewHeight : -keyboardHeight;
        [UIView animateWithDuration:0.25 animations:^{
            [weakSelf.inputView mas_updateConstraints:^(MASConstraintMaker *make) {
                make.bottom.equalTo(weakSelf.view.mas_bottom).offset(btmOffset);
            }];
            [weakSelf.inputView.superview layoutIfNeeded];
        }];
    };
    self.inputView.textViewHeightChangeBlock = ^(CGFloat height) {
        [UIView animateWithDuration:0.25 animations:^{
            [weakSelf.inputView mas_updateConstraints:^(MASConstraintMaker *make) {
                make.height.mas_equalTo(kInputViewHeight+height);
            }];
            [weakSelf.inputView.superview layoutIfNeeded];
        }];
    };
    self.inputView.textConfirmBlock = ^(NSString * _Nonnull text) {
        weakSelf.currentPasteView.text = text;
        if (weakSelf.currentSelectedColor) {
            weakSelf.currentPasteView.textColor = weakSelf.currentSelectedColor;
        }
        
        [weakSelf.inputView mas_updateConstraints:^(MASConstraintMaker *make) {
            make.height.mas_equalTo(kInputViewHeight);
        }];
    };
    
    self.closeAndConfirmView.diyCloseAndConfirmBtnClickBlock = ^(NSInteger btnTag) {
        UIImage *image;
        if (btnTag == 1) {// 保存
            image = [weakSelf.fontEditView snapshot];
        }
        if (weakSelf.fontVCPopBlock) {
            weakSelf.fontVCPopBlock(image);
        }
        [weakSelf.navigationController popViewControllerAnimated:YES];
    };
}


// 展示上个页面带过来的图
- (void)showLastImage:(UIImage *)image {
    if (image) {
        UIImageView *imageView = [[UIImageView alloc] init];
        imageView.image = image;
        [self.fontBgImageView addSubview:imageView];
        
        [imageView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.equalTo(self.fontEditView);
        }];
    }
}

- (UIImage *)diyUVImageWithDiyTagId:(NSInteger)tagId {
    switch (tagId) {
        case 109:
            return [UIImage imageNamed:@"diy_uv_expression"];
            break;
            
        case 110:
            return [UIImage imageNamed:@"diy_uv_jacket"];
            break;
            
        case 111:
            return [UIImage imageNamed:@"diy_uv_pants"];
            break;
            
        case 112:
            return [UIImage imageNamed:@"diy_uv_shoes"];
            break;
            
        default:
            return [UIImage imageNamed:@"diy_uv_jacket"];
            break;
    }
}
/*
- (UIImage *)diyBgImageWithDiyTagId:(NSInteger)tagId {
    switch (tagId) {
        case 109:
            return [UIImage imageNamed:@"diy_bgView_expression"];
            break;
            
        case 110:
            return [UIImage imageNamed:@"diy_bgView_jacket"];
            break;
            
        case 111:
            return [UIImage imageNamed:@"diy_bgView_pants"];
            break;
            
        case 112:
            return [UIImage imageNamed:@"diy_bgView_shoes"];
            break;
            
        default:
            return [UIImage imageNamed:@"diy_bgView_jacket"];
            break;
    }
}
*/
#pragma mark - Layout

- (void)setupUI {
    
    [self.view addSubview:self.bgImageView];
    [self.view addSubview:self.topToolbarView];
    [self.view addSubview:self.colorSelectView];
    [self.view addSubview:self.closeAndConfirmView];
    [self.view addSubview:self.shadowView];
    [self.view addSubview:self.fontBgImageView];
    [self.view addSubview:self.fontEditView];
    [self.view addSubview:self.diyUVImageView];
    [self.view addSubview:self.inputView];
    
    [self.bgImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.left.right.equalTo(self.view);
        make.bottom.equalTo(self.closeAndConfirmView.mas_top).offset(-6);
    }];
    
    [self.topToolbarView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.view.mas_top).offset(44);
        make.left.right.equalTo(self.view);
        make.height.mas_equalTo(44);
    }];
    
    [self.shadowView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.topToolbarView.mas_bottom);
        make.left.equalTo(self.view.mas_left).offset(15);
        make.size.mas_equalTo(CGSizeMake(kScreenWidth-30, kScreenWidth-30));
    }];
    
    [self.fontBgImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.topToolbarView.mas_bottom);
        make.left.equalTo(self.view.mas_left).offset(15);
        make.size.mas_equalTo(CGSizeMake(kScreenWidth-30, kScreenWidth-30));
    }];
    
    [self.fontEditView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.fontBgImageView);
    }];
    
    [self.diyUVImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.fontBgImageView);
    }];
    
    [self.colorSelectView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.equalTo(self.view);
        make.bottom.equalTo(self.closeAndConfirmView.mas_top).offset(-6);
        make.height.mas_equalTo(64+6);
    }];
    
    [self.closeAndConfirmView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.bottom.equalTo(self.view);
        make.height.mas_equalTo(34 + 49+6);
    }];
    
    [self.inputView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.equalTo(self.view);
        make.height.mas_equalTo(kInputViewHeight);
        make.bottom.equalTo(self.view.mas_bottom).offset(kInputViewHeight);
    }];
}

#pragma mark - 懒加载

- (UIImageView *)bgImageView {
    if (!_bgImageView) {
        _bgImageView = [[UIImageView alloc] init];
        _bgImageView.image = [UIImage imageNamed:@"diy_bgImage"];
    }
    return _bgImageView;
}

- (ArtboardTopToolBarView *)topToolbarView {
    if (!_topToolbarView) {
        _topToolbarView = [[ArtboardTopToolBarView alloc] init];
        _topToolbarView.backgroundColor = [UIColor clearColor];
        _topToolbarView.topLineHidden = YES;
        _topToolbarView.btmLineHidden = YES;
    }
    return _topToolbarView;
}

- (CloseAndConfirmView *)closeAndConfirmView {
    if (!_closeAndConfirmView) {
        _closeAndConfirmView = [[CloseAndConfirmView alloc] init];
    }
    return _closeAndConfirmView;
}

- (UIView *)shadowView {
    if (!_shadowView) {
        _shadowView = [[UIView alloc] init];
        _shadowView.backgroundColor= [UIColor whiteColor];
        _shadowView.layer.shadowOpacity = 1;
        _shadowView.layer.shadowColor = [UIColor colorWithRed:95/255.0 green:79/255.0 blue:135/255.0 alpha:0.3].CGColor;
        _shadowView.layer.shadowOffset = CGSizeMake(0, 0);
    }
    return _shadowView;
}

- (UIImageView *)fontBgImageView {
    if (!_fontBgImageView) {
        _fontBgImageView = [[UIImageView alloc] init];
        _fontBgImageView.backgroundColor = HEXColor(0xF2F5FF);
        _fontBgImageView.clipsToBounds = YES;
        _fontBgImageView.contentMode = UIViewContentModeScaleAspectFill;
    }
    return _fontBgImageView;
}

- (FontEditView *)fontEditView {
    if (!_fontEditView) {
        _fontEditView = [[FontEditView alloc] init];
    }
    return _fontEditView;
}

- (UIImageView *)diyUVImageView {
    if (!_diyUVImageView) {
        _diyUVImageView = [[UIImageView alloc] init];
    }
    return _diyUVImageView;
}

- (FontColorSelectView *)colorSelectView {
    if (!_colorSelectView) {
        _colorSelectView = [[FontColorSelectView alloc] init];
        _colorSelectView.backgroundColor = [UIColor whiteColor];
    }
    return _colorSelectView;
}

- (InputView *)inputView {
    if (!_inputView) {
        _inputView = [[InputView alloc] init];
    }
    return _inputView;
}

@end
