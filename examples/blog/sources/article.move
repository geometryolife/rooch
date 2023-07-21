// <autogenerated>
//   This file was generated by dddappp code generator.
//   Any changes made to this file manually will be lost next time the file is regenerated.
// </autogenerated>

module rooch_examples::article {
    use moveos_std::event;
    use moveos_std::object::{Self, Object};
    use moveos_std::object_id::ObjectID;
    use moveos_std::object_storage;
    use moveos_std::storage_context::{Self, StorageContext};
    use moveos_std::table::{Self, Table};
    use moveos_std::tx_context;
    use rooch_examples::comment::{Self, Comment};
    use std::error;
    use std::option;
    use std::signer;
    use std::string::String;
    friend rooch_examples::article_update_comment_logic;
    friend rooch_examples::article_remove_comment_logic;
    friend rooch_examples::article_add_comment_logic;
    friend rooch_examples::article_create_logic;
    friend rooch_examples::article_update_logic;
    friend rooch_examples::article_delete_logic;
    friend rooch_examples::article_aggregate;

    const EID_ALREADY_EXISTS: u64 = 101;
    const EDATA_TOO_LONG: u64 = 102;
    const EINAPPROPRIATE_VERSION: u64 = 103;
    const ENOT_GENESIS_ACCOUNT: u64 = 105;
    const EID_NOT_FOUND: u64 = 106;

    struct CommentTableItemAdded has key {
        article_id: ObjectID,
        comment_seq_id: u64,
    }

    public fun initialize(storage_ctx: &mut StorageContext, account: &signer) {
        assert!(signer::address_of(account) == @rooch_examples, error::invalid_argument(ENOT_GENESIS_ACCOUNT));
        let _ = storage_ctx;
        let _ = account;
    }

    struct Article has key {
        version: u64,
        title: String,
        body: String,
        comments: Table<u64, Comment>,
        comment_seq_id_generator: CommentSeqIdGenerator,
    }

    struct CommentSeqIdGenerator has store {
        sequence: u64,
    }

    public(friend) fun current_comment_seq_id(article_obj: &Object<Article>): u64 {
        object::borrow(article_obj).comment_seq_id_generator.sequence
    }

    public(friend) fun next_comment_seq_id(article_obj: &mut Object<Article>): u64 {
        object::borrow_mut(article_obj).comment_seq_id_generator.sequence = object::borrow(article_obj).comment_seq_id_generator.sequence + 1;
        object::borrow(article_obj).comment_seq_id_generator.sequence
    }

    /// get object id
    public fun id(article_obj: &Object<Article>): ObjectID {
        object::id(article_obj)
    }

    public fun version(article_obj: &Object<Article>): u64 {
        object::borrow(article_obj).version
    }

    public fun title(article_obj: &Object<Article>): String {
        object::borrow(article_obj).title
    }

    public(friend) fun set_title(article_obj: &mut Object<Article>, title: String) {
        assert!(std::string::length(&title) <= 200, EDATA_TOO_LONG);
        object::borrow_mut(article_obj).title = title;
    }

    public fun body(article_obj: &Object<Article>): String {
        object::borrow(article_obj).body
    }

    public(friend) fun set_body(article_obj: &mut Object<Article>, body: String) {
        assert!(std::string::length(&body) <= 2000, EDATA_TOO_LONG);
        object::borrow_mut(article_obj).body = body;
    }

    public(friend) fun add_comment(storage_ctx: &mut StorageContext, article_obj: &mut Object<Article>, comment: Comment) {
        let comment_seq_id = comment::comment_seq_id(&comment);
        assert!(!table::contains(&object::borrow_mut(article_obj).comments, comment_seq_id), EID_ALREADY_EXISTS);
        table::add(&mut object::borrow_mut(article_obj).comments, comment_seq_id, comment);
        event::emit(storage_ctx, CommentTableItemAdded {
            article_id: id(article_obj),
            comment_seq_id,
        });
    }

    public(friend) fun remove_comment(article_obj: &mut Object<Article>, comment_seq_id: u64) {
        assert!(table::contains(&object::borrow_mut(article_obj).comments, comment_seq_id), EID_NOT_FOUND);
        let comment = table::remove(&mut object::borrow_mut(article_obj).comments, comment_seq_id);
        comment::drop_comment(comment);
    }

    public(friend) fun borrow_mut_comment(article_obj: &mut Object<Article>, comment_seq_id: u64): &mut Comment {
        table::borrow_mut(&mut object::borrow_mut(article_obj).comments, comment_seq_id)
    }

