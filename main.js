const electron = require('electron')
// Module to control application life.
const app = electron.app
// Module to create native browser window.
const BrowserWindow = electron.BrowserWindow

const ipcMain = electron.ipcMain

const storage = require('electron-json-storage');

// Keep a global reference of the window object, if you don't, the window will
// be closed automatically when the JavaScript object is garbage collected.
let mainWindow

function createWindow () {
  // Create the browser window.
  mainWindow = new BrowserWindow({width: 1800, height: 1080})

  // and load the index.html of the app.
  // mainWindow.loadURL(`file://${__dirname}/index.html`)

  // mainWindow.loadURL(`file://${__dirname}/index.html`)

  getToken(function(token){
    console.log( 'token', token)
    if(!token) {
      mainWindow.loadURL(`file://${__dirname}/login.html`)
    }else {
      mainWindow.loadURL(`file://${__dirname}/index.html`)
    }
  })



  // Open the DevTools.
  // mainWindow.webContents.openDevTools()
  mainWindow.center()

  // Emitted when the window is closed.
  mainWindow.on('closed', function () {
    // Dereference the window object, usually you would store windows
    // in an array if your app supports multi windows, this is the time
    // when you should delete the corresponding element.
    mainWindow = null
  })
}

// This method will be called when Electron has finished
// initialization and is ready to create browser windows.
// Some APIs can only be used after this event occurs.
app.on('ready', createWindow)

// Quit when all windows are closed.
app.on('window-all-closed', function () {
  // On OS X it is common for applications and their menu bar
  // to stay active until the user quits explicitly with Cmd + Q
  if (process.platform !== 'darwin') {
    app.quit()
  }
})

app.on('activate', function () {
  // On OS X it's common to re-create a window in the app when the
  // dock icon is clicked and there are no other windows open.
  if (mainWindow === null) {
    createWindow()
  }
})


ipcMain.on('login', (event, arg) => {
  console.log(arg);

  setToken(arg, function(){
    event.returnValue = 'ok';
  })
});

ipcMain.on('resetToken', (event) => {
  setToken(null, function(){
    event.returnValue = 'ok';
  })
});

ipcMain.on('getToken', (event) => {
  console.log( 'dasd')
  getToken(function(tk){
    console.log( '222')
    event.returnValue = tk;
  })
});




function getToken(cb) {
  storage.get('token', function(error, data) {
    if (error) throw error;

    console.log('data', data);
    cb(data.token)
  });
}


function setToken(token, cb) {
  storage.set('token', {token:token},  function(error, data) {
    if (error) throw error;
    cb()
  });
}








// In this file you can include the rest of your app's specific main process
// code. You can also put them in separate files and require them here.
