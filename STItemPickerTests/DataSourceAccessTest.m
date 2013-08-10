// @author Simon Toens 06/02/13

#import <OCMock/OCMock.h>
#import <SenTestingKit/SenTestingKit.h>
#import "DataSourceAccess.h"
#import "ItemPickerDataSource.h"

@interface DataSourceAccessTest : SenTestCase
{
    @private
    NSArray *items;
    id dataSource;
    DataSourceAccess *dataSourceAccess;
    
    BOOL initForRangeCalled;
    BOOL otherRangeMethodsCalled;
}
- (void)callMethodsOnDataSourceAccessWithIndexPath:(NSIndexPath *)indexPath expectedItem:(NSString *)expectedItem;
- (void)mockDataSourceForRange:(NSRange)range sectionsEnabled:(BOOL)sectionsEnabled;
@end

@implementation DataSourceAccessTest

- (void)setUp
{
    [super setUp];
    items = [NSArray arrayWithObjects:@"2", @"1", nil];
    dataSource = [OCMockObject mockForProtocol:@protocol(ItemPickerDataSource)];
    dataSourceAccess = [[DataSourceAccess alloc] initWithDataSource:dataSource autoSelected:NO];
    dataSourceAccess.itemCache.size = 1;
    otherRangeMethodsCalled = NO;
    initForRangeCalled = NO;
}    

- (void)testInitForRangeCalledOnceWithoutSections
{
    NSRange range = NSMakeRange(0, 1);
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:0 inSection:0];
    
    [self mockDataSourceForRange:range sectionsEnabled:NO];
    
    [self callMethodsOnDataSourceAccessWithIndexPath:indexPath expectedItem:@"2"];
    STAssertTrue(initForRangeCalled, @"Expected initForRange to be called");
    STAssertTrue(otherRangeMethodsCalled, @"Expected other range methods to be called");
    
    initForRangeCalled = NO;
    otherRangeMethodsCalled = NO;
    
    [self callMethodsOnDataSourceAccessWithIndexPath:indexPath expectedItem:@"2"];
    STAssertFalse(initForRangeCalled, @"Did not expect initForRange to be called again");
    STAssertFalse(otherRangeMethodsCalled, @"Did not expect other range methods to be called");

    otherRangeMethodsCalled = NO;
    range = NSMakeRange(1, 1);
    indexPath = [NSIndexPath indexPathForRow:1 inSection:0];
    
    [self mockDataSourceForRange:range sectionsEnabled:NO];
    
    [self callMethodsOnDataSourceAccessWithIndexPath:indexPath expectedItem:@"1"];
    STAssertTrue(initForRangeCalled, @"Expected initForRange to be called");
    STAssertTrue(otherRangeMethodsCalled, @"Expected other range methods to be called");
}

- (void)testInitForRangeCalledOnceWithCalculatedSections
{
    NSRange range = NSMakeRange(0, 2);
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:0 inSection:0];
    
    [self mockDataSourceForRange:range sectionsEnabled:YES];
    
    [self callMethodsOnDataSourceAccessWithIndexPath:indexPath expectedItem:@"1"];
    STAssertTrue(initForRangeCalled, @"Expected initForRange to be called");
    STAssertTrue(otherRangeMethodsCalled, @"Expected other range methods to be called");
    
    initForRangeCalled = NO;
    otherRangeMethodsCalled = NO;
    
    [self callMethodsOnDataSourceAccessWithIndexPath:indexPath expectedItem:@"1"];
    STAssertFalse(initForRangeCalled, @"Did not expect initForRange to be called again");
    STAssertFalse(otherRangeMethodsCalled, @"Did not expect other range methods to be called");
    
    otherRangeMethodsCalled = NO;
    range = NSMakeRange(1, 1);
    indexPath = [NSIndexPath indexPathForRow:1 inSection:0];
    
    [self mockDataSourceForRange:range sectionsEnabled:YES];
    
    [self callMethodsOnDataSourceAccessWithIndexPath:indexPath expectedItem:@"2"];
    STAssertFalse(initForRangeCalled, @"Did not expect initForRange to be called again");
    STAssertFalse(otherRangeMethodsCalled, @"Expected other range methods to be called");
}

- (void)callMethodsOnDataSourceAccessWithIndexPath:(NSIndexPath *)indexPath expectedItem:(NSString *)expectedItem
{
    NSString *item = [dataSourceAccess getItem:indexPath];
    STAssertEqualObjects(item, expectedItem, @"getItem returned an unexpected item");
    
    [dataSourceAccess getItemDescription:indexPath];
    [dataSourceAccess getItemImage:indexPath];
    [dataSourceAccess getItemAttributes:indexPath];    
}

- (void)mockDataSourceForRange:(NSRange)range sectionsEnabled:(BOOL)sectionsEnabled
{
    [[[dataSource stub] andReturnValue:OCMOCK_VALUE((NSUInteger){[items count]})] count];
    [[[dataSource stub] andCall:@selector(dataSourceInitForRange:) onObject:self] initForRange:range];
    [[[dataSource stub] andCall:@selector(dataSourceGetItemsInRange:) onObject:self] getItemsInRange:range];
    [[[dataSource stub] andCall:@selector(dataSourceGetItemsInRange:) onObject:self] getItemDescriptionsInRange:range];
    [[[dataSource stub] andCall:@selector(dataSourceGetItemsInRange:) onObject:self] getItemImagesInRange:range];
    [[[dataSource stub] andCall:@selector(dataSourceGetItemsInRange:) onObject:self] getItemAttributesInRange:range];
    [[dataSource expect] isLeaf];
    [[dataSource expect] metaCellTitle];
    [[[dataSource stub] andReturnValue:OCMOCK_VALUE((BOOL){sectionsEnabled})] sectionsEnabled];
    if (sectionsEnabled)
    {
        [[[dataSource stub] andReturn:nil] sections];
    }
}

- (void)dataSourceInitForRange:(NSRange)range
{
    initForRangeCalled = YES;
    STAssertFalse(otherRangeMethodsCalled, @"initForRange should only be called before any other range methods");
}

- (NSArray *)dataSourceGetItemsInRange:(NSRange)aRange
{
    otherRangeMethodsCalled = YES;
    return [items subarrayWithRange:aRange];
}

@end