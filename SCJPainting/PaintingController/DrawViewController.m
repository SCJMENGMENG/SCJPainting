//
//  DrawViewController.m
//  SCJPainting
//
//  Created by scj on 2020/10/13.
//  Copyright © 2020 scj. All rights reserved.
//

#import "DrawViewController.h"
#import "ArtboardTopToolBarView.h"
#import "ArtboardBottomToolBarView.h"
#import "CloseAndConfirmView.h"
#import "ArtboardView.h"

#import <Masonry.h>

@interface DrawViewController ()

/// 上一次绘制的图(合成图)
@property (nonatomic, strong) UIImage *lastImage;

@property (nonatomic, strong) UIImage *diyBgImage;


@property (nonatomic, strong) UIImageView *bgImageView;
/// 顶部工具栏
@property (nonatomic, strong) ArtboardTopToolBarView *topToolbarView;
/// 底部绘图工具栏
@property (nonatomic, strong) ArtboardBottomToolBarView *btmToolbarView;
/// 底部关闭确认view
@property (nonatomic, strong) CloseAndConfirmView *bottomView;
/// 背景图
@property (nonatomic, strong) UIView *artboardBgView;

@property (nonatomic, strong) UIView *shadowView;

/// 底图
@property (nonatomic, strong) UIImageView *drawBgIamgeView;
/// 画板
@property (nonatomic, strong) ArtboardView *artboardView;

@end

@implementation DrawViewController

+ (void)openDrawVCWithDiyBgImage:(UIImage *)bgImage baseVC:(UIViewController *)vc lastImage:(UIImage *)lastImage saveBlock:(DrawVCPopBlock)drawVCPopBlock {
    DrawViewController *drawVC = [[DrawViewController alloc] init];
    drawVC.lastImage = lastImage;
    drawVC.diyBgImage = bgImage;
    drawVC.drawVCPopBlock = drawVCPopBlock;
    [vc.navigationController pushViewController:drawVC animated:YES];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.navigationController.navigationBar.hidden = YES;
    self.view.backgroundColor = [UIColor whiteColor];
    
    [self setupUI];
    [self addBlock];
    
    if (self.lastImage) {
        [self showLastImage:self.lastImage];
    }
    
    if (self.diyBgImage) {
        self.drawBgIamgeView.image = self.diyBgImage ;
    }
}
#pragma mark - Private

