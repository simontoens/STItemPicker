// @author Simon Toens 12/14/12

#import "ItemPickerContext.h"
#import "ItemPickerViewController.h"
#import "Preconditions.h"
#import "TableHeaderViewContainer.h"
#import "TableSectionHandler.h"
#import "TableViewCell.h"
#import "TableViewCellContainer.h"

@interface ItemPickerViewController()
- (void)configureHeaderView;
- (void)configureTitle;
- (id)initWithNibName:(NSString *)nibName dataSource:(id<ItemPickerDataSource>)dataSource;
- (UIImage *)getCellImageForRow:(NSUInteger)row;
- (NSInteger)getItemRow:(NSIndexPath *)indexPath;

/**
 * Returns an array of ItemPickerContext instances.
 */
- (NSArray *)getSelections;
- (ItemPickerContext *)getPreviousSelection;

@property(nonatomic, strong) ItemPickerContext *context;
@property(nonatomic, strong) TableSectionHandler *tableSectionHandler;

@end

@implementation ItemPickerViewController

UIColor *kGreyBackgroundColor;

@synthesize context = _context;
@synthesize itemPickerDelegate;
@synthesize tableSectionHandler = _tableSectionHandler;


- (id)initWithDataSource:(id<ItemPickerDataSource>)dataSource
{
    return [self initWithNibName:@"PlainItemPickerTableView" dataSource:dataSource];
}

- (id)initWithNibName:(NSString *)nibName dataSource:(id<ItemPickerDataSource>)dataSource
{
    if (self = [super initWithNibName:nibName bundle:nil]) 
    {
        _context = [[ItemPickerContext alloc] initWithDataSource:dataSource];
        _tableSectionHandler = [[TableSectionHandler alloc] initWithItems:dataSource.items 
                                                            alreadySorted:dataSource.itemsAlreadySorted];
        _tableSectionHandler.sectionsEnabled = dataSource.sectionsEnabled;
        _tableSectionHandler.itemImages = dataSource.itemImages;

        if (self.tabBarItem) 
        {
            self.title = dataSource.title;
            self.tabBarItem.image = dataSource.tabImage;
        }
    }
    return self;
}


- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation != UIInterfaceOrientationPortraitUpsideDown);
}

-(void)viewDidLoad
{
    [super viewDidLoad];
    [self configureHeaderView];
    [self configureTitle];
}

#pragma mark - UITableViewDelegate methods

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section
{    
    // hack to get rid of empty rows in table view (also see heightForFooterInSection)
    return [[UIView alloc] init];
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    return section == [self.tableSectionHandler.sections count] - 1 ? 1 : 0;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath 
{
    self.context.selectedIndex = [self getItemRow:indexPath];
    self.context.selectedItem = [self.tableSectionHandler.items objectAtIndex:[self getItemRow:indexPath]];
    
    id<ItemPickerDataSource> nextDataSource = [self.context.dataSource getNextDataSourceForSelectedRow:self.context.selectedIndex
                                                                                          selectedItem:self.context.selectedItem];    
    if (nextDataSource) 
    {
        ItemPickerViewController *controller = [[ItemPickerViewController alloc] initWithDataSource:nextDataSource];
        controller.itemPickerDelegate = self.itemPickerDelegate;
        [self.navigationController pushViewController:controller animated:YES];
    } 
    else 
    {
        [self.itemPickerDelegate pickedItem:self.context.selectedItem atIndex:self.context.selectedIndex];
    }
}

#pragma mark - UITableViewDataSource protocol

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView 
{
    return [self.tableSectionHandler.sections count];
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section 
{
    return [self.tableSectionHandler.sections objectAtIndex:section];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section 
{
    NSString *s = [self.tableSectionHandler.sections objectAtIndex:section];
   return [[self.tableSectionHandler.sectionToNumberOfItems objectForKey:s] intValue];
} 

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath 
{  
    int row = [self getItemRow:indexPath];
    UIImage *cellImage = [self getCellImageForRow:row];
    TableViewCell *cell = nil;
    
    if (cellImage)
    {
        cell = [tableView dequeueReusableCellWithIdentifier:[TableViewCellContainer imageTableViewCellIdentifier]];
        if (cell == nil) 
        {
            cell = [TableViewCellContainer newImageTableViewCell];
        }
        cell.iview.image = [self getCellImageForRow:row];
    }
    else 
    {
        cell = [tableView dequeueReusableCellWithIdentifier:[TableViewCellContainer plainTableViewCellIdentifier]];
        if (cell == nil) 
        {
            cell = [TableViewCellContainer newPlainTableViewCell];
        }        
    }
    
    cell.label.text = [self.tableSectionHandler.items objectAtIndex:row];
    return cell; 
}

- (NSArray *)sectionIndexTitlesForTableView:(UITableView *)tableView 
{
    return self.tableSectionHandler.sections;
}

#pragma mark - Private methods

- (UIImage *)getCellImageForRow:(NSUInteger)row
{
    UIImage *cellImage = nil;       
    if (self.tableSectionHandler.itemImages)
    {
        id thing = [self.tableSectionHandler.itemImages objectAtIndex:row];
        if (thing != [NSNull null])
        {
            cellImage = thing;
        }
    }
    return cellImage;
}

- (NSArray *)getSelections
{
    NSMutableArray *selections = [[NSMutableArray alloc] initWithCapacity:[self.navigationController.viewControllers count]];
    for (ItemPickerViewController *vc in self.navigationController.viewControllers) 
    {
        [selections addObject:vc.context];
    }
    return selections;
}

- (ItemPickerContext *)getPreviousSelection
{
    NSArray *selections = [self getSelections];
    return [selections count] >= 2 ? [selections objectAtIndex:[selections count] - 2] : nil;
}

- (ItemPickerContext *)getContextFrom:(NSArray *)selections atOffsetFromEnd:(NSUInteger)offset
{
    return [selections count] > offset ? [selections objectAtIndex:[selections count] - 1 - offset] : nil;
}

- (void)configureHeaderView 
{        
    UIImage *headerImage = self.context.dataSource.headerImage;
    if (headerImage)
    {
        NSArray *selections = [self getSelections];
        NSString *grandfatherSelection = [self getContextFrom:selections atOffsetFromEnd:1].selectedItem;
        NSString *parentSelection = [self getContextFrom:selections atOffsetFromEnd:2].selectedItem;
        NSString *numItems = [NSString stringWithFormat:@"%i %@", [self.tableSectionHandler.items count], self.context.dataSource.title];
        
        self.tableView.tableHeaderView = [TableHeaderViewContainer newTableHeaderView:headerImage label1:grandfatherSelection label2:parentSelection label3:numItems];
    }    
}

- (void)configureTitle 
{
    ItemPickerContext *prevSelection = [self getPreviousSelection];
    self.title = prevSelection ? prevSelection.selectedItem : self.context.dataSource.title;
}

- (NSInteger)getItemRow:(NSIndexPath *)indexPath
{
    NSInteger row = 0;
    for (int i = 0; i < indexPath.section; i++) 
    {
        NSString *s = [self.tableSectionHandler.sections objectAtIndex:i];
        row += [[self.tableSectionHandler.sectionToNumberOfItems objectForKey:s] intValue];
    }
    return row + indexPath.row;
}

@end