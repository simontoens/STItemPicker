// @author Simon Toens 03/30/13

#import "ItemPickerContext.h"
#import "Preconditions.h"

@implementation ItemPickerContext

@synthesize autoSelected = _autoSelected;
@synthesize dataSource = _dataSource;
@synthesize selectedIndex = _selectedIndex; 
@synthesize selectedItem = _selectedItem;

- (id)initWithDataSource:(id<ItemPickerDataSource>)dataSource 
           selectedIndex:(NSUInteger)selectedIndex
            selectedItem:(NSString *)selectedItem
            autoSelected:(BOOL)autoSelected
{
    if (self = [super init]) 
    {
       [Preconditions assertNotNil:dataSource message:@"datasource cannot be nil"];
        _autoSelected = autoSelected;
        _dataSource = dataSource;
        _selectedIndex = selectedIndex;
        _selectedItem = selectedItem;
    }
    return self;
}

- (BOOL)isEqual:(id)object
{
    if (self == object)
    {
        return YES;
    }
    if (![object isKindOfClass:[ItemPickerContext class]])
    {
        return NO;
    }
    ItemPickerContext *other = (ItemPickerContext *)object;
    return self.selectedIndex == other.selectedIndex && [self.selectedItem isEqualToString:other.selectedItem];
}

- (NSUInteger)hash 
{
    int prime = 31;
    int result = prime + self.selectedIndex;
    result = prime * result + [self.selectedItem hash];
    return result;
}

- (id)copyWithZone:(NSZone *)zone
{
    return [[ItemPickerContext alloc] initWithDataSource:self.dataSource 
                                           selectedIndex:self.selectedIndex 
                                            selectedItem:[self.selectedItem copyWithZone:zone] 
                                            autoSelected:self.autoSelected];
}

- (NSString *)description 
{
    return [NSString stringWithFormat:@"%@ %i %@", self.dataSource, self.selectedIndex, self.selectedItem];
}

@end