//
//  BGChangeNameViewController.m
//  shzTravelC
//
//  Created by 孙林茂 on 2018/5/9.
//  Copyright © 2018年 biao. All rights reserved.
//

#import "BGChangeNameViewController.h"
#import "BGSystemApi.h"

@interface BGChangeNameViewController ()<UITextFieldDelegate>
@property(nonatomic,strong) UITextField *textField;
@property (nonatomic, strong) UILabel *numLabel;
@property (nonatomic, strong) UIButton *rightButton;
@property (nonatomic, strong) UIImageView *checkManImgView;
@property (nonatomic, strong) UIImageView *checkWomanImgView;
@property (nonatomic, strong) NSString *genderStr;

@end

@implementation BGChangeNameViewController
-(UITextField *)textField{
    if (!_textField) {
        self.textField = [[UITextField alloc]initWithFrame:CGRectMake(20, 2, SCREEN_WIDTH-40, 46)];
    }
    return _textField;
}
- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor = kAppBgColor;
    if ([self.viewType isEqualToString:@"1"])
    {
        self.title = @"设置昵称";
        [self showTextField];
    }else if ([self.viewType isEqualToString:@"2"])
    {
        self.title = @"设置个性签名";
        [self showTextField];
    }else if ([self.viewType isEqualToString:@"3"])
    {
        self.title = @"设置性别";
        [self showSetGender];
    }
    
    _rightButton = [UIButton buttonWithType:UIButtonTypeCustom];
    _rightButton.frame = CGRectMake(SCREEN_WIDTH-40, 5, 40, 30);
    _rightButton.titleLabel.font = [UIFont systemFontOfSize:15];
    [_rightButton setTitle:@"完成" forState:UIControlStateNormal];
    [_rightButton setTitleColor:kAppMainColor forState:UIControlStateNormal];
    [_rightButton addTarget:self action:@selector(saveEditButton) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:_rightButton];
    self.navigationItem.rightBarButtonItem = rightBarButtonItem;
    
}
-(void)showTextField {
    UIView *whiteView = [[UIView alloc]initWithFrame:CGRectMake(0, SafeAreaTopHeight+15, SCREEN_WIDTH, 50)];
    whiteView.backgroundColor = kAppWhiteColor;
    [self.view addSubview:whiteView];
    self.textField.clearButtonMode = UITextFieldViewModeAlways;
    _textField.delegate = self;
    _textField.textColor = kAppBlackColor;
    _textField.font = [UIFont systemFontOfSize:15];
    _textField.layer.cornerRadius = 3;
    [_textField addTarget:self action:@selector(textFieldDidChange:) forControlEvents:UIControlEventEditingChanged];
    _textField.backgroundColor = [UIColor whiteColor];
    [_textField becomeFirstResponder];
    [whiteView addSubview:_textField];
    
    _numLabel = [[UILabel alloc]initWithFrame:CGRectMake(SCREEN_WIDTH-80, SafeAreaTopHeight+75, 60, 20)];
    _numLabel.textAlignment = NSTextAlignmentRight;
    _numLabel.textColor = kApp999Color;
    _numLabel.font = [UIFont systemFontOfSize:15];
    [self.view addSubview:_numLabel];
    
    if ([self.viewType isEqualToString:@"1"])
    {
        _textField.placeholder = @"请输入小于11个文字";
        _numLabel.text = [NSString stringWithFormat:@"%d/10",(int)_textFieldName.length];
    }else if([self.viewType isEqualToString:@"2"])
    {
        _textField.placeholder = @"请输入小于33个文字";
        _numLabel.text = [NSString stringWithFormat:@"%d/32",(int)_textFieldName.length];
    }
    
    if (self.textFieldName.length > 0)
    {
        _textField.text = self.textFieldName;
    }
}
-(void)showSetGender {
    
    UIView *whiteView = [[UIView alloc]initWithFrame:CGRectMake(0, SafeAreaTopHeight+15, SCREEN_WIDTH, 81)];
    whiteView.backgroundColor = kAppWhiteColor;
    [self.view addSubview:whiteView];
    
    UIButton *manBtn = [UIButton buttonWithType:(UIButtonTypeCustom)];
    manBtn.frame = CGRectMake(15, 0, SCREEN_WIDTH-15, 40);
    [manBtn setTitle:@"男" forState:(UIControlStateNormal)];
    manBtn.titleLabel.font = [UIFont systemFontOfSize:13.0];
    [manBtn setTitleColor:kAppBlackColor forState:(UIControlStateNormal)];
    manBtn.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
    [manBtn addTarget:self action:@selector(selectGenderAction:) forControlEvents:(UIControlEventTouchUpInside)];
    
    self.checkManImgView = [[UIImageView alloc] initWithImage:BGImage(@"gender_selected")];
    _checkManImgView.frame = CGRectMake(manBtn.width-26, (manBtn.height-10)*0.5, 11, 10);
    [manBtn addSubview:_checkManImgView];
    [whiteView addSubview:manBtn];
    
    
    UIView *lineView = [[UIView alloc] initWithFrame:CGRectMake(0, manBtn.y+manBtn.height, SCREEN_WIDTH, 1)];
    lineView.backgroundColor = kAppLineBGColor;
    [whiteView addSubview:lineView];
    
    
    UIButton *womanBtn = [UIButton buttonWithType:(UIButtonTypeCustom)];
    womanBtn.frame = CGRectMake(15, lineView.y+lineView.height, SCREEN_WIDTH-15, 40);
    [womanBtn setTitle:@"女" forState:(UIControlStateNormal)];
    womanBtn.titleLabel.font = [UIFont systemFontOfSize:13.0];
    [womanBtn setTitleColor:kAppBlackColor forState:(UIControlStateNormal)];
    womanBtn.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
    [womanBtn addTarget:self action:@selector(selectGenderAction:) forControlEvents:(UIControlEventTouchUpInside)];
    
    self.checkWomanImgView = [[UIImageView alloc] initWithImage:BGImage(@"gender_selected")];
    _checkWomanImgView.frame = CGRectMake(womanBtn.width-26, (womanBtn.height-10)*0.5, 11, 10);
    [womanBtn addSubview:_checkWomanImgView];
    [whiteView addSubview:womanBtn];
    
    
    if ([_textFieldName isEqualToString:@"女"]){
        _checkManImgView.hidden = YES;
        self.genderStr = @"女";
    }else{
        _checkWomanImgView.hidden = YES;
        self.genderStr = @"男";
    }
}
-(void)selectGenderAction:(UIButton *)sender{
    if ([sender.titleLabel.text isEqualToString:@"男"]) {
        _checkManImgView.hidden = NO;
        _checkWomanImgView.hidden = YES;
        _genderStr = @"男";
    }else{
        _checkManImgView.hidden = YES;
        _checkWomanImgView.hidden = NO;
        _genderStr = @"女";
    }
    
}
//限制字符
- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    NSString *comcatstr = [textField.text stringByReplacingCharactersInRange:range withString:string];
    
    NSInteger caninputlen;
    if ([self.viewType isEqualToString:@"2"])
    {
        caninputlen = 32 - comcatstr.length;
    }else
    {
        caninputlen = 10 - comcatstr.length;
    }
    
    if (caninputlen >= 0)
    {
        return YES;
    }
    else
    {
        NSInteger len = string.length + caninputlen;
        //防止当text.length + caninputlen < 0时，使得rg.length为一个非法最大正数出错
        NSRange rg = {0,MAX(len,0)};
        
        if (rg.length > 0)
        {
            NSString *s = [string substringWithRange:rg];
            
            [textField setText:[textField.text stringByReplacingCharactersInRange:range withString:s]];
        }
        return NO;
    }
}

