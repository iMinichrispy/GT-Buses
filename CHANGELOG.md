## Changelog

#### App Store Changelog

##### 2.0
- 2 Notification Center widgets for easy access to time predictions for nearby stops, as well as your favorite stops
- Ability to search for campus buildings and see where they are on the map
- New Settings screen for:
    - Changing time prediction format
    - Showing bus identifiers
    - Toggling routes on/off
- Switched to new server, so routes no longer take a week to update
    - All requests now made over HTTPS

##### 1.1.1
- Optimized for iOS 8, iPhone 6/6+
- GLC route now fits better on map (and if new routes are added in the future, they will also now automatically be fitted properly)
- Many behind the scenes improvements & bug fixes

##### 1.1
- Now a universal app w/ iPad support
- Reduced rendering cycles & improved efficiency
- Added "Review App" button in About menu
- Fixed potential crash, should number of routes ever change
- App icon artwork now displays correctly in iTunes

#### Detailed Changelog

##### 2.0
- Bus stop idendifiers shown on stop annotation
- Now using GT Buses heroku backend
    - Routes no longer take a week to update
- About Controller now uses auto layout
- Review App button changes to Update Now in About controller when new version is available
- Sped up animation time when switching between routes
- Bus arrow image and stop dot image now rendered on device (no longer a png)
- Added search buildings ability
- Moved refresh button to bus route control
- Ensured buses always appear above stops
- Notification center widget for bus predictions
- Replaced About view with Settings view, changed presentation (R.I.P. hamburger menu)
- Enabled orientation changes on iPhone 6 Plus
- All user-facing strings now localized w/ NSLocalizedString
- Restructured request handler errors as NSErrors
- Added blur effect to search table
- Split up extension into 2: favorites and nearby
- Tap and hold building cell to call phone, copy address
- Switched to better way of calculating map region for route - also allowed for re-enabling alpha on bus route control
- Buildings saved on device and also updated from server when buildings data version changes
- Added settings: arrival vs time until, showing bus identifiers
- Added custom URL scheme (gtbuses://), and support for changing agency via url
- Switched to using pdfs instead of pngs for images
- Added ability to toggle routes for route control and nearby widget
- Ability to change nextbus agency
- Buildings now custom to agencies
- Buidings cached on device, removed buildings version number

##### 1.1.1
- Added "No Predictions" default subtitle for annotation
- Region calculation for route now more accurate & no longer partially hard-coded - fixes GLC route
- Switched to auto layout, dropped iOS 5 support
- Consolidated all RequestHandler changes over various projects
- Top segmented control bar now properly centered (padding 6 instead of 5)
- Top segmented control bar now slightly bigger (more tappable)
- [Debug] Buses labeled  with bus identifier
- Updated for iOS 8 user location request - [CLLocationManager requestWhenInUseAuthorization]
- Custom tint colors
- Updated for iPhone 6/6+
- Switched to image assets & added more image sizes (3x for iPhone 6+)
- Bigger bus arrows on iPad

##### 1.1
- Fixed iTunes library image artwork containing gloss effects [Fix didn't work - actually fixed in 1.1.1]
- If selected route was saved as index 4 and one the next launch, route at that index no longer exists, app will no longer crash and will instead revert to index 0
- iPad support
- Reduce # of Map/CPU rendering cycles by comparing last updated time
- Added "Review App" button in About menu
- Fixed status bars on the App Store screenshots (cell signal and about button were lower than they should have been)
- iPad Default.png images

##### 1.0
- Now retrieves bus predictions
- Now retrieving bus positions
- Bus positions/predictions refreshed every five seconds
- Added color for bus annotations
- Bus position image now rotates for bus direction
- Added images instead of dropped pins for bus stops
- [BUG] Fixed occasional crach due to MKUserLocation
- [BUG] When bus goes out of service, it is now removed from view
- Accounted for situation where less than 3 predictions are given - emory route
- iOS 6 segmented control no longer bigger than it should be
- Better error handling
- Icon
- Default.png images
- Should request right away (See when requests are made, didload, didenterbg)
- iOS 5 support
- About info screen
