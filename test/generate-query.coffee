describe 'sqlizer.generateQuery', ->

  CustomModel = application.models.Post
  options     = {}

  it 'should exist', ->
    expect(CustomModel.__generateQuery).to.exist

  it 'should generate a simple from', ->
    filter = {}
    res = CustomModel.__generateQuery filter
    expect(res.text).to.eql 'SELECT Post.* FROM Post'

  it 'should generate a join', ->
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