// 监听改变按钮
- (void)textFieldDidChange:(UITextField*) sender
{
    if ([self.viewType isEqualToString:@"2"])
    {
        if (_textField.text.length > 32)
        {
            [WHIndicatorView toast:@"请输入小于33个文字"];
            NSString *s = [_textField.text substringToIndex:32];
            _textField.text = s;
            return;
        }
        _numLabel.text = [NSString stringWithFormat:@"%d/32",(int)_textField.text.length];
    }else
    {
        if (_textField.text.length > 10)
        {
            [WHIndicatorView toast:@"请输入小于11个文字"];
            NSString *s = [_textField.text substringToIndex:10];
            _textField.text = s;
            return;
        }
        _numLabel.text = [NSString stringWithFormat:@"%d/10",(int)_textField.text.length];
    }
}

//保存
- (void)saveEditButton
{
    NSString *temp = @"";
    if ([self.viewType isEqualToString:@"3"])
    {
        if ([_genderStr isEqualToString:@"男"]) {
            temp = @"1";
        }else{
            temp = @"2";
            
        }
    }else{
        [_textField resignFirstResponder];
        
        temp = [_textField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
        if (temp.length < 1)
        {
            if ([self.viewType isEqualToString:@"1"])
            {
                [WHIndicatorView toast:@"请编辑昵称"];
                
            }else if ([self.viewType isEqualToString:@"2"])
            {
                [WHIndicatorView toast:@"请编辑签名"];
            }
            return;
        }
    }
    
    [self saveNameActionWithTemp:temp];
    
}


-(BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    return YES;
}

-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    [_textField resignFirstResponder];
}

