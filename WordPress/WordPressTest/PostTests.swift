import Foundation
import XCTest

@testable import WordPress

class PostTests: XCTestCase {

    fileprivate var contextManager: TestContextManager!
    fileprivate var context: NSManagedObjectContext!

    fileprivate func newTestBlog() -> Blog {
        return NSEntityDescription.insertNewObject(forEntityName: "Blog", into: context) as! Blog
    }

    fileprivate func newTestPost() -> Post {
        return NSEntityDescription.insertNewObject(forEntityName: Post.entityName, into: context) as! Post
    }

    fileprivate func newTestPostCategory() -> PostCategory {
        return NSEntityDescription.insertNewObject(forEntityName: "Category", into: context) as! PostCategory
    }

    fileprivate func newTestPostCategory(_ name: String) -> PostCategory {
        let category = newTestPostCategory()
        category.categoryName = name

        return category
    }

    override func setUp() {
        super.setUp()
        contextManager = TestContextManager()
        context = NSManagedObjectContext(concurrencyType: .mainQueueConcurrencyType)
        context.parent = contextManager.mainContext
    }

    override func tearDown() {
        context.rollback()
        ContextManager.overrideSharedInstance(nil)
        super.tearDown()
    }

    func testThatNoCategoriesReturnEmptyStringWhenCallingCategoriesText() {
        let post = newTestPost()
        let categoriesText = post.categoriesText()

        XCTAssertEqual(categoriesText, "")
    }

    func testThatSomeCategoriesReturnAListWhenCallingCategoriesText() {

        let post = newTestPost()

        post.categories = [newTestPostCategory("1"), newTestPostCategory("2"), newTestPostCategory("3")]

        let categoriesText = post.categoriesText()

        XCTAssertEqual(categoriesText, "1, 2, 3")
    }

    func testSetCategoriesFromNamesWithTwoCategories() {
        let blog = newTestBlog()
        let post = newTestPost()

        let category1 = newTestPostCategory("One")
        let category2 = newTestPostCategory("Two")
        let category3 = newTestPostCategory("Three")

        blog.categories = [category1, category2, category3]

        post.blog = blog
        post.setCategoriesFromNames(["One", "Three"])

        let postCategories = post.categories!
        XCTAssertEqual(postCategories.count, 2)
        XCTAssertTrue(postCategories.contains(category1))
        XCTAssertFalse(postCategories.contains(category2))
        XCTAssertTrue(postCategories.contains(category3))
    }

    func testThatSettingNilLikeCountReturnsZeroNumberOfLikes() {
        let post = newTestPost()

        post.likeCount = nil

        XCTAssertEqual(post.numberOfLikes(), 0)
    }

    func testThatSettingLikeCountAffectsNumberOfLikes() {
        let post = newTestPost()

        post.likeCount = 2

        XCTAssertEqual(post.numberOfLikes(), 2)
    }

    func testThatSettingNilCommentCountReturnsZeroNumberOfComments() {
        let post = newTestPost()

        post.commentCount = nil

        XCTAssertEqual(post.numberOfComments(), 0)
    }

    func testThatSettingCommentCountAffectsNumberOfComments() {
        let post = newTestPost()

        post.commentCount = 2

        XCTAssertEqual(post.numberOfComments(), 2)
    }

    func testThatAddCategoriesWorks() {
        let post = newTestPost()
        let testCategories = Set([newTestPostCategory("1"), newTestPostCategory("2"), newTestPostCategory("3")])

        post.addCategories(testCategories)

        guard let postCategories = post.categories else {
            XCTFail("post.categories should not be nil here.")
            return
        }

        XCTAssert(postCategories.count == testCategories.count)

        for testCategory in testCategories {
            XCTAssertTrue(postCategories.contains(testCategory))
        }
    }

    func testThatAddCategoriesObjectWorks() {
        let post = newTestPost()
        let testCategory = newTestPostCategory("1")

        post.addCategoriesObject(testCategory)

        guard let postCategories = post.categories else {
            XCTFail("post.categories should not be nil here.")
            return
        }

        XCTAssertEqual(postCategories.count, 1)
        XCTAssertTrue(postCategories.contains(testCategory))
    }

