//
//  BGMineEditViewController.m
//  shzTravelC
//
//  Created by 孙林茂 on 2018/5/9.
//  Copyright © 2018年 biao. All rights reserved.
//

#import "BGMineEditViewController.h"
#import "BGChangeNameViewController.h"
#import "BGMineCustomTwoCell.h"
#import "BGMineCustomThreeCell.h"
#import "UIImageView+WebCache.h"
#import <AVFoundation/AVFoundation.h>
#import <AssetsLibrary/AssetsLibrary.h>
#import "BGBirthdayPickView.h"
#import "BGSystemApi.h"
#import <QiniuSDK.h>
#import "BGMemberApi.h"
#import "BLAreaPickerView.h"

#define PickViewHeight 240
@interface BGMineEditViewController ()<UITableViewDelegate,UITableViewDataSource,UIImagePickerControllerDelegate,UINavigationControllerDelegate,BGBirthDateDelegate,BLPickerViewDelegate>
@property (nonatomic,strong)UITableView *tableView;
@property (nonatomic,strong) UIImage *changeImage;
@property (nonatomic, strong) UILabel *nameLabel;
@property (nonatomic, strong) UILabel *signLabel;
@property (nonatomic, strong) UILabel *genderLabel;
@property (nonatomic, strong) UILabel *timeLabel;
@property (nonatomic, strong) UILabel *areaLabel;
@property (nonatomic, strong) BGBirthdayPickView *birthdayView;
@property (nonatomic, strong) UIView *backView;
@property (nonatomic, copy) NSString *headImgHostStr;
@property (nonatomic, strong) BLAreaPickerView *pickView;
@property (nonatomic, strong) UITextField *textField;

@end

@implementation BGMineEditViewController
-(UITextField *)textField{
    if (!_textField) {
        self.textField = UITextField.new;
        [self.view addSubview:_textField];
    }
    return _textField;
}
-(UIView *)backView{
    if (!_backView) {
        self.backView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT)];
        _backView.backgroundColor = [UIColor clearColor];
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(canaleCallBack)];
        [_backView addGestureRecognizer:tap];
    }
    return _backView;
}
-(BGBirthdayPickView *)birthdayView{
    if (!_birthdayView) {
        NSArray *arr = [_timeLabel.text componentsSeparatedByString:@"-"];
        _birthdayView = [[BGBirthdayPickView alloc] initWithDelegate:self year:[arr[0] intValue] month:[arr[1] intValue] day:[arr[2] intValue]];
        _birthdayView.frame = CGRectMake(0, SCREEN_HEIGHT, SCREEN_WIDTH, PickViewHeight);
    }
    return _birthdayView;
}
-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    self.navigationController.navigationBarHidden = NO;
   
    
}
-(void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    [self canaleCallBack];
    
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self loadSubViews];
    [self loadData];
}
#pragma mark - 加载视图
- (void)loadSubViews {
    
    self.navigationItem.title = @"个人资料";
    self.automaticallyAdjustsScrollViewInsets = NO;
    
    self.tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, SafeAreaTopHeight, SCREEN_WIDTH, SCREEN_HEIGHT-SafeAreaTopHeight) style:(UITableViewStyleGrouped)];
    //    _tableView.scrollEnabled = NO;
    _tableView.backgroundColor = kAppBgColor;
    _tableView.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
    _tableView.separatorColor = kAppLineBGColor;
    _tableView.dataSource = self;
    _tableView.delegate = self;
    [self.view addSubview:_tableView];
    
    // 注册cell
    [_tableView registerNib:[UINib nibWithNibName:@"BGMineCustomThreeCell" bundle:nil] forCellReuseIdentifier:@"BGMineCustomThreeCell"];
    [_tableView registerNib:[UINib nibWithNibName:@"BGMineCustomTwoCell" bundle:nil] forCellReuseIdentifier:@"BGMineCustomTwoCell"];
    
}
#pragma mark - 加载数据  -
- (void)loadData {
    
    __block typeof(self) weakSelf = self;
    [BGSystemApi getUserInfo:nil succ:^(NSDictionary *response) {
        [self hideNodateView];
        DLog(@"\n>>>[getUserInfo sucess]:%@",response);
        [self.tableView reloadData];
        
    } failure:^(NSDictionary *response) {
        DLog(@"\n>>>[getUserInfo failure]:%@",response);
        [self shownoNetWorkViewWithType:1];
        [self setRefreshBlock:^{
            [weakSelf loadData];
        }];
    }];
}

