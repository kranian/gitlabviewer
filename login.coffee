$           = require 'jquery'
ipcRenderer = require('electron').ipcRenderer


$('#login').click ->

    $.ajax({
        url : "http://kranian.:9937/api/v3/session"
        method : 'POST'
        data : {
            login : $('#gitlab_id').val()
            password: $('#gitlab_passwd').val()
        }
    }).done((rslt ) ->
        ipcRenderer.sendSync('login', rslt.private_token)
        window.location.replace('index.html');
    ).fail((dd) ->
        alert('login fail!')
    )




