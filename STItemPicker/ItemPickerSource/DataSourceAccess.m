// @author Simon Toens 05/16/13 on the way to KIX

#import "DataSourceAccess.h"
#import "ItemPickerDataSourceDefaults.h"
#import "ItemPickerSection.h"
#import "TableSectionHandler.h"

@interface DataSourceAccess()
@property(nonatomic, strong) id<ItemPickerDataSource> dataSource;
@property(nonatomic, assign) BOOL processed;
@property(nonatomic, strong) NSArray *sections;
@property(nonatomic, strong) NSArray *sectionTitles;
@property(nonatomic, strong) TableSectionHandler *tableSectionHandler;
@property(nonatomic, assign) NSRange currentRange;

- (void)buildDefaultSection;
- (void)buildSections;
- (void)buildSectionTitles;
- (NSInteger)convertIndexPathToArrayIndex:(NSIndexPath *)indexPath;
- (void)process;
- (void)initializeDataSourceForRange:(NSRange)range;

@end

@implementation DataSourceAccess

static NSRange kUnsetRange;

@synthesize currentRange = _currentRange;
@synthesize dataSource = _dataSource;
@synthesize processed = _processed;
@synthesize sections = _sections;
@synthesize sectionTitles;
@synthesize tableSectionHandler;

+ (void)initialize
{
    kUnsetRange = NSMakeRange(0, 0);
}

- (id)initWithDataSource:(id<ItemPickerDataSource>)dataSource
{
    if (self = [super init])
    {
        _currentRange = kUnsetRange;
        _dataSource = dataSource;
        _processed = NO;
    }
    return self;
}

- (id<ItemPickerDataSource>)getDataSource
{
    return self.dataSource;
}

- (NSUInteger)getCount
{
    return self.dataSource.count;
}

- (NSString *)getTitle
{
    return self.dataSource.title;
}

- (UIImage *)getTabImage
{
    return self.dataSource.tabImage;
}

- (ItemPickerHeader *)getHeader
{
    return self.dataSource.header;
}

- (id)getSection:(NSUInteger)index
{
    [self process];
    return [self.sections objectAtIndex:index];
}

- (NSArray *)getSectionTitles
{
    [self process];
    return self.sectionTitles;
}

- (NSString *)getItem:(NSIndexPath *)indexPath
{
    [self process];
    NSUInteger index = [self convertIndexPathToArrayIndex:indexPath];
    if (self.tableSectionHandler)
    {
        return [self.tableSectionHandler.items objectAtIndex:index];
    }
    else
    {
        NSRange range = NSMakeRange(index, 1);
        [self initializeDataSourceForRange:range];
        return [[self.dataSource getItemsInRange:range] lastObject];
    }
}

- (NSString *)getItemDescription:(NSIndexPath *)indexPath
{
    [self process];
    NSUInteger index = [self convertIndexPathToArrayIndex:indexPath];
    if (self.tableSectionHandler)
    {
        return [self.tableSectionHandler.itemDescriptions objectAtIndex:index];
    }
    else
    {
        NSRange range = NSMakeRange(index, 1);
        [self initializeDataSourceForRange:range];
        return [[self.dataSource getItemDescriptionsInRange:range] lastObject];
    }
}

- (UIImage *)getItemImage:(NSIndexPath *)indexPath
{
    [self process];
    NSUInteger index = [self convertIndexPathToArrayIndex:indexPath];
    id image = nil;
    if (self.tableSectionHandler)
    {
        image = [self.tableSectionHandler.itemImages objectAtIndex:index];
    }
    else
    {
        NSRange range = NSMakeRange(index, 1);
        [self initializeDataSourceForRange:range];
        image = [[self.dataSource getItemImagesInRange:range] lastObject];
    }
    
    return image == [NSNull null] ? nil : image;
}

- (ItemAttributes *)getItemAttributes:(NSIndexPath *)indexPath
{
    [self process];
    NSUInteger index = [self convertIndexPathToArrayIndex:indexPath];
    if (self.tableSectionHandler)
    {
        return [self.tableSectionHandler.itemAttributes objectAtIndex:index];
    }
    else
    {
        NSRange range = NSMakeRange(index, 1);
        [self initializeDataSourceForRange:range];        
        return [[self.dataSource getItemAttributesInRange:range] lastObject];
    }
}

- (id<ItemPickerDataSource>)getUnwrappedDataSource
{
    // and so the abstraction begins to break down...
    return [self.dataSource isKindOfClass:[ItemPickerDataSourceDefaults class]] ? 
        ((ItemPickerDataSourceDefaults *)self.dataSource).dataSource : self.dataSource;
}

- (ItemPickerSelection *)getItemPickerContext:(NSIndexPath *)indexPath autoSelected:(BOOL)autoSelected
{
    return [[ItemPickerSelection alloc] initWithDataSource:[self getUnwrappedDataSource]
                                           selectedIndex:[self convertIndexPathToArrayIndex:indexPath]
                                            selectedItem:[self getItem:indexPath] 
                                            autoSelected:autoSelected];
}

- (void)process
{
    if (self.processed)
    {
        return;
    }
    self.processed = YES;
    if (self.dataSource.sectionsEnabled)
    {
        self.sections = self.dataSource.sections;
        if (!self.sections)
        {
            [self buildSections];
        }
    }
    
    if (!self.sections)
    {
        [self buildDefaultSection];
    }
    
    [self buildSectionTitles];
}

- (void)initializeDataSourceForRange:(NSRange)range
{
    if (self.currentRange.location != range.location || self.currentRange.length != range.length)
    {
        [self.dataSource initForRange:range];
        self.currentRange = range;
    }
}

- (void)buildSections
{
    NSRange range = NSMakeRange(0, self.dataSource.count);
    [self.dataSource initForRange:range];

    self.tableSectionHandler = [[TableSectionHandler alloc] initWithItems:[self.dataSource getItemsInRange:range]];
    self.tableSectionHandler.itemDescriptions = [self.dataSource getItemDescriptionsInRange:range];
    self.tableSectionHandler.itemImages = [self.dataSource getItemImagesInRange:range];
    self.tableSectionHandler.itemAttributes = [self.dataSource getItemAttributesInRange:range];
    self.sections = self.tableSectionHandler.sections;
}

- (void)buildDefaultSection
{
    self.sections = [NSArray arrayWithObject:[[ItemPickerSection alloc] 
        initWithTitle:@"" range:NSMakeRange(0, self.dataSource.count)]];
}

- (void)buildSectionTitles
{
    NSMutableArray *titles = [[NSMutableArray alloc] initWithCapacity:[self.sections count]];
    for (id section in self.sections)
    {
        [titles addObject:[section title]];
    }
    self.sectionTitles = titles;
}

- (NSInteger)convertIndexPathToArrayIndex:(NSIndexPath *)indexPath
{
    NSInteger row = 0;
    for (int i = 0; i < indexPath.section; i++) 
    {
        NSRange range = [[self.sections objectAtIndex:i] range];
        row += range.length;
    }
    return row + indexPath.row;
}

@end