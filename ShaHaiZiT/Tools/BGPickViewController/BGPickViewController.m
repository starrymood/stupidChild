//
//  BGPickViewController.m
//  LLMall
//
//  Created by biao on 2016/11/18.
//  Copyright © 2016年 ZZLL. All rights reserved.
//

#import "BGPickViewController.h"

@interface BGPickViewController ()
@property (weak, nonatomic) IBOutlet UIView *backView;
@property (nonatomic,assign) BOOL isFirst;
@property (nonatomic, assign) NSInteger index;
@end

@implementation BGPickViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    self.isFirst = YES;
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(tapClick)];
    [self.backView addGestureRecognizer:tap];
}

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView{
    return 1;
}
- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component{
    return [_arry count];
}
- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component{
    return [_arry objectAtIndex:row];
}
- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component{
    _chooseText = [NSString stringWithFormat:@"%@",[_arry objectAtIndex:row]];
    self.isFirst = NO;
    self.index = row;
}
// 点击空白区域取消选择
- (void)tapClick {
    [self dismissViewControllerAnimated:YES completion:nil];

}
//取消按钮
- (IBAction)cancel:(id)sender{
    [self dismissViewControllerAnimated:YES completion:nil];
}
//确定按钮
- (IBAction)submit:(id)sender{
   
    
    if (_delegate && [_delegate respondsToSelector:@selector(getTextStr:)]) {
        if (self.isFirst) {
            _chooseText = [NSString stringWithFormat:@"%@",[_arry objectAtIndex:0]];
            [_delegate getTextStr:_chooseText];
        }
        [_delegate getTextStr:_chooseText];
    }
    if (_delegate && [_delegate respondsToSelector:@selector(getTextStr:index:)]) {
        if (self.isFirst) {
            _chooseText = [NSString stringWithFormat:@"%@",[_arry objectAtIndex:0]];
            [_delegate getTextStr:_chooseText index:0];
        }
        [_delegate getTextStr:_chooseText index:_index];
    }
    [self dismissViewControllerAnimated:YES completion:nil];
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
