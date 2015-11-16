describe 'sqlizer.find', ->

  mock = {}

  before ->
    application.dataSources.db.automigrate()

  before (done) ->
    application.models.User.create
      email: 'user@example.com'
      password: 'password'
    , (err, user) ->
      mock.user = user
      done err

  before (done) ->
    application.models.Post.create
      authorId: mock.user.id
      title: 'Just a post'
      content: 'This is the content of the post'
    , (err, post) ->
      mock.post = post
      done err

  before (done) ->
    application.models.Comment.create
      postId: mock.post.id
      content: 'coucou'
      userId: mock.user.id
    , (err, comment) ->
      mock.comment = comment
      done err

  it 'should return a post', (done) ->
    application.models.Post.sqlFind
      join: [
        {
          relation: 'comments'
          scope:
            where:
              content: 'coucou'
        }
      ]
    , (err, res) ->
      expect(err).to.not.exist
      expect(res).to.be.instanceOf Array
      done err
