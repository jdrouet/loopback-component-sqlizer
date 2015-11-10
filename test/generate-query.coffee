describe 'sqlizer.generateQuery', ->

  CustomModel = {}
  options     = {}

  before ->
    sqlizer CustomModel, options

  it 'should exist', ->
    expect(CustomModel.__generateQuery).toBeDefined

  it 'should general join', (done) ->
    filter =
      join:
        relation: 'comments'
        scope:
          where:
            content: 'coucou'
    CustomModel.__generateQuery filter, (err, res) ->
      expect(err).not.toBeDefined
      expect(res.params).to.be.instanceof Array
      expect(res.params[0]).to.eql 'coucou'
      expect(res.query).toEqual 'SELECT post.* FROM post JOIN comment ON post.id = comment.postid WHERE comment.content = $1'
      done()
