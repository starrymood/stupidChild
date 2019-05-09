//
//  BGFeedbackViewController.m
//  shzTravelC
//
//  Created by 孙林茂 on 2018/5/11.
//  Copyright © 2018年 biao. All rights reserved.
//

#import "BGFeedbackViewController.h"
#import <AVFoundation/AVFoundation.h>
#import <AssetsLibrary/AssetsLibrary.h>
#import "BGMemberApi.h"
#import <QiniuSDK.h>
#import <MBProgressHUD.h>
#import "HXPhotoPicker.h"
#import "BGSystemApi.h"

static const CGFloat kPhotoViewMargin = 15.0;
@interface BGFeedbackViewController ()<UITextViewDelegate,UIImagePickerControllerDelegate,HXPhotoViewDelegate>
@property (weak, nonatomic) IBOutlet UITextView *textView;
@property (weak, nonatomic) IBOutlet UILabel *yuNumLabel;
@property (nonatomic, strong) UILabel *placeholderLabel;
@property (weak, nonatomic) IBOutlet UIView *btnView;
@property (nonatomic, copy) NSString *feedbackTypeStr;
@property (nonatomic, copy) NSString *headImgHostStr;
@property (weak, nonatomic) IBOutlet UIView *photoBgView;
@property (nonatomic, strong) NSMutableArray *imageUrl;
@property (strong, nonatomic) HXPhotoManager *manager;
@property (strong, nonatomic) HXPhotoView *photoView;
@property (weak, nonatomic) IBOutlet UIButton *publishBtn;

@end

@implementation BGFeedbackViewController
- (HXPhotoManager *)manager {
    if (!_manager) {
        _manager = [[HXPhotoManager alloc] initWithType:HXPhotoManagerSelectedTypePhoto];
        _manager.configuration.openCamera = NO;
        _manager.configuration.lookLivePhoto = NO;
        _manager.configuration.photoMaxNum = 4;
        _manager.configuration.videoMaxNum = 0;
        _manager.configuration.maxNum = 4;
        _manager.configuration.showDateSectionHeader = YES;
        _manager.configuration.selectTogether = NO;
    }
    return _manager;
}
-(NSMutableArray *)imageUrl{
    if (!_imageUrl) {
        self.imageUrl = [NSMutableArray array];
    }
    return _imageUrl;
}
- (void)viewDidLoad {
    [super viewDidLoad];

    self.navigationItem.title = @"意见反馈";
    self.view.backgroundColor = kAppBgColor;
    NSInteger sum = [self needLinesWithWidth:(SCREEN_WIDTH-20-6)];
    if (sum == 1) {
         self.placeholderLabel = [[UILabel alloc] initWithFrame:CGRectMake(3, 3, SCREEN_WIDTH-20-6, 25)];
    }else{
         self.placeholderLabel = [[UILabel alloc] initWithFrame:CGRectMake(3, 3, SCREEN_WIDTH-20-6, 44)];
    }
    _placeholderLabel.enabled = NO;
    _placeholderLabel.text = @"傻孩子APP的每一次进步，都离不开您的意见和建议.";
    _placeholderLabel.numberOfLines = 0;
    _placeholderLabel.font = kFont(14);
    _placeholderLabel.textColor = kApp999Color;
    [_textView addSubview:_placeholderLabel];
    
    self.feedbackTypeStr = @"功能异常";
    
    HXPhotoView *photoView = [HXPhotoView photoManager:self.manager];
    photoView.frame = CGRectMake(kPhotoViewMargin, kPhotoViewMargin, SCREEN_WIDTH - kPhotoViewMargin * 2, 0);
    photoView.delegate = self;
    photoView.backgroundColor = [UIColor whiteColor];
    photoView.lineCount = 4;
    [_photoBgView addSubview:photoView];
    self.photoView = photoView;
    
}

