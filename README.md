## GT Buses

An iOS app for tracking the Georgia Tech buses.  
More Info: [gtbuses.iminichrispy.com](http://gtbuses.iminichrispy.com)  
Backend: [gtbuses.herokuapp.com](http://gtbuses.herokuapp.com)  
Download: [itunes.apple.com](https://itunes.apple.com/us/app/gt-buses/id815448630?ls=1&mt=8)

## To-Do


iOS 8:
- Add extension
    - Use App Group for sharing data
    - Color circle for indicating bus route
    - Bus stop name with time predictions under it
    - Rotates through stops (two/three at a time)
- Don't use activateConstraints:

In possible update:
- Incorporate notifications (and displaying messages/warning included with stops from API)
- Add ability to search for buildings  
- Space stops that are close together farther apart  
- (BUG) When bus annotation center coordinate is being animated and map view window is changed (pan, pinch), bus animation gets thrown off  
- [mapview removeAllAnnotations] removes all annotations, including user location annotation (Not noticeable)  
- Add list view for viewing buses as a list  
- (BUG) Sometimes, some buses flash visible after switching to different route  
- (BUG) Regions not how they should be on iOS 6 and below  
- (BUG) Closing mail composer changes status bar style on iOS 6 and below  
- Ability to tun off/on certain routes  
- Add a Call Stingerette button: 404-385-7433  
- Add ability to set a timer to be notified when a bus arrives  
    1. User can view predictions for buses and set a timer to be notified  
        - User only has a limited number of bus predictions to go off of  
    2. User selects what time they want to leave by and I use background app refresh to update times and notify accurately  
        - I have no control over how often the app refreshes in the background  
    3. User sets what time they want to leave by and I use a push server that updates time data and sends a push notification to accurately notify them when the bus is there  
        - Requires Internet to send timer  
        - A lot of work to implement  
- Type in where/what building you need to go to: http://gtjourney.gatech.edu/gt-devhub/apis#campusmapapi  
    - http://m.gatech.edu/widget/gtplaces/content/api/buildings
    - Once you find nearest stop, you can get bus routes that stop there
    - Also need to user current location to find nearest stop to you and find out which route to take - including direction
    - What if user has no location?
- Table of current route w/ stop info (makes switchig routes and maintaining list view annoying)
- Change update interval (test optimal)
- Schedule

## Done

v1.0
- Add images instead of dropped pins for bus stops
- Add retrieving bus positions
- Refresh bus positions/predictions every five seconds
- Add color for bus positions
- Bus position image rotation for bus direction
- Add retrieving bus predictions
- (BUG) Occasionally crashed due to MKUserLocation?
- (BUG) When bus goes inactive, it is not removed from view
- Account for situation where less than 3 predictions are given - emory route
- iOS 6 segmented control is bigger than it should be
- Better error handling
- Icon
- Default.png
- Should request right away (See when requests are made, didload, didenterbg)
- Start new project with map view and just setting coordinates to see if it works
- Add iOS 5 support
- Add about info

v1.1
- Fix iTunes library image artwork containing gloss effects
- What if you're saving selected route index between launches and one day, there's only one route returned by server and index was for 3?
- In iTunes Connect tags, change 'gt' to 'ga'
- iPad support
- Reduce # of Map/CPU rendering cycles
- Add Review App button in sidebar
- The status bars on the App Store Screens are wrong (cell signal and about button lower than it should be)
- iPad Default.png images

v1.1.1
- Test regionthatfits ios 6
- Added "No Predictions" default subtitle for annotation
- Glc route now fits better on map (including all routes)
- Drop iOS 5 support for auto layout
- Consolidate all request handler changes over HousePoints, StreamTester
- Top segmented control bar now properly centered (padding 6 instead of 5)
- Top segmented control bar now slightly bigger (more tappable)
- iOS 8 location request
- [Debug] Label buses with bus identifier
- Make sure rotating on iPad works (Starting in landscape, etc)
- [CLLocationManager requestWhenInUseAuthorization], also in Info.plist: Privacy - Location Usage Description
- Custom tint colors
- Updated for iPhone 6/iPhone 6 Plus
- Switched to image assets & added more image sizes
- Bigger bus arrows on iPad
- 3x images

v1.1.2
- [Debug] Show stop ids on stop annotation
- [Debug] Display predictions in minutes & seconds
- [Debug] Added Reset, Stops, and Party button items to toolbar
- [Debug] Added CPU graph
- Now using GT Buses heroku backend
    - Routes no longer take a week to update
- About Controller now uses auto layout
- Review App button changes to Update Now in About controller when new version is available
- Sped up animation time when switching routes


## Debug Target Differences

- Bus stops display stop id's
- Predictions displayed in minutes & seconds
- Buses labeled with bus identifier
- Toolbar for reset, party, and updating stops
- CPU graph
