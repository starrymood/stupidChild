//
//  BLAreaPickerView.m
//  AreaPicker
//
//  Created by boundlessocean on 2016/11/21.
//  Copyright © 2016年 ocean. All rights reserved.
//

#import "BLAreaPickerView.h"

@interface BLAreaPickerView()<UIPickerViewDelegate, UIPickerViewDataSource>
/** 地址数据 */
@property (nonatomic, strong) NSArray *areaArray;
/** pickView */
@property (nonatomic, strong) UIPickerView *pickView;
/** 顶部视图 */
@property (nonatomic, strong) UIView *topView;
/** 取消按钮 */
@property (nonatomic, strong) UIButton *cancelButton;
/** 确定按钮 */
@property (nonatomic, strong) UIButton *sureButton;
@end

static const CGFloat topViewHeight = 40;
static const CGFloat buttonWidth = 60;
static const CGFloat animationDuration = 0.3;
#define BL_ScreenW  [[UIScreen mainScreen] bounds].size.width
#define BL_ScreenH  [[UIScreen mainScreen] bounds].size.height
typedef enum : NSUInteger {
    BLComponentTypeProvince = 0, // 省
    BLComponentTypeCity,         // 市
    BLComponentTypeArea,         // 区
} BLComponentType;

@implementation BLAreaPickerView
{
    NSInteger _provinceSelectedRow;
    NSInteger _citySelectedRow;
    NSInteger _areaSelectedRow;
    
    NSString *_selectedProvinceTitle;
    NSString *_selectedCityTitle;
    NSString *_selectedAreaTitle;
    
    CGRect _pickViewFrame;
}

#pragma mark - - load
- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self bl_initData:frame];
        [self bl_initSubviews];
    }
    return self;
}

/** 初始化子视图 */
- (void)bl_initSubviews{
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(cancelButtonClicked)];
    [self addGestureRecognizer:tap];
    [self addSubview:self.topView];
    [self addSubview:self.pickView];
    [self.topView addSubview:self.cancelButton];
    [self.topView addSubview:self.sureButton];
}

/** 初始化数据 */
- (void)bl_initData:(CGRect)frame{
    _pickViewFrame = frame;
    
    self.frame = CGRectMake(0, 0, BL_ScreenW, BL_ScreenH);
    self.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.5];
    
    _provinceSelectedRow = 0;
    _citySelectedRow = 0;
    _areaSelectedRow = 0;
    
}

#pragma mark - - get
- (UIPickerView *)pickView{
    if (!_pickView) {
        _pickView = [[UIPickerView alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(_topView.frame), BL_ScreenW, _pickViewFrame.size.height)];
        _pickView.dataSource = self;
        _pickView.delegate = self;
        _pickView.backgroundColor = [UIColor colorWithRed:244.0/255 green:244.0/255 blue:244.0/255 alpha:1];
    }
    return _pickView;
}

- (UIView *)topView{
    if (!_topView) {
        _topView = [[UIView alloc] initWithFrame:CGRectMake(0, BL_ScreenH, BL_ScreenW, topViewHeight)];
        _topView.backgroundColor = kAppWhiteColor;
    }
    return _topView;
}

- (UIButton *)cancelButton{
    if (!_cancelButton) {
        _cancelButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _cancelButton.frame = CGRectMake(0, 0, buttonWidth, topViewHeight);
        [_cancelButton setTitle:@"取消" forState:UIControlStateNormal];
        [_cancelButton setTitleColor:kApp999Color forState:UIControlStateNormal];
        [_cancelButton.titleLabel setFont:kFont(15)];
        [_cancelButton addTarget:self action:@selector(cancelButtonClicked) forControlEvents:UIControlEventTouchUpInside];
    }
    return _cancelButton;
}

