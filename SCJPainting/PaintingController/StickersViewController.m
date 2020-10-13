//
//  StickersViewController.m
//  SCJPainting
//
//  Created by scj on 2020/10/13.
//  Copyright © 2020 scj. All rights reserved.
//

#import "StickersViewController.h"
#import "ArtboardTopToolBarView.h"
#import "CloseAndConfirmView.h"
#import "StickersView.h"
#import "PhotoSelectView.h"

#import "TZImagePickerController.h"
#import <Masonry.h>

#define kScreenWidth  [UIScreen mainScreen].bounds.size.width

@interface StickersViewController ()<TZImagePickerControllerDelegate>

/// 背景图
@property (nonatomic, strong) UIImage *diyBgImage;
/// 上一次绘制的图(合成图)
@property (nonatomic, strong) UIImage *lastImage;


/// 背景图
@property (nonatomic, strong) UIImageView *bgImageView;
/// 顶部工具栏
@property (nonatomic, strong) ArtboardTopToolBarView *topToolbarView;
/// 底部关闭确认view
@property (nonatomic, strong) CloseAndConfirmView *closeAndConfirmView;

@property (nonatomic, strong) UIView *shadowView;
/// 背景图-底图
@property (nonatomic, strong) UIImageView *stickersBgImageView;
/// 贴图区域
@property (nonatomic, strong) StickersView *stickersView;
/// 辅助图
@property (nonatomic, strong) UIImageView *diyUVImageView;
/// 选择照片
@property (nonatomic, strong) PhotoSelectView *photoSelectedView;

@property (nonatomic, strong) UIImage *selctedImage;
@end

@implementation StickersViewController

+ (void)openStickersVCWithDiyBgImage:(UIImage *)bgImage baseVC:(UIViewController *)vc lastImage:(UIImage *)lastImage confirmBlock:(StickersVCPopBlock)stickersVCPopBlock {
    StickersViewController *stickersVC = [[StickersViewController alloc] init];
    stickersVC.diyBgImage = bgImage;
    stickersVC.lastImage = lastImage;
    stickersVC.stickersVCPopBlock = stickersVCPopBlock;
    [vc.navigationController pushViewController:stickersVC animated:YES];
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
        self.stickersBgImageView.image = self.diyBgImage;
    }
}

- (void)addBlock {
    
    __weak __typeof(&*self)weakSelf = self;
    
    self.closeAndConfirmView.diyCloseAndConfirmBtnClickBlock = ^(NSInteger btnTag) {
        
        UIImage *image;
        
        if (btnTag == 1) {// 保存
            image = [weakSelf.stickersView snapshot];
        }
        
        if (weakSelf.stickersVCPopBlock) {
            weakSelf.stickersVCPopBlock(image);
        }
        [weakSelf.navigationController popViewControllerAnimated:YES];
    };
    
    self.photoSelectedView.cellSelectedBlock = ^(NSInteger indexPathRow, UIImage * _Nonnull image) {
        if (indexPathRow == 0) {
            [weakSelf takingPictures];
        }
        else {
            weakSelf.stickersView.selctedImage = image;
        }
    };
    self.photoSelectedView.closeAndOpenBtnClickBlock = ^(BOOL btnSelected) {
        [weakSelf updatePhotoSelectedViewLayout:btnSelected];
    };
}

// 展示上个页面带过来的图
- (void)showLastImage:(UIImage *)image {
    if (image) {
        UIImageView *imageView = [[UIImageView alloc] init];
        imageView.image = image;
        [self.view insertSubview:imageView atIndex:4];
        
        [imageView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.equalTo(self.stickersView);
        }];
    }
}

- (void)updatePhotoSelectedViewLayout:(BOOL)isSelected {
    CGFloat height = isSelected ? 46 : 201;
    
    [self.photoSelectedView.superview setNeedsLayout];
    [UIView animateWithDuration:0.25 animations:^{
        [self.photoSelectedView mas_updateConstraints:^(MASConstraintMaker *make) {
            make.height.mas_equalTo(height);
        }];
        
        [self.photoSelectedView.superview layoutIfNeeded];
    }];
}

// 选择照片
- (void)takingPictures {
    
    TZImagePickerController *imagePickerVc = [[TZImagePickerController alloc] initWithMaxImagesCount:1 delegate:self];
    imagePickerVc.modalPresentationStyle = UIModalPresentationFullScreen;
    imagePickerVc.allowPickingVideo = NO;
    imagePickerVc.allowTakePicture = NO;
    imagePickerVc.allowPickingOriginalPhoto = NO;
    [imagePickerVc setDidFinishPickingPhotosHandle:^(NSArray<UIImage *> *photos, NSArray *assets, BOOL isSelectOriginalPhoto) {
        if (photos.firstObject) {
            self.selctedImage = photos.firstObject;
            self.stickersView.selctedImage = photos.firstObject;
        }
    }];
    [self presentViewController:imagePickerVc animated:YES completion:nil];
}

#pragma mark - Layout

- (void)setupUI {
    [self.view addSubview:self.bgImageView];
    [self.view addSubview:self.topToolbarView];
    [self.view addSubview:self.shadowView];
    [self.view addSubview:self.stickersBgImageView];
    [self.view addSubview:self.photoSelectedView];
    [self.view addSubview:self.closeAndConfirmView];
    [self.view addSubview:self.stickersView];
    [self.view addSubview:self.diyUVImageView];
    
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
    
    [self.stickersBgImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.shadowView);
    }];
    
    [self.diyUVImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.stickersBgImageView);
    }];
    
    [self.stickersView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.left.equalTo(self.stickersBgImageView);
        make.size.equalTo(self.stickersBgImageView);
    }];
    
    [self.closeAndConfirmView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.bottom.equalTo(self.view);
        make.height.mas_equalTo(34 + 49+6);
    }];
    
    [self.photoSelectedView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.equalTo(self.view);
        make.bottom.equalTo(self.closeAndConfirmView.mas_top).offset(-3);
        make.height.mas_equalTo(201);
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

- (UIImageView *)stickersBgImageView {
    if (!_stickersBgImageView) {
        _stickersBgImageView = [[UIImageView alloc] init];
        _stickersBgImageView.backgroundColor = [UIColor colorWithRed:242/255.0 green:245/255.0 blue:255/255.0 alpha:1];
        _stickersBgImageView.clipsToBounds = YES;
        _stickersBgImageView.contentMode = UIViewContentModeScaleAspectFill;
    }
    return _stickersBgImageView;
}

- (UIImageView *)diyUVImageView {
    if (!_diyUVImageView) {
        _diyUVImageView = [[UIImageView alloc] init];
    }
    return _diyUVImageView;
}

- (StickersView *)stickersView {
    if (!_stickersView) {
        _stickersView = [[StickersView alloc] init];
    }
    return _stickersView;
}

- (PhotoSelectView *)photoSelectedView {
    if (!_photoSelectedView) {
        _photoSelectedView = [[PhotoSelectView alloc] init];
    }
    return _photoSelectedView;
}
@end