    public fun borrow_comment(article_obj: &Object<Article>, comment_seq_id: u64): &Comment {
        table::borrow(&object::borrow(article_obj).comments, comment_seq_id)
    }

    public fun comments_contains(article_obj: &Object<Article>, comment_seq_id: u64): bool {
        table::contains(&object::borrow(article_obj).comments, comment_seq_id)
    }

    fun new_article(
        tx_ctx: &mut tx_context::TxContext,
        title: String,
        body: String,
    ): Article {
        assert!(std::string::length(&title) <= 200, EDATA_TOO_LONG);
        assert!(std::string::length(&body) <= 2000, EDATA_TOO_LONG);
        Article {
            version: 0,
            title,
            body,
            comments: table::new<u64, Comment>(tx_ctx),
            comment_seq_id_generator: CommentSeqIdGenerator { sequence: 0, },
        }
    }

    struct CommentUpdated has key {
        id: ObjectID,
        version: u64,
        comment_seq_id: u64,
        commenter: String,
        body: String,
        owner: address,
    }

    public fun comment_updated_id(comment_updated: &CommentUpdated): ObjectID {
        comment_updated.id
    }

    public fun comment_updated_comment_seq_id(comment_updated: &CommentUpdated): u64 {
        comment_updated.comment_seq_id
    }

    public fun comment_updated_commenter(comment_updated: &CommentUpdated): String {
        comment_updated.commenter
    }

    public fun comment_updated_body(comment_updated: &CommentUpdated): String {
        comment_updated.body
    }

    public fun comment_updated_owner(comment_updated: &CommentUpdated): address {
        comment_updated.owner
    }

    public(friend) fun new_comment_updated(
        article_obj: &Object<Article>,
        comment_seq_id: u64,
        commenter: String,
        body: String,
        owner: address,
    ): CommentUpdated {
        CommentUpdated {
            id: id(article_obj),
            version: version(article_obj),
            comment_seq_id,
            commenter,
            body,
            owner,
        }
    }

    struct CommentRemoved has key {
        id: ObjectID,
        version: u64,
        comment_seq_id: u64,
    }

    public fun comment_removed_id(comment_removed: &CommentRemoved): ObjectID {
        comment_removed.id
    }

    public fun comment_removed_comment_seq_id(comment_removed: &CommentRemoved): u64 {
        comment_removed.comment_seq_id
    }

    public(friend) fun new_comment_removed(
        article_obj: &Object<Article>,
        comment_seq_id: u64,
    ): CommentRemoved {
        CommentRemoved {
            id: id(article_obj),
            version: version(article_obj),
            comment_seq_id,
        }
    }

    struct CommentAdded has key {
        id: ObjectID,
        version: u64,
        comment_seq_id: u64,
        commenter: String,
        body: String,
        owner: address,
    }

    public fun comment_added_id(comment_added: &CommentAdded): ObjectID {
        comment_added.id
    }

    public fun comment_added_comment_seq_id(comment_added: &CommentAdded): u64 {
        comment_added.comment_seq_id
    }

    public fun comment_added_commenter(comment_added: &CommentAdded): String {
        comment_added.commenter
    }

    public fun comment_added_body(comment_added: &CommentAdded): String {
        comment_added.body
    }

    public fun comment_added_owner(comment_added: &CommentAdded): address {
        comment_added.owner
    }

    public(friend) fun new_comment_added(
        article_obj: &Object<Article>,
        comment_seq_id: u64,
        commenter: String,
        body: String,
        owner: address,
    ): CommentAdded {
        CommentAdded {
            id: id(article_obj),
            version: version(article_obj),
            comment_seq_id,
            commenter,
            body,
            owner,
        }
    }

    struct ArticleCreated has key {
        id: option::Option<ObjectID>,
        title: String,
        body: String,
    }

    public fun article_created_id(article_created: &ArticleCreated): option::Option<ObjectID> {
        article_created.id
    }

    public(friend) fun set_article_created_id(article_created: &mut ArticleCreated, id: ObjectID) {
        article_created.id = option::some(id);
    }

    public fun article_created_title(article_created: &ArticleCreated): String {
        article_created.title
    }

    public fun article_created_body(article_created: &ArticleCreated): String {
        article_created.body
    }

    public(friend) fun new_article_created(
        title: String,
        body: String,
    ): ArticleCreated {
        ArticleCreated {
            id: option::none(),
            title,
            body,
        }
    }

    struct ArticleUpdated has key {
        id: ObjectID,
        version: u64,
        title: String,
        body: String,
    }

