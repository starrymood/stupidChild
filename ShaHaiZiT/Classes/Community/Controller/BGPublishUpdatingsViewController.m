//
//  BGPublishUpdatingsViewController.m
//  shzTravelC
//
//  Created by biao on 2018/7/25.
//  Copyright © 2018年 biao. All rights reserved.
//

#import "BGPublishUpdatingsViewController.h"
#import "BGCommunityApi.h"
#import "BGPickViewController.h"
#import "BGCommunityTypeModel.h"
#import "HXPhotoPicker.h"
#import "BGMemberApi.h"
#import <QiniuSDK.h>
#import "BGEssayDetailModel.h"
#import <JCAlertController.h>
#import "UITextField+BGLimit.h"
#import <MBProgressHUD.h>
#import <UIImageView+WebCache.h>

static const CGFloat kPhotoViewMargin = 12.0;

@interface BGPublishUpdatingsViewController ()<pickViewDelegate,HXPhotoViewDelegate,UIImagePickerControllerDelegate,UITextViewDelegate>
@property (weak, nonatomic) IBOutlet UIImageView *picImgView;
@property (weak, nonatomic) IBOutlet UIView *bottomView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *centerY;
@property (weak, nonatomic) IBOutlet UIButton *sortBtn;
@property (weak, nonatomic) IBOutlet UITextField *titleTextField;
@property (weak, nonatomic) IBOutlet UITextView *textView;
@property (nonatomic, strong) UILabel *placeholderLabel;
@property (weak, nonatomic) IBOutlet UIButton *publishBtn;
@property (nonatomic, copy) NSArray *titleArr;
@property (nonatomic, copy) NSArray *idArr;
@property (nonatomic, copy) NSString *sortIdStr;
@property (nonatomic, strong) BGEssayDetailModel *fModel;

@property (strong, nonatomic) HXPhotoManager *manager;
@property (strong, nonatomic) HXPhotoManager *managerOne;
@property (strong, nonatomic) HXPhotoView *photoView;
@property (strong, nonatomic) HXDatePhotoToolManager *toolManager;
@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
@property (nonatomic, copy) NSString *headImgHostStr;
@property (nonatomic, strong) NSMutableArray *allUrl;
@property (nonatomic, strong) NSMutableArray *imageUrl;
@property (nonatomic, assign) BOOL isVideo;
@property (nonatomic, strong) JCAlertController *alert;
@property (nonatomic, assign) BOOL isEditPic;
@property (assign, nonatomic) BOOL original;
@property(nonatomic,copy) NSString *picStr;
@property(nonatomic,copy) NSString *picUrlStr;
@property(nonatomic,strong) UIImage *picImg;
@property(nonatomic,assign) NSTimeInterval requestTime;

@end

@implementation BGPublishUpdatingsViewController
-(NSMutableArray *)imageUrl{
    if (!_imageUrl) {
        self.imageUrl = [NSMutableArray array];
    }
    return _imageUrl;
}
-(NSMutableArray *)allUrl{
    if (!_allUrl) {
        self.allUrl = [NSMutableArray array];
    }
    return _allUrl;
}
- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self loadSubViews];
}

