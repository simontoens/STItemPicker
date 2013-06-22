// @author Simon Toens 06/14/13

#import "ItemPickerContext.h"

@implementation ItemPickerContext

@synthesize selectedItems = _selectedItems;

- (id)init
{
    if (self = [super init])
    {
        _selectedItems = [[NSMutableArray alloc] init];
    }
    return self;
}

@end