//
//  ViewController.m
//  SCJPainting
//
//  Created by scj on 2020/10/13.
//  Copyright © 2020 scj. All rights reserved.
//

#import "ViewController.h"
#import "PaintingBottomView.h"
#import "PaintingDefaultView.h"
#import "CacheTool.h"
#import "DrawViewController.h"
#import "StickersViewController.h"
#import "FontViewController.h"

#import "TZImagePickerController.h"
#import <Masonry.h>

#define kScreenWidth  [UIScreen mainScreen].bounds.size.width

@interface ViewController ()<TZImagePickerControllerDelegate>

@property (nonatomic, strong) UIImageView *bgImageView;
/// 画板区域view
@property (nonatomic, strong) PaintingDefaultView *defaultView;
/// 底部菜单栏
@property (nonatomic, strong) PaintingBottomView *bottomView;

@property (nonatomic, strong) UIImage *selectedImage;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.navigationController.navigationBar.hidden = YES;
    self.view.backgroundColor = [UIColor whiteColor];
    [self initUI];
}

- (void)initUI {
    [self.view addSubview:self.bgImageView];
    [self.view addSubview:self.defaultView];
    [self.view addSubview:self.bottomView];
    
    [self.bgImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.left.bottom.right.equalTo(self.view);
    }];
    [self.defaultView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(44);
        make.left.equalTo(self.view.mas_left).offset(15);
        make.size.mas_equalTo(CGSizeMake(kScreenWidth-30, kScreenWidth-30));
    }];
    [self.bottomView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.bottom.equalTo(self.view);
        make.height.mas_equalTo(34+49+6);
    }];
    
    __weak __typeof(&*self)weakSelf = self;
    self.bottomView.photoBtnClickBlock = ^{
        [weakSelf takingPictures];
    };
    self.bottomView.drawBtnClickBlock = ^{
        [weakSelf updatePicture:0];
    };
    self.bottomView.stickersBtnClickBlock = ^{
        [weakSelf updatePicture:1];
    };
    self.bottomView.fontBtnClickBlock = ^{
        [weakSelf updatePicture:2];
    };
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
            
            self.selectedImage = photos.firstObject;
            self.defaultView.bgImage = self.selectedImage;
            
            [CacheTool removeCacheWithName:@"kCacheName"];
        }
    }];
    [self presentViewController:imagePickerVc animated:YES completion:nil];
}

// 清除撤销的
- (void)cleanAndUpdateTopBarState {
    [self.defaultView cleanRevokeImage];
}

- (void)updatePicture:(NSInteger)type {
    __weak __typeof(&*self)weakSelf = self;
    
    [self cleanAndUpdateTopBarState];
    
    // 底图
    UIImage *bgImage = self.selectedImage;
    // 合并的图片
    UIImage *lastImage = [weakSelf.defaultView mergeImage];
    if (type == 0) {// 绘制
        [DrawViewController openDrawVCWithDiyBgImage:bgImage baseVC:self lastImage:lastImage saveBlock:^(UIImage * _Nonnull drawImage) {
            if (drawImage) {
                [weakSelf.defaultView addImage:drawImage edit:NO];
            }
        }];
    }
    else if (type == 1) { // 贴图
        [StickersViewController openStickersVCWithDiyBgImage:bgImage baseVC:self lastImage:lastImage confirmBlock:^(UIImage * _Nonnull image) {
            if (image) {
                [weakSelf.defaultView addImage:image edit:NO];
            }
        }];
    }
    else if (type == 2) {// 字体
        [FontViewController openFontVCWithDiyBgImage:bgImage baseView:self lastImage:lastImage confirmBlock:^(UIImage * _Nonnull image) {
            if (image) {
                [weakSelf.defaultView addImage:image edit:NO];
            }
        }];
    }
}

#pragma mark - 懒加载

- (UIImageView *)bgImageView {
    if (!_bgImageView) {
        _bgImageView = [[UIImageView alloc] init];
        _bgImageView.image = [UIImage imageNamed:@"diy_bgImage"];
    }
    return _bgImageView;
}

- (PaintingDefaultView *)defaultView {
    if (!_defaultView) {
        _defaultView = [[PaintingDefaultView alloc] init];
        // 添加阴影
        _defaultView.layer.shadowOpacity = 1;
        _defaultView.layer.shadowColor = [UIColor colorWithRed:95/255.0 green:79/255.0 blue:135/255.0 alpha:0.35].CGColor;
        _defaultView.layer.shadowOffset = CGSizeMake(0, 0);
    }
    return _defaultView;
}

- (PaintingBottomView *)bottomView {
    if (!_bottomView) {
        _bottomView = [[PaintingBottomView alloc] init];
    }
    return _bottomView;
}

@end