#pragma mark  -  TableViewDelegate  -
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 2;
}
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return section == 0? 1:6;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 0) {
        BGMineCustomTwoCell *cell = [tableView dequeueReusableCellWithIdentifier:@"BGMineCustomTwoCell" forIndexPath:indexPath];
        cell.twoNameLabel.text = @"傻孩子账号";
        cell.userInteractionEnabled = NO;
        cell.twoDetailLabel.text = [self valueForKey:@"UserSHZ"] ? : @"暂无账号";
        cell.accessoryType = UITableViewCellAccessoryNone;
        return cell;
    }else{
        if (indexPath.row == 0) {
            BGMineCustomThreeCell *cell = [tableView dequeueReusableCellWithIdentifier:@"BGMineCustomThreeCell" forIndexPath:indexPath];
            
            // 头像
            NSString *fullPath = [[NSHomeDirectory() stringByAppendingPathComponent:@"Documents"] stringByAppendingPathComponent:@"currentImage.png"];
            UIImage *savedImage = [[UIImage alloc] initWithContentsOfFile:fullPath];
            if (savedImage == nil) {
                [cell.profileHeadImgView setImage:[UIImage imageNamed:@"headImg_placeholder"]];
            }else{
                [cell.profileHeadImgView setImage:savedImage];
            }
            return cell;
        }else{
            BGMineCustomTwoCell *cell = [tableView dequeueReusableCellWithIdentifier:@"BGMineCustomTwoCell" forIndexPath:indexPath];
            switch (indexPath.row) {
                case 1:{    // 昵称
                    cell.twoNameLabel.text = @"昵称";
                    
                    cell.twoDetailLabel.text = [self valueForKey:@"UserNickname"] ? : @"暂未设置昵称";
                    self.nameLabel = cell.twoDetailLabel;
                    
                }
                    break;

                case 2:{    // 性别
                    cell.twoNameLabel.text = @"性别";
                    NSString *status = [self valueForKey:@"UserSex"] ? : @"0";
                    if(status.intValue == 1){
                        cell.twoDetailLabel.text = @"男";
                    }else if(status.intValue == 2){
                        cell.twoDetailLabel.text = @"女";
                    }else{
                        cell.twoDetailLabel.text = @"未知";
                    }
                    self.genderLabel = cell.twoDetailLabel;
                    
                }
                    break;
                    
                case 3:{    // 生日
                    cell.twoNameLabel.text = @"生日";
                    NSString *birthdayStr = [self valueForKey:@"UserBDay"];
                    if (birthdayStr.length > 8) {
                        cell.twoDetailLabel.text = [Tool dateFormatter:[birthdayStr substringToIndex:9].doubleValue dateFormatter:@"yyyy-MM-dd"];
                        self.timeLabel = cell.twoDetailLabel;
                    }else{
                        cell.twoDetailLabel.text = @"暂未设置生日";
                        self.timeLabel = cell.twoDetailLabel;
                        self.timeLabel.text = @"1990-01-01";
                    }
                    
                }
                    break;
                case 4:{    // 地区
                    cell.twoNameLabel.text = @"地区";
                    // [self valueForKey:@"UserPlace"]
                    cell.twoDetailLabel.text = [self valueForKey:@"UserArea"] ?: @"暂未设置地区";
                    self.areaLabel = cell.twoNameLabel;
                }
                    break;
                case 5:{    // 个性签名
                    cell.twoNameLabel.text = @"个性签名";
                    cell.twoDetailLabel.text = [self valueForKey:@"UserSignature"] ?: @"暂未设置个性签名";
                    self.signLabel = cell.twoDetailLabel;
                    
                }
                    break;
                default:
                    break;
            }
            
            
            return cell;
        }
    }
    
    
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
    if (indexPath.section == 1) {
        switch (indexPath.row) {
            case 0: {  // 上传头像
                
                [self onClickUploadPickerVC];
            }
                break;
            case 1: {  // 修改昵称
                BGChangeNameViewController *nameVC =[[BGChangeNameViewController alloc]init];
                nameVC.textFieldName = _nameLabel.text;
                nameVC.viewType = @"1";
                __block typeof(self) weakSelf = self;
                nameVC.refreshEditBlock = ^{
                    [weakSelf loadData];
                };
                [self.navigationController pushViewController:nameVC animated:YES];
            }
                break;
            case 2: {  // 修改性别
                BGChangeNameViewController *nameVC =[[BGChangeNameViewController alloc]init];
                nameVC.textFieldName = _genderLabel.text;
                nameVC.viewType = @"3";
                __block typeof(self) weakSelf = self;
                nameVC.refreshEditBlock = ^{
                    [weakSelf loadData];
                };
                [self.navigationController pushViewController:nameVC animated:YES];
            }
                break;
            case 3: {  // 修改生日

                [self showBirthdayPickAction];
                
            }
                break;
            case 4: {  // 修改地区
                DLog(@"修改地区");
                [ProgressHUDHelper showLoading];
                NSMutableDictionary *param = [[NSMutableDictionary alloc] init];
                [param setObject:@"0" forKey:@"parentId"];
                
                [BGMemberApi getAllAddressList:param succ:^(NSDictionary *response) {
//                     DLog(@"\n>>>[getAllAddressList sucess]:%@",response);
                    NSArray *dataArr = [NSArray arrayWithArray:response[@"result"]];
                    self.pickView = [[BLAreaPickerView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, PickViewHeight)];
                    self.pickView.pickViewDelegate = self;
                    [self.pickView bl_showWithData:dataArr];
                } failure:^(NSDictionary *response) {
                     DLog(@"\n>>>[getAllAddressList failure]:%@",response);
                }];
                
            }
                break;
            case 5: {  // 修改个性签名
                BGChangeNameViewController *nameVC =[[BGChangeNameViewController alloc]init];
                if ([_signLabel.text isEqualToString:@"暂未设置个性签名"]) {
                    nameVC.textFieldName = @"";
                }else{
                    nameVC.textFieldName = _signLabel.text;
                }
                nameVC.viewType = @"2";
                __block typeof(self) weakSelf = self;
                nameVC.refreshEditBlock = ^{
                    [weakSelf loadData];
                };
                [self.navigationController pushViewController:nameVC animated:YES];
                
            }
                break;
          
            default:
                break;
        }
    }
}
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return indexPath.section == 0? 40:(indexPath.row==0 ? 70:49);
}
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 10;
}
-(CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section{
    return 0.01;
}
- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    return nil;
}
- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section{
    return nil;
}