- (void)addBlock {
    __weak __typeof(&*self)weakSelf = self;
    /** RWDIYArtboardTopToolbarView 回调*/
    // 撤销回调
    self.topToolbarView.revokeBtnClickBlock = ^{
        [weakSelf.artboardView back];
    };
    // 下一步回调
    self.topToolbarView.backBtnClickBlock = ^{
        [weakSelf.artboardView next];
    };
    
    /** RWDIYArtboardBottomToolbarView 回调*/
    // 画笔按钮点击
    self.btmToolbarView.brushBtnClickBlock = ^(CGFloat brushSliderValue) {
        weakSelf.artboardView.isErase = NO;
        weakSelf.btmToolbarView.isSelectedEraser = NO;
        weakSelf.artboardView.lineWidth = brushSliderValue;
        
        [weakSelf updateBtmToolbarLayout:NO];
    };
    // 橡皮擦点击
    self.btmToolbarView.eraserBtnClickBlock = ^(CGFloat eraserSliderValue) {
        weakSelf.artboardView.isErase = YES;
        weakSelf.btmToolbarView.isSelectedEraser = YES;
        weakSelf.artboardView.lineWidth = eraserSliderValue;
        
        [weakSelf updateBtmToolbarLayout:YES];
    };
    // 进度条滑动
    self.btmToolbarView.sliderChangedBlock = ^(CGFloat sliderValue) {
        weakSelf.artboardView.lineWidth = sliderValue;
    };
    // 切换颜色
    self.btmToolbarView.colorChangedBlock = ^(UIColor * _Nonnull color) {
        weakSelf.artboardView.lineColor = color;
    };
    
    // 返回和确认点击Block
    self.bottomView.diyCloseAndConfirmBtnClickBlock = ^(NSInteger btnTag) {
        UIImage *image;
        if (btnTag == 1) {// 保存
            image = [weakSelf.artboardView snapshot];
        }
        
        if (weakSelf.drawVCPopBlock) {
            weakSelf.drawVCPopBlock(image);
        }
        [weakSelf.navigationController popViewControllerAnimated:YES];
    };
    
    /** 画板回调*/
    self.artboardView.touchesEndedBlock = ^(NSArray * _Nonnull pathArr, NSArray * _Nonnull backPathArr) {
        [weakSelf topToolbarViewBtnState:pathArr backPathArr:backPathArr];
    };
    
    self.artboardView.revokeAndBackClickBlock = ^(NSArray * _Nonnull pathArr, NSArray * _Nonnull backPathArr) {
        [weakSelf topToolbarViewBtnState:pathArr backPathArr:backPathArr];
    };
    
    self.artboardView.pinchGestureBlock = ^(UIView * _Nonnull artboardView, CGFloat scale) {
        if (scale < 1) {
            if (artboardView.frame.size.width > kArtboardViewWidth) {
                [weakSelf updateLocationArtboardWithView:artboardView scale:scale];
            }
        } else {
            if (artboardView.frame.size.width <= 4 * kArtboardViewWidth) {
                [weakSelf updateLocationArtboardWithView:artboardView scale:scale];
            }
        }
    };
    
    self.artboardView.panGestureBlock = ^(UIView * _Nonnull artboardView) {
        weakSelf.drawBgIamgeView.center = artboardView.center;
//        weakSelf.shadowView.center = artboardView.center;
    };
}

- (void)topToolbarViewBtnState:(NSArray *)pathArr backPathArr:(NSArray *)backPathArr {
    self.topToolbarView.revokeBtnAndBackBtnHidden = (pathArr.count == 0 && backPathArr.count == 0) ? YES : NO;
    self.topToolbarView.revokeBtnSelected = pathArr.count > 0 ? YES : NO;
    self.topToolbarView.backBtnSelected = backPathArr.count > 0 ? YES : NO;
}

- (void)updateLocationArtboardWithView:(UIView *)artboardView scale:(CGFloat)scale {
    [UIView animateWithDuration:0.3 animations:^{
        self.drawBgIamgeView.center = artboardView.center;
        self.drawBgIamgeView.transform = CGAffineTransformScale(artboardView.transform, scale, scale);

//        self.shadowView.center = artboardView.center;
//        self.shadowView.transform = CGAffineTransformScale(artboardView.transform, scale, scale);
    }];
}

// 展示上个页面带过来的图
- (void)showLastImage:(UIImage *)image {
    if (image) {
        UIImageView *imageView = [[UIImageView alloc] init];
        imageView.image = image;
        [self.drawBgIamgeView addSubview:imageView];

        [imageView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.equalTo(self.artboardView);
        }];
    }
}

- (void)updateBtmToolbarLayout:(BOOL)isSelectedEraser {
    CGFloat height = isSelectedEraser ? 116-30 : 116;
    
    [self.btmToolbarView.superview setNeedsLayout];
    [UIView animateWithDuration:0.25 animations:^{
        [self.btmToolbarView mas_updateConstraints:^(MASConstraintMaker *make) {
            make.height.mas_equalTo(height);
        }];
        
        [self.btmToolbarView.superview layoutIfNeeded];
    }];
}

#pragma mark - Layout

