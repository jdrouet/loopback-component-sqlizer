# loopback-component-sqlizer
Component to add sql methods to models

[![Build Status](https://travis-ci.org/jdrouet/loopback-component-sqlizer.svg)](https://travis-ci.org/jdrouet/loopback-component-sqlizer)
[![codecov.io](https://codecov.io/github/jdrouet/loopback-component-sqlizer/coverage.svg?branch=master)](https://codecov.io/github/jdrouet/loopback-component-sqlizer?branch=master)

## Description

This module enable to make sql join request with loopback through the api.

## Installation

1) Install the module in you project

2) Open server/model-config.json and add `loopback-component-sqlizer/lib` to the `_meta.mixins` node.

3) Enable the mixin for the model by adding this in your model.json

```javascript
  "mixins": {
    "Sqlizer": {
      "findOne": {
        "method": true,
        "remote": true
      },
      "find": {
        "method": true,
        "remote": true
      }
    }
  }
```

## How to use it

Use it like if you were using loopback API.
Imagine you have a Post model that contains Comments. 
If you want to get the posts having comment with 'hi' in the comment just do a GET on /sql-find
```javascript
include: ['comments'],
join: [
  {
    relation: 'comments',
    scope: {
      where: {
        content: {
          like: 'hi'
        }
      }
    }
  }
]
```