    public fun article_updated_id(article_updated: &ArticleUpdated): ObjectID {
        article_updated.id
    }

    public fun article_updated_title(article_updated: &ArticleUpdated): String {
        article_updated.title
    }

    public fun article_updated_body(article_updated: &ArticleUpdated): String {
        article_updated.body
    }

    public(friend) fun new_article_updated(
        article_obj: &Object<Article>,
        title: String,
        body: String,
    ): ArticleUpdated {
        ArticleUpdated {
            id: id(article_obj),
            version: version(article_obj),
            title,
            body,
        }
    }

    struct ArticleDeleted has key {
        id: ObjectID,
        version: u64,
    }

    public fun article_deleted_id(article_deleted: &ArticleDeleted): ObjectID {
        article_deleted.id
    }

    public(friend) fun new_article_deleted(
        article_obj: &Object<Article>,
    ): ArticleDeleted {
        ArticleDeleted {
            id: id(article_obj),
            version: version(article_obj),
        }
    }


    public(friend) fun create_article(
        storage_ctx: &mut StorageContext,
        title: String,
        body: String,
    ): Object<Article> {
        let tx_ctx = storage_context::tx_context_mut(storage_ctx);
        let article = new_article(
            tx_ctx,
            title,
            body,
        );
        let obj_owner = tx_context::sender(tx_ctx);
        let article_obj = object::new(
            tx_ctx,
            obj_owner,
            article,
        );
        article_obj
    }

    public(friend) fun update_version_and_add(storage_ctx: &mut StorageContext, article_obj: Object<Article>) {
        object::borrow_mut(&mut article_obj).version = object::borrow( &mut article_obj).version + 1;
        //assert!(object::borrow(&article_obj).version != 0, EINAPPROPRIATE_VERSION);
        private_add_article(storage_ctx, article_obj);
    }

    public(friend) fun remove_article(storage_ctx: &mut StorageContext, obj_id: ObjectID): Object<Article> {
        let obj_store = storage_context::object_storage_mut(storage_ctx);
        object_storage::remove<Article>(obj_store, obj_id)
    }

    public(friend) fun add_article(storage_ctx: &mut StorageContext, article_obj: Object<Article>) {
        assert!(object::borrow(&article_obj).version == 0, EINAPPROPRIATE_VERSION);
        private_add_article(storage_ctx, article_obj);
    }

    fun private_add_article(storage_ctx: &mut StorageContext, article_obj: Object<Article>) {
        assert!(std::string::length(&object::borrow(&article_obj).title) <= 200, EDATA_TOO_LONG);
        assert!(std::string::length(&object::borrow(&article_obj).body) <= 2000, EDATA_TOO_LONG);
        let obj_store = storage_context::object_storage_mut(storage_ctx);
        object_storage::add(obj_store, article_obj);
    }

    public fun get_article(storage_ctx: &mut StorageContext, obj_id: ObjectID): Object<Article> {
        remove_article(storage_ctx, obj_id)
    }

    public fun return_article(storage_ctx: &mut StorageContext, article_obj: Object<Article>) {
        private_add_article(storage_ctx, article_obj);
    }

    public(friend) fun drop_article(article_obj: Object<Article>) {
        let (_id, _owner, article) =  object::unpack(article_obj);
        let Article {
            version: _version,
            title: _title,
            body: _body,
            comments,
            comment_seq_id_generator,
        } = article;
        let CommentSeqIdGenerator {
            sequence: _,
        } = comment_seq_id_generator;
        table::destroy_empty(comments);
    }

    public(friend) fun emit_comment_updated(storage_ctx: &mut StorageContext, comment_updated: CommentUpdated) {
        event::emit(storage_ctx, comment_updated);
    }

    public(friend) fun emit_comment_removed(storage_ctx: &mut StorageContext, comment_removed: CommentRemoved) {
        event::emit(storage_ctx, comment_removed);
    }

    public(friend) fun emit_comment_added(storage_ctx: &mut StorageContext, comment_added: CommentAdded) {
        event::emit(storage_ctx, comment_added);
    }

    public(friend) fun emit_article_created(storage_ctx: &mut StorageContext, article_created: ArticleCreated) {
        event::emit(storage_ctx, article_created);
    }

    public(friend) fun emit_article_updated(storage_ctx: &mut StorageContext, article_updated: ArticleUpdated) {
        event::emit(storage_ctx, article_updated);
    }

    public(friend) fun emit_article_deleted(storage_ctx: &mut StorageContext, article_deleted: ArticleDeleted) {
        event::emit(storage_ctx, article_deleted);
    }

}
