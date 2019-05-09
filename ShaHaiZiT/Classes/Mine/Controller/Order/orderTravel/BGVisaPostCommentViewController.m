//
//  BGVisaPostCommentViewController.m
//  ShaHaiZiT
//
//  Created by biao on 2019/1/20.
//  Copyright © 2019 biao. All rights reserved.
//

#import "BGVisaPostCommentViewController.h"
#import "BGOrderTravelApi.h"
#import <UIImageView+WebCache.h>
#import "XHStarRateView.h"
#import "BGMemberApi.h"
#import <QiniuSDK.h>
#import "HXPhotoPicker.h"
#import <MBProgressHUD.h>

static const CGFloat kPhotoViewMargin = 12.0;
@interface BGVisaPostCommentViewController ()<HXPhotoViewDelegate,UIImagePickerControllerDelegate,UITextViewDelegate>
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *contentCenterY;
@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
@property (weak, nonatomic) IBOutlet UIView *gradesView;
@property (weak, nonatomic) IBOutlet UITextView *textView;
@property (weak, nonatomic) IBOutlet UIView *uploadView;
@property (weak, nonatomic) IBOutlet UIButton *publishBtn;
@property (nonatomic, copy) NSString *starOneStr;
@property (nonatomic, copy) NSString *starTwoStr;
@property (nonatomic, copy) NSString *starThreeStr;
@property (nonatomic, strong) UILabel *placeholderLabel;
@property (strong, nonatomic) HXPhotoManager *manager;
@property (strong, nonatomic) HXPhotoView *photoView;
@property (nonatomic, strong) NSMutableArray *imageUrl;
@property (nonatomic, copy) NSString *headImgHostStr;


@end

