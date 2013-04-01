// @author Simon Toens 03/30/13

#import <Foundation/Foundation.h>

@interface TableHeaderViewContainer : NSObject

+ (UIView *)newTableHeaderView:(UIImage *)image 
                        label1:(NSString *)l1 
                        label2:(NSString *)l2
                        label3:(NSString *)l3;

@end