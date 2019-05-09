//
//  BGPostCommentListViewController.m
//  shzTravelC
//
//  Created by biao on 2018/6/29.
//  Copyright © 2018年 biao. All rights reserved.
//

#import "BGPostCommentListViewController.h"
#import "BGShopApi.h"
#import "BGPostCommentCell.h"
#import "BGPostCommentView.h"
#import <AVFoundation/AVFoundation.h>
#import <AssetsLibrary/AssetsLibrary.h>
#import "BGMemberApi.h"
#import <QiniuSDK.h>
#import "BGShopModel.h"
#import "StringHelper.h"

#define BGString(appendix) [NSString stringWithFormat:@"%zd",appendix]
@interface BGPostCommentListViewController ()<UITableViewDelegate,UITableViewDataSource,UIImagePickerControllerDelegate,UINavigationControllerDelegate>

@property (nonatomic,strong)UITableView *tableView;

@property (nonatomic, strong) NSMutableDictionary *picDic;
@property (nonatomic, strong) NSMutableDictionary *contentDic;
@property (nonatomic, strong) NSMutableArray *picArr;
@property (nonatomic, strong) UIImage *changeImage;
@property (nonatomic, copy) NSString *headImgHostStr;
@property (nonatomic, strong) NSString *selectedSection;
@property (nonatomic, copy) NSString *score1;
@property (nonatomic, copy) NSString *score2;
@property (nonatomic, copy) NSString *score3;
@property (nonatomic, strong) UITextField *textField;

@end

@implementation BGPostCommentListViewController
-(NSMutableArray *)picArr{
    if (!_picArr) {
        self.picArr = [NSMutableArray array];
    }
    return _picArr;
}
-(UITextField *)textField{
    if (!_textField) {
        self.textField = UITextField.new;
        [self.view addSubview:_textField];
    }
    return _textField;
}
- (void)viewDidLoad {
    [super viewDidLoad];

    [self loadSubViews];
}

