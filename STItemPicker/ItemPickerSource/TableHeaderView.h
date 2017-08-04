// @author Simon Toens 10/27/13

#import <UIKit/UIKit.h>
#import "DataSourceAccess.h"
#import "Stack.h"

@interface TableHeaderView : UIView

+ (UIView *)initWithHeader:(ItemPickerHeader *)header
            selectionStack:(Stack *)selectionStack
          dataSourceAccess:(DataSourceAccess *)dataSourceAccess
         selectAllCallback:(void (^)())selectAllCallback;

@end