-(void)loadSubViews{
    self.navigationItem.title = @"发布新动态";
    self.view.backgroundColor = kAppBgColor;
    self.centerY.constant = (self.bottomView.height+self.bottomView.y-SCREEN_HEIGHT+SafeAreaTopHeight)*0.5;
     UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(imgViewClicked:)];
     [_picImgView addGestureRecognizer:tap];
    self.picStr = @"";
    self.picUrlStr = @"";
    self.sortBtn.layer.borderColor = kAppMainColor.CGColor;
    self.sortBtn.layer.borderWidth = 1.0;
    self.sortBtn.layer.cornerRadius = 2;
    self.placeholderLabel = [[UILabel alloc] initWithFrame:CGRectMake(3, 3, SCREEN_WIDTH-20-6, 25)];

    _placeholderLabel.enabled = NO;
    _placeholderLabel.text = @"添加描述";
    _placeholderLabel.numberOfLines = 0;
    _placeholderLabel.font = kFont(13);
    _placeholderLabel.textColor = kApp999Color;
    [_textView addSubview:_placeholderLabel];
    
    _titleTextField.maxLenght = 50;
    
    _sortIdStr = @"";
    self.original = NO;
    self.isEditPic = NO;
    self.requestTime = 0;
    self.scrollView.alwaysBounceVertical = YES;
    if (_isEdit) {
        self.navigationItem.rightBarButtonItem = [UIBarButtonItem itemWithImage:@"address_delete_icon" highImage:@"address_delete_icon" target:self action:@selector(clickedDeleteItem:)];
        [self loadDetailDataAction];
    }else{
        CGFloat width = _scrollView.frame.size.width;
        HXPhotoView *photoView = [HXPhotoView photoManager:self.manager];
        photoView.frame = CGRectMake(kPhotoViewMargin, kPhotoViewMargin, width - kPhotoViewMargin * 2, 0);
        photoView.spacing = kPhotoViewMargin*2;
        photoView.delegate = self;
        photoView.backgroundColor = [UIColor whiteColor];
        [_scrollView addSubview:photoView];
        self.photoView = photoView;
    }
}
-(void)imgViewClicked:(UITapGestureRecognizer *)tap{
    if ([Tool isBlankString:self.picUrlStr]) {
        [self actionSelectPhotoWithTap:tap];
    }else{
        UIAlertController *menu = [UIAlertController alertControllerWithTitle:nil message:nil preferredStyle:(UIAlertControllerStyleActionSheet)];
        __block typeof(self) weakSelf = self;
        
        UIAlertAction *cameraAction = [UIAlertAction actionWithTitle:@"从手机相册选择" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            [weakSelf actionSelectPhotoWithTap:tap];
        }];
        UIAlertAction *photoAction = [UIAlertAction actionWithTitle:@"删除" style:UIAlertActionStyleDestructive handler:^(UIAlertAction * _Nonnull action) {
            [weakSelf actionDeletePhotoWithTap:tap];
        }];
        UIAlertAction *actionNo = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
            
        }];
        
        [menu addAction:actionNo];
        [menu addAction:cameraAction];
        [menu addAction:photoAction];
        [self presentViewController:menu animated:YES completion:nil];
    }
}
-(void)actionSelectPhotoWithTap:(UITapGestureRecognizer *)tap{
    [self.managerOne clearSelectedList];
    __weak typeof(self) weakSelf = self;
    [self hx_presentSelectPhotoControllerWithManager:self.managerOne didDone:^(NSArray<HXPhotoModel *> *allList, NSArray<HXPhotoModel *> *photoList, NSArray<HXPhotoModel *> *videoList, BOOL isOriginal, UIViewController *viewController, HXPhotoManager *manager) {
        NSSLog(@"photo - %@",photoList);
        [weakSelf writeToFileWithArr:photoList];
    } cancel:^(UIViewController *viewController, HXPhotoManager *manager) {
        NSSLog(@"取消了");
    }];
}
-(void)writeToFileWithArr:(NSArray *)photoList{
    [ProgressHUDHelper showLoading];
    __weak typeof(self) weakSelf = self;
    [self.toolManager writeSelectModelListToTempPathWithList:photoList requestType:HXDatePhotoToolManagerRequestTypeHD success:^(NSArray<NSURL *> *allURL, NSArray<NSURL *> *photoURL, NSArray<NSURL *> *videoURL) {
        NSSLog(@"\nall : %@ \nimage : %@ \nvideo : %@",allURL,photoURL,videoURL);
        NSURL *url = photoURL.firstObject;
        if (url) {
            UIImage *image = [UIImage imageWithData:[NSData dataWithContentsOfURL:url]];
            weakSelf.picImg = image;
            weakSelf.picStr = [NSString stringWithFormat:@"%@",url];
            [weakSelf getQiniuTokenActionOne];
        }
    } failed:^{
        [ProgressHUDHelper removeLoading];
        NSSLog(@"写入失败");
    }];
}
-(void)getQiniuTokenActionOne{
    __block typeof(self)weakSelf = self;
    [BGMemberApi getQiniuKey:nil succ:^(NSDictionary *response) {
        DLog(@"\n>>>[getQiniuKey sucess]:%@",response);
        NSString *qiniuToken = response[@"result"][@"auth_token"];
        if (![Tool isBlankString:qiniuToken]) {
            [weakSelf uploadImageWithTokenOne:qiniuToken];
            weakSelf.headImgHostStr = response[@"result"][@"host"];
        }else{
            weakSelf.publishBtn.userInteractionEnabled = YES;
            [WHIndicatorView toast:@"网络问题,请重试"];
        }
    } failure:^(NSDictionary *response) {
        DLog(@"\n>>>[getQiniuKey failure]:%@",response);
        weakSelf.publishBtn.userInteractionEnabled = YES;
    }];
}
/**
 上传头像网络请求
 
 @return void
 */
