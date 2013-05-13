// @author Simon Toens 12/14/12

#import "ItemPickerContext.h"
#import "ItemPickerViewController.h"
#import "Preconditions.h"
#import "Stack.h"
#import "TableHeaderViewContainer.h"
#import "TableSectionHandler.h"
#import "TableViewCell.h"
#import "TableViewCellContainer.h"

@interface ItemPickerViewController()
- (id)initWithDataSource:(id<ItemPickerDataSource>)dataSource items:(NSArray *)items contextStack:(Stack *)contextStack;
- (id)initWithNibName:(NSString *)nibName dataSource:(id<ItemPickerDataSource>)dataSource items:(NSArray *)items contextStack:(Stack *)contextStack;

- (void)configureHeaderView;
- (void)configureNavigationItem;
- (void)configureTableSectionHandler;
- (void)configureTitle;

- (UIImage *)getCellImageForRow:(NSUInteger)row;
- (ItemPickerContext *)getItemPickerContext:(NSIndexPath *)indexPath 
                                      items:(NSArray *)items 
                                 dataSource:(id<ItemPickerDataSource>)dataSource
                               autoSelected:(BOOL)autoSelected;
- (NSInteger)getItemRow:(NSIndexPath *)indexPath;
- (ItemPickerContext *)getPreviousContext;
- (void)handleSelection:(NSIndexPath *)indexPath;
- (BOOL)isCellSelectedAtIndexPath:(NSIndexPath *)indexPath;
- (void)pushDataSource:(id<ItemPickerDataSource>)dataSource;
- (void)selectedItemAtIndexPath:(NSIndexPath *)indexPath 
                  fromItems:(NSArray *)items 
                 dataSource:(id<ItemPickerDataSource>)dataSource 
               autoSelected:(BOOL)autoSelected;
- (void)updateViewState;

@property(nonatomic, strong) Stack *contextStack;
@property(nonatomic, strong) id<ItemPickerDataSource> dataSource;
@property(nonatomic, weak) UIBarButtonItem *doneButton;
@property(nonatomic, strong) NSArray *items;
@property(nonatomic, strong) NSMutableArray *selectedItems;
@property(nonatomic, strong) TableSectionHandler *tableSectionHandler;

@end

@implementation ItemPickerViewController

UIColor *kGreyBackgroundColor;

@synthesize contextStack = _contextStack;
@synthesize dataSource = _dataSource;
@synthesize doneButton;
@synthesize items = _items;
@synthesize itemPickerDelegate;
@synthesize maxSelectableItems = _maxSelectableItems;
@synthesize selectedItems = _selectedItems;
@synthesize showCancelButton = _showCancelButton;
@synthesize tableSectionHandler = _tableSectionHandler;


- (id)initWithDataSource:(id<ItemPickerDataSource>)dataSource
{
    return [self initWithDataSource:dataSource items:nil contextStack:[[Stack alloc] init]];    
}

- (id)initWithDataSource:(id<ItemPickerDataSource>)dataSource items:(NSArray *)items contextStack:(Stack *)contextStack
{
    return [self initWithNibName:@"PlainItemPickerTableView" dataSource:dataSource items:items contextStack:contextStack];
}

- (id)initWithNibName:(NSString *)nibName 
           dataSource:(id<ItemPickerDataSource>)dataSource 
                items:(NSArray *)items 
         contextStack:(Stack *)contextStack
{
    if (self = [super initWithNibName:nibName bundle:nil]) 
    {
        _contextStack = contextStack;
        _dataSource = dataSource;
        _items = items;
        
        _maxSelectableItems = 1;
        _selectedItems = [[NSMutableArray alloc] init];
        _showCancelButton = NO;

        if (self.tabBarItem) 
        {
            self.title = dataSource.title;
            self.tabBarItem.image = dataSource.tabImage;
        }
    }
    return self;
}


#pragma mark - UIViewController

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation != UIInterfaceOrientationPortraitUpsideDown);
}

- (void)viewDidLoad
{
    [super viewDidLoad];    
    [self configureTableSectionHandler];
    [self configureHeaderView];
    [self configureNavigationItem];
    [self configureTitle];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self updateViewState];
}

