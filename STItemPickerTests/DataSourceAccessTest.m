// @author Simon Toens 06/02/13

#import <OCMock/OCMock.h>
#import <SenTestingKit/SenTestingKit.h>
#import "DataSourceAccess.h"
#import "ItemPickerDataSource.h"

@interface DataSourceAccessTest : SenTestCase
{
    @private
    NSArray *items;
    NSArray *itemDescriptions;
    NSArray *itemImages;
    NSArray *itemAttributes;
    id dataSource;
    DataSourceAccess *dataSourceAccess;
    
    BOOL initForRangeCalled;
    BOOL otherRangeMethodsCalled;
}
@end

@implementation DataSourceAccessTest

- (void)setUp
{
    [super setUp];
    items = @[@"2", @"1"];
    dataSource = [OCMockObject mockForProtocol:@protocol(ItemPickerDataSource)];
    dataSourceAccess = [[DataSourceAccess alloc] initWithDataSource:dataSource autoSelected:NO];
    dataSourceAccess.itemCacheSize = 1;
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

- (void)assertPropertyValue:(SEL)property atIndex:(int)index expectedValue:(id)expectedValue
{
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:index inSection:0];
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
    id val = [dataSourceAccess performSelector:property withObject:indexPath];
#pragma clang diagnostic pop        

    if (expectedValue == [NSNull null])
    {
        STAssertNil(val, @"Expected nil but got %@", val);    
    }
    else
    {
        STAssertEquals(val, expectedValue, @"Unexpected desc");
    }
}

- (void)testNSNullForDescriptions
{
    itemDescriptions = @[[NSNull null], @"desc"];
    [self mockDataSourceForRange:NSMakeRange(0, 2) sectionsEnabled:YES];    
    
    [self assertPropertyValue:@selector(getItemDescription:) atIndex:0 expectedValue:@"desc"];        
    [self assertPropertyValue:@selector(getItemDescription:) atIndex:1 expectedValue:[NSNull null]];
}

- (void)testNSNullForImages
{
    itemImages = @[[NSNull null]];
    [self mockDataSourceForRange:NSMakeRange(0, 1) sectionsEnabled:NO];    
    [self assertPropertyValue:@selector(getItemImage:) atIndex:0 expectedValue:[NSNull null]];        
}

- (void)testNSNullForAttributes
{
    itemAttributes = @[[NSNull null]];
    [self mockDataSourceForRange:NSMakeRange(0, 1) sectionsEnabled:NO];    
    [self assertPropertyValue:@selector(getItemAttributes:) atIndex:0 expectedValue:[NSNull null]];            
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
    [[[dataSource stub] andCall:@selector(dataSourceGetDescriptionsInRange:) onObject:self] getItemDescriptionsInRange:range];
    [[[dataSource stub] andCall:@selector(dataSourceGetImagesInRange:) onObject:self] getItemImagesInRange:range];
    [[[dataSource stub] andCall:@selector(dataSourceGetAttributesInRange:) onObject:self] getItemAttributesInRange:range];
    [[dataSource expect] isLeaf];
    [[dataSource expect] metaCellTitle];
    [[dataSource expect] metaCellDescription];
    [[[dataSource stub] andReturnValue:OCMOCK_VALUE((BOOL){sectionsEnabled})] sectionsEnabled];
    if (sectionsEnabled)
    {
        [[[dataSource stub] andReturn:nil] sections];
    }
}

- (void)dataSourceInitForRange:(NSRange)range
{
    initForRangeCalled = YES;
    STAssertFalse(otherRangeMethodsCalled, @"initForRange should be called before any other range methods");
}

- (NSArray *)dataSourceGetItemsInRange:(NSRange)range
{
    otherRangeMethodsCalled = YES;
    return [items subarrayWithRange:range];
}

- (NSArray *)dataSourceGetDescriptionsInRange:(NSRange)range 
{
    return itemDescriptions ? [itemDescriptions subarrayWithRange:range] : [self dataSourceGetItemsInRange:range];
}

- (NSArray *)dataSourceGetImagesInRange:(NSRange)range 
{
    return itemImages ? [itemImages subarrayWithRange:range] : [self dataSourceGetItemsInRange:range];
}

- (NSArray *)dataSourceGetAttributesInRange:(NSRange)range 
{
    return itemAttributes ? [itemAttributes subarrayWithRange:range] : [self dataSourceGetItemsInRange:range];
}

@end