/**
 显示生日选择器
 */
-(void)showBirthdayPickAction{
    
    [[[UIApplication sharedApplication] keyWindow] addSubview:self.backView];
    [[[UIApplication sharedApplication] keyWindow] addSubview:self.birthdayView];
    __block typeof(self) weakSelf = self;
    [UIView transitionWithView:self.backView duration:0.3 options:0 animations:^{
        weakSelf.backView.backgroundColor = [UIColor colorWithWhite:0 alpha:0.4];
        weakSelf.birthdayView.y = (SCREEN_HEIGHT-PickViewHeight);
    } completion:nil];
}
#pragma mark 修改生日
- (void)confrmCallBack:(NSInteger)Year month:(NSInteger)month day:(NSInteger)day
{
    _timeLabel.text = [NSString stringWithFormat:@"%d-%02d-%02d",(int)Year,(int)month,(int)day];
    [self saveBirthdayAction];
    [self canaleCallBack];
}


// 修改生日
-(void)saveBirthdayAction {

    NSMutableDictionary *param = [[NSMutableDictionary alloc] init];
    NSString *timeStampStr = [Tool timeString:_timeLabel.text withFormatte:@"YYYY-MM-dd"];
    if (timeStampStr.length > 8) {
        [param setObject:timeStampStr forKey:@"birthday"];
    }
    DLog(@"\n>>>[modifyBirthday timeStampStr]:%@",timeStampStr);

    __block typeof(self) weakSelf = self;
    [BGSystemApi modifyUserInfo:param succ:^(NSDictionary *response) {
        DLog(@"\n>>>[modifyBirthday success]:%@",response);
        [weakSelf loadData];
        [WHIndicatorView toast:@"修改生日成功"];
    } failure:^(NSDictionary *response) {
        DLog(@"\n>>>[modifyBirthday failure]:%@",response);
    }];
    
}
- (void)canaleCallBack{
    
    __block typeof(self) weakSelf = self;
    [UIView transitionWithView:self.backView duration:0.3 options:0 animations:^{
        weakSelf.backView.backgroundColor = [UIColor clearColor];
        weakSelf.birthdayView.y = SCREEN_HEIGHT;
    } completion:^(BOOL finished) {
        [weakSelf.birthdayView removeFromSuperview];
        weakSelf.birthdayView = nil;
        [weakSelf.backView removeFromSuperview];
        weakSelf.backView = nil;
    }];
}

#pragma mark - pickHeaderImage
/**
 点击头像cell的响应事件
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

/**
 选择相册 or 拍照
 @param type UIImagePickerControllerSourceType
 */