#pragma mark - 上传头像

-(void)uploadImageWithTokenOne:(NSString *)token{
    __weak __typeof(self) weakSelf = self;
    [ProgressHUDHelper showLoading];
    QNUploadManager *upManager = [[QNUploadManager alloc] init];
    [upManager putFile:[self.picStr substringFromIndex:5] key:nil token:token complete:^(QNResponseInfo *info, NSString *key, NSDictionary *resp) {
        if (!info.error) {
            NSString *nameStr = BGdictSetObjectIsNil(resp[@"name"]);
            self.picUrlStr = [NSString stringWithFormat:@"%@%@",self.headImgHostStr,nameStr];
            [weakSelf.picImgView setImage:weakSelf.picImg];
        }
        [ProgressHUDHelper removeLoading];
    } option:nil];
}
-(void)actionDeletePhotoWithTap:(UITapGestureRecognizer *)tap{
    self.picUrlStr = @"";
    [self.picImgView setImage:BGImage(@"feedback_add_pictures")];
    
}
-(void)loadDetailDataAction{
    [ProgressHUDHelper showLoading];
    NSMutableDictionary *param = [[NSMutableDictionary alloc] init];
    [param setObject:_IDStr forKey:@"post_id"];
    __weak __typeof(self) weakSelf = self;
    [BGCommunityApi getEditEssayDetail:param succ:^(NSDictionary *response) {
        DLog(@"\n>>>[getEditEssayDetail sucess]:%@",response);
        [weakSelf hideNodateView];
        
        BGEssayDetailModel *model = [BGEssayDetailModel mj_objectWithKeyValues:BGdictSetObjectIsNil(response[@"result"])];
         weakSelf.fModel = model;
        [weakSelf updateSubViewsWithModel:model];
    } failure:^(NSDictionary *response) {
        DLog(@"\n>>>[getEditEssayDetail failure]:%@",response);
        [ProgressHUDHelper removeLoading];
        [weakSelf shownoNetWorkViewWithType:0];
        [weakSelf setRefreshBlock:^{
            [weakSelf loadDetailDataAction];
        }];
    }];
}
-(void)updateSubViewsWithModel:(BGEssayDetailModel *)model{
    self.requestTime = [[NSDate date] timeIntervalSince1970];//精确到毫秒
    self.picUrlStr = model.picture;
    [self.picImgView sd_setImageWithURL:[NSURL URLWithString:model.picture] placeholderImage:BGImage(@"feedback_add_pictures")];
    _sortIdStr = model.classification_id;
    _titleTextField.text = model.post_title;
    [_placeholderLabel setHidden:YES];
    _textView.text = model.content;
    self.isEditPic = NO;
    if (model.type.intValue == 1) {
        _isVideo = NO;
    }
    if (model.type.intValue == 2) {
        _isVideo = YES;
    }
    CGFloat width = _scrollView.frame.size.width;
    HXPhotoView *photoView = [HXPhotoView photoManager:self.manager];
    photoView.frame = CGRectMake(kPhotoViewMargin, kPhotoViewMargin, width - kPhotoViewMargin * 2, 0);
    photoView.delegate = self;
    photoView.spacing = kPhotoViewMargin*2;
    photoView.backgroundColor = [UIColor whiteColor];
    [_scrollView addSubview:photoView];
    self.photoView = photoView;
    __weak __typeof(self) weakSelf = self;
    _photoView.deleteNetworkPhotoBlock = ^(NSString *networkPhotoUrl) {
        weakSelf.isEditPic = YES;
    };
    if (_isVideo) {
        _manager.configuration.photoMaxNum = 1;
        _manager.configuration.videoMaxNum = 0;
        _manager.configuration.maxNum = 1;
        NSString *playUrl = [NSString stringWithFormat:@"%@?vframe/jpg/offset/0/rotate/auto",model.file_url[0]];
        HXCustomAssetModel *model = HXCustomAssetModel.new;
        model.type = HXCustomAssetModelTypeNetWorkImage;
        model.networkImageURL = [NSURL URLWithString:playUrl];
        model.selected = YES;
        model.networkThumbURL = [NSURL URLWithString:playUrl];
        [self.manager addCustomAssetModel:@[model]];
        _photoView.collectionView.allowsSelection = NO;
        _photoView.collectionView.editEnabled = NO;
    }else{
        NSMutableArray *picUrlArr = [[NSMutableArray alloc] init];
        for (int i = 0; i<model.file_url.count; i++) {
            HXCustomAssetModel *cModel = HXCustomAssetModel.new;
            cModel.type = HXCustomAssetModelTypeNetWorkImage;
            cModel.networkImageURL = [NSURL URLWithString:model.file_url[i]];
            cModel.selected = YES;
            cModel.networkThumbURL = [NSURL URLWithString:model.file_url[i]];
            [picUrlArr addObject:cModel];
        }
        [self.manager addCustomAssetModel:picUrlArr];
    }
    [self.photoView refreshView];
    
    [BGCommunityApi getPublishTypeList:nil succ:^(NSDictionary *response) {
        DLog(@"\n>>>[getPublishTypeList sucess]:%@",response);
        NSArray *arr = BGdictSetObjectIsNil(response[@"result"]);
        for (NSDictionary *dic in arr) {
            if ([[NSString stringWithFormat:@"%@",BGdictSetObjectIsNil(dic[@"id"])] isEqualToString:model.classification_id]) {
                [self.sortBtn setTitle:BGdictSetObjectIsNil(dic[@"categoryName"]) forState:(UIControlStateNormal)];
            }
        }
    } failure:^(NSDictionary *response) {
        DLog(@"\n>>>[getPublishTypeList failure]:%@",response);
    }];
    
}

