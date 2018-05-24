#// This file is required by the index.html file and will
#// be executed in the renderer process for that window.
#// All of the Node.js APIs are available in this process.

$ = require('jquery');
_ = require('lodash');
d3 = require('d3');
showdown  = require('showdown')
api = require('./gitlabApi');
shell = require('electron').shell;
ipcRenderer = require('electron').ipcRenderer

$body = $('body')

issueTmpl = _.template """

      <td><%=iss.prjName%></td>
      <td><%=iss.milestone.title %></td>
      <td><%=iss.project_id == 19 ? iss.client : iss.subjectLabel %></td>
      <td><%=iss.assignee.realname%></td>
      <td class='<%=iss.el_state%>' ><span class='<%=iss.el_state%>' data-url='http://elevisor.iptime.org:9937/elevisor/<%=iss.realprjName%>/issues/<%=iss.iid%>' data-projectid='<%=iss.project_id%>' data-issueid='<%=iss.id%>'><%=iss.title%></span></td>
      <td><%=iss.important%></td>
      <td><%=iss.urgent%></td>
      <td align='right'><%=iss.budget%></td>
      <td><%=iss.created_at.substr(0,10)%></td>
      <td><%=iss.updated_at.substr(0,10)%></td>
      <td><%=iss.beginDt%></td>
      <td><%=iss.endDt%></td>
      <td>#<%=iss.iid%></td>
      <td><%=iss.client%></td>
      <td></td>
      <td><button></button></td>
"""

filterItemTmpl = _.template """
  <span class="nav-group-item itm" data-id='${id}'>${name}</span>
"""

filterPrjItemTmpl = _.template """
  <span class="nav-group-item itm" data-id='${id}'>${name}</span>
"""

filterBtnTmpl = _.template """
  <button class="btn btn-default label" data-id='${id}'>${name}</button>
"""



#userNameMap = {
#  'kranian' : '허여송'
#  'callin' : '임창진'
#  'BOK' : '복정규'
#  'acacia' : '이석우'
#  'yujeong' : '최유정'
#  '':''
#}

#projectNameMap =
#  2: '신제품 개발'
#  19: '기존제품'
#  14:'홈페이지'
#  20 : 'tasklist'
#
#realprojectNameMap =
#  2: 'server'
#  19: 'maintenance'
#  14 : 'homepage'
#  20 : 'tasklist'

allIssue = []

filter = {
  project_id : '*'
  milestone : '*'
  label : '*'
  user : '*'
  progress : '*'
  issueTitle : ''
}

allMilestone = []
allLabel = []
allProject = []
allUser = []


dateRegEx = ///
    !DT\[(.*)\]
///

budgetRegEx = ///
    !BG\[(.*)\]
///

