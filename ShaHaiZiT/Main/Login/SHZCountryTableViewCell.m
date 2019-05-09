//
//  SHZCountryTableViewCell.m
//  shahaizic
//
//  Created by 姜昊 on 2018/1/30.
//  Copyright © 2018年 姜昊. All rights reserved.
//


#import "SHZCountryTableViewCell.h"

@interface SHZCountryTableViewCell ()

@property (weak, nonatomic) IBOutlet UILabel *countryNameLab;
@property (weak, nonatomic) IBOutlet UILabel *countryNumLab;


@end

@implementation SHZCountryTableViewCell

- (void)layoutSubviews {
    
    self.countryNameLab.text = self.countryDic[@"name"];
    self.countryNumLab.text = [NSString stringWithFormat:@"+%@",self.countryDic[@"c_code"]];

}

@end
