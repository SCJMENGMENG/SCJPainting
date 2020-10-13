//
//  ColorSelectView.m
//  SCJPainting
//
//  Created by scj on 2020/10/13.
//  Copyright © 2020 scj. All rights reserved.
//

#import "ColorSelectView.h"
#import "ColorSelectModel.h"
#import "ColorSelectCell.h"

#import <Masonry.h>

@interface ColorSelectView ()<UICollectionViewDataSource, UICollectionViewDelegate>
@property (nonatomic, strong) UICollectionView *collectionView;
@property (nonatomic, strong) UICollectionViewFlowLayout *flowLayout;
@property (nonatomic, strong) NSMutableArray *dataArr;
@end

@implementation ColorSelectView

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        [self setupUI];
    }
    return self;
}

- (void)setColorArr:(NSArray *)colorArr {
    _colorArr = colorArr;
    
    [self initializeColorSelectedModel];
}

- (void)setEdgeInsetsLeft:(CGFloat)edgeInsetsLeft {
    _edgeInsetsLeft = edgeInsetsLeft;

    self.flowLayout.sectionInset = UIEdgeInsetsMake(0, edgeInsetsLeft, 0, 0);
}

- (void)initializeColorSelectedModel {

    for (int i = 0; i < self.colorArr.count; i++) {
        UIColor *color = self.colorArr[i];
        ColorSelectModel *model = [[ColorSelectModel alloc] init];
        model.color = color;
        model.isSelected = i == 1 ? YES : NO;
        [self.dataArr addObject:model];
    }
    
    [self.collectionView reloadData];
}

- (void)setDefaultSelectedIndex:(NSInteger)defaultSelectedIndex {
    _defaultSelectedIndex = defaultSelectedIndex;
    if (defaultSelectedIndex < self.dataArr.count) {
        for (ColorSelectModel *model in self.dataArr) {
            if (model.isSelected) {
                model.isSelected = NO;
                break;
            }
        }
        ((ColorSelectModel *)self.dataArr[1]).isSelected = NO;
        ColorSelectModel *model = self.dataArr[defaultSelectedIndex];
        model.isSelected = YES;
    }
    [self.collectionView reloadData];
}

- (void)setSelectedColor:(UIColor *)selectedColor {
    _selectedColor = selectedColor;
    
    [self.dataArr enumerateObjectsUsingBlock:^(ColorSelectModel * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if (CGColorEqualToColor(selectedColor.CGColor, obj.color.CGColor)) {
         self.defaultSelectedIndex = idx;
            *stop = YES;
        }
    }];
}

#pragma mark - UICollectionViewDataSorce

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    
    return self.dataArr.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    ColorSelectCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"ColorSelectCell" forIndexPath:indexPath];
    if (!cell) {
        cell = [[ColorSelectCell alloc] init];
    }
    cell.indexPathRow = indexPath.row;
    cell.model = self.dataArr[indexPath.row];
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
  
    for (ColorSelectModel *model in self.dataArr) {
        if (model.isSelected) {
            model.isSelected = NO;
            break;
        }
    }
    
    ColorSelectModel *selectedModel = self.dataArr[indexPath.row];
     selectedModel.isSelected = YES;
    
    if (self.colorSelectedBlock) {
        self.colorSelectedBlock(selectedModel.color);
    }
    
    [self.collectionView reloadData];
}

#pragma mark - Layout

- (void)setupUI {
    [self addSubview:self.collectionView];
    
    [self.collectionView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.left.bottom.right.equalTo(self);
    }];
}

#pragma mark - 懒加载

- (UICollectionView *)collectionView {
    if (!_collectionView) {
        _collectionView = [[UICollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:self.flowLayout];
        _collectionView.backgroundColor = [UIColor whiteColor];
        _collectionView.dataSource = self;
        _collectionView.delegate = self;
        _collectionView.showsHorizontalScrollIndicator = NO;
        [_collectionView registerClass:[ColorSelectCell class] forCellWithReuseIdentifier:@"ColorSelectCell"];
    }
    return _collectionView;
}

- (UICollectionViewFlowLayout *)flowLayout {
    if (!_flowLayout) {
        _flowLayout = [[UICollectionViewFlowLayout alloc] init];
        _flowLayout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
        _flowLayout.minimumLineSpacing = 1;
        _flowLayout.minimumInteritemSpacing = 6;
        _flowLayout.sectionInset = UIEdgeInsetsMake(0, 20, 0, 20);
        _flowLayout.itemSize = CGSizeMake(kCellWidth, kCellWidth);
    }
    return _flowLayout;
}

- (NSMutableArray *)dataArr {
    if (!_dataArr) {
        _dataArr = [NSMutableArray array];
    }
    return _dataArr;
}
@end
