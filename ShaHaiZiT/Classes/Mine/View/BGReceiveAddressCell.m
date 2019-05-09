//
//  BGReceiveAddressCell.m
//  shzTravelC
//
//  Created by 孙林茂 on 2018/5/12.
//  Copyright © 2018年 biao. All rights reserved.
//

#import "BGReceiveAddressCell.h"
#import "BGAddressModel.h"

@interface BGReceiveAddressCell()
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UILabel *phoneLabel;
@property (weak, nonatomic) IBOutlet UILabel *addressLabel;
@property (weak, nonatomic) IBOutlet UIButton *defaultBtn;
@end
@implementation BGReceiveAddressCell


-(void)updataWithCellArray:(BGAddressModel *)model{
    self.nameLabel.text = model.name;
    self.phoneLabel.text = model.mobile;
    if ([model.is_default isEqualToString:@"1"]) {
        [_defaultBtn setImage:BGImage(@"address_address_selection") forState:(UIControlStateNormal)];
    }else{
        [_defaultBtn setImage:BGImage(@"address_address_default") forState:(UIControlStateNormal)];
    }
    self.addressLabel.text = [NSString stringWithFormat:@"%@%@%@%@",model.province_name,model.city_name,model.region_name,model.address_detail];
}

- (IBAction)btnSetDefaultClicked:(UIButton *)sender {
    if (self.setDefaultCellClicked) {
        self.setDefaultCellClicked();
    }
}
- (IBAction)btnEditAddressClicked:(UIButton *)sender {
    if (self.editCellClicked) {
        self.editCellClicked();
    }
}
- (IBAction)btnDeleteAddressClicked:(UIButton *)sender {
    if (self.deleteCellClicked) {
        self.deleteCellClicked();
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
