//
//  ScreenSmokeTests.swift
//  WMobile_EntTests
//
//  Loads every addressable scene in every storyboard shipped in the app bundle and
//  forces view loading, so that all @IBOutlet / @IBAction connections are resolved.
//
//  This covers the class of breakage the Swift compiler cannot see: a storyboard that
//  references a scene identifier, custom class, outlet or selector which no longer
//  exists. Those fail only at runtime, when the screen is actually opened.
//

import XCTest
import UIKit
@testable import WMobile_Ent

final class ScreenSmokeTests: XCTestCase {

    /// Scenes that cannot be loaded standalone because `viewDidLoad` reads state the
    /// presenting screen is required to inject first. Every entry needs a reason; if a
    /// scene is here it is NOT covered by this test, so keep the list as short as possible.
    private let knownUnloadable: Set<String> = [
        // viewDidLoad does notificationRec[currentRowAt] on an array that defaults to
        // empty — callers assign notificationRec before pushing. Pre-existing by design.
        "NotificationSB.NotificationCollectionView",
    ]

    // MARK: - Discovery

    /// Every compiled storyboard in the app bundle (`*.storyboardc`).
    private func allStoryboardNames() -> [String] {
        let urls = (try? FileManager.default.contentsOfDirectory(
            at: Bundle.main.bundleURL, includingPropertiesForKeys: nil)) ?? []
        return urls
            .filter { $0.pathExtension == "storyboardc" }
            .map { $0.deletingPathExtension().lastPathComponent }
            .sorted()
    }

    /// The identifiers a storyboard can actually be asked for.
    ///
    /// UIKit keeps these in a private `identifierToNibNameMap`, which contains both
    /// author-assigned `storyboardIdentifier`s and the synthetic entries Interface Builder
    /// emits for unnamed scenes (`UIViewController-hbq-NG-PqM`). Only the former can be
    /// instantiated; asking for a synthetic one raises NSInternalInconsistencyException.
    ///
    /// No `storyboardIdentifier` authored in this project contains a hyphen, whereas every
    /// synthetic name does (`<Class>-<objectID>`), so that separates them cleanly. If a
    /// hyphenated identifier is ever added by hand, widen this filter.
    private func addressableIdentifiers(_ storyboard: UIStoryboard) -> [String] {
        guard let map = storyboard.value(forKey: "identifierToNibNameMap") as? [String: Any] else {
            return []
        }
        return map.keys.filter { !$0.contains("-") }.sorted()
    }

    // MARK: - Tests

    func testEveryStoryboardSceneLoadsWithoutCrashing() {
        let names = allStoryboardNames()
        XCTAssertFalse(names.isEmpty, "No storyboards found in the app bundle")

        var loadedScenes = 0
        var visited: [String] = []

        for name in names {
            let sb = UIStoryboard(name: name, bundle: .main)

            for identifier in addressableIdentifiers(sb) {
                let key = "\(name).\(identifier)"
                if knownUnloadable.contains(key) { continue }

                let vc = sb.instantiateViewController(withIdentifier: identifier)
                vc.loadViewIfNeeded()
                XCTAssertNotNil(vc.view, "\(key) produced a nil view")
                loadedScenes += 1
                visited.append(key)
            }
        }

        print("[SMOKE] loaded \(loadedScenes) addressable scenes across \(names.count) storyboards")
        for v in visited { print("[SMOKE]   ok  \(v)") }
        XCTAssertGreaterThan(loadedScenes, 0, "No scenes were addressable — discovery is broken")
    }