- (void)viewWillDisappear:(BOOL)animated {
    if ([self.navigationController.viewControllers indexOfObject:self] == NSNotFound) 
    {
        while ([[self.contextStack pop] autoSelected]);
    }
    [super viewWillDisappear:animated];
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
    [self selectedItemAtIndexPath:indexPath fromItems:self.tableSectionHandler.items dataSource:self.dataSource autoSelected:NO];
}

#pragma mark - UITableViewDataSource protocol

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView 
{
    return [self.tableSectionHandler.sections count];
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section 
{
    return [[self.tableSectionHandler.sections objectAtIndex:section] title];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section 
{
    NSRange range = [[self.tableSectionHandler.sections objectAtIndex:section] range];
    return range.length;
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
    cell.accessoryType = [self isCellSelectedAtIndexPath:indexPath] ? UITableViewCellAccessoryCheckmark : UITableViewCellAccessoryNone;
    return cell; 
}

- (NSArray *)sectionIndexTitlesForTableView:(UITableView *)tableView 
{
    return self.tableSectionHandler.sectionTitles;
}

#pragma mark - Private methods

- (void)updateViewState
{
    self.doneButton.enabled = [self.selectedItems count] > 0;
}

- (void)onMultiSelectDone
{
    [self.itemPickerDelegate onPickItems:self.selectedItems];
}

- (BOOL)isCellSelectedAtIndexPath:(NSIndexPath *)indexPath
{
    // review how we determine that a cell has been previously selected - 
    // this is creating a lot of ItemPickerContext instances
    ItemPickerContext *ctx = [self getItemPickerContext:indexPath items:self.tableSectionHandler.items dataSource:self.dataSource autoSelected:NO];
    [self.contextStack push:ctx];
    NSArray *selectionPath = [self.contextStack allObjects];
    BOOL selected = [self.selectedItems containsObject:selectionPath];
    [self.contextStack pop];
    return selected;
}

- (ItemPickerContext *)getItemPickerContext:(NSIndexPath *)indexPath 
                                      items:(NSArray *)items 
                                 dataSource:(id<ItemPickerDataSource>)dataSource
                               autoSelected:(BOOL)autoSelected
{
    int selectedIndex = [self getItemRow:indexPath];
    ItemPickerContext *ctx = [[ItemPickerContext alloc] initWithDataSource:dataSource];
    ctx.selectedIndex = selectedIndex;
    ctx.selectedItem = [items objectAtIndex:selectedIndex];
    ctx.autoSelected = autoSelected;
    return ctx;
}

- (void)selectedItemAtIndexPath:(NSIndexPath *)indexPath
                  fromItems:(NSArray *)items 
                 dataSource:(id<ItemPickerDataSource>)dataSource 
               autoSelected:(BOOL)autoSelected
{
    ItemPickerContext *ctx = [self getItemPickerContext:indexPath items:items dataSource:dataSource autoSelected:autoSelected];
    [self.contextStack push:ctx];
    
    id<ItemPickerDataSource> nextDataSource = [dataSource getNextDataSourceForSelectedRow:ctx.selectedIndex
                                                                             selectedItem:ctx.selectedItem];        
    if (nextDataSource)
    {
        [self pushDataSource:nextDataSource];    
    } 
    else
    {
        [self handleSelection:indexPath];
    }
}

- (void)handleSelection:(NSIndexPath *)indexPath
{
    if (self.maxSelectableItems > 1)
    {
        UITableViewCell* cell = [self.tableView cellForRowAtIndexPath:indexPath];            
        NSArray *selectionPath = [self.contextStack allObjects];            
        if ([self.selectedItems containsObject:selectionPath])
        {
            [self.selectedItems removeObject:selectionPath];
            cell.accessoryType = UITableViewCellAccessoryNone;
        }
        else
        {
            if ([self.selectedItems count] < self.maxSelectableItems)
            {
                [self.selectedItems addObject:[selectionPath copy]];
                cell.accessoryType = UITableViewCellAccessoryCheckmark;    
            }
        }
        [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
        [self.contextStack pop];
        [self updateViewState];
    }
    else
    {
        [self.itemPickerDelegate onPickItems:[NSArray arrayWithObject:[self.contextStack allObjects]]];
    }
}

- (void)pushDataSource:(id<ItemPickerDataSource>)dataSource
{
    NSArray *items = dataSource.items;
    
    if (dataSource.autoSelectSingleItem)
    {
        if ([items count] == 1)
        {
            NSIndexPath *indexPath = [NSIndexPath indexPathForRow:0 inSection:0];
            [self selectedItemAtIndexPath:indexPath fromItems:items dataSource:dataSource autoSelected:YES];
            return;
        }
    }
    
    ItemPickerViewController *controller = [[ItemPickerViewController alloc] initWithDataSource:dataSource 
                                                                                          items:items
                                                                                   contextStack:self.contextStack];
    controller.itemPickerDelegate = self.itemPickerDelegate;
    controller.maxSelectableItems = self.maxSelectableItems;
    controller.selectedItems = self.selectedItems;
    controller.showCancelButton = self.showCancelButton;
    [self.navigationController pushViewController:controller animated:YES];    
}

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

- (ItemPickerContext *)getPreviousContext
{
    NSArray *contexts = [self.contextStack allObjects];
    return [contexts count] > 0 ? [contexts objectAtIndex:[contexts count] - 1] : nil;
}

- (ItemPickerContext *)getContextFrom:(NSArray *)contexts atOffsetFromEnd:(NSUInteger)offset
{
    return [contexts count] > offset ? [contexts objectAtIndex:[contexts count] - 1 - offset] : nil;
}

- (void)configureTableSectionHandler
{
    if (!self.items)
    {
        self.items = self.dataSource.items;
    }
    self.tableSectionHandler = [[TableSectionHandler alloc] initWithItems:self.items sections:self.dataSource.sections];
    self.tableSectionHandler.sectionsEnabled = self.dataSource.sectionsEnabled;
    self.tableSectionHandler.itemImages = self.dataSource.itemImages;
}

- (void)configureHeaderView 
{        
    UIImage *headerImage = self.dataSource.headerImage;
    if (headerImage)
    {
        NSArray *contexts = [self.contextStack allObjects];
        NSString *grandfatherSelection = [self getContextFrom:contexts atOffsetFromEnd:1].selectedItem;
        NSString *parentSelection = [self getContextFrom:contexts atOffsetFromEnd:0].selectedItem;
        NSString *numItems = [NSString stringWithFormat:@"%i %@", [self.tableSectionHandler.items count], self.dataSource.title];
        
        self.tableView.tableHeaderView = [TableHeaderViewContainer newTableHeaderView:headerImage label1:grandfatherSelection label2:parentSelection label3:numItems];
    }
}

- (void)configureTitle 
{
    ItemPickerContext *prevSelection = [self getPreviousContext];
    self.title = prevSelection ? prevSelection.selectedItem : self.dataSource.title;
}

- (void)configureNavigationItem
{
    UIBarButtonItem *button = nil, *cancelButton = nil;
    
    if (self.maxSelectableItems > 1)
    {
        button = self.doneButton = [[UIBarButtonItem alloc] initWithTitle:@"Done" style:UIBarButtonItemStyleBordered 
                                                                   target:self
                                                                   action:@selector(onMultiSelectDone)];
        [self updateViewState];
    }
    
    if (self.showCancelButton)
    {
        button = cancelButton = [[UIBarButtonItem alloc] initWithTitle:@"Cancel" style:UIBarButtonItemStyleBordered 
                                                                target:self.itemPickerDelegate
                                                                action:@selector(onCancel)];
    }
    
    if (doneButton && cancelButton)
    {
        self.navigationItem.rightBarButtonItems = [NSArray arrayWithObjects:cancelButton, doneButton, nil];    
    }
    else
    {
        self.navigationItem.rightBarButtonItem = button;
    }
}

- (NSInteger)getItemRow:(NSIndexPath *)indexPath
{
    NSInteger row = 0;
    for (int i = 0; i < indexPath.section; i++) 
    {
        NSRange range = [[self.tableSectionHandler.sections objectAtIndex:i] range];
        row += range.length;
    }
    return row + indexPath.row;
}

@end