//
//  MainViewController.m
//  interview
//
//  Created by 김규완 on 12. 7. 31..
//  Copyright (c) 2012년 김규완. All rights reserved.
//

#import "MainViewController.h"
#import "FriendViewController.h"
#import "TalkListViewController.h"
#import "FriendAddViewController.h"
#import "SettingViewController.h"
#import "TalkViewController.h"

@interface MainViewController ()

@end

@implementation MainViewController

@synthesize tabController, naviController, loginController, isRotate;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    isRotate = NO;
    
    UIColor *backImg = [[UIColor alloc] initWithPatternImage:[UIImage imageNamed:@"main_bg"]];
    self.view.backgroundColor = backImg;
    [backImg release];
    
    
    
    /*
    UITabBarController *tab = [[UITabBarController alloc] init];
    tab.customizableViewControllers = nil;
    FriendViewController *tab1 = [[FriendViewController alloc] initWithNibName:@"FriendViewController" bundle:nil];
    [[tab1 tabBarItem] setImage:[UIImage imageNamed:@"108-Group"]];
    [[tab1 tabBarItem] setTitle:@"친구"];
    
    
    TalkListViewController *tab2 = [[TalkListViewController alloc] initWithNibName:@"TalkListViewController" bundle:nil];
    [[tab2 tabBarItem] setImage:[UIImage imageNamed:@"036-SMS"]];
    [[tab2 tabBarItem] setTitle:@"채팅"];
    
    FriendAddViewController *tab3 = [[FriendAddViewController alloc] initWithNibName:@"FriendAddViewController" bundle:nil];
    [[tab3 tabBarItem] setImage:[UIImage imageNamed:@"105-AddUser"]];
    [[tab3 tabBarItem] setTitle:@"친구찾기"];
    
    SettingViewController *tab4 = [[SettingViewController alloc] initWithNibName:@"SettingViewController" bundle:nil];
    [[tab4 tabBarItem] setImage:[UIImage imageNamed:@"073-Setting"]];
    [[tab4 tabBarItem] setTitle:@"설정"];
    
    tab.viewControllers = [NSArray arrayWithObjects:tab1, tab2, tab3, tab4, nil];
    //tab.tabBar.backgroundImage = [UIImage imageNamed:@"tabbar_bg"];
    [tab1 release];
    [tab2 release];
    [tab3 release];
    [tab4 release];
    
    self.tabController = tab;
    [[self tabController] setDelegate:self];
    
    [tab release];
    
    UINavigationController *navi = [[UINavigationController alloc] initWithRootViewController:self.tabBarController];
    self.naviController = navi;
    
    [navi release];
    
    [self.view addSubview:self.naviController.view];
    */
    
    //탭 컨트롤러 등록
	if (self.tabController.view.superview == nil) {

		if (tabController == nil) {
            UITabBarController *tab = [[UITabBarController alloc] init];
			tab.customizableViewControllers = nil;
            
            
            
            
            
            //UIImage *naviBg = [UIImage imageNamed:@"nav_back"];
            
            FriendViewController *tab1 = [[FriendViewController alloc] initWithNibName:@"FriendViewController" bundle:nil];
            UINavigationController *tab1Navi = [[UINavigationController alloc] initWithRootViewController:tab1];
            [tab1 release];
            
            [[tab1Navi tabBarItem] setImage:[UIImage imageNamed:@"108-Group"]];
            [[tab1Navi tabBarItem] setTitle:@"친구"];
            
            //if([tab1Navi.navigationBar respondsToSelector:@selector(setBackgroundImage:forBarMetrics:)]) {
            //    [tab1Navi.navigationBar setBackgroundImage:naviBg forBarMetrics:UIBarMetricsDefault];
            //}
            
            TalkListViewController *tab2 = [[TalkListViewController alloc] initWithNibName:@"TalkListViewController" bundle:nil];
            UINavigationController *tab2Navi = [[UINavigationController alloc] initWithRootViewController:tab2];
            [[tab2Navi tabBarItem] setImage:[UIImage imageNamed:@"036-SMS"]];
            [[tab2Navi tabBarItem] setTitle:@"채팅"];
            [tab2 release];
            
            //if([tab2Navi.navigationBar respondsToSelector:@selector(setBackgroundImage:forBarMetrics:)]) {
            //    [tab2Navi.navigationBar setBackgroundImage:naviBg forBarMetrics:UIBarMetricsDefault];
            //}
            
            FriendAddViewController *tab3 = [[FriendAddViewController alloc] initWithNibName:@"FriendAddViewController" bundle:nil];
            UINavigationController *tab3Navi = [[UINavigationController alloc] initWithRootViewController:tab3];
            [[tab3Navi tabBarItem] setImage:[UIImage imageNamed:@"105-AddUser"]];
            [[tab3Navi tabBarItem] setTitle:@"친구찾기"];
            [tab3 release];
            
            //if([tab3Navi.navigationBar respondsToSelector:@selector(setBackgroundImage:forBarMetrics:)]) {
            //    [tab3Navi.navigationBar setBackgroundImage:naviBg forBarMetrics:UIBarMetricsDefault];
            //}
            
                        
            SettingViewController *setting = [[SettingViewController alloc] initWithNibName:@"SettingViewController" bundle:nil];
            UINavigationController *tab4Navi = [[UINavigationController alloc] initWithRootViewController:setting];
            [[tab4Navi tabBarItem] setImage:[UIImage imageNamed:@"073-Setting"]];
            [[tab4Navi tabBarItem] setTitle:@"설정"];
            [setting release];
            
            //if([tab5Navi.navigationBar respondsToSelector:@selector(setBackgroundImage:forBarMetrics:)]) {
            //    [tab5Navi.navigationBar setBackgroundImage:naviBg forBarMetrics:UIBarMetricsDefault];
            //}
            
            //[naviBg release];
            //naviBg = nil;
            
            tab.viewControllers = [NSArray arrayWithObjects:tab1Navi, tab2Navi, tab3Navi, tab4Navi, nil];
            //tab.tabBar.backgroundImage = [UIImage imageNamed:@"tabbar_bg"];
            [tab1Navi release];
            [tab2Navi release];
            [tab3Navi release];
            [tab4Navi release];
            
            self.tabController = tab;
            [[self tabController] setDelegate:self];
            
            [tab release];
     
        }
    }
    
    [self.view addSubview:self.tabController.view];
    

}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [self.tabController viewWillAppear:animated];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
    self.loginController = nil;
    self.tabController = nil;
    self.naviController = nil;
}