@implementation BGVisaPostCommentViewController
-(NSMutableArray *)imageUrl{
    if (!_imageUrl) {
        self.imageUrl = [NSMutableArray array];
    }
    return _imageUrl;
}
- (void)viewDidLoad {
    [super viewDidLoad];
   
    [self loadSubViews];
}
-(void)loadSubViews{
    self.navigationItem.title = @"发表评价";
    self.view.backgroundColor = kAppBgColor;
   
    XHStarRateView *starRateView1 = [[XHStarRateView alloc] initWithFrame:CGRectMake(103, 57, 150, 20) isT:YES finish:^(CGFloat currentScore) {
        self.starOneStr = [NSString stringWithFormat:@"%d",(int)currentScore];
    }];
    XHStarRateView *starRateView2 = [[XHStarRateView alloc] initWithFrame:CGRectMake(103, 97, 150, 20) isT:YES finish:^(CGFloat currentScore) {
        self.starTwoStr = [NSString stringWithFormat:@"%d",(int)currentScore];
    }];
    XHStarRateView *starRateView3 = [[XHStarRateView alloc] initWithFrame:CGRectMake(103, 137, 150, 20) isT:YES finish:^(CGFloat currentScore) {
        self.starThreeStr = [NSString stringWithFormat:@"%d",(int)currentScore];
    }];
    [self.gradesView addSubview:starRateView1];
    [self.gradesView addSubview:starRateView2];
    [self.gradesView addSubview:starRateView3];
    
    self.placeholderLabel = [[UILabel alloc] initWithFrame:CGRectMake(3, 3, SCREEN_WIDTH-20-6, 44)];
    _placeholderLabel.enabled = NO;
    _placeholderLabel.text = @"小主，您对此次行程还满意吗？\n您的评价会帮助我们更好的进步哟~";
    _placeholderLabel.numberOfLines = 0;
    _placeholderLabel.font = kFont(13);
    _placeholderLabel.textColor = kApp999Color;
    [_textView addSubview:_placeholderLabel];
    
    self.scrollView.alwaysBounceVertical = YES;
    CGFloat width = _scrollView.frame.size.width;
    HXPhotoView *photoView = [HXPhotoView photoManager:self.manager];
    photoView.frame = CGRectMake(kPhotoViewMargin, kPhotoViewMargin, width - kPhotoViewMargin * 2, 0);
    photoView.delegate = self;
    photoView.backgroundColor = [UIColor whiteColor];
    [_scrollView addSubview:photoView];
    self.photoView = photoView;
    
    self.contentCenterY.constant = (_uploadView.y+143-SCREEN_HEIGHT+SafeAreaTopHeight+SafeAreaBottomHeight)*0.5;
    [UIView animateWithDuration:.2 animations:^{
        [self.view layoutIfNeeded];
    }];
    
}
- (IBAction)btnUploadCommentClicked:(UIButton *)sender {
   
    if ([Tool isBlankString:_starOneStr]) {
        [WHIndicatorView toast:@"请给出签速度评分"];
        return;
    }
    if ([Tool isBlankString:_starTwoStr]) {
        [WHIndicatorView toast:@"请给材料需求评分"];
        return;
    }
    if ([Tool isBlankString:_starThreeStr]) {
        [WHIndicatorView toast:@"请给服务态度评分"];
        return;
    }
    sender.userInteractionEnabled = NO;
    if ([Tool arrayIsNotEmpty:_imageUrl]) {
        [self getQiniuTokenAction];
    }else{
        [self publishPostAction];
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
    for (int index = 0; index < _imageUrl.count ; index++){
        [urlList addObject:@""];
        __weak __typeof(self) weakSelf = self;
        dispatch_async(queue_serial, ^{
            //获取上传uploadtoken
            QNUploadManager *upManager = [[QNUploadManager alloc] init];
            NSString *fileStr = [NSString stringWithFormat:@"%@",self.imageUrl[index]];
            if (fileStr.length >5) {
                [upManager putFile:[fileStr substringFromIndex:5] key:nil token:token complete:^(QNResponseInfo *info, NSString *key, NSDictionary *resp) {
                    if (!info.error) {
                        NSString *nameStr = BGdictSetObjectIsNil(resp[@"name"]);
                        NSString *imageUrl = [NSString stringWithFormat:@"%@%@",self.headImgHostStr,nameStr];
                        [urlList replaceObjectAtIndex:index withObject:imageUrl];
                        getSuccessful ++;
                        if (getSuccessful == weakSelf.imageUrl.count) {
                            [weakSelf publishPostActionWithArr:urlList];
                        }else{
                            //                            [MBProgressHUD hideHUDForView:self.navigationController.view animated:YES];
                        }
                    }else{
                        //                        NSString *imageUrl = [NSString stringWithFormat:@"error%d",index];
                        //                        [urlList addObject:imageUrl];
                        getFail++;
                        //                        DLog(@"imageurl  getFail >>>> %@ >>> ",imageUrl);
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
    [param setObject:_starOneStr forKey:@"time_degree"];
    [param setObject:_starTwoStr forKey:@"play_experience"];
    [param setObject:_starThreeStr forKey:@"service_attitude"];
    [param setObject:_order_number forKey:@"order_number"];
    
    if (_textView.text.length <1) {
        [param setObject:@"" forKey:@"content"];
    }else{
        [param setObject:_textView.text forKey:@"content"];
    }
    
    if ([Tool arrayIsNotEmpty:arr]) {
        NSString *urlStr = arr[0];
        for (int i = 1; i<arr.count; i++) {
            urlStr = [NSString stringWithFormat:@"%@,%@",urlStr,arr[i]];
        }
        [param setObject:urlStr forKey:@"picture"];
    }
    
    [BGOrderTravelApi addProductReview:param succ:^(NSDictionary *response) {
        DLog(@"\n>>>[addProductReview sucess]:%@",response);
        [MBProgressHUD hideHUDForView:self.navigationController.view animated:YES];
        [WHIndicatorView toast:@"评价成功"];
        [self.navigationController popToRootViewControllerAnimated:YES];
    } failure:^(NSDictionary *response) {
        DLog(@"\n>>>[addProductReview failure]:%@",response);
        [MBProgressHUD hideHUDForView:self.navigationController.view animated:YES];
        self.publishBtn.userInteractionEnabled = YES;
    }];
    
}
-(void)publishPostAction{
    NSMutableDictionary *param = [[NSMutableDictionary alloc] init];
    [param setObject:_starOneStr forKey:@"time_degree"];
    [param setObject:_starTwoStr forKey:@"play_experience"];
    [param setObject:_starThreeStr forKey:@"service_attitude"];
    [param setObject:_order_number forKey:@"order_number"];
    
    if (_textView.text.length <1) {
        [param setObject:@"" forKey:@"content"];
    }else{
        [param setObject:_textView.text forKey:@"content"];
    }
    [ProgressHUDHelper showLoading];
    [BGOrderTravelApi addProductReview:param succ:^(NSDictionary *response) {
        DLog(@"\n>>>[addProductReview sucess]:%@",response);
        [WHIndicatorView toast:@"评价成功"];
        [self.navigationController popToRootViewControllerAnimated:YES];
    } failure:^(NSDictionary *response) {
        DLog(@"\n>>>[addProductReview failure]:%@",response);
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
    
    if (text.text.length > 500) {
        [WHIndicatorView toast:@"请输入小于500个文字"];
        NSString *s = [text.text substringToIndex:500];
        text.text = s;
    }
    return nil;
}

- (HXPhotoManager *)manager {
    if (!_manager) {
        _manager = [[HXPhotoManager alloc] initWithType:HXPhotoManagerSelectedTypePhoto];
        _manager.configuration.openCamera = NO;
        _manager.configuration.lookLivePhoto = YES;
        _manager.configuration.photoMaxNum = 9;
        _manager.configuration.maxNum = 9;
        _manager.configuration.showDateSectionHeader = NO;
        _manager.configuration.selectTogether = NO;
    }
    return _manager;
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
    
    NSSLog(@"所有:%@ - 照片:%@ - 视频:%@",allList,photos,videos);
    
    if (allList.count == 0) {
        [self.imageUrl removeAllObjects];
    }
    [ProgressHUDHelper showLoading];
    [HXPhotoTools selectListWriteToTempPath:allList requestList:^(NSArray *imageRequestIds, NSArray *videoSessions) {
        //            [ProgressHUDHelper removeLoading];
        NSSLog(@"requestIds - image : %@ \nsessions - video : %@",imageRequestIds,videoSessions);
    } completion:^(NSArray<NSURL *> *allUrl, NSArray<NSURL *> *imageUrls, NSArray<NSURL *> *videoUrls) {
        [ProgressHUDHelper removeLoading];
        NSSLog(@"allUrl - %@\nimageUrls - %@\nvideoUrls - %@",allUrl,imageUrls,videoUrls);
        [self.imageUrl removeAllObjects];
        self.imageUrl = [NSMutableArray arrayWithArray:imageUrls];
    } error:^{
        [ProgressHUDHelper removeLoading];
        NSSLog(@"失败");
    }];
    
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
/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
