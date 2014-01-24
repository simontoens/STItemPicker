// @author Simon Toens 03/23/13

#import <SenTestingKit/SenTestingKit.h>

#import "ItemAttributes.h"
#import "TableSectionHandler.h"
#import "Tuple.h"

@interface SectionItem : NSObject
@property (nonatomic, strong) NSString *title;
@property (nonatomic, assign) NSRange range;
@end

@implementation SectionItem
@synthesize title, range;
@end

@interface TableSectionHandlerTest : SenTestCase
@end

@implementation TableSectionHandlerTest

- (void)testBasicSections 
{
    [self runTestItems:@[@"a", @"b", @"c"]
      expectedSections:@[@"A", @"B", @"C"]
    expectedItemCounts:(int[]){1, 1, 1}];
    
    [self runTestItems:@[@"aa", @"bb", @"cc"]
      expectedSections:@[@"A", @"B", @"C"]
    expectedItemCounts:(int[]){1, 1, 1}];
    
    [self runTestItems:@[@"aa", @"bb", @"cc", @"ccc"]
      expectedSections:@[@"A", @"B", @"C"]
    expectedItemCounts:(int[]){1, 1, 2}];
    
    [self runTestItems:@[@"aa", @"AABB", @"AACC", @"cc", @"ccc", @"CCCAA"]
      expectedSections:@[@"A",@"C"]
    expectedItemCounts:(int[]){3, 3}];
}

- (void)testNonEnglishAlphabetSections
{
    [self runTestItems:@[@"äa", @"ÄB", @"éa", @"üC", @"ßa", @"øa", @"Øa", @"åa", @"Å", @"Œa", @"Ücc", @"あんまり", @"œa", @"öc", @"ça", @"Ça", @"ÖB"]
      expectedSections:@[@"A", @"C", @"E", @"O", @"S", @"U", kTableSectionHandlerNonLatinLetterSymbolHeader]
    expectedItemCounts:(int[]){4, 2, 1, 6, 1, 2, 1}];
    
    [self runTestItems:@[@"(äÄÜ)"]
      expectedSections:@[@"A"]
    expectedItemCounts:(int[]){1}];
}

- (void)testNumberSections 
{
    [self runTestItems:@[@"3", @"3003"]
      expectedSections:@[kTableSectionHandlerNumberHeader]
    expectedItemCounts:(int[]){2}];
}

- (void)testSymbolSections 
{
    [self runTestItems:@[@"*a", @"(zzz)", @"!44", @"@444", @"%$#"]
      expectedSections:@[kTableSectionHandlerSymbolHeader, kTableSectionHandlerNumberHeader, @"A", @"Z"]
    expectedItemCounts:(int[]){1, 2, 1, 1}];
}

- (void)testAllLetters 
{
    NSString *alphabet = @"abcdefghijklmnopqrstuvwxyz";
    STAssertEquals([alphabet length], (NSUInteger)26, @"bad number of letters");
    NSMutableArray *lowerCaseItems = [NSMutableArray arrayWithCapacity:[alphabet length]];
    NSMutableArray *upperCaseItems = [NSMutableArray arrayWithCapacity:[alphabet length]];
    int counts[[alphabet length]];
    for (int i = 0; i < [alphabet length]; i++) 
    {
        NSRange r;
        r.location = i;
        r.length = 1;
        counts[i] = 1;
        NSString *letter = [alphabet substringWithRange:r];
        [lowerCaseItems addObject:[letter lowercaseString]];
        [upperCaseItems addObject:[letter uppercaseString]];
    }

    [self runTestItems:lowerCaseItems expectedSections:upperCaseItems expectedItemCounts:counts];
    [self runTestItems:upperCaseItems expectedSections:upperCaseItems expectedItemCounts:counts];
}