#pragma mark - 加载视图
- (void)loadSubViews {
    self.navigationItem.title = @"发表评价";
    self.view.backgroundColor = kAppBgColor;
    BGRemoveUserDefaultObjectForKey(@"PostPicDic");
    BGRemoveUserDefaultObjectForKey(@"PostContentDic");
    self.score1 = @"0";
    self.score2 = @"0";
    self.score3 = @"0";
    self.tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, SafeAreaTopHeight+1, SCREEN_WIDTH, SCREEN_HEIGHT-SafeAreaBottomHeight-SafeAreaTopHeight-1) style:(UITableViewStyleGrouped)];
    _tableView.backgroundColor = kAppBgColor;
    _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    _tableView.separatorColor = kAppLineBGColor;
    _tableView.estimatedRowHeight = 290;
    _tableView.rowHeight = UITableViewAutomaticDimension;
    _tableView.dataSource = self;
    _tableView.delegate = self;
    [self.view addSubview:_tableView];
    
    [_tableView registerNib:[UINib nibWithNibName:@"BGPostCommentCell" bundle:nil] forCellReuseIdentifier:@"BGPostCommentCell"];
    
    UIView *headerView = UIView.new;
    headerView.backgroundColor = kAppWhiteColor;
    headerView.frame = CGRectMake(0, 0, SCREEN_WIDTH, 44);
    _tableView.tableHeaderView = headerView;
    
    UILabel *shopInfoLabel = UILabel.new;
    shopInfoLabel.frame = CGRectMake(15, 14, 160, 15);
    shopInfoLabel.text = @"商品信息";
    shopInfoLabel.font = kFont(14);
    [shopInfoLabel setTextColor:kApp333Color];
    [headerView addSubview:shopInfoLabel];
    
    BGPostCommentView *footerView = [[BGPostCommentView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, 259)];
    _tableView.tableFooterView = footerView;
    __weak __typeof(self) weakSelf = self;
    footerView.starOneClicked = ^(NSString *star) {
        weakSelf.score1 = star;
    };
    footerView.starTwoClicked = ^(NSString *star) {
        weakSelf.score2 = star;
    };
    footerView.starThreeClicked = ^(NSString *star) {
        weakSelf.score3 = star;
    };
    footerView.publishBtnClicked = ^(UIButton *sender) {
        [weakSelf publishActionWithBtn:sender];
    };
    
}
-(void)publishActionWithBtn:(UIButton *)sender{
    [self keyboarkHidden];
    if (self.score1.intValue == 0) {
        [WHIndicatorView toast:@"请给描述相符评分"];
        return;
    }
    if (self.score2.intValue == 0) {
        [WHIndicatorView toast:@"请给物流服务评分"];
        return;
    }
    if (self.score3.intValue == 0) {
        [WHIndicatorView toast:@"请给服务态度评分"];
        return;
    }
    
    sender.enabled = NO;
    [ProgressHUDHelper showLoading];
    NSMutableDictionary *param = [[NSMutableDictionary alloc] init];
    [param setObject:self.score1 forKey:@"store_desc_credit"];
    [param setObject:self.score2 forKey:@"store_service_credit"];
    [param setObject:self.score3 forKey:@"store_deliver_credit"];
    [param setObject:_order_number forKey:@"order_number"];
    NSMutableArray *extArr = [NSMutableArray array];
    for (NSInteger i = 0; i<_orderItems.count; i++) {
         BGShopModel *model = [BGShopModel mj_objectWithKeyValues:_orderItems[i]];
        NSMutableDictionary *dic = [[NSMutableDictionary alloc] init];
        [dic setObject:model.goods_id forKey:@"goods_id"];
        [dic setObject:model.item_id forKey:@"item_id"];
         NSMutableDictionary *contentDic = [NSMutableDictionary dictionaryWithDictionary:BGGetUserDefaultObjectForKey(@"PostContentDic")];
        NSString *contentStr = contentDic[BGString(i)];
        if (![Tool isBlankString:contentStr]) {
            [dic setObject:contentStr forKey:@"content"];
        }
        NSMutableDictionary *picDic = [NSMutableDictionary dictionaryWithDictionary:BGGetUserDefaultObjectForKey(@"PostPicDic")];
        NSMutableArray *picArr = [[NSMutableArray alloc] initWithArray:picDic[BGString(i)]];
        [dic setObject:picArr forKey:@"imageList"];
//        NSMutableArray *arr = [[NSMutableArray alloc] initWithArray:picDic[BGString(i)]];
//        if ([Tool arrayIsNotEmpty:arr]) {
//            NSString *urlStr = arr[0];
//            for (int i = 1; i<arr.count; i++) {
//                urlStr = [NSString stringWithFormat:@"%@,%@",urlStr,arr[i]];
//            }
//            [dic setObject:urlStr forKey:@"imageList"];
//        }else{
//            [dic setObject:@"" forKey:@"imageList"];
//        }
        [extArr addObject:dic];
    }
    [param setObject:extArr forKey:@"memberCommentExts"];
    __weak __typeof(self) weakSelf = self;
    [BGShopApi postComment:param succ:^(NSDictionary *response) {
         DLog(@"\n>>>[postComment sucess]:%@",response);
        [WHIndicatorView toast:@"感谢您的评价"];
        if (weakSelf.postBtnClicked) {
            weakSelf.postBtnClicked();
        }
        [weakSelf.navigationController popViewControllerAnimated:YES];
    } failure:^(NSDictionary *response) {
         DLog(@"\n>>>[postComment failure]:%@",response);
        sender.enabled = YES;
    }];
}
#pragma mark  -  TableViewDelegate  -
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return _orderItems.count;
}
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 1;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    BGPostCommentCell *cell = [tableView dequeueReusableCellWithIdentifier:@"BGPostCommentCell" forIndexPath:indexPath];
    [self.picDic removeAllObjects];
    [self.contentDic removeAllObjects];
    self.picDic = [NSMutableDictionary dictionaryWithDictionary:BGGetUserDefaultObjectForKey(@"PostPicDic")];
    self.contentDic = [NSMutableDictionary dictionaryWithDictionary:BGGetUserDefaultObjectForKey(@"PostContentDic")];
    [cell updataWithCellArray:self.orderItems[indexPath.section] picArr:self.picDic[BGString(indexPath.section)] contentStr:self.contentDic[BGString(indexPath.section)]];
    __weak __typeof(self) weakSelf = self;
    cell.uploadImgClicked = ^{
        [self.picArr removeAllObjects];
        weakSelf.selectedSection = BGString(indexPath.section);
        if ([Tool dictContainsObject:weakSelf.picDic forKey:BGString(indexPath.section)]) {
            weakSelf.picArr = [[NSMutableArray alloc] initWithArray:weakSelf.picDic[BGString(indexPath.section)]];
        }
         [weakSelf onClickUploadPickerVC];
    };
    cell.delImgClicked = ^(NSInteger tag) {
        weakSelf.selectedSection = BGString(indexPath.section);
        if ([Tool dictContainsObject:weakSelf.picDic forKey:BGString(indexPath.section)]) {
            weakSelf.picArr = [[NSMutableArray alloc] initWithArray:weakSelf.picDic[BGString(indexPath.section)]];
            [weakSelf.picArr removeObjectAtIndex:tag];
            [weakSelf.picDic setObject:weakSelf.picArr forKey:weakSelf.selectedSection];
            BGSetUserDefaultObjectForKey(weakSelf.picDic, @"PostPicDic");
            NSIndexSet *indexSet=[[NSIndexSet alloc]initWithIndex:weakSelf.selectedSection.integerValue];
            [weakSelf.tableView reloadSections:indexSet withRowAnimation:UITableViewRowAnimationAutomatic];
        }
    };
    cell.textViewDone = ^(NSString *text) {
        [weakSelf.contentDic setObject:text forKey:BGString(indexPath.section)];
        BGSetUserDefaultObjectForKey(weakSelf.contentDic, @"PostContentDic");
    };
    
    return cell;
}
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
};

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return section == 0 ? 1:15;
}
-(CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section{
    return section == _orderItems.count-1? 10:0.01;
}
- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    return nil;
}
- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section{
    return nil;
}
#pragma mark - pickHeaderImage
/**
 点击上传图片的响应事件
 */
