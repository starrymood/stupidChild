//
//  UITextField+BGLimit.m
//  LLBike
//
//  Created by biao on 2017/8/8.
//  Copyright © 2017年 ZZLL. All rights reserved.
//

#import "UITextField+BGLimit.h"
#import <objc/runtime.h>

char* const UITextField_Master_maxLenght = "UITextField_Master_maxLenght";
char* const UITextField_Master_digitsChars = "UITextField_Master_digitsChars";

@implementation UITextField (BGLimit)
- (void)setMaxLenght:(NSInteger)maxLenght{
    objc_setAssociatedObject(self,UITextField_Master_maxLenght,[NSNumber numberWithInteger:maxLenght],OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    [self removeTarget:self action:@selector(MasterTextFieldChange:) forControlEvents:UIControlEventEditingChanged];
    [self addTarget:self action:@selector(MasterTextFieldChange:) forControlEvents:UIControlEventEditingChanged];
}

- (NSInteger)maxLenght{
    NSNumber* maxLenght =objc_getAssociatedObject(self,UITextField_Master_maxLenght);
    return [maxLenght integerValue];
}

- (void)setDigitsChars:(NSArray *)digitsChars{
    objc_setAssociatedObject(self,UITextField_Master_digitsChars,digitsChars,OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    [self removeTarget:self action:@selector(MasterTextFieldChange:) forControlEvents:UIControlEventEditingChanged];
    [self addTarget:self action:@selector(MasterTextFieldChange:) forControlEvents:UIControlEventEditingChanged];
}

- (NSArray*)digitsChars{
    NSArray* chars =objc_getAssociatedObject(self,UITextField_Master_digitsChars);
    return chars;
}

- (void)MasterTextFieldChange:(UITextField*)textField{
    if (textField.markedTextRange == nil && self.digitsChars && self.digitsChars.count>0) {
        NSMutableString* newString = [NSMutableString stringWithString:@""];
        for (int i =0; i<textField.text.length; i++) {
            NSString* str = [textField.text substringWithRange:NSMakeRange(i, 1)];
            if ([self.digitsChars containsObject:str]) {
                [newString appendString:str];
            }
        }
        textField.text=newString;
    }
    if (self.maxLenght>0) {
        if (textField.markedTextRange == nil && textField.text.length > self.maxLenght) {
            textField.text = [textField.text substringToIndex:self.maxLenght];
        }
    }
}

@end