$.when(api.getProjectList(), api.getAllIssueList()).done (prjects,  rslt) ->
#  allProject =
  allProjectMapper = {}

  _.each(prjects,(val)->
    prjId = val.id
    allProjectMapper[prjId] = {}
    allProjectMapper[prjId].id = val.id;
    allProjectMapper[prjId].name = val.name;
  )
  console.log('allProjectMapper',allProjectMapper)

  allIssue = _.map(rslt, (iss)->
    iss.subjectLabel = _(iss.labels)
      .filter((l)-> l.indexOf('[') < 0 )
      .filter((l)-> l.indexOf('진행') < 0 )
      .filter((l)-> l.indexOf('긴급') < 0 )
      .filter((l)-> l.indexOf('종료') < 0 )
      .filter((l)-> l != '상' )
      .filter((l)-> l != '중' )
      .filter((l)-> l != '하' )
      .filter((l)-> l.indexOf('확인') < 0 )
      .filter((l)-> l.indexOf('TODO') < 0 )
      .filter((l)-> l.indexOf('report') < 0 )
      .filter((l)-> l.indexOf('_cl') < 0 )
      .value()

    iss.client = _(iss.labels)
    .filter((l)-> l.indexOf('_cl') > 0 )
    .map((l)->l.split('_')[0])
    .value().join(',')

    iss.urgent = _(iss.labels)
    .filter((l)-> l.indexOf('긴급') >= 0 )
    .map(->'O')
    .value().join('')

    iss.important = _(iss.labels)
    .filter((l)-> l.indexOf('중요') >= 0 )
    .map(->'O')
    .value().join('')

    iss.el_state = _(iss.labels)
    .filter((l)-> l.indexOf('작업종료') >= 0  or l.indexOf('진행중') >= 0)
    .map((l)-> switch l
      when '작업종료' then 'done'
      when '진행중' then 'inprogress'
      else ''
    )
    .value().join('')



    iss.milestone ?= {title:''}
    iss.assignee ?= {name:''}
    iss.assignee.realname = iss.assignee.name
    iss.prjName = allProjectMapper[iss.project_id].name
    iss.realprjName = allProjectMapper[iss.project_id].name
    iss.beginDt = ''
    iss.endDt = ''

    r = dateRegEx.exec(iss.description)
    if r != null
      #console.log r
      iss.beginDt = r[1].split('~')[0]
      iss.endDt = r[1].split('~')[1]

    budget = budgetRegEx.exec(iss.description)
    iss.budget = ''
    if budget != null
      iss.budget = budget[1]
    #---------------------------------------------------------------

    iss
  )


  allMilestone = _(allIssue).map('milestone').filter((v)->v!=null).map('title').uniq().value()
  allLabel = _(allIssue).map('labels').flatten().uniq().sort().value()
  allProject = prjects
  allUser = _(allIssue).map('assignee').filter((v)->v!=null).map('name').uniq().value()

  allIssue.sort (a,b) ->
    order = b.project_id - a.project_id
    return order if order != 0

    if a.milestone.title != b.milestone.title
      return  if a.milestone.title < b.milestone.title then 1 else -1
    if a.subjectLabel.join(',') != b.subjectLabel.join(',')
      return  if a.subjectLabel.join(',') < b.subjectLabel.join(',') then 1 else -1

    return if a.assignee.name < b.assignee.name then 1 else -1

  rows = d3.select('.main tbody').selectAll('tr').data(allIssue,(d)->d.id)

  rows.enter()
  .append('tr')
  .html((d)->
    issueTmpl({iss:d})
  )

#  console.log '--------------------------'
  #----------------------------------
#  console.log 'allProject', allProject
  _.each(allProject, (prj)->
    $('nav.project').append(filterPrjItemTmpl(prj))
  )

  #-----------------------------
  _.each(allLabel, (lbl)->
    $('#labelBtnGrp').append(filterBtnTmpl({id:lbl, name:lbl}))
  )

  #-----------------------------
  _.each(allMilestone, (m)->
    $('nav.milestone').append(filterItemTmpl({id:m, name:m}))
  )

  #-----------------------------
  _.each(allUser, (u)->
    $('nav.user').append(filterItemTmpl({id:u, name:u}))
  )

#--------------------------------------- event -----------------------

$('nav').on('mousedown', '.nav-group-item', (evt)->
  $t = $(evt.target)
  $nav = $t.parent()

  category = $nav.data('ctype')

  $nav.find('.nav-group-item').removeClass('active')
  $(evt.target).addClass('active')

  idVal = $t.data('id')
  #console.log idVal, category

  switch category
    when 'progress' then filter.progress = idVal.split(',')
    when 'project'
      filter.project_id = (''+idVal)
      filter.milestone = '*'
      filter.label = '*'
      filterReset('project')
    when 'milestone'
      filter.milestone = idVal
      filter.label = '*'
      filterReset('milestone')

    when 'user' then filter.user = idVal

  doFilter()
)

$('#labelBtnGrp').on('click', 'button.label', (evt)->
  $(evt.target).toggleClass('active')
  selectedLabels = $('#labelBtnGrp button.active').map(-> $(@).data('id')).get()
  if selectedLabels.length == 0
    filter.label = '*'
  else
    filter.label = selectedLabels

  doFilter()
)