- (IBAction)btnChooseSortClicked:(UIButton *)sender {
    [self keyboarkHidden];
    [ProgressHUDHelper showLoading];
    __block typeof(self)weakSelf = self;
    [BGCommunityApi getPublishTypeList:nil succ:^(NSDictionary *response) {
        DLog(@"\n>>>[getPublishTypeList sucess]:%@",response);
        NSMutableArray *arr = [NSMutableArray array];
        arr = [BGCommunityTypeModel mj_objectArrayWithKeyValuesArray:BGdictSetObjectIsNil(response[@"result"])];
        NSMutableArray *tempTitleArr = [NSMutableArray array];
        NSMutableArray *tempIdArr = [NSMutableArray array];
        for (BGCommunityTypeModel *model in arr) {
            [tempTitleArr addObject:model.categoryName];
            [tempIdArr addObject:model.ID];
        }
       
        weakSelf.titleArr = [NSArray arrayWithArray:tempTitleArr];
        weakSelf.idArr = [NSArray arrayWithArray:tempIdArr];
        
        BGPickViewController *pick = [[BGPickViewController alloc] initWithNibName:@"BGPickViewController" bundle:nil];
        pick.delegate = self;
        pick.arry = tempTitleArr;
        pick.modalPresentationStyle = UIModalPresentationCustom;
        [weakSelf presentViewController:pick animated:YES completion:nil];
        
    } failure:^(NSDictionary *response) {
        DLog(@"\n>>>[getPublishTypeList failure]:%@",response);
    }];
    
}
- (IBAction)btnPublishClicked:(UIButton *)sender {
    if ([Tool isBlankString:_sortIdStr]) {
        [WHIndicatorView toast:@"请选择所属分类"];
        return;
    }
    if (_titleTextField.text.length < 1) {
        [WHIndicatorView toast:@"请填写标题内容"];
        return;
    }
    if ([Tool isBlankString:self.picUrlStr]) {
        [WHIndicatorView toast:@"请上传封面图"];
        return;
    }
    if (_textView.text.length < 1) {
        [WHIndicatorView toast:@"请填写描述内容"];
        return;
    }
    if (_isEdit && !_isEditPic) {
    }else{
        if (![Tool arrayIsNotEmpty:self.allUrl]) {
            [WHIndicatorView toast:@"请上传图片或视频"];
            return;
        }
    }
    
    sender.userInteractionEnabled = NO;
    if (_isEdit && !_isEditPic) {
        if (_isVideo) {
            [self editPublishAction];
        }else{
            [self editNoPicPublishAction];
        }
    }else{
         [self getQiniuTokenAction];
    }
   
    
}
-(void)getQiniuTokenAction{
    [ProgressHUDHelper showLoading];
    __block typeof(self)weakSelf = self;
    [BGMemberApi getQiniuKey:nil succ:^(NSDictionary *response) {
        DLog(@"\n>>>[getQiniuKey sucess]:%@",response);
        NSString *qiniuToken = response[@"result"][@"auth_token"];
        if (![Tool isBlankString:qiniuToken]) {
            [weakSelf uploadImageWithToken:qiniuToken];
            weakSelf.headImgHostStr = response[@"result"][@"host"];
        }else{
            weakSelf.publishBtn.userInteractionEnabled = YES;
            [WHIndicatorView toast:@"网络问题,请重试"];
        }
    } failure:^(NSDictionary *response) {
        DLog(@"\n>>>[getQiniuKey failure]:%@",response);
        weakSelf.publishBtn.userInteractionEnabled = YES;
    }];
}
/**
 上传头像网络请求
 
 @return void
 */
