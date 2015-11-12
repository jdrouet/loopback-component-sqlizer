describe 'sqlizer.generateQuery', ->

  CustomModel = application.models.Post
  options     = {}

  it 'should exist', ->
    expect(CustomModel.__generateQuery).to.exist

  it 'should generate a simple from', ->
    filter = {}
    res = CustomModel.__generateQuery filter
    expect(res.text).to.eql 'SELECT _origin_.* FROM Post `_origin_`'

  it 'should generate a join', ->
    filter =
      join:
        relation: 'comments'
        scope:
          where:
            content: 'coucou'
    res = CustomModel.__generateQuery filter
    expect(res.values).to.be.instanceof Array
    expect(res.values[0]).to.eql 'coucou'
    expect(res.text).toEqual 'SELECT post.* FROM post JOIN comment ON post.id = comment.postid WHERE comment.content = $1'
