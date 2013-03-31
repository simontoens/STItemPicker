// @author Simon Toens 03/30/13

#import "ItemPickerContext.h"
#import "Preconditions.h"

@implementation ItemPickerContext

@synthesize dataSource = _dataSource;
@synthesize selectedIndex, selectedItem;

- (id)initWithDataSource:(id<ItemPickerDataSource>)dataSource 
{
    if (self = [super init]) 
    {
       [Preconditions assertNotNil:dataSource message:@"datasource cannot be nil"];
        _dataSource = dataSource;
    }
    return self;
}

- (NSString *)description 
{
    return [NSString stringWithFormat:@"%@ %i %@", self.dataSource, self.selectedIndex, self.selectedItem];
}

@end