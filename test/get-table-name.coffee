describe 'sqlizer.getTableName', ->

  CustomModel = application.models.Post
  options     = {}

  it 'should exist', ->
    expect(CustomModel.__getTableName).to.exist

  it 'should return table name', ->
    filter = {}
    res = CustomModel.__getTableName 'Post'
    expect(res).to.eql 'Post'