- (void)onClickUploadPickerVC {
    UIAlertController *menu = [UIAlertController alertControllerWithTitle:nil message:nil preferredStyle:(UIAlertControllerStyleActionSheet)];
    __block typeof(self) weakSelf = self;
    
    UIAlertAction *cameraAction = [UIAlertAction actionWithTitle:@"拍照" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [weakSelf alertTakePhotoAction:0];
    }];
    UIAlertAction *photoAction = [UIAlertAction actionWithTitle:@"从手机相册选择" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [weakSelf alertTakePhotoAction:1];
    }];
    UIAlertAction *actionNo = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
        
    }];
    
    [menu addAction:actionNo];
    [menu addAction:cameraAction];
    [menu addAction:photoAction];
    [self presentViewController:menu animated:YES completion:nil];
    
}
//点击取消按钮所执行的方法

-(void)imagePickerControllerDidCancel:(UIImagePickerController *)picker{
    
    
    //这是捕获点击右上角cancel按钮所触发的事件，如果我们需要在点击cancel按钮的时候做一些其他逻辑操作。就需要实现该代理方法，如果不做任何逻辑操作，就可以不实现
    
    [picker dismissViewControllerAnimated:YES completion:nil];
    
    [self.textField becomeFirstResponder];
    __block typeof(self)weakSelf = self;
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.01 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [weakSelf.textField resignFirstResponder];
    });
    
}
/**
 选择相册 or 拍照
 @param type UIImagePickerControllerSourceType
 */
-(void)alertTakePhotoAction:(int)type {
    
    UIImagePickerController *pickerController = [[UIImagePickerController alloc] init];
    pickerController.sourceType = type == 0 ? UIImagePickerControllerSourceTypeCamera : UIImagePickerControllerSourceTypePhotoLibrary;
    pickerController.delegate = self;
    pickerController.allowsEditing = NO;
    pickerController.navigationBar.translucent = NO;//去除毛玻璃效果
    self.modalPresentationStyle = UIModalPresentationOverCurrentContext;
    self.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
    [self presentViewController:pickerController animated:YES completion:nil];
}

/**
 选中图片的代理方法
 
 @param picker 图片选择器
 @param info 信息
 */
-(void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info{
    
    UIImage *image = [info objectForKey:UIImagePickerControllerOriginalImage];
    self.changeImage = image;
    // 应该在提交成功后再保存到沙盒，下次进来直接去沙盒路径取
    
    [picker dismissViewControllerAnimated:YES completion:nil];
    [self.textField becomeFirstResponder];
    __block typeof(self)weakSelf = self;
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.01 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [weakSelf.textField resignFirstResponder];
    });
    [self getQiniuTokenAction];
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
            [WHIndicatorView toast:@"网络问题,请重试"];
        }
    } failure:^(NSDictionary *response) {
        DLog(@"\n>>>[getQiniuKey failure]:%@",response);
    }];
}
/**
 上传头像网络请求
 
 @return void
 */
#pragma mark - 上传头像

-(void)uploadImageWithToken:(NSString *)token{
    [ProgressHUDHelper showLoading];
    QNUploadManager *upManager = [[QNUploadManager alloc] init];
    NSData *data = [self compressImage:self.changeImage toMaxFileSize:1500*1024];
    __block typeof(self) weakSelf = self;
    
    [upManager putData:data key:nil token:token complete:^(QNResponseInfo *info, NSString *key, NSDictionary *resp) {
        [ProgressHUDHelper removeLoading];
        DLog(@"\n>>>[uploadImage sucess] resp:%@",resp);
        int size = [NSString stringWithFormat:@"%@",resp[@"size"]].intValue;
        if (size>200) {
            NSString *nameStr = BGdictSetObjectIsNil(resp[@"name"]);
            NSString *imgStr = [NSString stringWithFormat:@"%@%@",weakSelf.headImgHostStr,nameStr];
            [weakSelf.picArr addObject:imgStr];
            [weakSelf.picDic setObject:weakSelf.picArr forKey:weakSelf.selectedSection];
            BGSetUserDefaultObjectForKey(weakSelf.picDic, @"PostPicDic");
            NSIndexSet *indexSet=[[NSIndexSet alloc]initWithIndex:weakSelf.selectedSection.integerValue];
            [weakSelf.tableView reloadSections:indexSet withRowAnimation:UITableViewRowAnimationAutomatic];
        }else{
            [WHIndicatorView toast:@"上传图片失败"];
        }
        
        
    } option:nil];
}

/**
 压缩图片
 
 @param image 需要被压缩的图片
 @param maxFileSize 文件的最大值
 @return 图片Data
 */
- (NSData *)compressImage:(UIImage *)image toMaxFileSize:(NSInteger)maxFileSize {
    CGFloat compression = 0.9f;
    CGFloat maxCompression = 0.1f;
    NSData *imageData = UIImageJPEGRepresentation(image, compression);
    while ([imageData length] > maxFileSize && compression > maxCompression) {
        compression -= 0.1;
        imageData = UIImageJPEGRepresentation(image, compression);
    }
    return imageData;
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