#pragma mark - 上传头像

-(void)uploadImageWithToken:(NSString *)token{
    [ProgressHUDHelper removeLoading];
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.navigationController.view animated:YES];
    hud.label.text = @"上传中...";
    NSMutableArray *urlList = [NSMutableArray array];
    //创建一个并行队列
    dispatch_queue_t queue_serial = dispatch_queue_create("tk.bourne.testQueue", DISPATCH_QUEUE_CONCURRENT);
    //遍历图片数组
    __block int getSuccessful = 0;
    __block int getFail = 0;
    for (int index = 0; index < _allUrl.count ; index++){
        [urlList addObject:@""];
        __weak __typeof(self) weakSelf = self;
        dispatch_async(queue_serial, ^{
                    //获取上传uploadtoken
            QNUploadManager *upManager = [[QNUploadManager alloc] init];
            NSString *fileStr = [NSString stringWithFormat:@"%@",self.allUrl[index]];
            if ([fileStr hasPrefix:@"http"]) {
                [urlList replaceObjectAtIndex:index withObject:fileStr];
                getSuccessful ++;
                if (getSuccessful == weakSelf.allUrl.count) {
                    [weakSelf publishPostActionWithArr:urlList];
                }
                return ;
            }
            if (fileStr.length >5) {
                [upManager putFile:[fileStr substringFromIndex:5] key:nil token:token complete:^(QNResponseInfo *info, NSString *key, NSDictionary *resp) {
                    if (!info.error) {
                        NSString *nameStr = BGdictSetObjectIsNil(resp[@"name"]);
                        NSString *imageUrl = [NSString stringWithFormat:@"%@%@",self.headImgHostStr,nameStr];
                        [urlList replaceObjectAtIndex:index withObject:imageUrl];
                        getSuccessful ++;
                        if (getSuccessful == weakSelf.allUrl.count) {
                            [weakSelf publishPostActionWithArr:urlList];
                        }
                    }else{
                        getFail++;
                    weakSelf.publishBtn.userInteractionEnabled = YES;
                    [MBProgressHUD hideHUDForView:self.navigationController.view animated:YES];
                    }
                } option:nil];
            }else{
                [MBProgressHUD hideHUDForView:self.navigationController.view animated:YES];
            }
        });
    }
    
    

}
-(void)publishPostActionWithArr:(NSMutableArray *)arr{
    NSMutableDictionary *param = [[NSMutableDictionary alloc] init];
    [param setObject:_titleTextField.text forKey:@"postTitle"];
    NSString *urlStr = arr[0];
    for (int i = 1; i<arr.count; i++) {
        urlStr = [NSString stringWithFormat:@"%@,%@",urlStr,arr[i]];
    }
    [param setObject:urlStr forKey:@"fileUrl"];
    [param setObject:_textView.text forKey:@"content"];
    [param setObject:_sortIdStr forKey:@"classificationId"];
    [param setObject:_picUrlStr forKey:@"picture"];
    
    [param setObject:_isVideo?@"2":@"1" forKey:@"type"];
    [param setObject:_isEdit?_IDStr:@"" forKey:@"id"];
    
    [BGCommunityApi publishEditPost:param succ:^(NSDictionary *response) {
        DLog(@"\n>>>[publishEditPost sucess]:%@",response);
        [MBProgressHUD hideHUDForView:self.navigationController.view animated:YES];
        [WHIndicatorView toast:BGdictSetObjectIsNil(response[@"msg"])];
        [self.navigationController popViewControllerAnimated:YES];
    } failure:^(NSDictionary *response) {
        DLog(@"\n>>>[publishEditPost failure]:%@",response);
        [MBProgressHUD hideHUDForView:self.navigationController.view animated:YES];
        self.publishBtn.userInteractionEnabled = YES;
    }];
    
}
-(void)editPublishAction{
    [ProgressHUDHelper showLoading];
    NSMutableDictionary *param = [[NSMutableDictionary alloc] init];
    [param setObject:_titleTextField.text forKey:@"postTitle"];
    [param setObject:_fModel.file_url[0] forKey:@"fileUrl"];
    [param setObject:_textView.text forKey:@"content"];
    [param setObject:_sortIdStr forKey:@"classificationId"];
    [param setObject:_picUrlStr forKey:@"picture"];
    [param setObject:@"2" forKey:@"type"];
    [param setObject:_IDStr forKey:@"id"];
    [BGCommunityApi publishEditPost:param succ:^(NSDictionary *response) {
        DLog(@"\n>>>[publishEditPost sucess]:%@",response);
        [WHIndicatorView toast:@"编辑成功"];
        [self.navigationController popViewControllerAnimated:YES];
    } failure:^(NSDictionary *response) {
        DLog(@"\n>>>[publishEditPost failure]:%@",response);
        self.publishBtn.userInteractionEnabled = YES;
    }];
}
-(void)editNoPicPublishAction{
    [ProgressHUDHelper showLoading];
    NSMutableDictionary *param = [[NSMutableDictionary alloc] init];
    [param setObject:_titleTextField.text forKey:@"postTitle"];
    NSString *urlStr = _fModel.file_url[0];
    for (int i = 1; i<_fModel.file_url.count; i++) {
        urlStr = [NSString stringWithFormat:@"%@,%@",urlStr,_fModel.file_url[i]];
    }
    [param setObject:urlStr forKey:@"fileUrl"];
    [param setObject:_textView.text forKey:@"content"];
    [param setObject:_sortIdStr forKey:@"classificationId"];
    [param setObject:_picUrlStr forKey:@"picture"];
    [param setObject:@"1" forKey:@"type"];
    [param setObject:_IDStr forKey:@"id"];
    [BGCommunityApi publishEditPost:param succ:^(NSDictionary *response) {
        DLog(@"\n>>>[publishEditPost sucess]:%@",response);
        [WHIndicatorView toast:@"编辑成功"];
        [self.navigationController popViewControllerAnimated:YES];
    } failure:^(NSDictionary *response) {
        DLog(@"\n>>>[publishEditPost failure]:%@",response);
        self.publishBtn.userInteractionEnabled = YES;
    }];
}
#pragma mark - UITextView -
-(void)textViewDidChange:(UITextView *)textView
{
    if ([textView.text length] == 0) {
        [_placeholderLabel setHidden:NO];
    }else{
        [_placeholderLabel setHidden:YES];
    }
    [self wordLimit: textView];
}