#pragma mark - UITextView -
-(void)textViewDidChange:(UITextView *)textView
{
    if ([textView.text length] == 0) {
        [_placeholderLabel setHidden:NO];
    }else{
        [_placeholderLabel setHidden:YES];
    }
    NSInteger wordCount = textView.text.length;
    self.yuNumLabel.text = [NSString stringWithFormat:@"%zd/500",wordCount];
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

- (IBAction)btnQuestionClicked:(UIButton *)sender {
    self.feedbackTypeStr = sender.titleLabel.text;
    for (int i = 0; i<4; i++) {
        UIButton *btn = (UIButton *)[self.btnView viewWithTag:200+i];
        [btn setImage:BGImage(@"feedback_default") forState:(UIControlStateNormal)];
    }
   
        [sender setImage:BGImage(@"feedback_selected") forState:(UIControlStateNormal)];
}

- (IBAction)btnSureClicked:(UIButton *)sender {
  
    if (_textView.text.length <1) {
        [WHIndicatorView toast:@"请输入需要反馈的内容"];
        return;
    }
    if ([Tool arrayIsNotEmpty:self.imageUrl]) {
        [self getQiniuTokenAction];
    }else{
        sender.enabled = NO;
        [ProgressHUDHelper showLoading];
        NSMutableDictionary *param = [[NSMutableDictionary alloc] init];
        [param setObject:_feedbackTypeStr forKey:@"type"];
        [param setObject:_textView.text forKey:@"content"];
        
        __block typeof(self)weakSelf = self;
        [BGSystemApi submitFeedback:param succ:^(NSDictionary *response) {
            sender.enabled = YES;
            DLog(@"\n>>>[submitFeedback success]:%@",response);
            [WHIndicatorView toast:@"提交成功"];
            [weakSelf.navigationController popViewControllerAnimated:YES];
        } failure:^(NSDictionary *response) {
            sender.enabled = YES;
            DLog(@"\n>>>[submitFeedback failure]:%@",response);
        }];
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
    [param setObject:_feedbackTypeStr forKey:@"type"];
    [param setObject:_textView.text forKey:@"content"];
    
    NSString *urlStr = arr[0];
    for (int i = 1; i<arr.count; i++) {
        urlStr = [NSString stringWithFormat:@"%@,%@",urlStr,arr[i]];
    }
    [param setObject:urlStr forKey:@"image"];
 
        [BGSystemApi submitFeedback:param succ:^(NSDictionary *response) {
            DLog(@"\n>>>[submitFeedback sucess]:%@",response);
            [MBProgressHUD hideHUDForView:self.navigationController.view animated:YES];
            [WHIndicatorView toast:@"提交成功"];
            [self.navigationController popViewControllerAnimated:YES];
        } failure:^(NSDictionary *response) {
            DLog(@"\n>>>[submitFeedback failure]:%@",response);
            [MBProgressHUD hideHUDForView:self.navigationController.view animated:YES];
            self.publishBtn.userInteractionEnabled = YES;
        }];
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

- (void)photoView:(HXPhotoView *)photoView currentDeleteModel:(HXPhotoModel *)model currentIndex:(NSInteger)index {
    NSSLog(@"%@ --> index - %ld",model,index);
}
/**
 显示当前文字需要几行
 
 @param width 给定一个宽度
 @return 返回行数
 */
- (NSInteger)needLinesWithWidth:(CGFloat)width{
    //创建一个labe
    UILabel * label = [[UILabel alloc]init];
    //font和当前label保持一致
    label.font = kFont(14);
    NSString * text = @"傻孩子APP的每一次进步，都离不开您的意见和建议.";
    NSInteger sum = 0;
    //总行数受换行符影响，所以这里计算总行数，需要用换行符分隔这段文字，然后计算每段文字的行数，相加即是总行数。
    NSArray * splitText = [text componentsSeparatedByString:@"\n"];
    for (NSString * sText in splitText) {
        label.text = sText;
        //获取这段文字一行需要的size
        CGSize textSize = [label systemLayoutSizeFittingSize:CGSizeZero];
        //size.width/所需要的width 向上取整就是这段文字占的行数
        NSInteger lines = ceilf(textSize.width/width);
        //当是0的时候，说明这是换行，需要按一行算。
        lines = lines == 0?1:lines;
        sum += lines;
    }
    return sum;
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