- (UIButton *)sureButton{
    if (!_sureButton) {
        _sureButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _sureButton.frame = CGRectMake(self.frame.size.width - buttonWidth, 0, buttonWidth, topViewHeight);
        [_sureButton setTitle:@"确定" forState:UIControlStateNormal];
        [_sureButton setTitleColor:kAppMainColor forState:UIControlStateNormal];
        [_sureButton.titleLabel setFont:kFont(15)];
        [_sureButton addTarget:self action:@selector(sureButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _sureButton;
}

#pragma mark - - set
- (void)setPickViewBackgroundColor:(UIColor *)pickViewBackgroundColor{
    self.pickView.backgroundColor = pickViewBackgroundColor;
}

- (void)setTopViewBackgroundColor:(UIColor *)topViewBackgroundColor{
    self.topView.backgroundColor = topViewBackgroundColor;
}

- (void)setCancelButtonColor:(UIColor *)cancelButtonColor{
    [self.cancelButton setTitleColor:cancelButtonColor forState:UIControlStateNormal];
}

- (void)setSureButtonColor:(UIColor *)sureButtonColor{
    [self.sureButton setTitleColor:sureButtonColor forState:UIControlStateNormal];
}

#pragma mark - show,dismiss

- (void)bl_showWithData:(NSArray *)data{
    self.areaArray = [NSMutableArray arrayWithArray:data];
    [[UIApplication sharedApplication].keyWindow addSubview:self];
    [UIView animateWithDuration:animationDuration animations:^{
        CGRect tempRect = _topView.frame;
        tempRect.origin.y = BL_ScreenH - topViewHeight - _pickViewFrame.size.height;
        _topView.frame = tempRect;
        tempRect = _pickViewFrame;
        tempRect.origin.y = CGRectGetMaxY(_topView.frame);
        _pickView.frame = tempRect;
    }];
}

- (void)bl_dismiss{
    [UIView animateWithDuration:animationDuration animations:^{
        CGRect tempRect = _topView.frame;
        tempRect.origin.y = BL_ScreenH;
        _topView.frame = tempRect;
        tempRect = _pickViewFrame;
        tempRect.origin.y = CGRectGetMaxY(_topView.frame);
        _pickView.frame = tempRect;
    } completion:^(BOOL finished) {
        [self removeFromSuperview];
        
    }];
}

#pragma mark - - Button Action
- (void)cancelButtonClicked{
    
    if (self.pickViewDelegate &&
        [self.pickViewDelegate respondsToSelector:@selector(bl_cancelButtonClicked)]) {
        [self.pickViewDelegate bl_cancelButtonClicked];
    }
    [self bl_dismiss];
}

- (void)sureButtonClicked:(UIButton *)sender{
    
    _selectedProvinceTitle = [self pickerView:_pickView titleForRow:_provinceSelectedRow forComponent:0];
    _selectedCityTitle = [self pickerView:_pickView titleForRow:_citySelectedRow forComponent:1]?:@"";
    _selectedAreaTitle = [self pickerView:_pickView titleForRow:_areaSelectedRow forComponent:2]?:@"";
    
    NSDictionary *provinceDic = [_areaArray objectAtIndex:_provinceSelectedRow];
    NSArray *cityArr = [provinceDic objectForKey:@"children"];
    NSString *province_id = [_areaArray[_provinceSelectedRow] objectForKey:@"regionId"];
    
    NSString *city_id = @"";
    NSString *region_id = @"";
    if ([Tool arrayIsNotEmpty:cityArr]) {
        NSDictionary *cityDic = [cityArr objectAtIndex:_citySelectedRow];
        city_id = [cityDic objectForKey:@"regionId"];
        
        NSDictionary *areaDic = [cityArr objectAtIndex:_citySelectedRow];
        NSArray *areaArr = [areaDic objectForKey:@"children"];
        if ([Tool arrayIsNotEmpty:areaArr]) {
        region_id = [areaArr[_areaSelectedRow] objectForKey:@"regionId"];
        }
    }
            
    if (self.pickViewDelegate &&
        [self.pickViewDelegate respondsToSelector:@selector(bl_selectedAreaResultWithProvince:city:area:province_id:city_id:region_id:)]) {
        [self.pickViewDelegate bl_selectedAreaResultWithProvince:_selectedProvinceTitle
                                                            city:_selectedCityTitle
                                                            area:_selectedAreaTitle
                                                     province_id:province_id
                                                         city_id:city_id
                                                       region_id:region_id];
    }
    [self bl_dismiss];
}

#pragma mark - - UIPickerViewDelegate,UIPickerViewDataSource
- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView{
    return 3;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component{
    switch (component) {
        case BLComponentTypeProvince:
            return _areaArray.count;
            break;
        case BLComponentTypeCity:{
            if ([Tool arrayIsNotEmpty:[[_areaArray objectAtIndex:_provinceSelectedRow] objectForKey:@"children"]]) {
                return [[[_areaArray objectAtIndex:_provinceSelectedRow] objectForKey:@"children" ] count];

            }else{
                return 0;
            }
    }
            break;
        case BLComponentTypeArea:{
            if ([Tool arrayIsNotEmpty:[[_areaArray objectAtIndex:_provinceSelectedRow] objectForKey:@"children"]]) {
               return [[[[[_areaArray objectAtIndex:_provinceSelectedRow] objectForKey:@"children" ] objectAtIndex:_citySelectedRow] objectForKey:@"children" ] count];
            }else{
                return 0;
            }
        }
            
            break;
        default:
            return _areaArray.count;
            break;
    }
}

- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component{
    
    NSDictionary *provinceDic = [_areaArray objectAtIndex:_provinceSelectedRow];
    NSArray *cityArr = [provinceDic objectForKey:@"children"];
    
    switch (component) {
        case BLComponentTypeProvince:
            return [_areaArray[row] objectForKey:@"localName"];
            break;
        case BLComponentTypeCity:{
            if ([Tool arrayIsNotEmpty:cityArr]) {
                NSDictionary *cityDic = [cityArr objectAtIndex:row];
                return [cityDic objectForKey:@"localName"];
            }else{
                return nil;
            }
           
            break;
        }
        case BLComponentTypeArea:{
            if ([Tool arrayIsNotEmpty:cityArr]) {
                NSDictionary *areaDic = [cityArr objectAtIndex:_citySelectedRow];
                NSArray *areaArr = [areaDic objectForKey:@"children"];
                if ([Tool arrayIsNotEmpty:areaArr]) {
                     return [areaArr[row] objectForKey:@"localName"];
                }else{
                    return nil;
                }
                
            }else{
                return nil;
            }
            break;
        }
        default:
            return [_areaArray[row] objectForKey:@"localName"];
            break;
    }
}

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component{
    switch (component) {
        case BLComponentTypeProvince:{
            _provinceSelectedRow = row;
            _citySelectedRow = 0;
            _areaSelectedRow = 0;
            [pickerView selectRow:0 inComponent:1 animated:NO];
            [pickerView selectRow:0 inComponent:2 animated:NO];
            break;
        }
        case BLComponentTypeCity:{
            _citySelectedRow = row;
            _areaSelectedRow = 0;
            [pickerView selectRow:0 inComponent:2 animated:NO];
            break;
        }
        case BLComponentTypeArea:
            _areaSelectedRow = row;
            break;
        default:
            _provinceSelectedRow = row;
            break;
    }
    [pickerView reloadAllComponents];
}

- (CGFloat)pickerView:(UIPickerView *)pickerView widthForComponent:(NSInteger)component{
    return self.frame.size.width / 3;
}
//第component列的行高是多少
- (CGFloat)pickerView:(UIPickerView *)pickerView rowHeightForComponent:(NSInteger)component
{
    return 30;
}
- (UIView *)pickerView:(UIPickerView *)pickerView viewForRow:(NSInteger)row forComponent:(NSInteger)component reusingView:(UIView *)view{
    
    UILabel* pickerLabel = (UILabel*)view;
    if (!pickerLabel){
        pickerLabel = [[UILabel alloc] init];
        pickerLabel.adjustsFontSizeToFitWidth = YES;
        [pickerLabel setTextAlignment:NSTextAlignmentCenter];
        [pickerLabel setBackgroundColor:[UIColor clearColor]];
        [pickerLabel setFont:_titleFont ? _titleFont : [UIFont systemFontOfSize:14]];
    }
    pickerLabel.text = [self pickerView:pickerView titleForRow:row forComponent:component];
    return pickerLabel;
}


@end
