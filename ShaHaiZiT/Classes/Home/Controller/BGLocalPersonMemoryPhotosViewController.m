//
//  BGLocalPersonMemoryPhotosViewController.m
//  ShaHaiZiT
//
//  Created by biao on 2019/3/28.
//  Copyright © 2019 biao. All rights reserved.
//

#import "BGLocalPersonMemoryPhotosViewController.h"
#import "BGLocalPhotosCell.h"

@interface BGLocalPersonMemoryPhotosViewController ()<UICollectionViewDataSource,UICollectionViewDelegate>

@property (nonatomic,strong) UICollectionView *collectionView;

@end

@implementation BGLocalPersonMemoryPhotosViewController

- (void)viewDidLoad {
    [super viewDidLoad];
   
    [self loadSubViews];
    [self setupLayoutAndCollectionView];
}
-(void)loadSubViews{
    self.view.backgroundColor = kAppBgColor;
    self.navigationItem.title = @"相片";
}
/**
 * 创建布局和collectionView
 */
- (void)setupLayoutAndCollectionView{
    
    // 创建布局
    CGFloat itemVideoWidth = (SCREEN_WIDTH-30)*0.5;
    UICollectionViewFlowLayout *flowLayout1 =[[UICollectionViewFlowLayout alloc]init];
    flowLayout1.itemSize = CGSizeMake(itemVideoWidth, itemVideoWidth*242/173.0);
    flowLayout1.sectionInset = UIEdgeInsetsMake(12, 10, 20, 10);
    flowLayout1.minimumLineSpacing = 10;
    flowLayout1.minimumInteritemSpacing  = 10;
    flowLayout1.scrollDirection = UICollectionViewScrollDirectionVertical;
    
    // 创建collectionView
    UICollectionView * collectionView = [[UICollectionView alloc]initWithFrame:CGRectMake(0, SafeAreaTopHeight, SCREEN_WIDTH, SCREEN_HEIGHT-SafeAreaTopHeight) collectionViewLayout:flowLayout1];
    collectionView.backgroundColor = kAppBgColor;
    
    collectionView.dataSource = self;
    collectionView.delegate = self;
    [self.view addSubview:collectionView];
    // 注册
    [collectionView registerNib:[UINib nibWithNibName:NSStringFromClass([BGLocalPhotosCell class]) bundle:nil] forCellWithReuseIdentifier:@"BGLocalPhotosCell"];
    
    self.collectionView = collectionView;
    
}
#pragma mark UICollectionViewDataSource
- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView{
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    
    
    return _photos.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    
    BGLocalPhotosCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"BGLocalPhotosCell" forIndexPath:indexPath];
    if ([Tool arrayIsNotEmpty:_photos]) {
        [cell updataWithCellArr:_photos[indexPath.item]];
    }
    
    return cell;
    
}


/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
