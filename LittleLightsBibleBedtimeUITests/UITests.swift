import XCTest

final class LittleLightsBibleBedtimeUITests: XCTestCase {
    
    let app = XCUIApplication()
    
    override func setUpWithError() throws {
        continueAfterFailure = false
        app.launch()
    }
    
    func testNavigateAndScreenshot() throws {
        sleep(3)
        
        // Screenshot home
        let homeAttachment = XCTAttachment(screenshot: XCUIScreen.main.screenshot())
        homeAttachment.name = "Home Screen"
        homeAttachment.lifetime = .keepAlways
        add(homeAttachment)
        
        // Tap Library
        app.tabBars.buttons["Library"].tap()
        sleep(2)
        
        let libAttachment = XCTAttachment(screenshot: XCUIScreen.main.screenshot())
        libAttachment.name = "Library Screen"
        libAttachment.lifetime = .keepAlways
        add(libAttachment)
        
        // Tap first story card
        let firstButton = app.scrollViews.firstMatch.buttons.firstMatch
        if firstButton.waitForExistence(timeout: 3) {
            firstButton.tap()
            sleep(2)
            
            let detailAttachment = XCTAttachment(screenshot: XCUIScreen.main.screenshot())
            detailAttachment.name = "Story Detail Screen"
            detailAttachment.lifetime = .keepAlways
            add(detailAttachment)
        }
        
        // Go back and check Home tab
        app.tabBars.buttons["Home"].tap()
        sleep(1)
        
        // Tap Tonight's Story card
        let tonightsStory = app.buttons.matching(NSPredicate(format: "label CONTAINS 'Jesus'")).firstMatch
        if tonightsStory.waitForExistence(timeout: 3) {
            tonightsStory.tap()
            sleep(2)
            let storyAttachment = XCTAttachment(screenshot: XCUIScreen.main.screenshot())
            storyAttachment.name = "Tonight Story Detail"
            storyAttachment.lifetime = .keepAlways
            add(storyAttachment)
        }
    }
}