    func testThatRemoveCategoriesWorks() {
        let post = newTestPost()
        let testCategories = Set<PostCategory>(arrayLiteral: newTestPostCategory("1"), newTestPostCategory("2"), newTestPostCategory("3"))

        post.categories = testCategories
        XCTAssertNotEqual(post.categories?.count, 0)
        XCTAssertEqual(post.categories?.count, testCategories.count)

        post.removeCategories(testCategories)
        XCTAssertEqual(post.categories?.count, 0)
    }

    func testThatRemoveCategoriesObjectWorks() {
        let post = newTestPost()
        let testCategory = newTestPostCategory("1")

        post.categories = Set<PostCategory>(arrayLiteral: testCategory)
        XCTAssertEqual(post.categories?.count, 1)

        post.removeCategoriesObject(testCategory)
        XCTAssertEqual(post.categories?.count, 0)
    }

    func testThatPostFormatTextReturnsDefault() {
        let defaultPostFormat = (key: "standard", value: "Default")

        let post = newTestPost()
        let blog = newTestBlog()

        blog.postFormats = [defaultPostFormat.key: defaultPostFormat.value]
        post.blog = blog

        let postFormatText = post.postFormatText()!
        XCTAssertEqual(postFormatText, defaultPostFormat.value)
    }

    func testThatPostFormatTextReturnsSelected() {
        let defaultPostFormat = (key: "standard", value: "Default")
        let secondaryPostFormat = (key: "secondary", value: "Secondary")

        let post = newTestPost()
        let blog = newTestBlog()

        blog.postFormats = [defaultPostFormat.key: defaultPostFormat.value,
                            secondaryPostFormat.key: secondaryPostFormat.value]
        post.blog = blog
        post.postFormat = secondaryPostFormat.key

        let postFormatText = post.postFormatText()!
        XCTAssertEqual(postFormatText, secondaryPostFormat.value)
    }

    func testThatSetPostFormatTextWorks() {
        let defaultPostFormat = (key: "standard", value: "Default")
        let secondaryPostFormat = (key: "secondary", value: "Secondary")

        let post = newTestPost()
        let blog = newTestBlog()

        blog.postFormats = [defaultPostFormat.key: defaultPostFormat.value,
                            secondaryPostFormat.key: secondaryPostFormat.value]
        post.blog = blog
        post.setPostFormatText(secondaryPostFormat.value)

        XCTAssertEqual(post.postFormat, secondaryPostFormat.key)
    }

    func testThatHasCategoriesWorks() {
        let post = newTestPost()

        XCTAssertFalse(post.hasCategories())
        post.categories = [newTestPostCategory("1"), newTestPostCategory("2"), newTestPostCategory("3")]
        XCTAssertTrue(post.hasCategories())
        post.categories = nil
        XCTAssertFalse(post.hasCategories())
    }

    func testThatHasTagsWorks() {
        let post = newTestPost()

        XCTAssertFalse(post.hasTags())
        post.tags = "a b c"
        XCTAssertTrue(post.hasTags())
        post.tags = nil
        XCTAssertFalse(post.hasTags())
    }

    func testThatTitleForDisplayWorks() {
        let post = newTestPost()

        XCTAssertEqual(post.titleForDisplay(), "(no title)")

        post.postTitle = "hello world"
        XCTAssertEqual(post.titleForDisplay(), "hello world")

        post.postTitle = "    "
        XCTAssertEqual(post.titleForDisplay(), "(no title)")
    }

    func testThatContentPreviewForDisplayWorks() {
        let post = newTestPost()

        post.content = "<HTML>some contents&nbsp;go here</HTML>"
        XCTAssertEqual(post.contentPreviewForDisplay(), "some contents\u{A0}go here")
    }

    func testThatContentPreviewForDisplayWorksWithExcerpt() {
        let post = newTestPost()

        post.mt_excerpt = "<HTML>some contents&nbsp;go here</HTML>"
        post.content = "blah blah"
        XCTAssertEqual(post.contentPreviewForDisplay(), "some contents\u{A0}go here")
    }