- (void)dealloc
{
    [loginController release];
    [tabController release];
    [naviController release];
    [super dealloc];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
    /*
    if(isRotate){
        return (interfaceOrientation == UIInterfaceOrientationLandscapeRight || interfaceOrientation == UIInterfaceOrientationPortrait);
    } else {
        return (interfaceOrientation == UIInterfaceOrientationPortrait);
    }
    */
    //return isRotate;
}


#pragma mark -
#pragma mark Custom Method



//로그인 화면으로 변경
- (void)switchLoginView {
    
	if (self.loginController.view.superview == nil) {
		if (self.loginController == nil) {
			LoginViewController *loginView = [[LoginViewController alloc]
											  initWithNibName:@"LoginViewController"
											  bundle:nil];
			self.loginController = loginView;
			//CGRect newFrame =  [[[mClassAppDelegate sharedAppDelegate] window] frame];
			//self.loginController.view.frame = newFrame;
			[loginView release];
			
		}
	}
	
	[self.view addSubview:self.loginController.view];
	
}

//대화 화면으로 변경
- (void)switchTalkView:(NSInteger)masterUid {
    
    if (self.naviController.view.superview == nil) {
        if(self.naviController == nil) {
            TalkViewController *talkViewController = [[TalkViewController alloc] initWithNibName:@"TalkViewController" bundle:nil];
            talkViewController.talkUid = masterUid;
            UINavigationController *navi = [[UINavigationController alloc] initWithRootViewController:talkViewController];
            self.naviController = navi;
            [navi release];
            [talkViewController release];
        }
    }
    
    [self.view addSubview:self.naviController.view];
    
}

- (void)switchTabView:(NSInteger)tabIndex
{
    if (self.loginController.view.superview != nil) {
		[self.loginController.view removeFromSuperview];
	}
	
	if (self.naviController.view.superview != nil) {
		[self.naviController.view removeFromSuperview];
	}
	
    
	[self.view addSubview:self.tabController.view];
	self.tabController.selectedIndex = tabIndex;
    [self.tabController viewWillAppear:NO];
}

#pragma mark -
#pragma mark UITabBarControllerDelegate
- (void)tabBarController:(UITabBarController *)tabBarController didSelectViewController:(UIViewController *)viewController {
	//[viewController viewWillAppear:NO];
}


#pragma mark -
#pragma mark UINavigationControllerDelegate
- (void)navigationController:(UINavigationController *)navigationController  willShowViewController:(UIViewController *)viewController animated:(BOOL)animated {
    //[viewController viewWillAppear:animated];
}


@end