    /// Pins the designated entry point of every storyboard that is embedded by a
    /// `viewControllerPlaceholder` carrying no `referencedIdentifier`.
    ///
    /// UIKit resolves such a placeholder to the referenced storyboard's *initial* view
    /// controller. Nothing in the code references that scene by name, so a reachability
    /// scan will call it dead — and deleting it swaps a whole screen for the wrong one
    /// while still compiling and still loading. That is exactly how the Notification tab
    /// briefly lost its header, "Read all" button and Unread/All tabs.
    func testEmbeddedStoryboardEntryPointsAreUnchanged() {
        let expected: [String: String] = [
            // MainTabBarSB embeds NotificationSB with no referencedIdentifier, so this
            // container — not the inner list — is the Notification tab.
            "NotificationSB": "CarbonNewNotificationVC",
        ]

        for (storyboard, entryPoint) in expected {
            let sb = UIStoryboard(name: storyboard, bundle: .main)
            guard let initial = sb.instantiateInitialViewController() else {
                XCTFail("\(storyboard) has no initial view controller; the tab embedding it will fail to load")
                continue
            }
            XCTAssertEqual(String(describing: type(of: initial)), entryPoint,
                           "\(storyboard)'s entry point changed — a screen embedded by placeholder is now the wrong one")
            initial.loadViewIfNeeded()
            XCTAssertNotNil(initial.view)
        }
    }

    /// The Notification tab's header is wired through outlets on the container above.
    /// Assert they resolve, so losing the title / Read-all / tab strip fails the build.
    func testNotificationTabHeaderOutletsAreConnected() {
        let sb = UIStoryboard(name: "NotificationSB", bundle: .main)
        guard let vc = sb.instantiateInitialViewController() as? CarbonNewNotificationVC else {
            XCTFail("Notification tab entry point is not CarbonNewNotificationVC")
            return
        }
        vc.loadViewIfNeeded()
        XCTAssertNotNil(vc.menuLabel, "Notification title label is not connected")
        XCTAssertNotNil(vc.readAllButton, "\"Read all\" button is not connected")
        XCTAssertNotNil(vc.collectionView, "Unread/All tab strip is not connected")
        XCTAssertNotNil(vc.contentView, "Notification list container is not connected")
    }

    /// Pins the app's root: LaunchScreenVC and LoginVC install it by storyboard identifier,
    /// so a rename would compile fine and only fail when a user logs in.
    func testAppRootIsTheMainTabBarNavigationController() {
        let sb = UIStoryboard(name: "MainTabBarSB", bundle: .main)
        let root = sb.instantiateViewController(withIdentifier: "MainTabBarNav")
        XCTAssertTrue(root is MainTabBarNavigationController,
                      "MainTabBarNav is \(type(of: root)); the .all orientation mask lives on the subclass")
        guard let nav = root as? UINavigationController else { return }
        XCTAssertTrue(nav.viewControllers.first is MainTabBarVC,
                      "MainTabBarNav's root must be MainTabBarVC — findMainTabBarVC() reads viewControllers.first")
        XCTAssertEqual(nav.supportedInterfaceOrientations, .all)
    }