-(BOOL)wordLimit:(UITextView *)text {
    
    if (text.text.length > 10000) {
        [WHIndicatorView toast:@"请输入小于10000个文字"];
        NSString *s = [text.text substringToIndex:10000];
        text.text = s;
    }
    return nil;
}

-(void)getTextStr:(NSString *)text index:(NSInteger)index{
    [self.sortBtn setTitle:text forState:(UIControlStateNormal)];
    _sortIdStr = self.idArr[index];
}


- (HXDatePhotoToolManager *)toolManager {
    if (!_toolManager) {
        _toolManager = [[HXDatePhotoToolManager alloc] init];
    }
    return _toolManager;
}

- (HXPhotoManager *)manager {
    if (!_manager) {
        _manager = [[HXPhotoManager alloc] initWithType:HXPhotoManagerSelectedTypePhotoAndVideo];
        _manager.configuration.openCamera = YES;
        _manager.configuration.lookLivePhoto = YES;
        _manager.configuration.photoMaxNum = 9;
        _manager.configuration.videoMaxNum = 1;
        _manager.configuration.maxNum = 9;
        _manager.configuration.videoMaximumSelectDuration = 60.f;
//        _manager.configuration.requestImageAfterFinishingSelection = YES;
        _manager.configuration.showDateSectionHeader = YES;
        _manager.configuration.selectTogether = NO;
        __weak typeof(self) weakSelf = self;
        _manager.configuration.shouldUseCamera = ^(UIViewController *viewController, HXPhotoConfigurationCameraType cameraType, HXPhotoManager *manager) {
            
            // 这里拿使用系统相机做例子
            UIImagePickerController *imagePickerController = [[UIImagePickerController alloc] init];
            imagePickerController.delegate = (id)weakSelf;
            imagePickerController.allowsEditing = NO;
            NSString *requiredMediaTypeImage = ( NSString *)kUTTypeImage;
            NSString *requiredMediaTypeMovie = ( NSString *)kUTTypeMovie;
            NSArray *arrMediaTypes;
            if (cameraType == HXPhotoConfigurationCameraTypePhoto) {
                arrMediaTypes=[NSArray arrayWithObjects:requiredMediaTypeImage,nil];
            }else if (cameraType == HXPhotoConfigurationCameraTypeVideo) {
                arrMediaTypes=[NSArray arrayWithObjects:requiredMediaTypeMovie,nil];
            }else {
                arrMediaTypes=[NSArray arrayWithObjects:requiredMediaTypeImage, requiredMediaTypeMovie,nil];
            }
            [imagePickerController setMediaTypes:arrMediaTypes];
            // 设置录制视频的质量
            [imagePickerController setVideoQuality:UIImagePickerControllerQualityTypeHigh];
            //设置最长摄像时间
            [imagePickerController setVideoMaximumDuration:60.f];
            imagePickerController.sourceType = UIImagePickerControllerSourceTypeCamera;
            imagePickerController.navigationController.navigationBar.tintColor = [UIColor whiteColor];
            imagePickerController.modalPresentationStyle=UIModalPresentationOverCurrentContext;
            [viewController presentViewController:imagePickerController animated:YES completion:nil];
        };
    }
    return _manager;
}
- (HXPhotoManager *)managerOne {
    if (!_managerOne) {
        _managerOne = [[HXPhotoManager alloc] initWithType:HXPhotoManagerSelectedTypePhoto];
        _managerOne.configuration.openCamera = NO;
        _managerOne.configuration.lookLivePhoto = YES;
        _managerOne.configuration.photoMaxNum = 1;
        _managerOne.configuration.maxNum = 1;
        _managerOne.configuration.showDateSectionHeader = NO;
        _managerOne.configuration.selectTogether = NO;
        _managerOne.configuration.videoCanEdit = NO;
        _managerOne.configuration.photoCanEdit = NO;
    }
    return _managerOne;
}
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary<NSString *,id> *)info {
    [picker dismissViewControllerAnimated:YES completion:nil];
    
    NSString *mediaType = [info objectForKey:UIImagePickerControllerMediaType];
    HXPhotoModel *model;
    if ([mediaType isEqualToString:(NSString *)kUTTypeImage]) {
        UIImage *image = [info objectForKey:UIImagePickerControllerOriginalImage];
        model = [HXPhotoModel photoModelWithImage:image];
        if (self.manager.configuration.saveSystemAblum) {
            [HXPhotoTools savePhotoToCustomAlbumWithName:self.manager.configuration.customAlbumName photo:model.thumbPhoto];
        }
    }else  if ([mediaType isEqualToString:(NSString *)kUTTypeMovie]) {
        NSURL *url = info[UIImagePickerControllerMediaURL];
        NSDictionary *opts = [NSDictionary dictionaryWithObject:[NSNumber numberWithBool:NO]
                                                         forKey:AVURLAssetPreferPreciseDurationAndTimingKey];
        AVURLAsset *urlAsset = [AVURLAsset URLAssetWithURL:url options:opts];
        float second = 0;
        second = urlAsset.duration.value/urlAsset.duration.timescale;
        model = [HXPhotoModel photoModelWithVideoURL:url videoTime:second];
        if (self.manager.configuration.saveSystemAblum) {
            [HXPhotoTools saveVideoToCustomAlbumWithName:self.manager.configuration.customAlbumName videoURL:url];
        }
    }
    if (self.manager.configuration.useCameraComplete) {
        self.manager.configuration.useCameraComplete(model);
    }
}
- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    [picker dismissViewControllerAnimated:YES completion:nil];
}