- (void)setupUI {
    
    [self.view addSubview:self.bgImageView];
    [self.view addSubview:self.topToolbarView];
    [self.view addSubview:self.btmToolbarView];
    [self.view addSubview:self.bottomView];
    
    /*
    [self.view addSubview:self.artboardBgView];
    [self.artboardBgView addSubview:self.shadowView];
    [self.artboardBgView addSubview:self.drawBgIamgeView];
    [self.artboardBgView addSubview:self.artboardView];
    [self.artboardBgView addSubview:self.diyUVImageView];
    */
    
    [self.view addSubview:self.shadowView];
    [self.shadowView addSubview:self.artboardBgView];
    [self.artboardBgView addSubview:self.drawBgIamgeView];
    [self.artboardBgView addSubview:self.artboardView];
    
    [self.bgImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.left.bottom.right.equalTo(self.view);
    }];
    
    [self.topToolbarView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.view.mas_top).offset(44);
        make.left.right.equalTo(self.view);
        make.height.mas_equalTo(44);
    }];
    
    /*
    [self.artboardBgView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.topToolbarView.mas_bottom).offset(kArtboardViewMargin);
        make.left.equalTo(self.view.mas_left).offset(kArtboardViewMargin);
        make.size.mas_equalTo(CGSizeMake(kArtboardViewWidth, kArtboardViewWidth));
    }];
    
    [self.shadowView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.center.equalTo(self.artboardBgView);
        make.size.mas_equalTo(CGSizeMake(kArtboardViewWidth, kArtboardViewWidth));
    }];
    */
    
    [self.shadowView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.topToolbarView.mas_bottom);
        make.left.equalTo(self.view.mas_left).offset(kArtboardViewMargin);
        make.size.mas_equalTo(CGSizeMake(kArtboardViewWidth, kArtboardViewWidth));
    }];

    [self.artboardBgView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.center.equalTo(self.shadowView);
        make.size.equalTo(self.shadowView);
    }];
    
    
    [self.drawBgIamgeView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.center.equalTo(self.artboardBgView);
        make.size.equalTo(self.artboardBgView);
    }];
    
    [self.artboardView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.drawBgIamgeView);
    }];
    
    [self.btmToolbarView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.equalTo(self.view);
        make.bottom.equalTo(self.bottomView.mas_top).offset(0);
        make.height.mas_equalTo(116);
    }];
    
    [self.bottomView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.bottom.equalTo(self.view);
        make.height.mas_equalTo(34 + 49);
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

- (ArtboardTopToolBarView *)topToolbarView {
    if (!_topToolbarView) {
        _topToolbarView = [[ArtboardTopToolBarView alloc] init];
        _topToolbarView.backgroundColor = [UIColor clearColor];
        _topToolbarView.topLineHidden = YES;
        _topToolbarView.btmLineHidden = YES;
    }
    return _topToolbarView;
}

- (UIView *)artboardBgView {
    if (!_artboardBgView) {
        _artboardBgView = [[UIView alloc] init];
        _artboardBgView.clipsToBounds = YES;
    }
    return _artboardBgView;
}

- (UIImageView *)drawBgIamgeView {
    if (!_drawBgIamgeView) {
        _drawBgIamgeView = [[UIImageView alloc] init];
        _drawBgIamgeView.backgroundColor = [UIColor colorWithRed:242/255.0 green:245/255.0 blue:255/255.0 alpha:1];
        _drawBgIamgeView.clipsToBounds = YES;
        _drawBgIamgeView.contentMode = UIViewContentModeScaleAspectFill;
    }
    return _drawBgIamgeView;
}

- (ArtboardView *)artboardView {
    if (!_artboardView) {
        _artboardView = [[ArtboardView alloc] init];
//        _artboardView.lineWidth = 17;
    }
    return _artboardView;
}

- (CloseAndConfirmView *)bottomView {
    if (!_bottomView) {
        _bottomView = [[CloseAndConfirmView alloc] init];
    }
    return _bottomView;
}

- (ArtboardBottomToolBarView *)btmToolbarView {
    if (!_btmToolbarView) {
        _btmToolbarView = [[ArtboardBottomToolBarView alloc] init];
    }
    return _btmToolbarView;
}

@end
