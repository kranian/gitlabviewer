$ = require 'jquery'
_ = require 'lodash'
ipcRenderer = require('electron').ipcRenderer

token = ipcRenderer.sendSync('getToken')
maintenancePrjId = 19;
devPrjId = 2;
bmtPrjId = 15;

customerTypeLabelColor = '#44ad8e'
taskTypeLabelColor = '#428bca'
deptTypeLabelColor = '#d9534f'
priorityTypeLabelColor = '#ff0000'


module.exports = {}



###
  issue format

  {
        "id": 350,
        "iid": 3,
        "project_id": 19,
        "description": "",
        "state": "opened",
        "created_at": "2016-10-10T15:39:35.203+09:00",
        "updated_at": "2016-10-10T15:45:43.812+09:00",
        "labels": [
            "교통안전공단",
            "기능개선"
        ],
        "milestone": null,
        "assignee": null,
        "author": {
            "name": "callin",
            "username": "callin",
            "id": 4,
            "state": "active",
            "avatar_url": "http://www.gravatar.com/avatar/beb88205c2b0bbf7f2bcc8a4f503eceb?s=80\u0026d=identicon",
            "web_url": "http://elevisor.iptime.org:9937/u/callin"
        }
    }
###




module.exports.setToken = (tkn) ->
  token = tkn


module.exports.getIssueList = (prjId=2) ->
  df = $.Deferred()

  per_page = 100
  page_index = 1;
  allIssueList = []

  getIsList = ->
    $.ajax({
      url : 'http://kranian:9937/api/v3/projects/'+prjId+'/issues?state=opened'
      headers : {'PRIVATE-TOKEN':token}
      data : {
        "per_page" : per_page
        "page" : page_index
      }
    }).then (response) ->
      #console.log 'response', response
      allIssueList.push(v) for v in response

      if per_page == response.length
        page_index++
        getIsList()
      else
        df.resolve(allIssueList)

  getIsList()
  return df.promise()



module.exports.getIssue = (prjId=2,issueId=1) ->
  df = $.Deferred()
  getIssue = ->
    $.ajax({
      url : "http://kranian:9937/api/v3/projects/#{prjId}/issues/#{issueId}"
      headers : {'PRIVATE-TOKEN':token}
    }).then (response) ->
      df.resolve(response)

  getIssue()
  return df.promise()


###0 {
    "id": 6,
    "description": null,
    "default_branch": "master",
    "public": false,
    "visibility_level": 0,
    "ssh_url_to_repo": "git@example.com:brightbox/puppet.git",
    "http_url_to_repo": "http://example.com/brightbox/puppet.git",
    "web_url": "http://example.com/brightbox/puppet",
    "tag_list": [
      "example",
      "puppet"
    ],
    "owner": {
      "id": 4,
      "name": "Brightbox",
      "created_at": "2013-09-30T13:46:02Z"
    },
    "name": "Puppet",
    "name_with_namespace": "Brightbox / Puppet",
    "path": "puppet",
    "path_with_namespace": "brightbox/puppet",
    "issues_enabled": true,
    "open_issues_count": 1,
    "merge_requests_enabled": true,
    "builds_enabled": true,
    "wiki_enabled": true,
    "snippets_enabled": false,
    "container_registry_enabled": false,
    "created_at": "2013-09-30T13:46:02Z",
    "last_activity_at": "2013-09-30T13:46:02Z",
    "creator_id": 3,
    "namespace": {
      "created_at": "2013-09-30T13:46:02Z",
      "description": "",
      "id": 4,
      "name": "Brightbox",
      "owner_id": 1,
      "path": "brightbox",
      "updated_at": "2013-09-30T13:46:02Z"
    },
    "permissions": {
      "project_access": {
        "access_level": 10,
        "notification_level": 3
      },
      "group_access": {
        "access_level": 50,
        "notification_level": 3
      }
    },
    "archived": false,
    "avatar_url": null,
    "shared_runners_enabled": true,
    "forks_count": 0,
    "star_count": 0,
    "runners_token": "b8547b1dc37721d05889db52fa2f02",
    "public_builds": true,
    "shared_with_groups": [],
    "only_allow_merge_if_build_succeeds": false,
    "request_access_enabled": false
  }

###
module.exports.getProjectList= () ->
  df = $.Deferred()

  per_page = 100
  page_index = 1;
  allIssueList = []

  getIsList = ->
    $.ajax({
      url : 'http://kranian:9937/api/v3/projects/all'
      headers : {'PRIVATE-TOKEN':token}
      data : {
        "per_page" : per_page
        "page" : page_index
      }
    }).then (response) ->
      console.log 'response', response
      allIssueList.push(v) for v in response

      if per_page == response.length
        page_index++
        getIsList()
      else
        df.resolve(allIssueList)

  getIsList()
  return df.promise()

module.exports.getUserList= () ->
  df = $.Deferred()

  per_page = 100
  page_index = 1;
  allIssueList = []

  getIsList = ->
    $.ajax({
      url : 'http://kranian.org:9937/api/v3/users'
      headers : {'PRIVATE-TOKEN':token}
      data : {
        "per_page" : per_page
        "page" : page_index
      }
    }).then (response) ->
      allIssueList.push(v) for v in response

      if per_page == response.length
        page_index++
        getIsList()
      else
        df.resolve(allIssueList)

  getIsList()
  return df.promise()



###
  {color:'#ff0000', name:'긴급'}
###
module.exports.getLabelList = (projId) ->
  df = $.Deferred()

  per_page = 100
  page_index = 1;
  allLabelList = []

  getLbl = ->
    $.ajax({
      url : 'http://kranian:9937/api/v3/projects/'+projId+'/labels'
      headers : {'PRIVATE-TOKEN':token}
      data : {
        "per_page" : per_page
        "page" : page_index
      }
    }).then (response) ->
      console.log 'response', response
      allLabelList.push(v) for v in response
      if per_page == response.body.length
        page_index++;
        getLbl();
      else
        df.resolve allLabelList

  getLbl()
  return df.promise()



module.exports.getLabelsByPrjNColor = (projId, color) ->
  df = $.Deferred()
  module.exports.getLabelList(projId).then (allLabelList )->
    df.resolve( _(allLabelList).filter((v)->v.color == color).map('name').value() )

  return df.promise()



module.exports.getAllIssueList = ()->
  df = $.Deferred()
  module.exports.getProjectList().then (rslt)->
    issP = _.map(rslt, (v)->module.exports.getIssueList(v.id))
    $.when.apply($,issP).then (args...)->df.resolve _.flatten(args)

  return df.promise()



