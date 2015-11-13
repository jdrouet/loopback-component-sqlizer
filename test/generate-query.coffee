describe 'sqlizer.generateQuery', ->

  CustomModel = application.models.Post
  options     = {}

  it 'should exist', ->
    expect(CustomModel.__generateQuery).to.exist

  it 'should generate a simple from', ->
    filter = {}
    res = CustomModel.__generateQuery filter
    expect(res.text).to.eql 'SELECT Post.* FROM Post'

  describe 'join tables', ->

    it 'should generate a query with a single join', ->
      filter =
        join: [
          {
            relation: 'comments'
            scope:
              where:
                content: 'coucou'
          }
        ]
      res = CustomModel.__generateQuery filter
      expect(res.values).to.be.instanceof Array
      expect(res.values[0]).to.eql 'coucou'
      expect(res.text).to.eql 'SELECT Post.* FROM Post INNER JOIN Comment ON (Post.id = Comment.postId) WHERE (Comment.content = ?)'

    it 'should generate a query with two joins', ->
      filter =
        join: [
          {
            relation: 'comments'
            scope:
              where:
                content: 'coucou'
          }
          {
            relation: 'author'
          }
        ]
      res = CustomModel.__generateQuery filter
      expect(res.values).to.be.instanceof Array
      expect(res.values[0]).to.eql 'coucou'
      expect(res.text).to.eql 'SELECT Post.* FROM Post INNER JOIN Comment ON (Post.id = Comment.postId) INNER JOIN User ON (User.id = Post.authorId) WHERE (Comment.content = ?)'

    it 'should generate a query with two joins and two where', ->
      filter =
        join: [
          {
            relation: 'comments'
            scope:
              where:
                content: 'coucou'
          }
          {
            relation: 'author'
            scope:
              where:
                email: 'user@example.com'
          }
        ]
      res = CustomModel.__generateQuery filter
      expect(res.values).to.be.instanceof Array
      expect(res.values[0]).to.eql 'coucou'
      expect(res.text).to.eql 'SELECT Post.* FROM Post INNER JOIN Comment ON (Post.id = Comment.postId) INNER JOIN User ON (User.id = Post.authorId) WHERE (Comment.content = ?) AND (User.email = ?)'

  describe 'where', ->

    it 'should handle gte', ->
      filter =
        join: [
          {
            relation: 'comments'
            scope:
              where:
                content:
                  gte: 'coucou'
          }
        ]
      res = CustomModel.__generateQuery filter
      expect(res.values).to.be.instanceof Array
      expect(res.values[0]).to.eql 'coucou'
      expect(res.text).to.eql 'SELECT Post.* FROM Post INNER JOIN Comment ON (Post.id = Comment.postId) WHERE (Comment.content >= ?)'

    it 'should handle lte', ->
      filter =
        join: [
          {
            relation: 'comments'
            scope:
              where:
                content:
                  lte: 'coucou'
          }
        ]
      res = CustomModel.__generateQuery filter
      expect(res.values).to.be.instanceof Array
      expect(res.values[0]).to.eql 'coucou'
      expect(res.text).to.eql 'SELECT Post.* FROM Post INNER JOIN Comment ON (Post.id = Comment.postId) WHERE (Comment.content <= ?)'

    it 'should handle neq', ->
      filter =
        join: [
          {
            relation: 'comments'
            scope:
              where:
                content:
                  neq: 'coucou'
          }
        ]
      res = CustomModel.__generateQuery filter
      expect(res.values).to.be.instanceof Array
      expect(res.values[0]).to.eql 'coucou'
      expect(res.text).to.eql 'SELECT Post.* FROM Post INNER JOIN Comment ON (Post.id = Comment.postId) WHERE (Comment.content <> ?)'

    it 'should handle like', ->
      filter =
        join: [
          {
            relation: 'comments'
            scope:
              where:
                content:
                  like: 'coucou'
          }
        ]
      res = CustomModel.__generateQuery filter
      expect(res.values).to.be.instanceof Array
      expect(res.values[0]).to.eql 'coucou'
      expect(res.text).to.eql 'SELECT Post.* FROM Post INNER JOIN Comment ON (Post.id = Comment.postId) WHERE (Comment.content LIKE ?)'

