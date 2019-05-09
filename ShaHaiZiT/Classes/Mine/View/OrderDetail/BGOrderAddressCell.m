//
//  BGOrderAddressCell.m
//  shzTravelC
//
//  Created by 孙林茂 on 2018/5/11.
//  Copyright © 2018年 biao. All rights reserved.
//

#import "BGOrderAddressCell.h"
#import "BGAddressModel.h"

@interface BGOrderAddressCell()
@property (weak, nonatomic) IBOutlet UIImageView *colorBarImgView;
@property (weak, nonatomic) IBOutlet UIImageView *rightImgView;

@property (weak, nonatomic) IBOutlet UILabel *nameAndPhoneLabel;
@property (weak, nonatomic) IBOutlet UILabel *areaLabel;
@property (weak, nonatomic) IBOutlet UILabel *detailAddressLabel;

@end

@implementation BGOrderAddressCell

- (void)updataWithCellArray:(NSDictionary *)dic isHiddenColorLine:(BOOL)isHidden{
    BGAddressModel *model = [BGAddressModel mj_objectWithKeyValues:dic];
    self.colorBarImgView.hidden = isHidden;
    self.rightImgView.hidden = isHidden;
    if (isHidden) {
        if ([Tool isBlankString:BGdictSetObjectIsNil(dic[@"ship_name"])]) {
            self.nameAndPhoneLabel.text = @"请点击添加新的收货地址";
        }else{
             self.nameAndPhoneLabel.text = [NSString stringWithFormat:@"%@   %@",BGdictSetObjectIsNil(dic[@"ship_name"]),BGdictSetObjectIsNil(dic[@"ship_mobile"])];
        }
        if ([Tool isBlankString:BGdictSetObjectIsNil(dic[@"shipping_area"])]) {
            self.areaLabel.text = @" 暂无地址";
        }else{
           self.areaLabel.text = [NSString stringWithFormat:@"%@",BGdictSetObjectIsNil(dic[@"shipping_area"])];
        }
        self.detailAddressLabel.text = BGdictSetObjectIsNil(dic[@"ship_addr"]);
    }else{
        
        if ([Tool isBlankString:model.name]) {
            self.nameAndPhoneLabel.text = @"请点击添加新的收货地址";
        }else{
            self.nameAndPhoneLabel.text = [NSString stringWithFormat:@"%@   %@",model.name,model.mobile];
        }
        if ([Tool isBlankString:model.province_name]) {
             self.areaLabel.text = @" 暂无地址";
        }else{
            self.areaLabel.text = [NSString stringWithFormat:@"%@ %@ %@",model.province_name,model.city_name,model.region_name];
        }
        self.detailAddressLabel.text = model.address_detail;
    }
}
- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