- (void)photoView:(HXPhotoView *)photoView changeComplete:(NSArray<HXPhotoModel *> *)allList photos:(NSArray<HXPhotoModel *> *)photos videos:(NSArray<HXPhotoModel *> *)videos original:(BOOL)isOriginal {
    NSSLog(@"所有:%ld - 照片:%ld - 视频:%ld",allList.count,photos.count,videos.count);
    self.original = isOriginal;
    if (self.requestTime != 0 && !_isEditPic) {
        NSTimeInterval now = [[NSDate date] timeIntervalSince1970];//精确到毫秒
        float time = now - self.requestTime;
        self.isEditPic = time<2 ? NO:YES;
         DLog(@"time:%f",time);
    }
   
    if (allList.count == 0) {
        [self.allUrl removeAllObjects];
    }
    if (allList.count == 0) {
        _photoView.collectionView.allowsSelection = YES;
        _manager.configuration.photoMaxNum = 9;
        _manager.configuration.videoMaxNum = 1;
        _manager.configuration.maxNum = 9;
        self.isVideo = NO;
        _photoView.collectionView.editEnabled = YES;
        _photoView.collectionView.allowsSelection = YES;
        _isEditPic = YES;
    }
        NSSLog(@"所有:%@ - 照片:%@ - 视频:%@",allList,photos,videos);
    if (_isEdit && !_isEditPic) {
        [self.photoView.collectionView reloadData];
    }else{
        if (photos.count>0) {
            _manager.configuration.videoMaxNum = 0;
            self.isVideo = NO;
        }
        if (videos.count > 0) {
            _manager.configuration.photoMaxNum = 0;
            self.isVideo = YES;
        }
        [ProgressHUDHelper showLoading];

        HXDatePhotoToolManagerRequestType requestType;
        if (self.original) {
            requestType = HXDatePhotoToolManagerRequestTypeOriginal;
        }else {
            requestType = HXDatePhotoToolManagerRequestTypeHD;
        }
        [self.toolManager writeSelectModelListToTempPathWithList:allList requestType:requestType success:^(NSArray<NSURL *> *allURL, NSArray<NSURL *> *photoURL, NSArray<NSURL *> *videoURL) {
            NSSLog(@"\nall : %@ \nimage : %@ \nvideo : %@",allURL,photoURL,videoURL);
            [self.allUrl removeAllObjects];
            self.allUrl = [NSMutableArray arrayWithArray:allURL];
            [ProgressHUDHelper removeLoading];
        } failed:^{
            [ProgressHUDHelper removeLoading];
            NSSLog(@"失败");
            if (self.allUrl.count == 0) {
                return ;
            }
            [WHIndicatorView toast:@"加载失败,请重试"];
            [self.navigationController popViewControllerAnimated:YES];
        }];
    }
    
}
- (void)photoView:(HXPhotoView *)photoView deleteNetworkPhoto:(NSString *)networkPhotoUrl {
    NSSLog(@"%@",networkPhotoUrl);
}