    func testThatStatusForDisplayWorksForOriginalPost() {
        let post = newTestPost()

        post.status = PostStatusDraft
        XCTAssertNil(post.statusForDisplay())

        post.status = PostStatusPending
        XCTAssertEqual(post.statusForDisplay(), Post.title(forStatus: PostStatusPending))

        post.status = PostStatusPrivate
        XCTAssertEqual(post.statusForDisplay(), Post.title(forStatus: PostStatusPrivate))

        post.status = PostStatusPublish
        XCTAssertNil(post.statusForDisplay())

        post.status = PostStatusScheduled
        XCTAssertEqual(post.statusForDisplay(), Post.title(forStatus: PostStatusScheduled))

        post.status = PostStatusTrash
        XCTAssertEqual(post.statusForDisplay(), Post.title(forStatus: PostStatusTrash))

        post.status = PostStatusDeleted
        XCTAssertEqual(post.statusForDisplay(), Post.title(forStatus: PostStatusDeleted))
    }

    func testThatStatusForDisplayWorksForRevisionPost() {
        let original = newTestPost()
        let revision = original.createRevision()

        revision.status = PostStatusDraft
        XCTAssertEqual(revision.statusForDisplay(), "Local")

        revision.status = PostStatusPending
        XCTAssertEqual(revision.statusForDisplay(), "\(Post.title(forStatus: PostStatusPending)), Local")

        revision.status = PostStatusPrivate
        XCTAssertEqual(revision.statusForDisplay(), "\(Post.title(forStatus: PostStatusPrivate)), Local")

        revision.status = PostStatusPublish
        XCTAssertEqual(revision.statusForDisplay(), "Local")

        revision.status = PostStatusScheduled
        XCTAssertEqual(revision.statusForDisplay(), "\(Post.title(forStatus: PostStatusScheduled)), Local")

        revision.status = PostStatusTrash
        XCTAssertEqual(revision.statusForDisplay(), "\(Post.title(forStatus: PostStatusTrash)), Local")

        revision.status = PostStatusDeleted
        XCTAssertEqual(revision.statusForDisplay(), "\(Post.title(forStatus: PostStatusDeleted)), Local")
    }

    func testThatHasLocalChangesWorks() {
        let original = newTestPost()
        var revision = original.createRevision() as! Post

        XCTAssertFalse(original.hasLocalChanges())
        XCTAssertFalse(revision.hasLocalChanges())

        revision.tags = "Ahoi"
        XCTAssertTrue(revision.hasLocalChanges())

        original.deleteRevision()
        original.tags = "ioha"
        revision = original.createRevision() as! Post

        XCTAssertFalse(revision.hasLocalChanges())

        revision.tags = "Ahoi"
        XCTAssertTrue(revision.hasLocalChanges())

        revision.tags = original.tags
        XCTAssertFalse(revision.hasLocalChanges())

        revision.publicizeMessage = ""
        XCTAssertFalse(revision.hasLocalChanges())

        revision.publicizeMessage = "Make it notorious"
        XCTAssertTrue(revision.hasLocalChanges())

        revision.publicizeMessage = original.publicizeMessage
        XCTAssertFalse(revision.hasLocalChanges())

        original.deleteRevision()
        original.disablePublicizeConnectionWithKeyringID(8888)
        revision = original.createRevision() as! Post

        XCTAssertFalse(revision.hasLocalChanges())

        revision.disablePublicizeConnectionWithKeyringID(1234)
        XCTAssertTrue(revision.hasLocalChanges())

        revision.enablePublicizeConnectionWithKeyringID(1234)
        XCTAssertFalse(revision.hasLocalChanges())

        revision.enablePublicizeConnectionWithKeyringID(8888)
        XCTAssertTrue(revision.hasLocalChanges())

        revision.disablePublicizeConnectionWithKeyringID(8888)
        XCTAssertFalse(revision.hasLocalChanges())

        revision.mt_excerpt = "Say cheese"
        XCTAssertTrue(revision.hasLocalChanges())

        revision.mt_excerpt = original.mt_excerpt
        XCTAssertFalse(revision.hasLocalChanges())
    }

    func testThatEnablingDisablingPublicizeConnectionsWorks() {
        let post = newTestPost()

        post.disablePublicizeConnectionWithKeyringID(1234)
        XCTAssertTrue(post.publicizeConnectionDisabledForKeyringID(1234))

        post.enablePublicizeConnectionWithKeyringID(1234)
        XCTAssertFalse(post.publicizeConnectionDisabledForKeyringID(1234))
    }
}