- (void)textFieldDidEndEditing:(UITextField *)textField
{
    if ([self.viewType isEqualToString:@"2"])
    {
        _numLabel.text = [NSString stringWithFormat:@"%d/32",(int)_textField.text.length];
    }else
    {
        _numLabel.text = [NSString stringWithFormat:@"%d/10",(int)_textField.text.length];
    }
    
    
}

/**
 网络请求修改
 */

-(void)saveNameActionWithTemp:(NSString *)temp {
    
    switch (self.viewType.intValue) {
        case 1:{
            // 修改昵称
            NSMutableDictionary *param = [[NSMutableDictionary alloc] init];
            [param setObject:temp forKey:@"nickname"];
            __block typeof(self) weakSelf = self;
            [BGSystemApi modifyUserInfo:param succ:^(NSDictionary *response) {
                DLog(@"\n>>>[modifyNickname success]:%@",response);
                if (weakSelf.refreshEditBlock) {
                    self.refreshEditBlock();
                }
                [weakSelf.navigationController popViewControllerAnimated:YES];
                [WHIndicatorView toast:@"修改昵称成功"];
            } failure:^(NSDictionary *response) {
                DLog(@"\n>>>[modifyNickname failure]:%@",response);
                
            }];
        }
            break;
        case 2:{
            // 修改签名
            NSMutableDictionary *param = [[NSMutableDictionary alloc] init];
            [param setObject:temp forKey:@"signature"];
            __block typeof(self) weakSelf = self;
            [BGSystemApi modifyUserInfo:param succ:^(NSDictionary *response) {
                DLog(@"\n>>>[modifySelfIntroduction success]:%@",response);
                if (weakSelf.refreshEditBlock) {
                    self.refreshEditBlock();
                }
                [weakSelf.navigationController popViewControllerAnimated:YES];
                [WHIndicatorView toast:@"修改签名成功"];
            } failure:^(NSDictionary *response) {
                DLog(@"\n>>>[modifySelfIntroduction failure]:%@",response);
            }];
        }
            break;
        case 3:{
            // 修改性别
            NSMutableDictionary *param = [[NSMutableDictionary alloc] init];
            [param setObject:temp forKey:@"sex"];
            __block typeof(self) weakSelf = self;
            [BGSystemApi modifyUserInfo:param succ:^(NSDictionary *response) {
                DLog(@"\n>>>[modifyGender success]:%@",response);
                if (weakSelf.refreshEditBlock) {
                    self.refreshEditBlock();
                }
                [weakSelf.navigationController popViewControllerAnimated:YES];
                [WHIndicatorView toast:@"修改性别成功"];
            } failure:^(NSDictionary *response) {
                DLog(@"\n>>>[modifyGender failure]:%@",response);
            }];
        }
            break;
            
        default:
            break;
    }
    
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