-(void)alertTakePhotoAction:(int)type {
    
    UIImagePickerController *pickerController = [[UIImagePickerController alloc] init];
    pickerController.sourceType = type == 0 ? UIImagePickerControllerSourceTypeCamera : UIImagePickerControllerSourceTypePhotoLibrary;
    pickerController.delegate = self;
    pickerController.allowsEditing = YES;
    pickerController.navigationBar.translucent = NO;//去除毛玻璃效果
    self.modalPresentationStyle = UIModalPresentationOverCurrentContext;
    self.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
    [self presentViewController:pickerController animated:YES completion:nil];
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
 选中图片的代理方法
 
 @param picker 图片选择器
 @param info 信息
 */
-(void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info{
    
    UIImage *image = [info objectForKey:UIImagePickerControllerEditedImage];    // 取裁剪后的图片
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
    NSData *data = [self compressImage:self.changeImage toMaxFileSize:1000*1024];
    __block typeof(self) weakSelf = self;
    
    [upManager putData:data key:nil token:token complete:^(QNResponseInfo *info, NSString *key, NSDictionary *resp) {
        [ProgressHUDHelper removeLoading];
        DLog(@"\n>>>[uploadImage sucess] resp:%@",resp);
        int size = [NSString stringWithFormat:@"%@",resp[@"size"]].intValue;
        if (size>200) {
            NSString *nameStr = BGdictSetObjectIsNil(resp[@"name"]);
            NSString *imgUrlStr = [NSString stringWithFormat:@"%@%@",self.headImgHostStr,nameStr];
            [weakSelf modifyUserImgURLWithName:imgUrlStr];
        }else{
            [WHIndicatorView toast:@"修改头像失败"];
        }
        
        
    } option:nil];
}
-(void)modifyUserImgURLWithName:(NSString *)name {
    // 修改头像地址
    NSMutableDictionary *param = [[NSMutableDictionary alloc] init];
    [param setObject:name forKey:@"face"];
    __block typeof(self) weakSelf = self;
    [BGSystemApi modifyUserInfo:param succ:^(NSDictionary *response) {
        DLog(@"\n>>>[modifyHeadImg success]:%@",response);
        [WHIndicatorView toast:@"上传头像成功"];
        [weakSelf saveImage:weakSelf.changeImage withName:@"currentImage.png"];
        [[NSNotificationCenter defaultCenter] postNotificationName:@"ChangeNickNameAndId" object:nil];
        [weakSelf.tableView reloadData];
        
    } failure:^(NSDictionary *response) {
        DLog(@"\n>>>[modifyHeadImg failure]:%@",response);
    }];
}
/**
 保存图片至沙盒,方便下次直接获取
 
 @param currentImage 需要保存的图片
 @param imageName 被保存图片的名称
 */
- (void)saveImage:(UIImage *)currentImage withName:(NSString *)imageName {
    
    NSData *imgData = [self compressImage:currentImage toMaxFileSize:1000*1024];
    // 获取沙盒目录
    
    NSString *fullPath = [[NSHomeDirectory() stringByAppendingPathComponent:@"Documents"] stringByAppendingPathComponent:imageName];
    // 将图片写入文件
    
    [imgData writeToFile:fullPath atomically:NO];
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

-(NSString *)valueForKey:(NSString *)key{
    NSString *valueStr = [NSString stringWithFormat:@"%@", BGGetUserDefaultObjectForKey(key)];
    if ([Tool isBlankString:valueStr]) {
        return nil;
    }else{
        return valueStr;
    }
}

#pragma mark - - BLPickerViewDelegate
- (void)bl_selectedAreaResultWithProvince:(NSString *)provinceTitle city:(NSString *)cityTitle area:(NSString *)areaTitle province_id:(NSString *)province_id city_id:(NSString *)city_id region_id:(NSString *)region_id{
    
    // 修改地区
    NSMutableDictionary *param = [[NSMutableDictionary alloc] init];
    [param setObject:provinceTitle forKey:@"province"];
    [param setObject:cityTitle forKey:@"city"];
    [param setObject:areaTitle forKey:@"region"];
    [param setObject:province_id forKey:@"province_id"];
    [param setObject:city_id forKey:@"city_id"];
    [param setObject:region_id forKey:@"region_id"];
    
    __block typeof(self) weakSelf = self;
    [BGSystemApi modifyUserInfo:param succ:^(NSDictionary *response) {
        DLog(@"\n>>>[modifyArea success]:%@",response);
        [weakSelf loadData];
        [WHIndicatorView toast:@"修改地区成功"];
    } failure:^(NSDictionary *response) {
        DLog(@"\n>>>[modifyArea failure]:%@",response);
    }];
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