- (void)photoView:(HXPhotoView *)photoView updateFrame:(CGRect)frame {
    NSSLog(@"%@",NSStringFromCGRect(frame));
    self.scrollView.contentSize = CGSizeMake(self.scrollView.frame.size.width, CGRectGetMaxY(frame) + kPhotoViewMargin);
    
}

- (void)photoView:(HXPhotoView *)photoView currentDeleteModel:(HXPhotoModel *)model currentIndex:(NSInteger)index {
    NSSLog(@"%@ --> index - %ld",model,index);
}
#pragma mark - clickedShareItem

- (void)clickedDeleteItem:(UIButton *)btn{
    
    self.alert = [JCAlertController alertWithTitle:@"提示" message:@"确定要删除该动态吗?"];
    
    [self.alert addButtonWithTitle:@"取消" type:JCButtonTypeCancel clicked:^{
        
    }];
    __weak __typeof(self) weakSelf = self;
    [self.alert addButtonWithTitle:@"删除" type:JCButtonTypeWarning clicked:^{
        [ProgressHUDHelper showLoading];
        NSMutableDictionary *param = [[NSMutableDictionary alloc] init];
        [param setObject:weakSelf.IDStr forKey:@"post_id"];
        [BGCommunityApi publishDeletePost:param succ:^(NSDictionary *response) {
            DLog(@"\n>>>[publishDeletePost sucess]:%@",response);
            [WHIndicatorView toast:@"删除成功"];
            [weakSelf.navigationController popViewControllerAnimated:YES];
        } failure:^(NSDictionary *response) {
            DLog(@"\n>>>[publishDeletePost failure]:%@",response);
        }];
        
        
    }];
    
    [self presentViewController:_alert animated:YES completion:nil];
    
    
    
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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