$('.tab-item').click (evt)->
  $('.tab-item').removeClass('active')
  $(@).addClass('active')
  tabid = $(@).data('tabid')

  $('.sidebar .pane').hide()
  $('.sidebar .pane.'+tabid).show()

$('#clearBtn').click ->
  $('#labelBtnGrp button').removeClass('active')
  filter.label = '*'
  doFilter()

$('#refreshBtn').click (evt)->
  if evt.shiftKey
    ipcRenderer.sendSync('resetToken')
  else
    window.location.reload()



$('tbody').on('click', 'td span', (evt)->
  projectId = $(@).data('projectid')
  issueId = $(@).data('issueid')
  console.log('projectId =>',projectId,issueId)
  cv = new showdown.Converter()
  api.getIssue(projectId,issueId)
    .then((issue) ->
      document.querySelector('.contents').innerHTML = ''
      $('.contents').append( cv.makeHtml(issue.description))
      document.querySelector('#hello_issue').showModal()
    )
)

$('#cancel').on('click',(evt) ->
  document.querySelector('#hello_issue').close(false)
)

$('#save').on('click',(evt) ->
  document.querySelector('#hello_issue').close(false)
)
#  url = $(@).data('url')
#  evt.preventDefault();
#  shell.openExternal(url);



$('input:text').keyup (evt)->
  #console.log $(evt.target)[0].value
  filter.issueTitle = $(evt.target).val()
  doFilter()



$('div.pane.scroll').scroll ->
  wst = $('div.pane.scroll').scrollTop()

  if wst > 75
    $('table.main thead').addClass('fixHeader')
    ths = $('table.main thead tr th')
    tds = $('table.main tbody tr:eq(0) td')

    for idx in [0..ths.length-1]
      $(ths[idx]).width $(tds[idx]).width()

  else
    $('table.main thead').removeClass('fixHeader')


filterReset = (level)->
  $('#labelBtnGrp button.label').remove()

  switch level
    when 'project'
      filteredIssue = _(allIssue)
        .filter((v)-> if filter.project_id == '*' then true else (''+v.project_id) == filter.project_id)

      allMilestone = filteredIssue
        .map('milestone').filter((v)->v!=null).map('title').uniq().value()

      allLabel = filteredIssue.map('labels').flatten().uniq().sort().value()

      $('nav.milestone span.itm').remove()

      _.each(allMilestone, (m)->
        $('nav.milestone').append(filterItemTmpl({id:m, name:m}))
      )
    when 'milestone'
      filteredIssue = _(allIssue)
        .filter((v)-> if filter.project_id == '*' then true else (''+v.project_id) == filter.project_id)
        .filter((v)-> if filter.milestone == '*' then true else v.milestone?.title == filter.milestone)

      allLabel = filteredIssue.map('labels').flatten().uniq().sort().value()


  _.each(allLabel, (lbl)->
    $('#labelBtnGrp').append(filterBtnTmpl({id:lbl, name:lbl}))
  )


doFilter = ->
  console.log 'filter', filter

  filteredIssue = _(allIssue)
    .filter((v)-> if filter.project_id == '*' then true else (''+v.project_id) == filter.project_id)
    .filter((v)-> if filter.milestone == '*' then true else v.milestone?.title == filter.milestone)
    .filter((v)-> if filter.issueTitle == '' then true else v.title.indexOf(filter.issueTitle) >= 0)
    .filter((v)-> if filter.label == '*' then true else _.intersection(v.labels, filter.label).length > 0 )
    .filter((v)-> if filter.user == '*' then true else v.assignee?.name == filter.user)
    .filter((v)-> if filter.progress[0] == '*' then true else _.intersection(v.labels, filter.progress).length > 0 )
    .value()


  console.log "filter.progress.length", filter.progress.length

  if filter.progress.length == 2
    filteredIssue.sort (a,b) ->
      if b.el_state > a.el_state then 1 else -1



  rows = d3.select('.main tbody').selectAll('tr').data(filteredIssue,(d)->d.id)
  rows.enter().append('tr').html((d)-> issueTmpl({iss:d}))
  rows.exit().remove()





