- (void)testAllNumbers 
{
    NSString *numbers = @"0123456789";
    NSMutableArray *items = [NSMutableArray arrayWithCapacity:[numbers length]];
    for (int i = 0; i < [numbers length]; i++) {
        NSRange r;
        r.location = i;
        r.length = 1;
        [items addObject:[numbers substringWithRange:r]];
    }
    
    [self runTestItems:items 
      expectedSections:@[kTableSectionHandlerNumberHeader]
    expectedItemCounts:(int[]){10}];
}

- (void)testItemImagesSort 
{
    NSArray *items = @[@"3", @"2", @"1"];
    NSArray *images = @[@"aa", @"bb", @"cc"];
    TableSectionHandler *handler = [[TableSectionHandler alloc] initWithItems:items];
    handler.itemImages = images;

    NSArray *expectedItems = @[@"1", @"2", @"3"];
    STAssertEqualObjects(handler.items, expectedItems, @"Bad sort order");
    
    NSArray *expectedImages = @[@"cc", @"bb", @"aa"];
    STAssertEqualObjects(handler.itemImages, expectedImages, @"Bad sort order");
}

- (void)testItemDescriptionsSort 
{
    NSArray *items = @[@"3", @"2", @"1", @"3"];
    NSArray *descriptions = @[@"aa", @"bb", @"cc", @"dd"];
    TableSectionHandler *handler = [[TableSectionHandler alloc] initWithItems:items];
    handler.itemDescriptions = descriptions;
    
    NSArray *expectedItems = @[@"1", @"2", @"3", @"3"];
    STAssertEqualObjects(handler.items, expectedItems, @"Bad sort order");
    
    NSArray *expectedDescriptions = @[@"cc", @"bb", @"aa", @"dd"];
    STAssertEqualObjects(handler.itemDescriptions, expectedDescriptions, @"Bad sort order");
}

- (void)testItemAttributesSort
{
    ItemAttributes *a1 = [[ItemAttributes alloc] init];
    ItemAttributes *a2 = [[ItemAttributes alloc] init];
    ItemAttributes *a3 = [[ItemAttributes alloc] init];
    NSArray *items = @[@"3", @"1", @"2"];
    NSArray *ItemAttributes = @[a1, a2, a3];
    TableSectionHandler *handler = [[TableSectionHandler alloc] initWithItems:items];
    handler.ItemAttributes = ItemAttributes;
    
    NSArray *expectedItems = @[@"1", @"2", @"3"];
    STAssertEqualObjects(handler.items, expectedItems, @"Bad sort order");
    
    NSArray *expectedAttributes = @[a2, a3, a1];
    STAssertEqualObjects(handler.itemAttributes, expectedAttributes, @"Bad sort order");
}

- (void)runTestItems:(NSArray *)items
    expectedSections:(NSArray *)expectedSections 
  expectedItemCounts:(int[])expectedItemCounts 
{
    TableSectionHandler *handler = [[TableSectionHandler alloc] initWithItems:items];
    [self runTestItems:expectedSections expectedItemCounts:expectedItemCounts tableSectionHandler:handler];
}

- (void)runTestItems:(NSArray *)expectedSections 
  expectedItemCounts:(int[])expectedItemCounts 
 tableSectionHandler:(TableSectionHandler *)handler
{
    STAssertEquals([handler.sections count], [expectedSections count], @"Unexpected number of sections");

    int expectedLocation = 0;
    for (int numSection = 0; numSection < [handler.sections count]; numSection++) {
        id section = [handler.sections objectAtIndex:numSection];
        NSString *title = [section title];
        NSRange range = [section range];
        STAssertEqualObjects(title, [expectedSections objectAtIndex:numSection], @"Unexpected section title for section: %@", section);        
        STAssertEquals(range.location, (NSUInteger)expectedLocation, @"Unexpected section location for section: %@", section);
        STAssertEquals(range.length, (NSUInteger)expectedItemCounts[numSection], @"Unexpected item count for section: %@", section);
        expectedLocation += range.length;
    }
}

@end
