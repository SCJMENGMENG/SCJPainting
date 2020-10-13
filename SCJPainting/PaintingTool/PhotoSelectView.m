//
//  PhotoSelectView.m
//  SCJPainting
//
//  Created by scj on 2020/10/13.
//  Copyright © 2020 scj. All rights reserved.
//

#import "PhotoSelectView.h"
#import "PhotoSelectCell.h"

#import <Masonry.h>

#define columns 5
#define kItemMargin 10
#define kCellItemWidth (kScreenWidth - 40 - (columns - 1)*kItemMargin)/columns
#define kScreenWidth  [UIScreen mainScreen].bounds.size.width

@interface PhotoSelectView ()<UICollectionViewDataSource, UICollectionViewDelegate>

@property (nonatomic, strong) UIImageView *shadowImage;
@property (nonatomic, strong) UIButton *closeAndOpenBtn;
@property (nonatomic, strong) UICollectionView *collectionView;
@property (nonatomic, strong) UICollectionViewFlowLayout *flowLayout;
@property (nonatomic, strong) NSArray *dataArr;
@end

@implementation PhotoSelectView

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        [self setupUI];
        
        self.dataArr = @[
        @"diy_stickers_arrow",
        @"diy_stickers_planet",
        @"diy_stickers_planet",
        @"diy_stickers_planet",
        @"diy_stickers_planet",
        @"diy_stickers_planet",
        @"diy_stickers_planet",
        @"diy_stickers_planet",
        @"diy_stickers_planet",
        @"diy_stickers_planet",
        @"diy_stickers_planet",
        @"diy_stickers_planet",
        @"diy_stickers_planet",
        @"diy_stickers_planet",
        @"diy_stickers_planet",
        @"diy_stickers_planet",
        @"diy_stickers_planet",
        @"diy_stickers_planet",
        @"diy_stickers_planet",
        @"diy_stickers_planet",
        @"diy_stickers_planet",
        @"diy_stickers_planet",
        @"diy_stickers_planet",
        @"diy_stickers_planet",
        @"diy_stickers_planet",
        @"diy_stickers_planet",
        @"diy_stickers_planet",
        @"diy_stickers_planet",
        @"diy_stickers_planet",
        @"diy_stickers_planet",
        ];
    }
    return self;
}

#pragma mark - UICollectionViewDataSorce

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.dataArr.count + 1;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {

    PhotoSelectCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"PhotoSelectCell" forIndexPath:indexPath];
    if (!cell) {
        cell = [[PhotoSelectCell alloc] init];
    }
    
    if (indexPath.row == 0) {
        cell.image = [UIImage imageNamed:@"diy_select_photo"];
    } else {
        cell.image = [UIImage imageNamed:self.dataArr[indexPath.row-1]];
    }

    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    
    UIImage *image = indexPath.row == 0 ? nil : [UIImage imageNamed:self.dataArr[indexPath.row-1]];
    if (self.cellSelectedBlock) {
        self.cellSelectedBlock(indexPath.row, image);
    }
}

#pragma mark - Layout

- (void)setupUI {
    [self addSubview:self.shadowImage];
    [self addSubview:self.closeAndOpenBtn];
    [self addSubview:self.collectionView];
    
    [self.shadowImage mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.left.right.equalTo(self);
    }];
    
    [self.closeAndOpenBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.mas_top).offset(11 + 6);// 6是阴影高度
        make.centerX.equalTo(self);
    }];
    
    [self.collectionView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.shadowImage.mas_bottom);
        make.left.bottom.right.equalTo(self);
    }];
}

#pragma mark - 懒加载

- (UICollectionView *)collectionView {
    if (!_collectionView) {
        _collectionView = [[UICollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:self.flowLayout];
        _collectionView.backgroundColor = [UIColor whiteColor];
        _collectionView.dataSource = self;
        _collectionView.delegate = self;
        _collectionView.showsVerticalScrollIndicator = NO;
        [_collectionView registerClass:[PhotoSelectCell class] forCellWithReuseIdentifier:@"PhotoSelectCell"];
    }
    return _collectionView;
}

- (UICollectionViewFlowLayout *)flowLayout {
    if (!_flowLayout) {
        _flowLayout = [[UICollectionViewFlowLayout alloc] init];
        _flowLayout.minimumLineSpacing = 8;
        _flowLayout.minimumInteritemSpacing = 10;
        _flowLayout.sectionInset = UIEdgeInsetsMake(0, 20, 0, 20);
        _flowLayout.itemSize = CGSizeMake(kCellItemWidth, kCellItemWidth);
    }
    return _flowLayout;
}

- (UIImageView *)shadowImage {
    if (!_shadowImage) {
        _shadowImage = [[UIImageView alloc] init];
        _shadowImage.image = [UIImage imageNamed:@"diy_corner_shadow"];
    }
    return _shadowImage;
}

- (UIButton *)closeAndOpenBtn {
    if (!_closeAndOpenBtn) {
        _closeAndOpenBtn = [[UIButton alloc] init];
        [_closeAndOpenBtn setBackgroundImage:[UIImage imageNamed:@"diy_down"] forState:UIControlStateNormal];
        [_closeAndOpenBtn setBackgroundImage:[UIImage imageNamed:@"diy_up"] forState:UIControlStateSelected];
        [_closeAndOpenBtn addTarget:self action:@selector(closeAndOpenBtnClick:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _closeAndOpenBtn;
}

- (void)closeAndOpenBtnClick:(UIButton *)btn {
    btn.selected = !btn.selected;
    if (self.closeAndOpenBtnClickBlock) {
        self.closeAndOpenBtnClickBlock(btn.selected);
    }
}

@end