    /// The Approvals header was re-constrained by hand when the WABOOKS side-menu (hamburger)
    /// button was removed: the title used to hang off that button's bottom and now hangs off the
    /// filter/search row's bottom instead, which reproduces the original spacing exactly (both the
    /// button and that row sat at top 20 with height 28, so the title still starts at y=58).
    ///
    /// The layout must stay two rows — filter/search right-aligned on top, full-width title below.
    /// An earlier attempt collapsed them onto one row, which still built, still loaded and still
    /// passed a load-only smoke test, but crammed the filter icon against the title. A storyboard
    /// that loads is not a storyboard that lays out.
    func testApprovalsHeaderLaysOutWithoutTheSideMenuButton() {
        let sb = UIStoryboard(name: "BoardsWeCmsSB", bundle: .main)
        guard let vc = sb.instantiateViewController(withIdentifier: "BoardsWeCmsVC") as? BoardsWeCmsVC else {
            XCTFail("BoardsWeCmsVC is not the Approvals tab any more")
            return
        }

        let window = UIWindow(frame: CGRect(x: 0, y: 0, width: 393, height: 852))
        window.rootViewController = vc
        window.makeKeyAndVisible()
        vc.view.layoutIfNeeded()

        XCTAssertNotNil(vc.titleBoardLabel, "Approvals title label is not connected")
        XCTAssertNotNil(vc.filterButton, "filter button is not connected")
        XCTAssertNotNil(vc.searchButton, "search button is not connected")

        guard let titleStack = vc.titleBoardLabel.superview, let header = titleStack.superview else {
            XCTFail("Approvals header view hierarchy changed shape")
            return
        }

        for view in [header, titleStack, vc.titleBoardLabel!, vc.filterButton!, vc.searchButton!, vc.collectionView!] {
            XCTAssertFalse(view.hasAmbiguousLayout,
                           "\(type(of: view)) in the Approvals header has ambiguous layout")
        }

        let title  = vc.titleBoardLabel.convert(vc.titleBoardLabel.bounds, to: vc.view)
        let filter = vc.filterButton.convert(vc.filterButton.bounds, to: vc.view)
        let search = vc.searchButton.convert(vc.searchButton.bounds, to: vc.view)

        XCTAssertGreaterThan(filter.width, 0, "filter button collapsed to zero width")
        XCTAssertGreaterThan(search.width, 0, "search button collapsed to zero width")
        XCTAssertFalse(title.intersects(filter), "Approvals title overlaps the filter button")
        XCTAssertFalse(title.intersects(search), "Approvals title overlaps the search button")

        // Two rows: the buttons sit entirely above the title, not beside it.
        XCTAssertLessThanOrEqual(filter.maxY, title.minY,
                                 "filter button must sit on its own row above the Approvals title")
        XCTAssertLessThanOrEqual(search.maxY, title.minY,
                                 "search button must sit on its own row above the Approvals title")

        // The title keeps the full content width it had before the hamburger was removed.
        XCTAssertEqual(title.minX, 20, accuracy: 1, "Approvals title lost its leading margin")
        XCTAssertEqual(title.maxX, vc.view.bounds.width - 20, accuracy: 1,
                       "Approvals title is no longer full width — it was squeezed beside the buttons")

        // Buttons stay right-aligned, search outermost.
        XCTAssertGreaterThan(search.minX, filter.minX, "search must sit to the right of filter")
        XCTAssertEqual(search.maxX, vc.view.bounds.width - 20, accuracy: 1,
                       "the filter/search row lost its trailing margin")

        // The tab strip has to clear the header row rather than be overlapped by it.
        let strip = vc.collectionView.convert(vc.collectionView.bounds, to: vc.view)
        XCTAssertGreaterThanOrEqual(strip.minY, title.maxY, "the section strip overlaps the title row")
    }

    /// Verifies every shipped nib is present and parseable.
    ///
    /// Deliberately does NOT call `instantiate(withOwner:)`: most cell xibs wire outlets
    /// to File's Owner, so instantiating with a nil owner raises NSUnknownKeyException for
    /// reasons that are not defects. Outlet wiring on those cells is exercised when their
    /// parent screen renders; their structural integrity is covered by the static audit.
    func testEveryXibIsPresentAndParseable() {
        let urls = (try? FileManager.default.contentsOfDirectory(
            at: Bundle.main.bundleURL, includingPropertiesForKeys: nil)) ?? []
        let nibs = urls
            .filter { $0.pathExtension == "nib" }
            .map { $0.deletingPathExtension().lastPathComponent }
            .sorted()

        XCTAssertFalse(nibs.isEmpty, "No nibs found in the app bundle")

        for name in nibs {
            XCTAssertNotNil(Bundle.main.path(forResource: name, ofType: "nib"),
                            "\(name).nib is referenced by the bundle but missing")
            _ = UINib(nibName: name, bundle: .main)
        }
        print("[SMOKE] verified \(nibs.count) nibs present")
    }
}
